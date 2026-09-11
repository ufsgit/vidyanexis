class CustomerTaskMonthModel {
  int? toUserId;
  String? staffName;
  String? taskDate;
  String? taskTypeName;
  String? taskStatusName;
  String? projectWing;

  CustomerTaskMonthModel({
    this.toUserId,
    this.staffName,
    this.taskDate,
    this.taskTypeName,
    this.taskStatusName,
    this.projectWing,
  });

  CustomerTaskMonthModel.fromJson(Map<String, dynamic> json) {
    toUserId = json['To_User_Id'];
    staffName = json['Staff_Name'];
    taskDate = json['Task_Date'];
    taskTypeName = json['Task_Type_Name'];
    taskStatusName = json['Task_Status_Name'];
    projectWing = json['Project_Wing'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['To_User_Id'] = toUserId;
    data['Staff_Name'] = staffName;
    data['Task_Date'] = taskDate;
    data['Task_Type_Name'] = taskTypeName;
    data['Task_Status_Name'] = taskStatusName;
    data['Project_Wing'] = projectWing;
    return data;
  }
}
