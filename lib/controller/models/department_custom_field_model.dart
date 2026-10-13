import 'package:vidyanexis/controller/models/custom_field_model.dart';

class DepartmentCustomFieldMapping {
  final int departmentId;
  final int enquiryForId;
  final String enquiryForName;
  final List<int> customFieldIds; // From API
  List<CustomFieldModel> customFields; // Resolved full objects
  final Map<int, int> createNewMap;

  DepartmentCustomFieldMapping({
    required this.departmentId,
    required this.enquiryForId,
    required this.enquiryForName,
    List<int>? customFieldIds,
    List<CustomFieldModel>? customFields,
    Map<int, int>? createNewMap,
  })  : customFieldIds = customFieldIds ?? [],
        customFields = customFields ?? [],
        createNewMap = createNewMap ?? {};

  // Factory to handle API response (custom_field_ids and custom_fields)
  factory DepartmentCustomFieldMapping.fromApi(
      Map<String, dynamic> json, int deptId) {
    List<int> ids = [];
    Map<int, int> isCreateNewMap = {};

    if (json['custom_fields'] != null && json['custom_fields'] is List) {
      for (var item in json['custom_fields']) {
        if (item is Map<String, dynamic>) {
          final id = item['custom_field_id'] ?? item['Custom_Field_Id'];
          if (id != null) {
            final fieldId = int.tryParse(id.toString()) ?? 0;
            if (fieldId > 0) {
              ids.add(fieldId);
              final isCreate = item['is_create_new'] ??
                  item['create_new'] ??
                  item['Is_Create_New'] ??
                  item['isCreateNew'];
              if (isCreate == 1 || isCreate == "1" || isCreate == true) {
                isCreateNewMap[fieldId] = 1;
              } else {
                isCreateNewMap[fieldId] = 0;
              }
            }
          }
        } else if (item is int) {
          ids.add(item);
        }
      }
    } else if (json['custom_field_ids'] != null &&
        json['custom_field_ids'] is List) {
      ids = List<int>.from(json['custom_field_ids']);
    }

    return DepartmentCustomFieldMapping(
      departmentId: deptId,
      enquiryForId: json['enquiry_for_id'] ?? 0,
      enquiryForName: json['enquiry_for_name'] ?? '',
      customFieldIds: ids,
      customFields: [], // Will be resolved later
      createNewMap: isCreateNewMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "enquiry_for_id": enquiryForId,
      "enquiry_for_name": enquiryForName,
      "custom_field_ids":
          customFields.map((f) => f.customFieldId ?? 0).toList(),
      "custom_fields": customFields
          .map((f) => {
                "custom_field_id": f.customFieldId ?? 0,
                "custom_field_name": f.customFieldName ?? '',
                "is_create_new": f.isCreateNew ?? 0,
              })
          .toList(),
    };
  }
}

