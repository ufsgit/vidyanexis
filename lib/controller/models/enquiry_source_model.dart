import 'package:techtify/controller/models/custom_field_by_status.dart';

class Enquirysourcemodel {
  final int enquirySourceId;
  final String enquirySourceName;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final int deleteStatus;
  List<CustomFieldByStatusId>? customFields;

  // Constructor
  Enquirysourcemodel({
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.deleteStatus,
    this.customFields,
  });

  // Factory method to create an instance from JSON with default values if necessary
  factory Enquirysourcemodel.fromJson(Map<String, dynamic> json) {
    return Enquirysourcemodel(
      sourceCategoryId: json["Source_Category_Id"] ?? 0,
      sourceCategoryName: json["Source_Category_Name"] ?? '',
      enquirySourceId:
          json['Enquiry_Source_Id'] ?? 0, // Default to 0 if missing
      enquirySourceName: json['Enquiry_Source_Name'] ??
          '', // Default to empty string if missing
      deleteStatus: json['DeleteStatus'] ?? 0, // Default to 0 if missing
      customFields: json["custom_fields"] == null
          ? []
          : List<CustomFieldByStatusId>.from(json["custom_fields"]!
              .map((x) => CustomFieldByStatusId.fromJson(x))),
    );
  }

  // Method to convert the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'DeleteStatus': deleteStatus,
      "custom_fields": customFields == null
          ? []
          : List<dynamic>.from(customFields!.map((x) => x.toJson())),
    };
  }
}
