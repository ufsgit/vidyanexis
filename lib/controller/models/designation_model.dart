class DesignationModel {
  final int designationId;
  final String designationName;
  final List<DesignationTaskType> taskTypes;

  DesignationModel({
    required this.designationId,
    required this.designationName,
    this.taskTypes = const [],
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      designationId: json['Designation_Id'] ?? json['designation_id'] ?? 0,
      designationName: json['Designation_Name'] ?? json['designation_name'] ?? '',
      taskTypes: (json['Task_Types'] as List<dynamic>?)
              ?.map((e) => DesignationTaskType.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'Designation_Id': designationId,
        'Designation_Name': designationName,
        'Task_Types': taskTypes.map((e) => e.toJson()).toList(),
      };
}

class DesignationTaskType {
  final int taskTypeId;
  final String taskTypeName;
  final int dailyCount;
  final int monthlyCount;

  DesignationTaskType({
    required this.taskTypeId,
    required this.taskTypeName,
    this.dailyCount = 0,
    this.monthlyCount = 0,
  });

  factory DesignationTaskType.fromJson(Map<String, dynamic> json) {
    return DesignationTaskType(
      taskTypeId: json['Task_Type_Id'] ?? json['task_type_id'] ?? 0,
      taskTypeName: json['Task_Type_Name'] ?? json['task_type_name'] ?? '',
      dailyCount: json['Daily_Count'] ?? json['daily_count'] ?? 0,
      monthlyCount: json['Monthly_Count'] ?? json['monthly_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Task_Type_Id': taskTypeId,
        'Task_Type_Name': taskTypeName,
        'Daily_Count': dailyCount,
        'Monthly_Count': monthlyCount,
      };
}