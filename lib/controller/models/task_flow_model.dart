// To parse this JSON data, do
//
//     final taskFlowModel = taskFlowModelFromJson(jsonString);

import 'dart:convert';

TaskFlowModel taskFlowModelFromJson(String str) =>
    TaskFlowModel.fromJson(json.decode(str));

String taskFlowModelToJson(TaskFlowModel data) => json.encode(data.toJson());

class TaskFlowModel {
  int? branchId;
  int? departmentId;
  int? taskTypeId;

  TaskFlowModel({
    this.branchId,
    this.departmentId,
    this.taskTypeId,
  });

  TaskFlowModel copyWith({
    int? branchId,
    int? departmentId,
    int? taskTypeId,
  }) =>
      TaskFlowModel(
        branchId: branchId ?? this.branchId,
        departmentId: departmentId ?? this.departmentId,
        taskTypeId: taskTypeId ?? this.taskTypeId,
      );

  factory TaskFlowModel.fromJson(Map<String, dynamic> json) => TaskFlowModel(
        branchId: json["branch_id"],
        departmentId: json["department_id"],
        taskTypeId: json["task_type_id"],
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "department_id": departmentId,
        "task_type_id": taskTypeId,
      };
}

class MandatoryTaskModel {
  List<String>? statusIds;
  int? taskTypeId;

  MandatoryTaskModel({
    this.statusIds,
    this.taskTypeId,
  });

  MandatoryTaskModel copyWith({
    List<String>? statusIds,
    int? taskTypeId,
  }) =>
      MandatoryTaskModel(
        statusIds: statusIds ?? this.statusIds,
        taskTypeId: taskTypeId ?? this.taskTypeId,
      );

  factory MandatoryTaskModel.fromJson(Map<String, dynamic> json) =>
      MandatoryTaskModel(
        statusIds:
            (json["status_id"] as List?)?.map((e) => e.toString()).toList(),
        taskTypeId: json["task_type_id"],
      );

  Map<String, dynamic> toJson() => {
        "status_id": statusIds,
        "task_type_id": taskTypeId,
      };
}
