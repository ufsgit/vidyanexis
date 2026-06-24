import 'package:vidyanexis/controller/models/custom_field_by_status.dart';

class EnquiryForModel {
  final int enquiryForId;
  final String enquiryForName;
  final int deleteStatus;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final List<CustomFieldByStatusId> parsedCustomFields;
  final List<dynamic>? taskTypes;

  // Constructor with default values
  EnquiryForModel({
    required this.enquiryForId,
    required this.enquiryForName,
    required this.deleteStatus,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    this.parsedCustomFields = const [],
    this.taskTypes,
  });

  // Factory method to create an instance from JSON, using ?? for null checks
  factory EnquiryForModel.fromJson(Map<String, dynamic> json) {
    List<CustomFieldByStatusId> customFieldsList = [];
    if (json['custom_fields'] != null) {
      customFieldsList = (json['custom_fields'] as List)
          .map((e) => CustomFieldByStatusId.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return EnquiryForModel(
      sourceCategoryId: json["Source_Category_Id"] ?? 0,
      sourceCategoryName: json["Source_Category_Name"] ?? '',
      enquiryForId: json['Enquiry_For_Id'] ?? 0,
      enquiryForName: json['Enquiry_For_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      parsedCustomFields: customFieldsList,
      taskTypes: json['Task_Types'] != null
          ? List<dynamic>.from(json['Task_Types'])
          : null,
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'Enquiry_For_Id': enquiryForId,
      'Enquiry_For_Name': enquiryForName,
      'DeleteStatus': deleteStatus,
      'Source_Category_Id': sourceCategoryId,
      'Source_Category_Name': sourceCategoryName,
      'custom_fields': parsedCustomFields.map((e) => e.toJson()).toList(),
      if (taskTypes != null) 'Task_Types': taskTypes,
    };
  }

  // Backward compatibility getter
  List<Map<String, dynamic>> get customFields {
    return parsedCustomFields.map((e) => e.toJson()).toList();
  }
}
