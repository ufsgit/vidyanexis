class UserEnquirySourceModel {
  final int? userEnquirySourceId;
  final int? userId;
  final String? userDetailsName;
  final int? enquirySourceId;
  final String? enquirySourceName;
  int isview;
  final int? deleteStatus;

  UserEnquirySourceModel({
    this.userEnquirySourceId,
    this.userId,
    this.userDetailsName,
    this.enquirySourceId,
    this.enquirySourceName,
    required this.isview,
    this.deleteStatus,
  });

  factory UserEnquirySourceModel.fromJson(Map<String, dynamic> json) {
    return UserEnquirySourceModel(
      userEnquirySourceId: json['user_enquiry_source_id'],
      userId: json['user_id'],
      userDetailsName: json['User_Details_Name'],
      enquirySourceId: json['enquiry_source_id'],
      enquirySourceName: json['Enquiry_Source_Name'],
      isview: json['isview'] ?? 0,
      deleteStatus: json['deletestatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_enquiry_source_id': userEnquirySourceId,
      'user_id': userId,
      'User_Details_Name': userDetailsName,
      'enquiry_source_id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'isview': isview,
      'deletestatus': deleteStatus,
    };
  }
}
