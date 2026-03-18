// To parse this JSON data, do
//
//     final taskTypeModel = taskTypeModelFromJson(jsonString);

import 'dart:convert';

List<TaskTypeModel> taskTypeModelFromJson(String str) =>
    List<TaskTypeModel>.from(
        json.decode(str).map((x) => TaskTypeModel.fromJson(x)));

String taskTypeModelToJson(List<TaskTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskTypeModel {
  int taskTypeId;
  String taskTypeName;
  String taskTypeColor;
  String taskTypeImage;
  int deleteStatus;
  dynamic departmentIds;
  dynamic branchIds;
  int defaultStatusId;
  int duration;
  int conversionTask;
  int locationTracking;

  String? departmentName;
  List<Status> statuses;

  TaskTypeModel(
      {required this.taskTypeId,
      required this.taskTypeName,
      required this.taskTypeColor,
      required this.taskTypeImage,
      required this.deleteStatus,
      required this.departmentIds,
      required this.branchIds,
      required this.defaultStatusId,
      required this.duration,
      required this.conversionTask,
      required this.locationTracking,
      required this.statuses,
      required this.departmentName});

  factory TaskTypeModel.fromJson(Map<String, dynamic> json) => TaskTypeModel(
      taskTypeId: json["Task_Type_Id"] ?? 0,
      taskTypeName: json["Task_Type_Name"] ?? '',
      taskTypeColor: json["Task_Type_Color"] ?? '',
      taskTypeImage: json["Task_Type_Image"] ?? '',
      deleteStatus: json["DeleteStatus"] ?? 0,
      departmentIds: json["Department_Ids"] ?? '',
      branchIds: json["Branch_Ids"] ?? '',
      defaultStatusId: json["default_status_id"] ?? 0,
      duration: json["Duration"] ?? 0,
      conversionTask: json["Is_Active"] ?? 0,
      locationTracking: json["Location_Tracking"] ?? 0,
      statuses: json["Statuses"] == null
          ? []
          : List<Status>.from(json["Statuses"].map((x) => Status.fromJson(x))),
      departmentName: json["Department_Name"]);

  Map<String, dynamic> toJson() => {
        "Task_Type_Id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "Task_Type_Color": taskTypeColor,
        "Task_Type_Image": taskTypeImage,
        "DeleteStatus": deleteStatus,
        "Department_Ids": departmentIds,
        "Branch_Ids": branchIds,
        "default_status_id": defaultStatusId,
        "Duration": duration,
        "Statuses": List<dynamic>.from(statuses.map((x) => x.toJson())),
        "Department_Name": departmentName,
      };
}

class Status {
  int statusId;

  Status({
    required this.statusId,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        statusId: json["Status_Id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
      };
}
