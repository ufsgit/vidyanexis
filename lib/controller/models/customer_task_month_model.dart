class CustomerTaskMonthModel {
  int? customerId;
  String? customerName;
  String? taskDate;
  String? taskTypeName;
  String? taskStatusName;
  String? projectWing;
  String? staffName;

  CustomerTaskMonthModel({
    this.customerId,
    this.customerName,
    this.taskDate,
    this.taskTypeName,
    this.taskStatusName,
    this.projectWing,
    this.staffName,
  });

  CustomerTaskMonthModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'];
    customerName = json['Customer_Name'];
    taskDate = json['Task_Date'];
    taskTypeName = json['Task_Type_Name'];
    taskStatusName = json['Task_Status_Name'];
    projectWing = json['Project_Wing'];
    staffName = json['Staff_Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Customer_Id'] = customerId;
    data['Customer_Name'] = customerName;
    data['Task_Date'] = taskDate;
    data['Task_Type_Name'] = taskTypeName;
    data['Task_Status_Name'] = taskStatusName;
    data['Project_Wing'] = projectWing;
    data['Staff_Name'] = staffName;
    return data;
  }
}
