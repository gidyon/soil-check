// // To parse this JSON data, do
// //
// //     final soilCheckResults = soilCheckResultsFromJson(jsonString);

// import 'dart:convert';
// import 'package:flutter_app/models/soil_check_result.dart';
// import 'package:json_store/json_store.dart';

// SoilCheckResults soilCheckResultsFromJson(String str) =>
//     SoilCheckResults.fromJson(json.decode(str));

// String soilCheckResultsToJson(SoilCheckResults data) =>
//     json.encode(data.toJson());

// class SoilCheckResults {
//   SoilCheckResults({
//     this.results,
//   });

//   List<String> results;

//   factory SoilCheckResults.fromJson(Map<String, dynamic> json) =>
//       SoilCheckResults(
//         results: List<String>.from(json["results"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "results": List<dynamic>.from(results.map((x) => x)),
//       };
// }

// Future<String> saveSoilTestResult(SoilCheckResult result) async {
//   JsonStore jsonStore = JsonStore();

//   var resultKey = '${result.timestamp}';

//   await jsonStore.setItem(resultKey, result.toJson());

//   var res = await jsonStore.getItem("soil_results");

//   if (res == null) {
//     res = {"results": []};
//   }

//   var soilResults = SoilCheckResults.fromJson(res ?? {});

//   soilResults.results?.add(resultKey);

//   jsonStore.setItem("soil_results", soilResults.toJson());

//   return resultKey;
// }

// Future<List<SoilCheckResult>> getSoilTestResults() async {
//   JsonStore jsonStore = JsonStore();

//   var res = await jsonStore.getItem("soil_results");

//   if (res == null) {
//     return [];
//   }

//   var soilResults = SoilCheckResults.fromJson(res);

//   List<SoilCheckResult> results = [];

//   print(soilResults.results);

//   for (var i = 0; i < soilResults.results.length; i++) {
//     var res = await jsonStore.getItem(soilResults.results[i]);
//     var soilResult = SoilCheckResult.fromJson(res);
//     results.insert(0, soilResult);
//   }

//   return results;
// }

// Future<SoilCheckResult> getSoilTestResult(String resultId) async {
//   JsonStore jsonStore = JsonStore();

//   var res = await jsonStore.getItem(resultId);

//   return SoilCheckResult.fromJson(res);
// }

// Future clearSoilResults() async {
//   JsonStore jsonStore = JsonStore();

//   await jsonStore.clearDataBase();
// }
