class TaskHistoryModel {
  String? taskHistoryId;
  String? entryDate;
  String? description;
  String? statusName;
  String? byUserName;

  TaskHistoryModel({
    this.taskHistoryId,
    this.entryDate,
    this.description,
    this.statusName,
    this.byUserName,
  });

  TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    taskHistoryId =
        json['Task_History_Id']?.toString() ?? json['Id']?.toString();
    entryDate = json['Entry_Date']?.toString() ?? json['Date']?.toString();
    description =
        json['Description']?.toString() ?? json['Task_Description']?.toString();
    statusName =
        json['Status_Name']?.toString() ?? json['Task_Status']?.toString();
    byUserName =
        json['By_User_Name']?.toString() ?? json['User_Name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Task_History_Id'] = taskHistoryId;
    data['Entry_Date'] = entryDate;
    data['Description'] = description;
    data['Status_Name'] = statusName;
    data['By_User_Name'] = byUserName;
    return data;
  }
}
