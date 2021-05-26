import 'package:flutter/material.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/views/result/result_raw.dart';

class SoilTestResultPage extends StatelessWidget {
  final SoilCheckResult soilResult;
  final bool heightGreaterThanWidth;

  const SoilTestResultPage(
      {Key key, this.soilResult, this.heightGreaterThanWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: SoilResultWidget(
        soilResult: soilResult,
        heightGreaterThanWidth: heightGreaterThanWidth,
      )),
    );
  }
}
