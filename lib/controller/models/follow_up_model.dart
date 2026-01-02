// To parse this JSON data, do
//
//     final followupStatusModel = followupStatusModelFromJson(jsonString);

import 'dart:convert';

List<FollowupStatusModel> followupStatusModelFromJson(String str) =>
    List<FollowupStatusModel>.from(
        json.decode(str).map((x) => FollowupStatusModel.fromJson(x)));

String followupStatusModelToJson(List<FollowupStatusModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FollowupStatusModel {
  int? statusId;
  String? statusName;
  int? statusOrder;
  String? viewInName;
  int? viewInId;
  int? followup;
  int? isRegistered;
  int? stageId;
  String? stageName;
  int? progressValue;
  String? colorCode;
  List<CustomField>? customFields;

  FollowupStatusModel({
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

  FollowupStatusModel copyWith({
    int? statusId,
    String? statusName,
    int? statusOrder,
    String? viewInName,
    int? viewInId,
    int? followup,
    int? isRegistered,
    int? stageId,
    String? stageName,
    int? progressValue,
    String? colorCode,
    List<CustomField>? customFields,
  }) =>
      FollowupStatusModel(
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

  factory FollowupStatusModel.fromJson(Map<String, dynamic> json) =>
      FollowupStatusModel(
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        statusOrder: json["Status_Order"],
        viewInName: json["ViewIn_Name"],
        viewInId: json["ViewIn_Id"],
        followup: json["Followup"],
        isRegistered: json["Is_Registered"],
        stageId: json["Stage_Id"],
        stageName: json["Stage_Name"],
        progressValue: json["Progress_Value"],
        colorCode: json["Color_Code"],
        customFields: json["custom_fields"] == null
            ? []
            : List<CustomField>.from(
                json["custom_fields"]!.map((x) => CustomField.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "ViewIn_Name": viewInName,
        "ViewIn_Id": viewInId,
        "Followup": followup,
        "Is_Registered": isRegistered,
        "Stage_Id": stageId,
        "Stage_Name": stageName,
        "Progress_Value": progressValue,
        "Color_Code": colorCode,
        "custom_fields": customFields == null
            ? []
            : List<dynamic>.from(customFields!.map((x) => x.toJson())),
      };
}

class CustomField {
  int? isMandatory;
  int? customFieldId;
  String? customFieldName;
  String? missingMandatoryCount;

  CustomField({
    this.isMandatory,
    this.customFieldId,
    this.customFieldName,
    this.missingMandatoryCount,
  });

  CustomField copyWith({
    int? isMandatory,
    int? customFieldId,
    String? customFieldName,
    String? missingMandatoryCount,
  }) =>
      CustomField(
        isMandatory: isMandatory ?? this.isMandatory,
        customFieldId: customFieldId ?? this.customFieldId,
        customFieldName: customFieldName ?? this.customFieldName,
        missingMandatoryCount:
            missingMandatoryCount ?? this.missingMandatoryCount,
      );

  factory CustomField.fromJson(Map<String, dynamic> json) => CustomField(
        isMandatory: json["isMandatory"],
        customFieldId: json["custom_field_id"],
        customFieldName: json["custom_field_name"],
        missingMandatoryCount: json["missing_mandatory_document_count"],
      );

  Map<String, dynamic> toJson() => {
        "isMandatory": isMandatory,
        "custom_field_id": customFieldId,
        "custom_field_name": customFieldName,
        "missing_mandatory_document_count": missingMandatoryCount,
      };
}
