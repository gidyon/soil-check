// To parse this JSON data, do
//
//     final soilCheckResult = soilCheckResultFromJson(jsonString);

import 'dart:convert';

SoilCheckResult soilCheckResultFromJson(String str) =>
    SoilCheckResult.fromJson(json.decode(str));

String soilCheckResultToJson(SoilCheckResult data) =>
    json.encode(data.toJson());

class SoilCheckResult {
  int resultId;
  int timestamp;
  String ownerPhone;
  String label;
  double confidence;
  bool resultsReady;
  bool resultSynced;
  String resultDescription;
  String resultStatus;
  String imageBase64;
  String imageUrl;
  List<ModelResults> modelResults;
  Recommendations recommendations;

  SoilCheckResult(
      {this.resultId,
      this.ownerPhone,
      this.timestamp,
      this.label,
      this.confidence,
      this.resultsReady,
      this.resultSynced,
      this.resultDescription,
      this.resultStatus,
      this.imageBase64,
      this.imageUrl,
      this.modelResults,
      this.recommendations});

  SoilCheckResult.fromJson(Map<String, dynamic> json) {
    resultId = json['resultId'];
    ownerPhone = json['ownerPhone'];
    timestamp = json['timestamp'];
    label = json['label'];
    confidence = json['confidence'];
    resultsReady = json['resultsReady'];
    resultSynced = json['resultSynced'];
    resultDescription = json['resultDescription'];
    resultStatus = json['resultStatus'];
    imageBase64 = json['imageBase64'];
    imageUrl = json['imageUrl'];
    if (json['modelResults'] != null) {
      modelResults = [];
      json['modelResults']?.forEach((v) {
        modelResults.add(new ModelResults.fromJson(v));
      });
    }
    recommendations = json['recommendations'] != null
        ? new Recommendations.fromJson(json['recommendations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultId'] = this.resultId;
    data['ownerPhone'] = this.ownerPhone;
    data['timestamp'] = this.timestamp;
    data['label'] = this.label;
    data['confidence'] = this.confidence;
    data['resultsReady'] = this.resultsReady;
    data['resultSynced'] = this.resultSynced;
    data['resultDescription'] = this.resultDescription;
    data['resultStatus'] = this.resultStatus;
    data['imageBase64'] = this.imageBase64;
    data['imageUrl'] = this.imageUrl;
    if (this.modelResults != null) {
      data['modelResults'] = this.modelResults.map((v) => v.toJson()).toList();
    }
    if (this.recommendations != null) {
      data['recommendations'] = this.recommendations.toJson();
    }
    return data;
  }
}

class ModelResults {
  String label;
  double confidence;

  ModelResults({this.label, this.confidence});

  ModelResults.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    confidence = json['confidence'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['confidence'] = this.confidence;
    return data;
  }
}

class Recommendations {
  List<String> sw;
  List<String> en;

  Recommendations({this.sw, this.en});

  Recommendations.fromJson(Map<String, dynamic> json) {
    sw = json['sw'].cast<String>();
    en = json['en'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sw'] = this.sw;
    data['en'] = this.en;
    return data;
  }
}
