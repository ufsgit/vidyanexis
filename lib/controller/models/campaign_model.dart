class CampaignModel {
  int campaignId;
  String campaignName;
  String campaignIdString;
  String userIds;
  int enquirySourceId;
  String enquirySourceName;
  int maxUserId;
  String createdDate;
  int deleteStatus;

  CampaignModel({
    required this.campaignId,
    required this.campaignName,
    required this.campaignIdString,
    required this.userIds,
    this.enquirySourceId = 0,
    this.enquirySourceName = '',
    this.maxUserId = 0,
    this.createdDate = '',
    this.deleteStatus = 0,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      campaignId: json['Campaign_Id'] ?? 0,
      campaignName: json['Campaign_Name'] ?? '',
      campaignIdString: json['Campaign_Id_String'] ?? '',
      userIds: json['User_Ids'] ?? '',
      enquirySourceId: json['Enquiry_Source_Id'] ?? 0,
      enquirySourceName: json['Enquiry_Source_Name'] ?? '',
      maxUserId: json['Max_User_Id'] ?? 0,
      createdDate: json['Created_Date'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Campaign_Id': campaignId,
      'Campaign_Name': campaignName,
      'Campaign_Id_String': campaignIdString,
      'User_Ids': userIds,
      'Enquiry_Source_Id': enquirySourceId,
      'Enquiry_Source_Name': enquirySourceName,
      'Max_User_Id': maxUserId,
      'Created_Date': createdDate,
      'DeleteStatus': deleteStatus,
    };
  }
}
