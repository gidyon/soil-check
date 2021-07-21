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
  String homeStead;
  String zone;
  String notes;
  double longitude;
  double latitude;
  String testType;
  String tag;
  String label;
  double confidence;
  int resultsReady;
  int resultSynced;
  String resultDescription;
  String resultStatus;
  String imageBase64;
  String imageRef;
  String imageUrl;
  String firebaseId;
  ModelResults modelResults;
  Recommendations recommendations;

  SoilCheckResult(
      {this.resultId,
      this.ownerPhone,
      this.homeStead,
      this.zone,
      this.latitude,
      this.longitude,
      this.testType,
      this.timestamp,
      this.tag,
      this.label,
      this.confidence,
      this.resultsReady,
      this.resultSynced,
      this.resultDescription,
      this.resultStatus,
      this.imageBase64,
      this.imageRef,
      this.imageUrl,
      this.firebaseId,
      this.modelResults,
      this.recommendations});

  SoilCheckResult.fromJson(Map<String, dynamic> json) {
    print('here');
    resultId = json['resultId'];
    print('here 2');

    ownerPhone = json['ownerPhone'];
    homeStead = json['homeStead'];
    zone = json['zone'];
    print('here 3');

    notes = json['notes'];
    latitude = json["latitude"];
    longitude = json['longitude'];
    print('here 4');
    testType = json['testType'];
    print('here 5');
    timestamp = json['timestamp'];
    print('here 6');
    label = json['label'];
    print('here 6');
    tag = json['tag'];
    print('here 7');
    confidence = json['confidence'];
    print('here 8');
    resultsReady = json['resultsReady'];
    print('here 9');
    resultSynced = json['resultSynced'];
    print('here 10');
    resultDescription = json['resultDescription'];
    print('here 11');
    resultStatus = json['resultStatus'];
    print('here 12');
    imageBase64 = json['imageBase64'];
    print('here 13');
    imageUrl = json['imageUrl'];
    print('here 14');
    imageRef = json['imageRef'];
    print('here 15');
    firebaseId = json['firebaseId'];
    if (json['modelResults'] != null) {
      modelResults = json['modelResults'] != null
          ? ModelResults.fromJson(jsonDecode(json['modelResults']))
          : null;
    }
    print('here 15');
    recommendations = json['recommendations'] != null
        ? Recommendations.fromJson(jsonDecode(json['recommendations']))
        : null;
    print('here 16');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resultId'] = this.resultId;
    data['ownerPhone'] = this.ownerPhone;
    data['homeStead'] = this.homeStead;
    data['zone'] = this.zone;
    data['notes'] = this.notes;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['testType'] = this.testType;
    data['timestamp'] = this.timestamp;
    data['label'] = this.label;
    data['tag'] = this.tag;
    data['confidence'] = this.confidence;
    data['resultsReady'] = this.resultsReady;
    data['resultSynced'] = this.resultSynced;
    data['resultDescription'] = this.resultDescription;
    data['resultStatus'] = this.resultStatus;
    data['imageBase64'] = this.imageBase64;
    data['imageRef'] = this.imageRef;
    data['imageUrl'] = this.imageUrl;
    data['firebaseId'] = this.firebaseId;
    if (this.modelResults != null) {
      data['modelResults'] = this.modelResults.toJson();
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
