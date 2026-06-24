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
  int? isCommercial;
  int? isChecked; // Added this property
  List<String>? dropDownValues;
  List<String>? checkBoxValues;
  int? quotationTypeId;

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
    this.isCommercial,
    this.isChecked,
    this.createdAt,
    this.quotationTypeId,
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
    int? isCommercial,
    int? isChecked,
    DateTime? createdAt,
    int? quotationTypeId,
  }) =>
      CustomFieldModel(
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldTypeId: customFieldTypeId ?? this.customFieldTypeId,
        customFieldName: customFieldName ?? this.customFieldName,
        deletedStatus: deletedStatus ?? this.deletedStatus,
        isQuotationCustom: isQuotationCustom ?? this.isQuotationCustom,
        isViewInQuotation: isViewInQuotation ?? this.isViewInQuotation,
        isCommercial: isCommercial ?? this.isCommercial,
        isChecked: isChecked ?? this.isChecked,
        dropDownValues: dropDownValues ?? this.dropDownValues,
        checkBoxValues: checkBoxValues ?? this.checkBoxValues,
        createdAt: createdAt ?? this.createdAt,
        quotationTypeId: quotationTypeId ?? this.quotationTypeId,
      );

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) =>
      CustomFieldModel(
        customFieldId: json["custom_field_id"] ?? json["Custom_Field_Id"],
        customFieldTypeId:
            json["custom_field_type_id"] ?? json["Custom_Field_Type_Id"],
        customFieldName: json["custom_field_name"] ?? json["Custom_Field_Name"],
        deletedStatus: json["Deleted_Status"] ?? json["deleted_status"],
        isQuotationCustom:
            json["quotation_custom"] ?? json["isQuotationCustom"],
        isViewInQuotation:
            json["view_in_quotation"] ?? json["isViewInQuotation"],
        isCommercial: json["is_commercial"] ?? json["isCommercial"],
        isChecked: json["is_checked"] != null
            ? int.tryParse(json["is_checked"].toString())
            : null,
        dropDownValues:
            (json["Dropdown_Values"] ?? json["dropdown_values"]) == null
                ? []
                : List<String>.from(
                    (json["Dropdown_Values"] ?? json["dropdown_values"])!),
        checkBoxValues:
            (json["Checkbox_Values"] ?? json["checkbox_values"]) == null
                ? []
                : List<String>.from(
                    (json["Checkbox_Values"] ?? json["checkbox_values"])!),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        quotationTypeId: json["quotation_type_id"] ?? json["Quotation_Type_Id"],
      );

  Map<String, dynamic> toJson() => {
        "custom_field_id": customFieldId,
        "custom_field_type_id": customFieldTypeId,
        "custom_field_name": customFieldName,
        "Deleted_Status": deletedStatus,
        "quotation_custom": isQuotationCustom,
        "view_in_quotation": isViewInQuotation,
        "is_commercial": isCommercial,
        "is_checked": isChecked,
        "Dropdown_Values": dropDownValues == null
            ? []
            : List<dynamic>.from(dropDownValues!.map((x) => x)),
        "created_at": createdAt?.toIso8601String(),
        "Checkbox_Values": checkBoxValues == null
            ? []
            : List<dynamic>.from(checkBoxValues!.map((x) => x)),
        "quotation_type_id": quotationTypeId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFieldModel &&
          runtimeType == other.runtimeType &&
          customFieldId == other.customFieldId;

  @override
  int get hashCode => customFieldId.hashCode;
}
