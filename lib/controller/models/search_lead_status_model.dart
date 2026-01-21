// To parse this JSON data, do
//
//     final searchLeadStatusModel = searchLeadStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:vidyanexis/controller/models/custom_field_by_status.dart';

List<SearchLeadStatusModel> searchLeadStatusModelFromJson(String str) =>
    List<SearchLeadStatusModel>.from(
        json.decode(str).map((x) => SearchLeadStatusModel.fromJson(x)));

String searchLeadStatusModelToJson(List<SearchLeadStatusModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchLeadStatusModel {
  int? statusId;
  String? statusName;
  int? statusOrder;
  String? viewInName;
  int? viewInId;
  int? followup;
  dynamic isRegistered;
  int? stageId;
  String? stageName;
  int? progressValue;
  String? colorCode;
  List<CustomFieldByStatusId>? customFields;

  SearchLeadStatusModel({
    this.statusId,
    this.statusName,
    this.statusOrder,
    this.viewInName,
    this.viewInId,
    this.followup,
    this.isRegistered,
    this.stageId,
    this.stageName,
    this.progressValue,
    this.colorCode,
    this.customFields,
  });

  SearchLeadStatusModel copyWith({
    int? statusId,
    String? statusName,
    int? statusOrder,
    String? viewInName,
    int? viewInId,
    int? followup,
    dynamic isRegistered,
    int? stageId,
    String? stageName,
    int? progressValue,
    String? colorCode,
    List<CustomFieldByStatusId>? customFields,
  }) =>
      SearchLeadStatusModel(
        statusId: statusId ?? this.statusId,
        statusName: statusName ?? this.statusName,
        statusOrder: statusOrder ?? this.statusOrder,
        viewInName: viewInName ?? this.viewInName,
        viewInId: viewInId ?? this.viewInId,
        followup: followup ?? this.followup,
        isRegistered: isRegistered ?? this.isRegistered,
        stageId: stageId ?? this.stageId,
        stageName: stageName ?? this.stageName,
        progressValue: progressValue ?? this.progressValue,
        colorCode: colorCode ?? this.colorCode,
        customFields: customFields ?? this.customFields,
      );

  factory SearchLeadStatusModel.fromJson(Map<String, dynamic> json) =>
      SearchLeadStatusModel(
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        statusOrder: json["Status_Order"],
        viewInName: json["ViewIn_Name"],
        viewInId: json["ViewIn_Id"],
        followup: json["Followup"],
        isRegistered: json["Is_Registered"] ?? json["registered"],
        stageId: json["Stage_Id"],
        stageName: json["Stage_Name"],
        progressValue: json["Progress_Value"],
        colorCode: json["Color_Code"],
        customFields: json["custom_fields"] == null
            ? []
            : List<CustomFieldByStatusId>.from(json["custom_fields"]!
                .map((x) => CustomFieldByStatusId.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "ViewIn_Name": viewInName,
        "ViewIn_Id": viewInId,
        "Followup": followup,
        "registered": isRegistered,
        "Stage_Id": stageId,
        "Stage_Name": stageName,
        "Progress_Value": progressValue,
        "Color_Code": colorCode,
        "custom_fields": customFields == null
            ? []
            : List<dynamic>.from(customFields!.map((x) => x.toJson())),
      };
}
