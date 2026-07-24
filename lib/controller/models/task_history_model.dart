class TaskHistoryModel {
  String? taskHistoryId;
  String? entryDate;
  String? description;
  String? statusName;
  String? remarks;
  String? byUserName;
  String? location;
  String? latitude;
  String? longitude;

  TaskHistoryModel({
    this.taskHistoryId,
    this.entryDate,
    this.description,
    this.statusName,
    this.remarks,
    this.byUserName,
    this.location,
    this.latitude,
    this.longitude,
  });

  TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    taskHistoryId =
        json['Task_History_Id']?.toString() ?? json['Id']?.toString();
    entryDate = json['Entry_Date']?.toString() ?? json['Date']?.toString();
    description =
        json['Description']?.toString() ?? json['Task_Description']?.toString();
    statusName =
        json['Status_Name']?.toString() ?? json['Task_Status']?.toString();
    remarks =
        json['Remarks']?.toString() ?? json['remarks']?.toString() ?? json['Remark']?.toString();
    byUserName =
        json['By_User_Name']?.toString() ?? json['User_Name']?.toString();
    location = json['Location']?.toString() ?? json['location']?.toString();
    latitude = json['Latitude']?.toString() ?? json['latitude']?.toString();
    longitude = json['Longitude']?.toString() ?? json['longitude']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Task_History_Id'] = taskHistoryId;
    data['Entry_Date'] = entryDate;
    data['Description'] = description;
    data['Status_Name'] = statusName;
    data['Remarks'] = remarks;
    data['By_User_Name'] = byUserName;
    data['Location'] = location;
    data['Latitude'] = latitude;
    data['Longitude'] = longitude;
    return data;
  }
}
