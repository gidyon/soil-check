import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/account.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/account_sqlite.dart';
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
import 'package:tflite/tflite.dart';

class TakeShot extends StatefulWidget {
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

  Future<void> _predictAndSave() async {
    try {
      // Get Account information
      Account account = await AccountServiceSQLite.getAccount();

      // Get model results
      var modelResults = await _applyModel();

      ModelResults firstResult;
      if (modelResults.length > 0) {
        firstResult = modelResults[0];
      }

      // Image as bytes
      var imageBytes = base64.encode(_croppedFile.readAsBytesSync());

      bool online = await isDeviceOnline();

      print('preparing result json');

      bool resultAboveConfidence = firstResult.confidence >= 0.8;

      var timestamp = DateTime.now().millisecondsSinceEpoch;

      // Prepare results
      SoilCheckResult result = SoilCheckResult.fromJson({
        "timestamp": timestamp,
        "label": firstResult.label,
        "confidence": firstResult.confidence,
        "resultsReady": resultAboveConfidence,
        "resultsSynced": false,
        "ownerPhone": account.phone,
        "imageBase64": imageBytes,
        "resultStatus": "RESULTS_NOT_SENT",
      });

      print('saving result model confidence: ${firstResult.confidence}');

      // If confidence above 80% we good
      if (resultAboveConfidence) {
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
            print('no online results');
            await updateResultOffline();
          }
        } else {
          await updateResultOffline();
        }
      } else {
        result.resultDescription =
            "Unable to infer correct result from image. Please send the results for further review";
      }

      // Save result to firestore if onlne
      if (online) {
        print('preparing result firebase if online');
        if (!resultAboveConfidence) {
          result.resultStatus = "AWAITING_RESULTS";
          result.resultDescription =
              "Unable to infer correct result from image. We will notify you once we review the image";
        } else {
          result.resultStatus = "RESULTS_SENT";
        }
        result.resultSynced = true;
        await SoilResultService.uploadSoilResult(result);
      }

      print('preparing result locally');

      // Update image since it was reset by the upload above
      result.imageBase64 = imageBytes;

      // Save result locally
      result.resultId = await SoilResultSQLite.saveSoilTestResult(result);

      print('save result locally');

      setState(() {
        _soilCheckResult = result;
      });

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
    } catch (e) {
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
              children: [
                _imageFile == null
                    ? Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: AppColors.shadeRed),
                                left: BorderSide(
                                    width: 1.0, color: AppColors.shadeRed),
                                right: BorderSide(
                                    width: 1.0, color: AppColors.shadeRed)),
                            shape: BoxShape.rectangle),
                        child: Column(
                          children: [
                            Container(
                              color: AppColors.shadeRed,
                              padding: EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: AppColors.whiteColor,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      'IMPORTANT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    child: Text(
                                      'After taking the shot, next make sure to crop the image to only capture the results section',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Image.asset(
                                    'assets/images/cropping.jpg',
                                    height: 200,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                // Guide
                Container(
                  child: _imageFile == null
                      ? Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  child: FloatingActionButton.extended(
                                    label: Text('TAKE CAMERA SHOT'),
                                    heroTag: UniqueKey(),
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
                                    heroTag: UniqueKey(),
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
                  height: 20,
                ),
                _croppedFile != null
                    ? Container(
                        child: Column(
                          children: [
                            RoundedLoadingButton(
                              child: Text('ANALYSE PAPER',
                                  style: TextStyle(color: Colors.white)),
                              controller: _analyseController,
                              onPressed: () async {
                                await _predictAndSave();
                                _analyseController.reset();
                              },
                              width: 200,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 20,
                      ),
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height * .80,
              child: Center(child: CircularProgressIndicator())),
    );
  }
}
