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
  int? isQuotationCustom;
  int? isViewInQuotation;
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
    this.isQuotationCustom,
    this.isViewInQuotation,
    this.createdAt,
  });

  CustomFieldModel copyWith({
    int? customFieldId,
    int? customFieldTypeId,
    String? customFieldName,
    List<String>? dropDownValues,
    List<String>? checkBoxValues,
    int? deletedStatus,
    int? isQuotationCustom,
    int? isViewInQuotation,
    DateTime? createdAt,
  }) =>
      CustomFieldModel(
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldTypeId: customFieldTypeId ?? this.customFieldTypeId,
        customFieldName: customFieldName ?? this.customFieldName,
        deletedStatus: deletedStatus ?? this.deletedStatus,
        isQuotationCustom: isQuotationCustom ?? this.isQuotationCustom,
        isViewInQuotation: isViewInQuotation ?? this.isViewInQuotation,
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
        isQuotationCustom: json["quotation_custom"],
        isViewInQuotation: json["view_in_quotation"],
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
        "quotation_custom": isQuotationCustom,
        "view_in_quotation": isViewInQuotation,
        "Dropdown_Values": dropDownValues == null
            ? []
            : List<dynamic>.from(dropDownValues!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
        "Checkbox_Values": checkBoxValues == null
            ? []
            : List<dynamic>.from(checkBoxValues!.map((x) => x)),
      };
}
