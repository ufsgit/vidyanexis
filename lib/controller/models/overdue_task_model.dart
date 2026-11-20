class OverdueTaskModel {
  final int? taskId;
  final int? customerId;
  final String? customerName;
  final String? phoneNumber;
  final int? taskTypeId;
  final String? taskTypeName;
  final String? taskName;
  final String? taskDetail;
  final int? duration;
  final int? taskStatusId;
  final String? taskStatusName;
  final int? toUserId;
  final String? toUserName;
  final String? entryDate;
  final String? dueDate;
  final int? daysPending;
  final int? overdueDays;
  final String? priorityName;
  final String? priorityColor;
  final int? departmentId;
  final String? departmentName;
  final Map<String, dynamic>? rawJson;

  OverdueTaskModel({
    this.taskId,
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.taskTypeId,
    this.taskTypeName,
    this.taskName,
    this.taskDetail,
    this.duration,
    this.taskStatusId,
    this.taskStatusName,
    this.toUserId,
    this.toUserName,
    this.entryDate,
    this.dueDate,
    this.daysPending,
    this.overdueDays,
    this.priorityName,
    this.priorityColor,
    this.departmentId,
    this.departmentName,
    this.rawJson,
  });

  factory OverdueTaskModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    int? parsedOverdue = parseInt(json['Overdue_Days'] ??
        json['overdue_days'] ??
        json['Overdue'] ??
        json['overdue'] ??
        json['OverdueDays'] ??
        json['Days_Overdue'] ??
        json['days_overdue']);

    if (parsedOverdue == null) {
      final dueDateRaw = json['Due_Date'] ??
          json['due_date'] ??
          json['Task_End_Date'] ??
          json['task_end_date'] ??
          json['Completion_Date'] ??
          json['completion_date'];
      if (dueDateRaw != null) {
        final parsed = DateTime.tryParse(dueDateRaw.toString());
        if (parsed != null && parsed.isBefore(DateTime.now())) {
          parsedOverdue = DateTime.now().difference(parsed).inDays;
        }
      }
    }

    return OverdueTaskModel(
      taskId: parseInt(json['Task_Id'] ?? json['task_id'] ?? json['TaskId'] ?? json['taskId']),
      customerId: parseInt(json['Customer_Id'] ?? json['customer_id'] ?? json['CustomerId'] ?? json['customerId']),
      customerName: parseString(
        json['Customer_Name'] ??
            json['customer_name'] ??
            json['CustomerName'] ??
            json['customerName'] ??
            json['Consumer_Name'] ??
            json['consumer_name'],
      ),
      phoneNumber: parseString(
        json['Phone_Number'] ??
            json['phone_number'] ??
            json['Contact_Number'] ??
            json['contact_number'] ??
            json['Mobile_No'] ??
            json['mobile_no'] ??
            json['Mobile_Number'] ??
            json['mobile_number'] ??
            json['Mobile'] ??
            json['mobile'] ??
            json['Phone'] ??
            json['phone'],
      ),
      taskTypeId: parseInt(json['Task_Type_Id'] ?? json['task_type_id'] ?? json['TaskTypeId']),
      taskTypeName: parseString(
        json['Task_Type_Name'] ??
            json['task_type_name'] ??
            json['TaskTypeName'] ??
            json['TaskType'] ??
            json['task_type'],
      ),
      taskName: parseString(json['Task_Name'] ?? json['task_name'] ?? json['TaskName']),
      taskDetail: parseString(
        json['Task_Detail'] ??
            json['task_detail'] ??
            json['Description'] ??
            json['description'] ??
            json['Remark'] ??
            json['remark'],
      ),
      duration: parseInt(json['Duration'] ?? json['duration'] ?? json['Task_Duration'] ?? json['task_duration']),
      taskStatusId: parseInt(json['Task_Status_Id'] ?? json['task_status_id'] ?? json['TaskStatusId']),
      taskStatusName: parseString(
        json['Task_Status_Name'] ??
            json['task_status_name'] ??
            json['TaskStatusName'] ??
            json['Status'] ??
            json['status'],
      ),
      toUserId: parseInt(json['To_User_Id'] ?? json['to_user_id'] ?? json['To_User'] ?? json['User_Details_Id'] ?? json['user_details_id']),
      toUserName: parseString(
        json['To_User_Name'] ??
            json['to_user_name'] ??
            json['User_Details_Name'] ??
            json['user_details_name'] ??
            json['Assigned_To'] ??
            json['assigned_to'],
      ),
      entryDate: parseString(
        json['Entry_Date'] ??
            json['entry_date'] ??
            json['Task_Date'] ??
            json['task_date'] ??
            json['Date'] ??
            json['date'],
      ),
      dueDate: parseString(
        json['Due_Date'] ??
            json['due_date'] ??
            json['Task_End_Date'] ??
            json['task_end_date'] ??
            json['Completion_Date'] ??
            json['completion_date'],
      ),
      daysPending: parseInt(json['Days_Pending'] ?? json['days_pending'] ?? json['DaysPending']),
      overdueDays: parsedOverdue,
      priorityName: parseString(json['Priority_Name'] ?? json['priority_name'] ?? json['Priority'] ?? json['priority']),
      priorityColor: parseString(json['Priority_Color'] ?? json['priority_color']),
      departmentId: parseInt(json['Department_Id'] ?? json['department_id']),
      departmentName: parseString(json['Department_Name'] ?? json['department_name']),
      rawJson: json,
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
      'Task_Name': taskName,
      'Task_Detail': taskDetail,
      'Duration': duration,
      'Task_Status_Id': taskStatusId,
      'Task_Status_Name': taskStatusName,
      'To_User_Id': toUserId,
      'To_User_Name': toUserName,
      'Entry_Date': entryDate,
      'Due_Date': dueDate,
      'Days_Pending': daysPending,
      'Overdue_Days': overdueDays,
      'Priority_Name': priorityName,
      'Priority_Color': priorityColor,
      'Department_Id': departmentId,
      'Department_Name': departmentName,
    };
  }
}
