class MandatoryStatusModel {
  final int taskTypeId;
  final String taskTypeName;
  final String requiredStatuses;
  final String requiredStatusesId;

  MandatoryStatusModel({
    required this.taskTypeId,
    required this.taskTypeName,
    required this.requiredStatuses,
    required this.requiredStatusesId,
  });

  /// Factory method to create a MandatoryStatusModel object from JSON
  factory MandatoryStatusModel.fromJson(Map<String, dynamic> json) {
    return MandatoryStatusModel(
      taskTypeId: json['task_type_id'] ?? 0,
      taskTypeName: json['Task_Type_Name'] ?? '',
      requiredStatuses: json['Required_Statuses'] ?? '',
      requiredStatusesId: json['Required_Statuses_Id']?.toString() ?? '',
    );
  }

  /// Method to convert MandatoryStatusModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'task_type_id': taskTypeId,
      'Task_Type_Name': taskTypeName,
      'Required_Statuses': requiredStatuses,
      'Required_Statuses_Id': requiredStatusesId,
    };
  }
}
