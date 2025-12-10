// To parse this JSON data, do
//
//     final customFieldTypeModel = customFieldTypeModelFromJson(jsonString);

import 'dart:convert';

List<CustomFieldTypeModel> customFieldTypeModelFromJson(String str) =>
    List<CustomFieldTypeModel>.from(
        json.decode(str).map((x) => CustomFieldTypeModel.fromJson(x)));

String customFieldTypeModelToJson(List<CustomFieldTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomFieldTypeModel {
  int? customFieldTypeId;
  int? customFieldId;
  String? customFieldTypeName;
  List<String>? dropDownValues;

  DateTime? createdAt;

  CustomFieldTypeModel({
    this.customFieldTypeId,
    this.customFieldId,
    this.customFieldTypeName,
    this.dropDownValues,
    this.createdAt,
  });

  CustomFieldTypeModel copyWith({
    int? customFieldTypeId,
    int? customFieldId,
    String? customFieldTypeName,
    List<String>? dropDownValues,
    DateTime? createdAt,
  }) =>
      CustomFieldTypeModel(
        customFieldTypeId: customFieldTypeId ?? this.customFieldTypeId,
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldTypeName: customFieldTypeName ?? this.customFieldTypeName,
        dropDownValues: dropDownValues ?? this.dropDownValues,
        createdAt: createdAt ?? this.createdAt,
      );

  factory CustomFieldTypeModel.fromJson(Map<String, dynamic> json) =>
      CustomFieldTypeModel(
        customFieldId: json["Custom_Field_Id"],
        customFieldTypeId: json["custom_field_type_id"],
        customFieldTypeName: json["custom_field_type_name"],
        dropDownValues: json["Dropdown_Values"] == null
            ? []
            : List<String>.from(json["Dropdown_Values"]!),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "custom_field_type_id": customFieldTypeId,
        'Custom_Field_Id': customFieldId,
        "custom_field_type_name": customFieldTypeName,
        "dropDownValues": dropDownValues,
        "created_at": createdAt?.toIso8601String(),
      };
}
