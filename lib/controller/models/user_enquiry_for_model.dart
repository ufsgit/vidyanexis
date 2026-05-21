class UserEnquiryForModel {
  final int? userEnquiryForId;
  final int? userId;
  final String? userDetailsName;
  final int? enquiryForId;
  final String? enquiryForName;
  int isview;
  final int? deleteStatus;

  UserEnquiryForModel({
    this.userEnquiryForId,
    this.userId,
    this.userDetailsName,
    this.enquiryForId,
    this.enquiryForName,
    required this.isview,
    this.deleteStatus,
  });

  factory UserEnquiryForModel.fromJson(Map<String, dynamic> json) {
    return UserEnquiryForModel(
      userEnquiryForId: json['user_enquiry_for_id'],
      userId: json['user_id'],
      userDetailsName: json['User_Details_Name'],
      enquiryForId: json['enquiry_for_id'],
      enquiryForName: json['Enquiry_For_Name'],
      isview: json['isview'] ?? 0,
      deleteStatus: json['deletestatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_enquiry_for_id': userEnquiryForId,
      'user_id': userId,
      'User_Details_Name': userDetailsName,
      'enquiry_for_id': enquiryForId,
      'Enquiry_For_Name': enquiryForName,
      'isview': isview,
      'deletestatus': deleteStatus,
    };
  }
}
