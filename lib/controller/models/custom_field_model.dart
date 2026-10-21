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
  int? isCreateNew;
  List<String>? dropDownValues;
  List<String>? checkBoxValues;
  int? quotationTypeId;
  int? customerView;
  int? order;

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
    this.isCreateNew,
    this.createdAt,
    this.quotationTypeId,
    this.customerView,
    this.order,
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
    int? isCreateNew,
    DateTime? createdAt,
    int? quotationTypeId,
    int? customerView,
    int? order,
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
        isCreateNew: isCreateNew ?? this.isCreateNew,
        dropDownValues: dropDownValues ?? this.dropDownValues,
        checkBoxValues: checkBoxValues ?? this.checkBoxValues,
        createdAt: createdAt ?? this.createdAt,
        quotationTypeId: quotationTypeId ?? this.quotationTypeId,
        customerView: customerView ?? this.customerView,
        order: order ?? this.order,
      );

  static int? _parseMandatoryValue(dynamic val) {
    if (val == null) return null;
    if (val == 1 || val == "1" || val == true || val == "true") return 1;
    if (val == 0 || val == "0" || val == false || val == "false") return 0;
    return int.tryParse(val.toString());
  }

  static int? _extractMandatory(Map<String, dynamic> json) {
    final candidateKeys = [
      'is_customfield_mandatory',
      'is_custom_field_mandatory',
      'Is_Customfield_Mandatory',
      'Is_Custom_Field_Mandatory',
      'is_mandatory',
      'isMandatory',
      'Is_Mandatory',
      'IsMandatory',
      'mandatory',
      'Mandatory',
      'is_required',
      'isRequired',
      'Is_Required',
      'IsRequired',
      'required',
      'Required',
    ];
    // First pass: If ANY key is explicitly 1 / "1" / true, return 1 immediately
    for (final key in candidateKeys) {
      if (json.containsKey(key)) {
        final val = _parseMandatoryValue(json[key]);
        if (val == 1) return 1;
      }
    }
    for (final entry in json.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll('_', '');
      if (keyClean == 'iscustomfieldmandatory' ||
          keyClean == 'iscustomfieldsmandatory' ||
          keyClean == 'ismandatory' ||
          keyClean == 'mandatory' ||
          keyClean == 'isrequired' ||
          keyClean == 'required') {
        final val = _parseMandatoryValue(entry.value);
        if (val == 1) return 1;
      }
    }
    return 0;
  }

  static int? _extractChecked(Map<String, dynamic> json) {
    final candidateKeys = [
      'is_checked',
      'Is_Checked',
      'isChecked',
      'IsChecked',
      'events',
      'Events',
    ];
    for (final key in candidateKeys) {
      if (json.containsKey(key) && json[key] != null) {
        final parsed = int.tryParse(json[key].toString());
        if (parsed != null && parsed == 1) return 1;
      }
    }
    for (final entry in json.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll('_', '');
      if (keyClean == 'ischecked' || keyClean == 'events') {
        final parsed = int.tryParse(entry.value.toString());
        if (parsed != null && parsed == 1) return 1;
      }
    }
    return 0;
  }

  static int? _extractCreateNew(Map<String, dynamic> json) {
    final candidateKeys = [
      'is_create_new',
      'isCreateNew',
      'Is_Create_New',
      'IsCreateNew',
      'create_new',
      'Create_New',
    ];
    for (final key in candidateKeys) {
      if (json.containsKey(key) && json[key] != null) {
        final val = json[key];
        if (val == 1 || val == "1" || val == true || val == "true") return 1;
        if (val == 0 || val == "0" || val == false || val == "false") return 0;
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    for (final entry in json.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll('_', '');
      if (keyClean == 'iscreatenew' || keyClean == 'createnew') {
        final val = entry.value;
        if (val == 1 || val == "1" || val == true || val == "true") return 1;
        if (val == 0 || val == "0" || val == false || val == "false") return 0;
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  static int? _extractCustomerView(Map<String, dynamic> json) {
    final candidateKeys = [
      'customer_view',
      'custemer_view',
      'Customer_View',
      'Custemer_View',
      'view_customer',
      'view_in_customer',
      'View_Customer',
      'View_In_Customer',
      'is_customer_view',
      'isCustomerView',
      'Is_Customer_View',
      'IsCustomerView',
    ];
    for (final key in candidateKeys) {
      if (json.containsKey(key) && json[key] != null) {
        final val = json[key];
        if (val == 1 || val == "1" || val == true || val == "true") return 1;
        if (val == 0 || val == "0" || val == false || val == "false") return 0;
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    for (final entry in json.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll('_', '');
      if (keyClean == 'customerview' ||
          keyClean == 'custemerview' ||
          keyClean == 'viewcustomer' ||
          keyClean == 'viewincustomer' ||
          keyClean == 'iscustomerview') {
        final val = entry.value;
        if (val == 1 || val == "1" || val == true || val == "true") return 1;
        if (val == 0 || val == "0" || val == false || val == "false") return 0;
        final parsed = int.tryParse(val.toString());
        if (parsed != null) return parsed;
      }
    }
    return 0;
  }

  static int? _extractOrder(Map<String, dynamic> json) {
    final candidateKeys = [
      'order',
      'Order',
      'orders',
      'Orders',
      'order_no',
      'Order_No',
      'order_by',
      'Order_By',
      'customer_order',
      'Customer_Order',
      'custemer_order',
      'Custemer_Order',
      'view_order',
      'View_Order',
      'customer_view_order',
      'Customer_View_Order',
    ];
    for (final key in candidateKeys) {
      if (json.containsKey(key) && json[key] != null) {
        final parsed = int.tryParse(json[key].toString());
        if (parsed != null) return parsed;
      }
    }
    for (final entry in json.entries) {
      final keyClean = entry.key.toLowerCase().replaceAll('_', '');
      if (keyClean == 'order' ||
          keyClean == 'orders' ||
          keyClean == 'orderno' ||
          keyClean == 'orderby' ||
          keyClean == 'customerorder' ||
          keyClean == 'custemerorder' ||
          keyClean == 'vieworder' ||
          keyClean == 'customervieworder') {
        final parsed = int.tryParse(entry.value.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

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
        isChecked: _extractChecked(json),
        isMandatory: _extractMandatory(json),
        isCreateNew: _extractCreateNew(json),
        customerView: _extractCustomerView(json),
        order: _extractOrder(json),
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
        "is_create_new": isCreateNew ?? 0,
        "view_in_customer": customerView ?? 0,
        "order": order ?? 0,
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
