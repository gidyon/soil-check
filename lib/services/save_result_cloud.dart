import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/models/model_recomendations.dart';
import 'package:flutter_app/models/soil_check_result.dart';
import 'package:flutter_app/services/account_sqlite.dart';
import 'package:flutter_app/services/soil_result_sqlite.dart';

class SoilResultService {
  static String soilResultsCollections = "soil-check-results";
  static String labelsCollection = "soil-check-labels";

  static Future<SoilCheckResult> fetchResultFirestore(String resultId) async {
    SoilCheckResult soilCheckResult;

    // Get result from firestore
    Query query = FirebaseFirestore.instance.collection(soilResultsCollections);
    var snapshot = await query.where("resultId", isEqualTo: resultId).get();
    if (snapshot.docs.length > 0) {
      var soilResultData = snapshot.docs[0].data();
      soilCheckResult = SoilCheckResult.fromJson(soilResultData);
    }

    return soilCheckResult;
  }

  static Future<List<SoilCheckResult>> fetchResultsFirestore() async {
    var account = await AccountServiceSQLite.getAccount();

    List<SoilCheckResult> soilCheckResults;

    // Get results from firestore
    Query query = FirebaseFirestore.instance.collection(soilResultsCollections);
    var snapshot =
        await query.where("ownerPhone", isEqualTo: account.phone).get();
    if (snapshot.docs.length > 0) {
      snapshot.docs.forEach((e) {
        var soilResult = SoilCheckResult.fromJson(e.data());
        soilCheckResults.add(soilResult);
      });
    }

    return soilCheckResults;
  }

  static Future<void> uploadSoilResult(SoilCheckResult soilCheckResult) async {
    // Upload image
    var url = await uploadImage(soilCheckResult);

    // Update image
    soilCheckResult.imageUrl = url;

    // Reset image base 64
    soilCheckResult.imageBase64 = '';

    // Upload firestore
    DocumentReference doc =
        FirebaseFirestore.instance.collection(soilResultsCollections).doc();

    await doc.set(soilCheckResult.toJson());
  }

  static Future<String> uploadImage(SoilCheckResult soilCheckResult) async {
    UploadTask uploadTask;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(soilResultsCollections + '/' + '${soilCheckResult.timestamp}');
    uploadTask = ref.putData(base64.decode(soilCheckResult.imageBase64));
    var taskSnapshot = await Future.value(uploadTask);
    var url = taskSnapshot.ref.getDownloadURL();
    return url;
  }

  static Future<void> syncSoilResults() async {
    var results = await SoilResultSQLite.getSoilTestResults();
    for (var i = 0; i < results.length; i++) {
      var result = results[1];
      if (!result.resultSynced) {
        await uploadSoilResult(result);
      }
    }
  }

  static Future<LabelRecommendations> getLabelRecommendationsOnline(
      String label) async {
    LabelRecommendations recomm;

    // Get result from firestore
    Query query = FirebaseFirestore.instance.collection(labelsCollection);
    var snapshot = await query.where("label", isEqualTo: label).get();
    if (snapshot.docs.length > 0) {
      var recommData = snapshot.docs[0].data();
      recomm = LabelRecommendations.fromJson(recommData);
    }

    return recomm;
  }

  static Future<LabelRecommendations> getLabelRecommendationsOffline(
    BuildContext context,
    String label,
  ) async {
    String recomms = await DefaultAssetBundle.of(context)
        .loadString('assets/recommendations/recommendations.json');

    var list = parseJson(recomms);

    var recomm = list?.firstWhere(
      (recom) => recom?.label?.toLowerCase() == label?.toLowerCase(),
      orElse: () => null,
    );

    return recomm;
  }

  static List<LabelRecommendations> parseJson(String response) {
    if (response == null) {
      return [];
    }
    final parsed =
        json.decode(response.toString()).cast<Map<String, dynamic>>();
    return parsed
        .map<LabelRecommendations>(
            (json) => new LabelRecommendations.fromJson(json))
        .toList();
  }
}
