class EnquiryForModel {
  final int enquiryForId;
  final String enquiryForName;
  final int deleteStatus;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final List<Map<String, dynamic>>? customFields;
  final List<Map<String, dynamic>>? taskTypes;

  // Constructor with default values
  EnquiryForModel({
    required this.enquiryForId,
    required this.enquiryForName,
    required this.deleteStatus,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    this.customFields,
    this.taskTypes,
  });

  // Factory method to create an instance from JSON, using ?? for null checks
  factory EnquiryForModel.fromJson(Map<String, dynamic> json) {
    return EnquiryForModel(
      sourceCategoryId: json["Source_Category_Id"] ?? 0,
      sourceCategoryName: json["Source_Category_Name"] ?? '',
      enquiryForId: json['Enquiry_For_Id'] ?? 0,
      enquiryForName: json['Enquiry_For_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      customFields: json['custom_fields'] != null
          ? List<Map<String, dynamic>>.from(json['custom_fields'])
          : null,
      taskTypes: json['Task_Types'] != null
          ? List<Map<String, dynamic>>.from(json['Task_Types'])
          : null,
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'Enquiry_For_Id': enquiryForId,
      'Enquiry_For_Name': enquiryForName,
      'DeleteStatus': deleteStatus,
      if (customFields != null) 'Custom_Fields': customFields,
      if (taskTypes != null) 'Task_Types': taskTypes,
    };
  }
}
