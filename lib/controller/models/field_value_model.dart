// To parse this JSON data, do
//
//     final fieldValueModel = fieldValueModelFromJson(jsonString);

import 'dart:convert';

FieldValueModel fieldValueModelFromJson(String str) =>
    FieldValueModel.fromJson(json.decode(str));

String fieldValueModelToJson(FieldValueModel data) =>
    json.encode(data.toJson());

class FieldValueModel {
  int? customFieldId;
  String? value;

  FieldValueModel({
    this.customFieldId,
    this.value,
  });

  FieldValueModel copyWith({
    int? customFieldId,
    String? value,
  }) =>
      FieldValueModel(
        customFieldId: customFieldId ?? this.customFieldId,
        value: value ?? this.value,
      );

  factory FieldValueModel.fromJson(Map<String, dynamic> json) =>
      FieldValueModel(
        customFieldId: json["custom_field_id"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "custom_field_id": customFieldId,
        "value": value,
      };
}
