import 'dart:convert';

List<TaskTypeSummaryModel> taskCountSummaryModelFromJson(String str) =>
    List<TaskTypeSummaryModel>.from(
        json.decode(str).map((x) => TaskTypeSummaryModel.fromJson(x)));

String taskCountSummaryModelToJson(List<TaskTypeSummaryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskTypeSummaryModel {
  final int? taskTypeId;
  final String taskTypeName;
  List<StatusCountModel> statusCounts;

  TaskTypeSummaryModel({
    this.taskTypeId,
    required this.taskTypeName,
    required this.statusCounts,
  });

  int get totalCount =>
      statusCounts.fold(0, (sum, item) => sum + item.count);

  factory TaskTypeSummaryModel.fromJson(Map<String, dynamic> json) {
    List<StatusCountModel> statuses = [];
    final rawStatuses = json['Status_Counts'] ?? json['status_counts'];

    if (rawStatuses is List) {
      statuses = rawStatuses
          .whereType<Map<String, dynamic>>()
          .map((e) => StatusCountModel.fromJson(e))
          .toList();
    } else if (json.containsKey('Status_Name')) {
      // Fallback for flat structure
      statuses.add(StatusCountModel.fromJson(json));
    }

    return TaskTypeSummaryModel(
      taskTypeId: json['Task_Type_Id'] is int
          ? json['Task_Type_Id']
          : int.tryParse(json['Task_Type_Id']?.toString() ?? ''),
      taskTypeName: (json['Task_Type_Name'] ?? '').toString(),
      statusCounts: statuses,
    );
  }

  Map<String, dynamic> toJson() => {
        'Task_Type_Id': taskTypeId,
        'Task_Type_Name': taskTypeName,
        'Status_Counts': statusCounts.map((x) => x.toJson()).toList(),
      };
}

class StatusCountModel {
  final int? taskStatusId;
  final String statusName;
  final int count;

  StatusCountModel({
    this.taskStatusId,
    required this.statusName,
    required this.count,
  });

  factory StatusCountModel.fromJson(Map<String, dynamic> json) {
    return StatusCountModel(
      taskStatusId: json['Task_Status_Id'] is int
          ? json['Task_Status_Id']
          : int.tryParse(json['Task_Status_Id']?.toString() ?? ''),
      statusName: (json['Status_Name'] ?? '').toString(),
      count: json['Count'] is int
          ? json['Count']
          : int.tryParse(json['Count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'Task_Status_Id': taskStatusId,
        'Status_Name': statusName,
        'Count': count,
      };
}

// Alias for backward compatibility
typedef TaskCountSummaryModel = TaskTypeSummaryModel;
