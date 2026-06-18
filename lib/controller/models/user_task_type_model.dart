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
      userTaskTypeId: json['user_task_type_id'],
      userId: json['user_id'],
      userDetailsName: json['User_Details_Name'],
      taskTypeId: json['task_type_id'] ?? json['Task_Type_Id'],
      taskTypeName: json['Task_Type_Name'],
      isview: json['isview'] ?? 0,
      deleteStatus: json['deletestatus'],
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
