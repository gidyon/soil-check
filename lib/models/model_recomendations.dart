// To parse this JSON data, do
//
//     final labelRecommendations = labelRecommendationsFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_app/models/soil_check_result.dart';

List<LabelRecommendations> labelRecommendationsFromJson(String str) =>
    List<LabelRecommendations>.from(
        json.decode(str).map((x) => LabelRecommendations.fromJson(x)));

String labelRecommendationsToJson(List<LabelRecommendations> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LabelRecommendations {
  LabelRecommendations({
    this.label,
    this.description,
    this.recommendations,
  });

  String label;
  String description;
  Recommendations recommendations;

  factory LabelRecommendations.fromJson(Map<String, dynamic> json) =>
      LabelRecommendations(
        label: json["label"],
        description: json["description"],
        recommendations: Recommendations.fromJson(json["recommendations"]),
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "description": description,
        "recommendations": recommendations.toJson(),
      };
}
