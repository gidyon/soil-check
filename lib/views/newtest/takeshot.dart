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
import 'package:tflite/tflite.dart';

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
    } finally {
      setState(() {
        _inProcess = false;
      });
    }
  }

  void _loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/model/model_unquant.tflite",
        labels: "assets/model/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  Future<List<ModelResults>> _applyModel() async {
    var recognitions = await Tflite.runModelOnImage(
        path: _croppedFile.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 1.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    return recognitions
        .map(
            (e) => ModelResults(label: e["label"], confidence: e["confidence"]))
        .toList();
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
      // Get model results
      var modelResults = await _applyModel();

      ModelResults firstResult;
      if (modelResults.length > 0) {
        firstResult = modelResults[0];
      }

      // Image as bytes
      var imageBytes = base64.encode(_croppedFile.readAsBytesSync());

      print('checking if online');
      bool online = await isDeviceOnline();
      print('done checking if online, state is $online');

      if (online) {
        await FirebaseAuth.instance.signInAnonymously();
      }

      print('preparing result json');

      bool resultAboveConfidence = firstResult.confidence >= 0.8;

      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var homeStead = await getHomeStead();
      var zone = await getZone();
      var notes = await getNotes();
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
        "label": firstResult.label,
        "confidence": firstResult.confidence,
        "resultsReady": resultAboveConfidence ? 1 : 0,
        "resultSynced": 0,
        "imageBase64": imageBytes,
        "resultStatus": "RESULTS_NOT_SENT",
      });

      result.modelResults = firstResult;

      print('model confidence: ${firstResult.confidence}');

      // Updates results offline
      var updateResultOffline = () async {
        print('preparing getting result offline');
        var recomms = await SoilResultService.getLabelRecommendationsOffline(
          context,
          firstResult.label,
        );
        result.recommendations = recomms?.recommendations;
        result.resultDescription = recomms?.description;

        inspect(result);
      };

      // If confidence above 80% we good
      if (resultAboveConfidence) {
        // Get online recommdations
        if (online) {
          print('preparing getting result online');
          var recomms = await SoilResultService.getLabelRecommendationsOnline(
            firstResult.label,
          );
          if (recomms != null) {
            result.recommendations = recomms.recommendations;
            result.resultDescription = recomms.description;
          } else {
            print('no online results ooops');
            await updateResultOffline();
          }
        } else {
          print('preparing getting result offline');
          await updateResultOffline();
        }
      } else {
        result.resultDescription =
            "Unable to infer correct result from image. Please send the results for further review";
        result.resultsReady = 0;
      }

      // Save result to firestore if onlne
      try {
        if (online) {
          print('preparing to save to firebase online');
          if (!resultAboveConfidence) {
            result.resultStatus = "AWAITING_RESULTS";
            result.resultDescription =
                "Unable to infer correct result from image. We will notify you once we review the image";
          } else {
            result.resultStatus = "RESULTS_SENT";
          }
          result.resultSynced = 1;
          await SoilResultService.uploadSoilResult(result);
        }
      } catch (e) {
        result.resultSynced = 0;
        result.resultStatus = 'RESULTS_NOT_SENT';
        print('failed to save results online: ${e.toString()}');
      }

      // Update image since it was reset by the upload above
      result.imageBase64 = imageBytes;

      inspect(result);

      // Update for test
      if (result.resultStatus != 'RESULTS_NOT_SENT') {
        result.resultStatus = "AWAITING_RESULTS";
      }
      result.resultDescription =
          "Unable to infer correct result from image. We will notify you once we review the image";
      result.resultsReady = 0;

      print('saving result locally');

      inspect(result);

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

  @override
  void initState() {
    super.initState();
    _loadModel();
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
                            // Container(
                            //   color: Colors.green,
                            //   padding: EdgeInsets.all(8),
                            //   child: Row(
                            //     children: [
                            //       Icon(
                            //         Icons.warning,
                            //         color: AppColors.whiteColor,
                            //       ),
                            //       SizedBox(
                            //         width: 10,
                            //       ),
                            //       Flexible(
                            //         child: Text(
                            //           'IMPORTANT',
                            //           style: TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             color: AppColors.whiteColor,
                            //           ),
                            //         ),
                            //       )
                            //     ],
                            //   ),
                            // ),
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
