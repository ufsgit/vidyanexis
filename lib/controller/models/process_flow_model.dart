// To parse this JSON data, do
//
//     final processFlowModel = processFlowModelFromJson(jsonString);

import 'dart:convert';

ProcessFlowModel processFlowModelFromJson(String str) =>
    ProcessFlowModel.fromJson(json.decode(str));

String processFlowModelToJson(ProcessFlowModel data) =>
    json.encode(data.toJson());

class ProcessFlowModel {
  int? flowId;
  int? taskTypeId;
  String? taskTypeName;
  int? statusId;
  String? statusName;
  int? enquiryForId;
  String? enquiryForName;

  ProcessFlowModel({
    this.flowId,
    this.taskTypeId,
    this.taskTypeName,
    this.statusId,
    this.statusName,
    this.enquiryForId,
    this.enquiryForName,
  });

  ProcessFlowModel copyWith({
    int? flowId,
    int? taskTypeId,
    String? taskTypeName,
    int? statusId,
    String? statusName,
    int? enquiryForId,
    String? enquiryForName,
  }) =>
      ProcessFlowModel(
        flowId: flowId ?? this.flowId,
        taskTypeId: taskTypeId ?? this.taskTypeId,
        taskTypeName: taskTypeName ?? this.taskTypeName,
        statusId: statusId ?? this.statusId,
        statusName: statusName ?? this.statusName,
        enquiryForId: enquiryForId ?? this.enquiryForId,
        enquiryForName: enquiryForName ?? this.enquiryForName,
      );

  factory ProcessFlowModel.fromJson(Map<String, dynamic> json) =>
      ProcessFlowModel(
        flowId: json["flow_id"],
        taskTypeId: json["task_type_id"],
        taskTypeName: json["Task_Type_Name"],
        statusId: json["status_id"],
        statusName: json["status_name"],
        enquiryForId: json["enquiry_for_id"],
        enquiryForName: json["enquiry_for_name"],
      );

  Map<String, dynamic> toJson() => {
        "flow_id": flowId,
        "task_type_id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "status_id": statusId,
        "status_name": statusName,
        "enquiry_for_id": enquiryForId,
        "enquiry_for_name": enquiryForName,
      };
}
