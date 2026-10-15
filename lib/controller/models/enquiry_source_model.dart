import 'package:vidyanexis/controller/models/custom_field_by_status.dart';

class Enquirysourcemodel {
  final int enquirySourceId;
  final String enquirySourceName;
  final int sourceCategoryId;
  final String sourceCategoryName;
  final int deleteStatus;
  List<CustomFieldByStatusId>? customFields;
  final int underSourceId;
  final String underSourceName;
  final double commissionPercent;

  // Constructor
  Enquirysourcemodel({
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.sourceCategoryId,
    required this.sourceCategoryName,
    required this.deleteStatus,
    this.customFields,
    this.underSourceId = 0,
    this.underSourceName = '',
    this.commissionPercent = 0.0,
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
      underSourceId: json["Under_Source_Id"] != null
          ? int.tryParse(json["Under_Source_Id"].toString()) ?? 0
          : (json["under_source_id"] != null
              ? int.tryParse(json["under_source_id"].toString()) ?? 0
              : (json["Under_Source"] != null
                  ? int.tryParse(json["Under_Source"].toString()) ?? 0
                  : 0)),
      underSourceName: json["Under_Source_Name"] ??
          json["under_source_name"] ??
          '',
      commissionPercent: json["Commission_Percentage"] != null
          ? double.tryParse(json["Commission_Percentage"].toString()) ?? 0.0
          : (json["Commission_Percent"] != null
              ? double.tryParse(json["Commission_Percent"].toString()) ?? 0.0
              : (json["commission_percent"] != null
                  ? double.tryParse(json["commission_percent"].toString()) ?? 0.0
                  : (json["Commission"] != null
                      ? double.tryParse(json["Commission"].toString()) ?? 0.0
                      : (json["commission"] != null
                          ? double.tryParse(json["commission"].toString()) ?? 0.0
                          : 0.0)))),
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
      'Under_Source_Id': underSourceId,
      'Under_Source_Name': underSourceName,
      'Commission_Percentage': commissionPercent,
      'Commission_Percent': commissionPercent,
      'Commission': commissionPercent,
      'commission_percent': commissionPercent,
    };
  }
}
