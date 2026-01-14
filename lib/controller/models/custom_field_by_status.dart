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
      );

  factory CustomFieldByStatusId.fromJson(Map<String, dynamic> json) =>
      CustomFieldByStatusId(
        isMandatory: json["isMandatory"],
        customFieldId: json["custom_field_id"],
        customFieldName: json["custom_field_name"],
        datavalue: json["datavalue"] ?? "",
        customFieldTypeId: json["custom_field_type_id"],
        dropdownValues: json["dropdown_values"] == null
            ? []
            : List<DropdownValue>.from(
                json["dropdown_values"]!.map((x) => DropdownValue.fromJson(x))),
        checkboxValues: json["checkbox_values"] == null
            ? []
            : List<CheckBoxValues>.from(json["checkbox_values"]!
                .map((x) => CheckBoxValues.fromJson(x))),
        missingMandatoryDocumentCount: json["missing_mandatory_document_count"],
        missingMandatoryDocumentNames:
            json["missing_mandatory_document_names"] == null
                ? []
                : List<String>.from(json["missing_mandatory_document_names"]!),
      );

  Map<String, dynamic> toJson() => {
        "isMandatory": isMandatory,
        "custom_field_id": customFieldId,
        "custom_field_name": customFieldName,
        "custom_field_type_id": customFieldTypeId,
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
        dropdownId: json["dropdown_id"],
        dropdownValue: json["dropdown_value"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "dropdown_id": dropdownId,
        "dropdown_value": dropdownValue,
      };
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
