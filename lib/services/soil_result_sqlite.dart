import 'dart:convert';
import 'dart:developer';

import 'package:flutter_app/database.dart';
import 'package:flutter_app/models/soil_check_result.dart';

const soilCheckResultsTable = "SoilCheckResults";

class SoilResultSQLite {
  static Future<int> saveSoilTestResult(SoilCheckResult result) async {
    if (result.timestamp == null) {
      result.timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    var recommendations = result.recommendations != null
        ? jsonEncode(result.recommendations.toJson())
        : null;
    var modalResults = result.modelResults != null
        ? jsonEncode(result.modelResults.toJson())
        : null;

    final db = await DBProvider.db.database;

    // int resultId;
    // int timestamp;
    // String ownerPhone;
    // String homeStead;
    // String zone;
    // String notes;
    // double longitude;
    // double latitude;
    // String testType;
    // String label;
    // double confidence;
    // bool resultsReady;
    // bool resultSynced;
    // String resultDescription;
    // String resultStatus;
    // String imageBase64;
    // String imageUrl;
    // List<ModelResults> modelResults;
    // recommendations recommendations;

    var res = await db.insert(soilCheckResultsTable, {
      "timestamp": result.timestamp,
      "ownerPhone": result.ownerPhone,
      "homeStead": result.homeStead,
      "zone": result.zone,
      "notes": result.notes,
      "longitude": result.longitude,
      "latitude": result.latitude,
      "testType": result.testType,
      "label": result.label,
      "confidence": result.confidence,
      "resultsReady": result.resultsReady,
      "resultSynced": result.resultSynced,
      "resultDescription": result.resultDescription,
      "resultStatus": result.resultStatus,
      "imageBase64": result.imageBase64,
      "imageUrl": result.imageUrl,
      "modelResults": modalResults,
      "recommendations": recommendations,
    });

    return res;
  }

  static Future<int> updateSoilTestResult(SoilCheckResult result) async {
    if (result.timestamp == null) {
      result.timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    final db = await DBProvider.db.database;

    var res = await db.update(soilCheckResultsTable, {
      "zone": result.zone,
      "notes": result.notes,
      "label": result.label,
      "confidence": result.confidence,
      "resultsReady": result.resultsReady,
      "resultSynced": result.resultSynced,
      "resultStatus": result.resultStatus,
    });

    return res;
  }

  static Future<List<SoilCheckResult>> getSoilTestResults() async {
    final db = await DBProvider.db.database;

    List<Map<String, dynamic>> results =
        await db.query(soilCheckResultsTable, orderBy: "id DESC");

    print('results.length ${results.length}');

    return !results.isNotEmpty
        ? []
        : List.generate(results.length, (i) {
            inspect(results[i]);
            inspect(results[i]["timestamp"]);
            inspect(results[i]["modelResults"]);
            var row = results[i];
            var res = SoilCheckResult.fromJson(row);
            res.resultId = results[i]["id"];
            inspect(res);
            return res;
          });
  }

  static Future<SoilCheckResult> getSoilTestResult(String resultId) async {
    final db = await DBProvider.db.database;
    var result = await db.query(soilCheckResultsTable,
        where: "id == ?", whereArgs: [resultId], limit: 1);
    if (result.length != null) {
      // var jsonData = jsonDecode(result[1]["modelResults"]);
      // var jsonData = jsonDecode(result[1]["recommendations"]);
      var res = SoilCheckResult.fromJson(result[1]);
      res.resultId = result[1]["id"];
      return res;
    }

    return null;
  }

  static Future clearSoilResults() async {
    final db = await DBProvider.db.database;
    await db.rawDelete("Delete from $soilCheckResultsTable");
  }
}
