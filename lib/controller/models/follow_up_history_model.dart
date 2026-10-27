class FollowUpHistoryModel {
  String? followUpId;
  String? followUpDate;
  String? nextFollowUpDate;
  String? remarks;
  String? statusName;
  String? assignedToName;
  String? assignedByName;
  String? statusId;
  String? colorCode;
  String? taskTypeName;
  String? departmentName;

  FollowUpHistoryModel(
      {this.followUpId,
      this.followUpDate,
      this.nextFollowUpDate,
      this.remarks,
      this.statusName,
      this.assignedToName,
      this.assignedByName,
      this.statusId,
      this.colorCode,
      this.taskTypeName,
      this.departmentName});

  FollowUpHistoryModel.fromJson(Map<String, dynamic> json) {
    followUpId = json['FollowUp_Id']?.toString() ??
        json['Followup_Id']?.toString() ??
        json['id']?.toString();
    followUpDate =
        json['FollowUp_Date']?.toString() ?? json['Entry_Date']?.toString();
    nextFollowUpDate = json['Next_FollowUp_Date']?.toString();
    remarks = json['Remarks']?.toString() ?? json['Remark']?.toString();
    statusName = json['Status_Name']?.toString();
    assignedToName = json['Assigned_To_Name']?.toString() ??
        json['To_User_Name']?.toString();
    assignedByName = json['Assigned_By_Name']?.toString() ??
        json['By_User_Name']?.toString();
    statusId = json['Status_Id']?.toString();
    colorCode = json['Color_Code']?.toString();
    taskTypeName = json['Task_Type_Name']?.toString() ??
        json['task_type_name']?.toString() ??
        json['Task_Type']?.toString();
    departmentName = json['Department_Name']?.toString() ??
        json['department_name']?.toString() ??
        json['Department']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FollowUp_Id'] = followUpId;
    data['FollowUp_Date'] = followUpDate;
    data['Next_FollowUp_Date'] = nextFollowUpDate;
    data['Remarks'] = remarks;
    data['Status_Name'] = statusName;
    data['Assigned_To_Name'] = assignedToName;
    data['Assigned_By_Name'] = assignedByName;
    data['Status_Id'] = statusId;
    data['Color_Code'] = colorCode;
    data['Task_Type_Name'] = taskTypeName;
    data['Department_Name'] = departmentName;
    return data;
  }
}
