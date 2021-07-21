import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/account.dart';
import 'package:flutter_app/services/save_result_cloud.dart';
import 'package:flutter_app/services/soil_result_sqlite.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/utils/online.dart';
import 'package:flutter_app/views/result/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pPath;
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakeShot extends StatefulWidget {
  final Function updateFn;
  final Function(SoilCheckResult) updateSoilResult;

  const TakeShot({Key key, this.updateFn, this.updateSoilResult})
      : super(key: key);

  @override
  _TakeShotState createState() => _TakeShotState();
}

class _TakeShotState extends State<TakeShot> {
  File _imageFile;
  File _croppedFile;
  bool _inProcess = false;
  String _error;
  SoilCheckResult _soilCheckResult;

  @override
  void initState() {
    super.initState();
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
      _croppedFile = null;
    });
  }

  _cropImage(String filePath) async {
    // Crop image
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: filePath,
        compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));

    if (croppedFile == null) {
      _clearImage();
      return;
    }

    print('length of file after crop: ${croppedFile.lengthSync()}');

    Directory tempDir = await pPath.getTemporaryDirectory();
    String tempPath = tempDir.path;

    final finalFileName =
        path.join(tempPath, '_final_${path.basename(croppedFile.path)}');

    // Compress image after crop
    final finalImage = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      finalFileName,
      quality: 88,
    );

    print(
        'length of file is after compress and crop: ${finalImage.lengthSync()}');
    print('path compressed: ${finalImage.path}');

    // await _imageFile.delete();

    setState(() {
      _croppedFile = finalImage;
    });
  }

  _processImage(ImageSource source) async {
    try {
      setState(() {
        _inProcess = true;
      });

      final pickedFile = await ImagePicker().getImage(source: source);

      Directory tempDir = await pPath.getTemporaryDirectory();
      String tempPath = tempDir.path;

      final fileName =
          path.join(tempPath, '_${path.basename(pickedFile.path)}');

      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        fileName,
        quality: 88,
      );

      print('length of file is after compress: ${compressedFile.lengthSync()}');
      print('path compressed: ${compressedFile.path}');

      setState(() {
        _imageFile = compressedFile;
      });

      await _cropImage(compressedFile.path);
    } catch (e) {
      print('Error happened while processing image: $e');
      _showToastError('The image format is invalid');
    } finally {
      setState(() {
        _inProcess = false;
      });
    }
  }

  _showToastError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<String> getHomeStead() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var homeStead = sp.getString("homestead");
      return homeStead;
    } catch (e) {
      return '';
    }
  }

  Future<String> getZone() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var homeStead = sp.getString("zone");
      return homeStead;
    } catch (e) {
      return '';
    }
  }

  Future<String> getNotes() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var notes = sp.getString("notes");
      return notes;
    } catch (e) {
      return '';
    }
  }

  Future<double> getLongitude() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var long = sp.getDouble("longitude");
      return long;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getLatitude() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var lat = sp.getDouble("latitude");
      return lat;
    } catch (e) {
      return 0;
    }
  }

  Future<String> getTag() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var lat = sp.getString("tag");
      return lat;
    } catch (e) {
      return "";
    }
  }

  Future<String> getTestType() async {
    try {
      var sp = await SharedPreferences.getInstance();
      var type = sp.getString("test_type");
      return type;
    } catch (e) {
      return '';
    }
  }

  Future<void> _predictAndSave() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text(
          'Uploading Data',
          textAlign: TextAlign.center,
        ),
      ),
    );

    try {
      // Image as bytes
      var imageBytes = base64.encode(_croppedFile.readAsBytesSync());

      print('checking if online');
      bool online = await isDeviceOnline();
      print('done checking if online, state is $online');

      if (online) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      print('preparing result json');

      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var homeStead = await getHomeStead();
      var zone = await getZone();
      var notes = await getNotes();
      var tag = await getTag();
      var long = await getLongitude();
      var lat = await getLatitude();
      var testType = await getTestType();
      var account = await AccountServiceV2.getAccount();

      // Prepare results
      SoilCheckResult result = SoilCheckResult.fromJson({
        "timestamp": timestamp,
        "ownerPhone": account.phone,
        "homeStead": homeStead,
        "zone": zone,
        "notes": notes,
        "longitude": long,
        "latitude": lat,
        "testType": testType,
        "tag": tag,
        "label": "",
        "confidence": 0.0,
        "resultsReady": 0,
        "resultSynced": 0,
        "imageBase64": imageBytes,
        "resultStatus": "RESULTS_NOT_SENT",
      });

      var unableToSend = "Unable to send results to the server";
      var awaitingReview =
          "Results sent to the server. You'll be notified once its ready";

      result.resultDescription = unableToSend;
      result.resultStatus = "RESULTS_NOT_SENT";
      result.resultsReady = 0;
      result.resultSynced = 0;

      // Save result to firestore if onlne
      try {
        if (online) {
          print('preparing to save to firebase online');
          result.resultStatus = "RESULTS_SENT";
          result.resultDescription = awaitingReview;
          result.resultSynced = 1;
          await SoilResultService.uploadSoilResult(result);
        }
      } catch (e) {
        result.resultStatus = 'RESULTS_NOT_SENT';
        result.resultDescription = unableToSend;
        result.resultsReady = 0;
        result.resultSynced = 0;
        print('failed to save results firebase online: ${e.toString()}');
      }

      // Update image since it was reset by the upload above
      result.imageBase64 = imageBytes;

      // Update for test
      if (result.resultStatus == 'RESULTS_SENT') {
        result.resultStatus = "AWAITING_RESULTS";
        result.resultDescription = awaitingReview;
      }

      print('saving result locally');

      // Save result locally
      result.resultId = await SoilResultSQLite.saveSoilTestResult(result);

      print('saved result locally');

      setState(() {
        _soilCheckResult = result;
      });

      if (widget.updateSoilResult != null) {
        widget.updateSoilResult(result);
      }

      if (widget.updateFn != null) {
        widget.updateFn();
      } else {
        var decodedImage = await decodeImageFromList(
          base64.decode(imageBytes),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SoilTestResultPage(
              soilResult: _soilCheckResult,
              heightGreaterThanWidth: decodedImage.height > decodedImage.width,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text(
            e.toString(),
            textAlign: TextAlign.center,
          ),
        ),
      );

      print(e.toString());
      setState(() {
        _error = e.toString();
      });
    }
  }

  final RoundedLoadingButtonController _analyseController =
      new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: !_inProcess
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _imageFile == null
                    ? Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      'After taking the shot, next make sure to crop the image to only capture the results section',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .caption
                                                .color,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Image.asset(
                                    'assets/images/cropping.jpg',
                                    // height: 200,
                                    width: MediaQuery.of(context).size.width,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                // Guide
                Container(
                  child: _imageFile == null
                      ? Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  child: FloatingActionButton.extended(
                                    heroTag: 'camera',
                                    label: Text('TAKE CAMERA SHOT'),
                                    onPressed: () async {
                                      await _processImage(ImageSource.camera);
                                    },
                                    icon: Icon(Icons.camera),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: FloatingActionButton.extended(
                                    heroTag: 'gallery',
                                    label: Text('UPLOAD FROM GALLERY'),
                                    onPressed: () async {
                                      await _processImage(ImageSource.gallery);
                                    },
                                    icon: Icon(Icons.photo_library),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Image.file(
                          _croppedFile,
                          height: 300,
                        ),
                ),
                SizedBox(
                  height: 5,
                ),
                _imageFile != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton.icon(
                              onPressed: _clearImage,
                              icon: Icon(
                                Icons.clear,
                                size: 20,
                              ),
                              label: Text('Clear Image')),
                          OutlinedButton.icon(
                              onPressed: () {
                                _cropImage(_imageFile.path);
                              },
                              icon: Icon(
                                Icons.edit,
                                size: 20,
                              ),
                              label: Text('Edit Original')),
                        ],
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                _croppedFile != null
                    ? Container(
                        child: Column(
                          children: [
                            RoundedLoadingButton(
                              child: Text('UPLOAD IMAGE',
                                  style: TextStyle(color: Colors.white)),
                              controller: _analyseController,
                              onPressed: () async {
                                setState(() {
                                  _error = null;
                                });
                                await _predictAndSave();
                                _analyseController.reset();
                              },
                              width: 200,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                _error != null
                    ? Text(
                        _error,
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(),
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height * .80,
              child: Center(child: CircularProgressIndicator())),
    );
  }
}
