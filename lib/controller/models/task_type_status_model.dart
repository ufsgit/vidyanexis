// To parse this JSON data, do
//
//     final taskTypeStatusModel = taskTypeStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';

TaskTypeStatusModel taskTypeStatusModelFromJson(String str) =>
    TaskTypeStatusModel.fromJson(json.decode(str));

String taskTypeStatusModelToJson(TaskTypeStatusModel data) =>
    json.encode(data.toJson());

class TaskTypeStatusModel {
  int? statusId;
  String? statusName;
  int? statusOrder;
  int? followup;
  dynamic isRegistered;
  Color? colorCode;
  int? taskTypeId;
  int? enquiryForId; // Added field
  int? isTime;
  List<SubStatus>? subStatuses;
  int? viewDateFollowup;

  TaskTypeStatusModel({
    this.statusId,
    this.statusName,
    this.statusOrder,
    this.followup,
    this.isRegistered,
    this.colorCode,
    this.taskTypeId,
    this.enquiryForId, // Added parameter
    this.isTime,
    this.subStatuses,
    this.viewDateFollowup,
  });

  TaskTypeStatusModel copyWith({
    int? statusId,
    String? statusName,
    int? statusOrder,
    int? followup,
    dynamic isRegistered,
    Color? colorCode,
    int? taskTypeId,
    int? enquiryForId, // Added parameter
    int? isTime,
    List<SubStatus>? subStatuses,
    int? viewDateFollowup,
  }) =>
      TaskTypeStatusModel(
        statusId: statusId ?? this.statusId,
        statusName: statusName ?? this.statusName,
        statusOrder: statusOrder ?? this.statusOrder,
        followup: followup ?? this.followup,
        isRegistered: isRegistered ?? this.isRegistered,
        colorCode: colorCode ?? this.colorCode,
        taskTypeId: taskTypeId ?? this.taskTypeId,
        enquiryForId: enquiryForId ?? this.enquiryForId, // Added assignment
        isTime: isTime ?? this.isTime,
        subStatuses: subStatuses ?? this.subStatuses,
        viewDateFollowup: viewDateFollowup ?? this.viewDateFollowup,
      );

  factory TaskTypeStatusModel.fromJson(Map<String, dynamic> json) =>
      TaskTypeStatusModel(
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        statusOrder: json["Status_Order"],
        followup: json["Followup"],
        isRegistered: json["registered"] ?? json["Is_Registered"],
        colorCode: json["Color_Code"] == null
            ? Colors.black
            : AppColors.parseColor(json["Color_Code"]),
        taskTypeId: json["Task_Type_Id"],
        enquiryForId: json["Enquiry_For_Id"], // Added field mapping
        isTime: json["Is_Time"]?.toInt(),
        subStatuses: (json["Sub_Statuses"] ??
                    json["sub_statuses"] ??
                    json["Sub_Status"]) ==
                null
            ? []
            : List<SubStatus>.from((json["Sub_Statuses"] ??
                    json["sub_statuses"] ??
                    json["Sub_Status"])!
                .map((x) => SubStatus.fromJson(x))),
        viewDateFollowup: json["view_date_followup"]?.toInt() ??
            json["View_Date_Followup"]?.toInt(),
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "Followup": followup,
        "registered": isRegistered,
        "Color_Code": colorCode,
        "Enquiry_For_Id": enquiryForId, // Added field to JSON map
        "Is_Time": isTime,
        "Sub_Statuses": subStatuses == null
            ? []
            : List<dynamic>.from(subStatuses!.map((x) => x.toJson())),
        "View_Date_Followup": viewDateFollowup,
      };
}
