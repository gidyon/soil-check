import 'dart:convert';
import 'package:flutter_app/services/soil_result_sqlite.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:flutter_app/views/result/result.dart';
import 'package:flutter_app/views/newtest/test.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';

class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final Future<List<SoilCheckResult>> _soilResults =
      SoilResultSQLite.getSoilTestResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: FutureBuilder<List<SoilCheckResult>>(
          future: _soilResults,
          builder: (context, snapshot) {
            List<SoilCheckResult> soilResults = snapshot.data;
            if (snapshot.hasData) {
              return Container(
                  margin: EdgeInsets.all(20),
                  child: soilResults.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: soilResults.length,
                          itemBuilder: (context, index) {
                            SoilCheckResult soilResult = soilResults[index];
                            return SoilTestPageTile(
                              soilResult: soilResult,
                            );
                          },
                        )
                      : Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                border:
                                    Border.all(color: AppColors.primaryColor),
                              ),
                              child: Text(
                                'No Soil Check Tests',
                                style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: FloatingActionButton.extended(
                                label: Text('Get Started'),
                                heroTag: UniqueKey(),
                                onPressed: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SoilTestPage()));
                                },
                                icon: Icon(Icons.camera),
                              ),
                            ),
                          ],
                        ));
            } else if (snapshot.hasError) {
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('Error: ${snapshot.error}'),
                    )
                  ],
                ),
              );
            } else {
              return Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

String wrapExtraText(String text, count) {
  if (text == null) {
    return '';
  }
  if (text.length > count) {
    return '${text.substring(0, count - 4)} ...';
  }
  return text;
}

class SoilTestPageTile extends StatelessWidget {
  final SoilCheckResult soilResult;

  const SoilTestPageTile({Key key, this.soilResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var date = DateFormat().format(
        DateTime.fromMicrosecondsSinceEpoch(soilResult.timestamp * 1000));
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        // border: Border.all(color: AppColors.primaryColor, width: 0.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 100.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              2.0, // Move to right 10  horizontally
              2.0, // Move to bottom 10 Vertically
            ),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Hero(
            tag: soilResult.resultId,
            child: CircleAvatar(
              backgroundImage:
                  MemoryImage(base64.decode(soilResult.imageBase64)),
              radius: 30,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    'On $date',
                    style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  child: Text(
                    wrapExtraText('${soilResult.resultDescription}', 100),
                    style: TextStyle(color: AppColors.greyish, fontSize: 13),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      label: Text(
                        'View Results',
                        style: TextStyle(
                          color: soilResult.resultsReady
                              ? AppColors.shadeGreen
                              : AppColors.primaryColor,
                        ),
                      ),
                      onPressed: () async {
                        var decodedImage = await decodeImageFromList(
                          base64.decode(soilResult.imageBase64),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SoilTestResultPage(
                              soilResult: soilResult,
                              heightGreaterThanWidth:
                                  decodedImage.height > decodedImage.width,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.east,
                        color: soilResult.resultsReady
                            ? AppColors.shadeGreen
                            : AppColors.primaryColor,
                      ),
                    ),
                    Icon(
                      soilResult.resultsReady ?? false
                          ? Icons.check_circle
                          : Icons.report,
                      size: 24,
                      color: soilResult.resultsReady
                          ? AppColors.shadeGreen
                          : AppColors.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
