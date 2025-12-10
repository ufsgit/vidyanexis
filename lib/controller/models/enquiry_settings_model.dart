class EnquirySourceModel {
  final int enquirySourceId;
  final String enquirySourceName;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final int deleteStatus;

  // Constructor
  EnquirySourceModel({
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.deleteStatus,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory EnquirySourceModel.fromJson(Map<String, dynamic> json) {
    return EnquirySourceModel(
      sourceCategoryId: json["Source_Category_Id"] ?? 0,
      sourceCategoryName: json["Source_Category_Name"] ?? '',
      enquirySourceId:
          json['Enquiry_Source_Id'] ?? 0, // Default to 0 if missing
      enquirySourceName: json['Enquiry_Source_Name'] ??
          '', // Default to empty string if missing
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if missing
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'DeleteStatus': deleteStatus,
    };
  }
}
