class UserTaskTypeModel {
  final int? userTaskTypeId;
  final int? userId;
  final String? userDetailsName;
  final int? taskTypeId;
  final String? taskTypeName;
  int isview;
  final int? deleteStatus;

  UserTaskTypeModel({
    this.userTaskTypeId,
    this.userId,
    this.userDetailsName,
    this.taskTypeId,
    this.taskTypeName,
    required this.isview,
    this.deleteStatus,
  });

  factory UserTaskTypeModel.fromJson(Map<String, dynamic> json) {
    return UserTaskTypeModel(
      userTaskTypeId: int.tryParse(json['user_task_type_id']?.toString() ?? json['User_Task_Type_Id']?.toString() ?? ''),
      userId: int.tryParse(json['user_id']?.toString() ?? json['User_Id']?.toString() ?? ''),
      userDetailsName: json['User_Details_Name'] ?? json['user_details_name'],
      taskTypeId: int.tryParse(json['task_type_id']?.toString() ?? json['Task_Type_Id']?.toString() ?? ''),
      taskTypeName: json['Task_Type_Name'] ?? json['task_type_name'],
      isview: int.tryParse(json['isview']?.toString() ?? json['isView']?.toString() ?? json['Is_View']?.toString() ?? json['IsView']?.toString() ?? '1') ?? 1,
      deleteStatus: int.tryParse(json['deletestatus']?.toString() ?? json['DeleteStatus']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_task_type_id': userTaskTypeId,
      'user_id': userId,
      'User_Details_Name': userDetailsName,
      'task_type_id': taskTypeId,
      'Task_Type_Name': taskTypeName,
      'isview': isview,
      'deletestatus': deleteStatus,
    };
  }
}
