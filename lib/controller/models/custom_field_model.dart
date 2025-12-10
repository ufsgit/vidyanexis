// To parse this JSON data, do
//
//     final customFieldModel = customFieldModelFromJson(jsonString);

import 'dart:convert';

List<CustomFieldModel> customFieldModelFromJson(String str) =>
    List<CustomFieldModel>.from(
        json.decode(str).map((x) => CustomFieldModel.fromJson(x)));

String customFieldModelToJson(List<CustomFieldModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomFieldModel {
  int? customFieldId;
  int? customFieldTypeId;
  String? customFieldName;
  int? deletedStatus;
  List<String>? dropDownValues;
  List<String>? checkBoxValues;

  DateTime? createdAt;

  CustomFieldModel({
    this.customFieldId,
    this.checkBoxValues,
    this.dropDownValues,
    this.customFieldTypeId,
    this.customFieldName,
    this.deletedStatus,
    this.createdAt,
  });

  CustomFieldModel copyWith({
    int? customFieldId,
    int? customFieldTypeId,
    String? customFieldName,
    List<String>? dropDownValues,
    List<String>? checkBoxValues,
    int? deletedStatus,
    DateTime? createdAt,
  }) =>
      CustomFieldModel(
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldTypeId: customFieldTypeId ?? this.customFieldTypeId,
        customFieldName: customFieldName ?? this.customFieldName,
        deletedStatus: deletedStatus ?? this.deletedStatus,
        dropDownValues: dropDownValues ?? this.dropDownValues,
        checkBoxValues: checkBoxValues ?? this.checkBoxValues,
        createdAt: createdAt ?? this.createdAt,
      );

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) =>
      CustomFieldModel(
        customFieldId: json["custom_field_id"],
        customFieldTypeId: json["custom_field_type_id"],
        customFieldName: json["custom_field_name"],
        deletedStatus: json["Deleted_Status"],
        dropDownValues: json["Dropdown_Values"] == null
            ? []
            : List<String>.from(json["Dropdown_Values"]!),
        checkBoxValues: json["Checkbox_Values"] == null
            ? []
            : List<String>.from(json["Checkbox_Values"]!),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "custom_field_id": customFieldId,
        "custom_field_type_id": customFieldTypeId,
        "custom_field_name": customFieldName,
        "Deleted_Status": deletedStatus,
        "Dropdown_Values": dropDownValues == null
            ? []
            : List<dynamic>.from(dropDownValues!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
        "Checkbox_Values": checkBoxValues == null
            ? []
            : List<dynamic>.from(checkBoxValues!.map((x) => x)),
      };
}
