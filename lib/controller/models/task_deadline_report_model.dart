class TaskDeadlineReportModel {
  final int? taskId;
  final int? customerId;
  final String? customerName;
  final String? phoneNumber;
  final int? taskTypeId;
  final String? taskTypeName;
  final int? duration;
  final int? taskStatusId;
  final String? taskStatusName;
  final int? toUserId;
  final String? toUserName;
  final String? entryDate;
  final int? daysPending;
  final int? overdueDays;

  TaskDeadlineReportModel({
    this.taskId,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.taskTypeId,
    this.taskTypeName,
    this.duration,
    this.taskStatusId,
    this.taskStatusName,
    this.toUserId,
    this.toUserName,
    this.entryDate,
    this.daysPending,
    this.overdueDays,
  });

  factory TaskDeadlineReportModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return TaskDeadlineReportModel(
      taskId: parseInt(json['Task_Id'] ?? json['task_id']),
      customerId: parseInt(json['Customer_Id'] ?? json['customer_id']),
      customerName: (json['Customer_Name'] ?? json['customer_name'] ?? '').toString(),
      phoneNumber: (json['Phone_Number'] ?? json['phone_number'] ?? '').toString(),
      taskTypeId: parseInt(json['Task_Type_Id'] ?? json['task_type_id']),
      taskTypeName: (json['Task_Type_Name'] ?? json['task_type_name'] ?? '').toString(),
      duration: parseInt(json['Duration'] ?? json['duration']),
      taskStatusId: parseInt(json['Task_Status_Id'] ?? json['task_status_id']),
      taskStatusName: (json['Task_Status_Name'] ?? json['task_status_name'] ?? '').toString(),
      toUserId: parseInt(json['To_User_Id'] ?? json['to_user_id']),
      toUserName: (json['To_User_Name'] ?? json['to_user_name'] ?? '').toString(),
      entryDate: (json['Entry_Date'] ?? json['entry_date'] ?? '').toString(),
      daysPending: parseInt(json['Days_Pending'] ?? json['days_pending']),
      overdueDays: parseInt(json['Overdue_Days'] ?? json['overdue_days']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Task_Id': taskId,
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Phone_Number': phoneNumber,
      'Task_Type_Id': taskTypeId,
      'Task_Type_Name': taskTypeName,
      'Duration': duration,
      'Task_Status_Id': taskStatusId,
      'Task_Status_Name': taskStatusName,
      'To_User_Id': toUserId,
      'To_User_Name': toUserName,
      'Entry_Date': entryDate,
      'Days_Pending': daysPending,
      'Overdue_Days': overdueDays,
    };
  }
}
