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
  int? categoryId;
  int? customFieldTypeId;
  String? customFieldName;
  String? categoryName;
  int? deletedStatus;
  int? isQuotationCustom;
  int? isViewInQuotation;
  int? isCommercial;
  int? isChecked; // Added this property
  int? isMandatory;
  List<String>? dropDownValues;
  List<String>? checkBoxValues;
  int? quotationTypeId;

  DateTime? createdAt;

  CustomFieldModel({
    this.customFieldId,
    this.categoryId,
    this.checkBoxValues,
    this.dropDownValues,
    this.customFieldTypeId,
    this.customFieldName,
    this.categoryName,
    this.deletedStatus,
    this.isQuotationCustom,
    this.isViewInQuotation,
    this.isCommercial,
    this.isChecked,
    this.isMandatory,
    this.createdAt,
    this.quotationTypeId,
  });

  CustomFieldModel copyWith({
    int? customFieldId,
    int? categoryId,
    int? customFieldTypeId,
    String? customFieldName,
    String? categoryName,
    List<String>? dropDownValues,
    List<String>? checkBoxValues,
    int? deletedStatus,
    int? isQuotationCustom,
    int? isViewInQuotation,
    int? isCommercial,
    int? isChecked,
    int? isMandatory,
    DateTime? createdAt,
    int? quotationTypeId,
  }) =>
      CustomFieldModel(
        customFieldId: customFieldId ?? this.customFieldId,
        categoryId: categoryId ?? this.categoryId,
        customFieldTypeId: customFieldTypeId ?? this.customFieldTypeId,
        customFieldName: customFieldName ?? this.customFieldName,
        categoryName: categoryName ?? this.categoryName,
        deletedStatus: deletedStatus ?? this.deletedStatus,
        isQuotationCustom: isQuotationCustom ?? this.isQuotationCustom,
        isViewInQuotation: isViewInQuotation ?? this.isViewInQuotation,
        isCommercial: isCommercial ?? this.isCommercial,
        isChecked: isChecked ?? this.isChecked,
        isMandatory: isMandatory ?? this.isMandatory,
        dropDownValues: dropDownValues ?? this.dropDownValues,
        checkBoxValues: checkBoxValues ?? this.checkBoxValues,
        createdAt: createdAt ?? this.createdAt,
        quotationTypeId: quotationTypeId ?? this.quotationTypeId,
      );

  factory CustomFieldModel.fromJson(Map<String, dynamic> json) =>
      CustomFieldModel(
        customFieldId: json["custom_field_id"] ?? json["Custom_Field_Id"],
        categoryId: json["Category_Id"] ?? json["category_id"],
        customFieldTypeId:
            json["custom_field_type_id"] ?? json["Custom_Field_Type_Id"],
        customFieldName: json["custom_field_name"] ?? json["Custom_Field_Name"],
        categoryName: json["Category_Name"] ?? json["category_name"],
        deletedStatus: json["Deleted_Status"] ?? json["deleted_status"],
        isQuotationCustom:
            json["quotation_custom"] ?? json["isQuotationCustom"],
        isViewInQuotation:
            json["view_in_quotation"] ?? json["isViewInQuotation"],
        isCommercial: json["is_commercial"] ?? json["isCommercial"],
        isChecked: (json["is_checked"] != null
                ? int.tryParse(json["is_checked"].toString())
                : null) ??
            (json["events"] != null
                ? int.tryParse(json["events"].toString())
                : null),
        isMandatory: (json["is_mandatory"] != null
                ? int.tryParse(json["is_mandatory"].toString())
                : null) ??
            (json["is_customfield_mandatory"] != null
                ? int.tryParse(json["is_customfield_mandatory"].toString())
                : null) ??
            (json["isMandatory"] != null
                ? int.tryParse(json["isMandatory"].toString())
                : null) ??
            (json["mandatory"] != null
                ? (json["mandatory"] == true || json["mandatory"] == 1 ? 1 : 0)
                : null),
        dropDownValues: _parseValuesList(
            json["Dropdown_Values"] ?? json["dropdown_values"]),
        checkBoxValues: _parseValuesList(
            json["Checkbox_Values"] ?? json["checkbox_values"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        quotationTypeId: json["quotation_type_id"] ?? json["Quotation_Type_Id"],
      );

  static List<String> _parseValuesList(dynamic rawList) {
    if (rawList == null) return [];
    if (rawList is! List) return [];
    List<String> result = [];
    for (var item in rawList) {
      if (item is String) {
        result.add(item);
      } else if (item is Map) {
        final val = item["dropdown_value"] ??
            item["checkbox_value"] ??
            item["value"] ??
            item["name"];
        if (val != null) {
          result.add(val.toString());
        }
      } else if (item != null) {
        result.add(item.toString());
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        "custom_field_id": customFieldId,
        "Category_Id": categoryId,
        "Category_Name": categoryName,
        "custom_field_type_id": customFieldTypeId,
        "custom_field_name": customFieldName,
        "Deleted_Status": deletedStatus,
        "quotation_custom": isQuotationCustom,
        "view_in_quotation": isViewInQuotation,
        "is_commercial": isCommercial,
        "is_checked": isChecked,
        "events": isChecked,
        "is_mandatory": isMandatory,
        "is_customfield_mandatory": isMandatory,
        "isMandatory": isMandatory,
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
