import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/home.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/save_result_cloud.dart';
import 'package:flutter_app/services/soil_result_sqlite.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/utils/online.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class SoilResultWidget extends StatelessWidget {
  final SoilCheckResult soilResult;
  final bool heightGreaterThanWidth;

  SoilResultWidget({Key key, this.soilResult, this.heightGreaterThanWidth})
      : super(key: key);

  List<String> _getRecommendations() {
    return soilResult.recommendations.sw;
  }

  final RoundedLoadingButtonController _submitController =
      new RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    var date = DateFormat().format(
      DateTime.fromMicrosecondsSinceEpoch(soilResult.timestamp * 1000),
    );

    var styles1 = TextStyle(
      color: AppColors.primaryColor,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // color: Colors.red,
            alignment: Alignment.center,
            height: 300,
            child: Container(
              height: null,
              width: null,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withAlpha(90),
                  width: 1,
                ),
              ),
              child: heightGreaterThanWidth ?? false
                  ? Hero(
                      tag: soilResult.resultId,
                      child: Transform.rotate(
                        angle: 1.5708,
                        alignment: Alignment.center,
                        child: Image.memory(
                          base64.decode(soilResult.imageBase64),
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                        ),
                      ),
                    )
                  : Hero(
                      tag: soilResult.resultId,
                      child: Image.memory(
                        base64.decode(soilResult.imageBase64),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ('On $date'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.shadeGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  child: Text(
                    '${soilResult.resultDescription}',
                    style: styles1,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ('Saved Details'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.shadeGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                soilResult.homeStead != null
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              soilResult.homeStead.isNotEmpty
                                  ? 'Homestead - ${soilResult.homeStead}'
                                  : 'NA',
                            ),
                            Text(
                              soilResult.zone.isNotEmpty
                                  ? 'Zone - ${soilResult.homeStead}'
                                  : 'NA',
                            ),
                            soilResult.notes.isNotEmpty
                                ? Text(
                                    soilResult.notes,
                                  )
                                : SizedBox()
                          ],
                        ),
                      )
                    : Text('Random Test'),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          soilResult.resultsReady == 1 ?? false
              ? Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        ('We Recommend You Do The Following'),
                        style: TextStyle(
                          color: AppColors.shadeGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: _getRecommendations()
                              .map(
                                (e) => Text(
                                  '* $e',
                                  style: TextStyle(
                                    color: AppColors.shadeGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      )
                    ],
                  ),
                )
              : Container(
                  child: Column(
                    children: [
                      soilResult.resultStatus == 'AWAITING_RESULTS'
                          ? Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Image and Test Data Submitted',
                                    style: TextStyle(
                                      color: AppColors.shadeGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.shadeRed,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
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
                                            ("We'll notify you when the results is ready"),
                                            style: TextStyle(
                                              color: AppColors.whiteColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      soilResult.resultStatus == 'RESULTS_NOT_SENT'
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Image and Test Data Not Submitted',
                                    style: TextStyle(
                                      color: AppColors.shadeGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.shadeRed,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10),
                                      ),
                                    ),
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
                                            ("Image and test data has not been sent to the server")
                                                .toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .copyWith(
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RoundedLoadingButton(
                                    child: Text(
                                      'Submit Results',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    controller: _submitController,
                                    onPressed: () async {
                                      try {
                                        bool online = await isDeviceOnline();
                                        if (online) {
                                          // Login firebase
                                          await FirebaseAuth.instance
                                              .signInAnonymously();

                                          if (soilResult.resultsReady == 1) {
                                            soilResult.resultStatus =
                                                "RESULTS_SENT";
                                          } else {
                                            soilResult.resultStatus =
                                                "AWAITING_RESULTS";
                                          }
                                          soilResult.resultSynced = 1;

                                          // Upload to firebase
                                          await SoilResultService
                                              .uploadSoilResult(soilResult);

                                          // Update to sqlite
                                          await SoilResultSQLite
                                              .updateSoilTestResult(soilResult);

                                          // Success status
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                'Results sent to server',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );

                                          Navigator.pop(context);
                                        } else {
                                          soilResult.resultStatus =
                                              "RESULTS_NOT_SENT";
                                          soilResult.resultSynced = 0;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                'Not connected to Internet',
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        soilResult.resultStatus =
                                            "RESULTS_NOT_SENT";
                                        soilResult.resultSynced = 0;
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.red,
                                            duration: Duration(seconds: 4),
                                            content: Text(
                                              e.toString(),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      } finally {
                                        _submitController.reset();
                                      }
                                    },
                                    width: 200,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
