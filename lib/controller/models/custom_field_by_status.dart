class CustomFieldByStatusId {
  int? isMandatory;
  int? customFieldId;
  int? customFieldTypeId;
  String? customFieldName;
  String? datavalue;
  List<DropdownValue>? dropdownValues;
  List<CheckBoxValues>? checkboxValues;
  dynamic missingMandatoryDocumentCount;
  List<String>? missingMandatoryDocumentNames;
  int? isQuotationCustom;
  int? isViewInQuotation;
  int? isChecked;
  int? isCommercial;
  int? categoryId;
  String? categoryName;

  CustomFieldByStatusId({
    this.isMandatory,
    this.customFieldId,
    this.datavalue,
    this.customFieldName,
    this.customFieldTypeId,
    this.dropdownValues,
    this.checkboxValues,
    this.missingMandatoryDocumentCount,
    this.missingMandatoryDocumentNames,
    this.isQuotationCustom,
    this.isViewInQuotation,
    this.isChecked,
    this.isCommercial,
    this.categoryId,
    this.categoryName,
  });

  CustomFieldByStatusId copyWith({
    int? isMandatory,
    int? customFieldId,
    String? customFieldName,
    String? datavalue,
    List<DropdownValue>? dropdownValues,
    List<CheckBoxValues>? checkboxValues,
    dynamic missingMandatoryDocumentCount,
    List<String>? missingMandatoryDocumentNames,
    int? isQuotationCustom,
    int? isViewInQuotation,
    int? isChecked,
    int? isCommercial,
    int? categoryId,
    String? categoryName,
  }) =>
      CustomFieldByStatusId(
        isMandatory: isMandatory ?? this.isMandatory,
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldName: customFieldName ?? this.customFieldName,
        datavalue: datavalue ?? this.datavalue,
        dropdownValues: dropdownValues ?? this.dropdownValues,
        checkboxValues: checkboxValues ?? this.checkboxValues,
        missingMandatoryDocumentCount:
            missingMandatoryDocumentCount ?? this.missingMandatoryDocumentCount,
        missingMandatoryDocumentNames:
            missingMandatoryDocumentNames ?? this.missingMandatoryDocumentNames,
        isQuotationCustom: isQuotationCustom ?? this.isQuotationCustom,
        isViewInQuotation: isViewInQuotation ?? this.isViewInQuotation,
        isChecked: isChecked ?? this.isChecked,
        isCommercial: isCommercial ?? this.isCommercial,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
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

  factory CustomFieldByStatusId.fromJson(Map<String, dynamic> json) =>
      CustomFieldByStatusId(
        isMandatory: _extractMandatory(json),
        customFieldId: json["custom_field_id"] ?? json["Custom_Field_Id"],
        customFieldName: json["custom_field_name"] ?? json["Custom_Field_Name"],
        datavalue: json["datavalue"] ?? json["DataValue"] ?? "",
        customFieldTypeId: json["custom_field_type_id"] ?? json["Custom_Field_Type_Id"],
        isQuotationCustom: json["quotation_custom"] ?? json["isQuotationCustom"],
        isViewInQuotation: json["view_in_quotation"] ?? json["isViewInQuotation"],
        isChecked: _extractChecked(json),
        isCommercial: json["is_commercial"] ?? json["isCommercial"],
        categoryId: json["Category_Id"] ?? json["category_id"],
        categoryName: json["Category_Name"] ?? json["category_name"],
        dropdownValues: json["dropdown_values"] == null && json["Dropdown_Values"] == null
            ? []
            : List<DropdownValue>.from(
                (json["dropdown_values"] ?? json["Dropdown_Values"])!
                    .map((x) => DropdownValue.fromJson(x))),
        checkboxValues: json["checkbox_values"] == null && json["Checkbox_Values"] == null
            ? []
            : List<CheckBoxValues>.from(
                (json["checkbox_values"] ?? json["Checkbox_Values"])!
                    .map((x) => CheckBoxValues.fromJson(x))),
        missingMandatoryDocumentCount: json["missing_mandatory_document_count"],
        missingMandatoryDocumentNames:
            json["missing_mandatory_document_names"] == null
                ? []
                : List<String>.from(json["missing_mandatory_document_names"]!),
      );

  Map<String, dynamic> toJson() => {
        "isMandatory": isMandatory,
        "is_mandatory": isMandatory,
        "is_customfield_mandatory": isMandatory,
        "mandatory": isMandatory,
        "custom_field_id": customFieldId,
        "custom_field_name": customFieldName,
        "custom_field_type_id": customFieldTypeId,
        "quotation_custom": isQuotationCustom,
        "view_in_quotation": isViewInQuotation,
        "is_checked": isChecked,
        "events": isChecked,
        "is_commercial": isCommercial,
        "Category_Id": categoryId,
        "Category_Name": categoryName,
        "dropdown_values": dropdownValues == null
            ? []
            : List<dynamic>.from(dropdownValues!.map((x) => x.toJson())),
        "checkbox_values": checkboxValues == null
            ? []
            : List<dynamic>.from(checkboxValues!.map((x) => x.toJson())),
        "missing_mandatory_document_count": missingMandatoryDocumentCount,
        "missing_mandatory_document_names": missingMandatoryDocumentNames ==
                null
            ? []
            : List<dynamic>.from(missingMandatoryDocumentNames!.map((x) => x)),
      };
}

class DropdownValue {
  int? dropdownId;
  String? dropdownValue;

  DropdownValue({
    this.dropdownId,
    this.dropdownValue,
  });

  DropdownValue copyWith({
    int? dropdownId,
    String? dropdownValue,
  }) =>
      DropdownValue(
        dropdownId: dropdownId ?? this.dropdownId,
        dropdownValue: dropdownValue ?? this.dropdownValue,
      );

  factory DropdownValue.fromJson(Map<String, dynamic> json) => DropdownValue(
        dropdownId: json["dropdown_id"] ?? json["id"],
        dropdownValue: (json["dropdown_value"] ?? json["value"])?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "dropdown_id": dropdownId,
        "dropdown_value": dropdownValue,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownValue &&
          runtimeType == other.runtimeType &&
          dropdownId == other.dropdownId &&
          dropdownValue == other.dropdownValue;

  @override
  int get hashCode => dropdownId.hashCode ^ dropdownValue.hashCode;
}

class CheckBoxValues {
  int? checkBoxId;
  String? checkBoxValues;

  CheckBoxValues({
    this.checkBoxId,
    this.checkBoxValues,
  });

  CheckBoxValues copyWith({
    int? checkBoxId,
    String? checkBoxValues,
  }) =>
      CheckBoxValues(
        checkBoxId: checkBoxId ?? this.checkBoxId,
        checkBoxValues: checkBoxValues ?? this.checkBoxValues,
      );

  factory CheckBoxValues.fromJson(Map<String, dynamic> json) => CheckBoxValues(
        checkBoxId: json["checkbox_id"],
        checkBoxValues: json["checkbox_value"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "checkbox_id": checkBoxId,
        "checkbox_value": checkBoxValues,
      };
}
