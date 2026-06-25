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
  String? templateId;
  int? leadStatusId;
  String? leadStatusName;
  int? taskSubStatusId;
  String? taskSubStatusName;
  int? leadSubStatusId;
  String? leadSubStatusName;

  ProcessFlowModel({
    this.flowId,
    this.taskTypeId,
    this.taskTypeName,
    this.statusId,
    this.statusName,
    this.enquiryForId,
    this.enquiryForName,
    this.templateId,
    this.leadStatusId,
    this.leadStatusName,
    this.taskSubStatusId,
    this.taskSubStatusName,
    this.leadSubStatusId,
    this.leadSubStatusName,
  });

  ProcessFlowModel copyWith({
    int? flowId,
    int? taskTypeId,
    String? taskTypeName,
    int? statusId,
    String? statusName,
    int? enquiryForId,
    String? enquiryForName,
    String? templateId,
    int? leadStatusId,
    String? leadStatusName,
    int? taskSubStatusId,
    String? taskSubStatusName,
    int? leadSubStatusId,
    String? leadSubStatusName,
  }) =>
      ProcessFlowModel(
        flowId: flowId ?? this.flowId,
        taskTypeId: taskTypeId ?? this.taskTypeId,
        taskTypeName: taskTypeName ?? this.taskTypeName,
        statusId: statusId ?? this.statusId,
        statusName: statusName ?? this.statusName,
        enquiryForId: enquiryForId ?? this.enquiryForId,
        enquiryForName: enquiryForName ?? this.enquiryForName,
        templateId: templateId ?? this.templateId,
        leadStatusId: leadStatusId ?? this.leadStatusId,
        leadStatusName: leadStatusName ?? this.leadStatusName,
        taskSubStatusId: taskSubStatusId ?? this.taskSubStatusId,
        taskSubStatusName: taskSubStatusName ?? this.taskSubStatusName,
        leadSubStatusId: leadSubStatusId ?? this.leadSubStatusId,
        leadSubStatusName: leadSubStatusName ?? this.leadSubStatusName,
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
        templateId: json["template_id"],
        leadStatusId: json["lead_status_id"],
        leadStatusName: json["lead_status_name"],
        taskSubStatusId: json["task_sub_status_id"],
        taskSubStatusName: json["task_sub_status_name"],
        leadSubStatusId: json["lead_sub_status_id"],
        leadSubStatusName: json["lead_sub_status_name"],
      );

  Map<String, dynamic> toJson() => {
        "flow_id": flowId,
        "task_type_id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "status_id": statusId,
        "status_name": statusName,
        "enquiry_for_id": enquiryForId,
        "enquiry_for_name": enquiryForName,
        "template_id": templateId,
        "lead_status_id": leadStatusId,
        "lead_status_name": leadStatusName,
        "task_sub_status_id": taskSubStatusId,
        "task_sub_status_name": taskSubStatusName,
        "lead_sub_status_id": leadSubStatusId,
        "lead_sub_status_name": leadSubStatusName,
      };
}
