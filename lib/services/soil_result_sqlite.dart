import 'dart:convert';

import 'package:flutter_app/database.dart';
import 'package:flutter_app/models/soil_check_result.dart';

const soilCheckResultsTable = "SoilCheckResults";

class SoilResultSQLite {
  static Future<int> saveSoilTestResult(SoilCheckResult result) async {
    if (result.timestamp == null) {
      result.timestamp = DateTime.now().millisecondsSinceEpoch;
    }

    var resultJson = jsonEncode(result.toJson());

    final db = await DBProvider.db.database;

    var res = await db.insert(soilCheckResultsTable, {
      "resultsJson": resultJson,
    });

    return res;
  }

  static Future<List<SoilCheckResult>> getSoilTestResults() async {
    final db = await DBProvider.db.database;

    var results = await db.query(soilCheckResultsTable);

    return !results.isNotEmpty
        ? []
        : List.generate(results.length, (i) {
            var jsonData = jsonDecode(results[i]["resultsJson"].toString());
            var res = SoilCheckResult.fromJson(jsonData);
            res.resultId = results[i]["id"];
            return res;
          });
  }

  static Future<SoilCheckResult> getSoilTestResult(String resultId) async {
    final db = await DBProvider.db.database;
    var result = await db.query(soilCheckResultsTable,
        where: "id == ?", whereArgs: [resultId], limit: 1);
    if (result.length != null) {
      var jsonData = jsonDecode(result[1]["resultsJson"]);
      var res = SoilCheckResult.fromJson(jsonData);
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
