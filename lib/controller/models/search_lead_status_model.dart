// To parse this JSON data, do
//
//     final searchLeadStatusModel = searchLeadStatusModelFromJson(jsonString);

import 'dart:convert';

import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';

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
  String? whatsappTemplateId;
  List<SubStatus>? subStatuses;
  List<SubStatus>? transferStatuses;
  int? isTransfer;
  int? isTime;
  int? isTransferStatus;
  int? isSendUser;
  String? templateId;
  int? isLinkForm;
  int? formId;
  String? formName;

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
    this.whatsappTemplateId,
    this.subStatuses,
    this.transferStatuses,
    this.isTransfer,
    this.isTime,
    this.isTransferStatus,
    this.isSendUser,
    this.templateId,
    this.isLinkForm,
    this.formId,
    this.formName,
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
    String? whatsappTemplateId,
    List<SubStatus>? subStatuses,
    List<SubStatus>? transferStatuses,
    int? isTransfer,
    int? isTime,
    int? isTransferStatus,
    int? isSendUser,
    String? templateId,
    int? isLinkForm,
    int? formId,
    String? formName,
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
        whatsappTemplateId: whatsappTemplateId ?? this.whatsappTemplateId,
        subStatuses: subStatuses ?? this.subStatuses,
        transferStatuses: transferStatuses ?? this.transferStatuses,
        isTransfer: isTransfer ?? this.isTransfer,
        isTime: isTime ?? this.isTime,
        isTransferStatus: isTransferStatus ?? this.isTransferStatus,
        isSendUser: isSendUser ?? this.isSendUser,
        templateId: templateId ?? this.templateId,
        isLinkForm: isLinkForm ?? this.isLinkForm,
        formId: formId ?? this.formId,
        formName: formName ?? this.formName,
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
        whatsappTemplateId: json["Whatsapp_Template_Id"]?.toString() ??
            json["whatsapp_template_id"]?.toString() ??
            json["WhatsApp_Template_Id"]?.toString(),
        subStatuses: json["Sub_Status"] == null
            ? []
            : List<SubStatus>.from(
                json["Sub_Status"]!.map((x) => SubStatus.fromJson(x))),
        transferStatuses: json["Transfer_Status"] == null
            ? []
            : List<SubStatus>.from(
                json["Transfer_Status"]!.map((x) => SubStatus.fromJson(x))),
        isTransfer: json["Is_transfer"]?.toInt() ?? 0,
        isTime: json["Is_Time"]?.toInt() ?? 0,
        isTransferStatus: json["Is_Transfer_Status"]?.toInt() ?? 0,
        isSendUser: json["Is_Send_User"]?.toInt() ?? json["is_send_user"]?.toInt() ?? json["Is_Sent_User"]?.toInt() ?? json["is_sent_user"]?.toInt() ?? 0,
        templateId: json["Template_Id"]?.toString() ?? json["template_id"]?.toString() ?? "",
        isLinkForm: json["Is_Link_Form"]?.toInt() ?? json["is_link_form"]?.toInt() ?? 0,
        formId: json["Form_Id"]?.toInt() ?? json["form_id"]?.toInt() ?? 0,
        formName: json["Form_Name"]?.toString() ?? json["form_name"]?.toString() ?? "",
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
        "Whatsapp_Template_Id": whatsappTemplateId,
        "sub_statuses": subStatuses == null
            ? []
            : List<dynamic>.from(subStatuses!.map((x) => x.toJson())),
        "transfer_statuses": transferStatuses == null
            ? []
            : List<dynamic>.from(transferStatuses!.map((x) => x.toJson())),
        "Is_transfer": isTransfer,
        "Is_Time": isTime,
        "Is_Transfer_Status": isTransferStatus,
        "Is_Send_User": isSendUser,
        "Template_Id": templateId,
        "Is_Link_Form": isLinkForm,
        "Form_Id": formId,
        "Form_Name": formName,
      };
}
