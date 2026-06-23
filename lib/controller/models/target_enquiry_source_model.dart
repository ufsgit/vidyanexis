class TargetEnquirySourceModel {
  final int targetEnquirySourceId;
  final int enquirySourceId;
  final String enquirySourceName;
  final String targetFrom;
  final String targetTo;
  final String durationFrom;
  final String durationTo;

  TargetEnquirySourceModel({
    required this.targetEnquirySourceId,
    required this.enquirySourceId,
    required this.enquirySourceName,
    required this.targetFrom,
    required this.targetTo,
    required this.durationFrom,
    required this.durationTo,
  });

  factory TargetEnquirySourceModel.fromJson(Map<String, dynamic> json) {
    return TargetEnquirySourceModel(
      targetEnquirySourceId: json['Target_Enquiry_Source_Id'] ?? 0,
      enquirySourceId: json['Enquiry_Source_Id'] ?? 0,
      enquirySourceName: json['Enquiry_Source_Name'] ?? '',
      targetFrom: json['Target_From'] ?? '',
      targetTo: json['Target_To'] ?? '',
      durationFrom: json['Duration_From'] ?? '',
      durationTo: json['Duration_To'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Target_Enquiry_Source_Id': targetEnquirySourceId,
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'Target_From': targetFrom,
      'Target_To': targetTo,
      'Duration_From': durationFrom,
      'Duration_To': durationTo,
    };
  }
}
