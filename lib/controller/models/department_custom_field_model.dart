import 'package:vidyanexis/controller/models/custom_field_model.dart';

class DepartmentCustomFieldMapping {
  final int departmentId;
  final int enquiryForId;
  final String enquiryForName;
  final List<int> customFieldIds;           // From API
  List<CustomFieldModel> customFields;      // Resolved full objects

  DepartmentCustomFieldMapping({
    required this.departmentId,
    required this.enquiryForId,
    required this.enquiryForName,
    List<int>? customFieldIds,
    List<CustomFieldModel>? customFields,
  })  : customFieldIds = customFieldIds ?? [],
        customFields = customFields ?? [];

  // Factory to handle API response (custom_field_ids)
  factory DepartmentCustomFieldMapping.fromApi(Map<String, dynamic> json, int deptId) {
    return DepartmentCustomFieldMapping(
      departmentId: deptId,
      enquiryForId: json['enquiry_for_id'] ?? 0,
      enquiryForName: json['enquiry_for_name'] ?? '',
      customFieldIds: List<int>.from(json['custom_field_ids'] ?? []),
      customFields: [], // Will be resolved later
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "enquiry_for_id": enquiryForId,
      "enquiry_for_name": enquiryForName,
      "custom_field_ids": customFields.map((f) => f.customFieldId ?? 0).toList(),
    };
  }
}