class LeadStatusReportModel {
  int? statusId;
  String? statusName;
  int? leadCount;

  LeadStatusReportModel({this.statusId, this.statusName, this.leadCount});

  LeadStatusReportModel.fromJson(Map<String, dynamic> json) {
    statusId = json['Status_Id'];
    statusName = json['Status_Name'];
    leadCount = json['Lead_Count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Status_Id'] = statusId;
    data['Status_Name'] = statusName;
    data['Lead_Count'] = leadCount;
    return data;
  }
}
