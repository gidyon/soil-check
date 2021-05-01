import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/utils/colors.dart';
import 'package:intl/intl.dart';

class SoilTestResultPage extends StatelessWidget {
  final SoilCheckResult soilResult;
  final bool heightGreaterThanWidth;

  const SoilTestResultPage(
      {Key key, this.soilResult, this.heightGreaterThanWidth})
      : super(key: key);

  List<String> _getRecommendations() {
    return soilResult.recommendations.sw;
  }

  @override
  Widget build(BuildContext context) {
    var date = DateFormat().format(
        DateTime.fromMicrosecondsSinceEpoch(soilResult.timestamp * 1000));

    return Scaffold(
      appBar: AppBar(
        title: Text('Soil Check Result'),
        leading: IconButton(
          icon: Icon(
            Icons.navigate_before,
            size: 38,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
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
                    ('On $date').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryColor,
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
                      style: TextStyle(
                        color: AppColors.shadeGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            soilResult.resultsReady ?? false
                ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          ('We recommend you do the following').toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primaryColor,
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
                              )
                            : SizedBox(),
                        soilResult.resultStatus == 'RESULTS_NOT_SENT'
                            ? Container(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
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
                                              ("Results has not been sent to the server"),
                                              style: TextStyle(
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
                                    FloatingActionButton.extended(
                                      label:
                                          Text('Send Results For Processing'),
                                      heroTag: UniqueKey(),
                                      onPressed: () async {
                                        //;
                                      },
                                      icon: Icon(Icons.send),
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
      )),
    );
  }
}
