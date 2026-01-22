// To parse this JSON data, do
//
//     final followUpStatusModel = followUpStatusModelFromJson(jsonString);

import 'dart:convert';

List<FollowUpStatusModel> followUpStatusModelFromJson(String str) =>
    List<FollowUpStatusModel>.from(
        json.decode(str).map((x) => FollowUpStatusModel.fromJson(x)));

String followUpStatusModelToJson(List<FollowUpStatusModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FollowUpStatusModel {
  int? statusId;
  String? statusName;
  int? statusOrder;
  int? followup;
  dynamic isRegistered;
  String? colorCode;

  FollowUpStatusModel({
    this.statusId,
    this.statusName,
    this.statusOrder,
    this.followup,
    this.isRegistered,
    this.colorCode,
  });

  factory FollowUpStatusModel.fromJson(Map<String, dynamic> json) =>
      FollowUpStatusModel(
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        statusOrder: json["Status_Order"],
        followup: json["Followup"],
        isRegistered: json["Is_Registered"] ?? json["registered"],
        colorCode: json["Color_Code"],
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "Followup": followup,
        "registered": isRegistered,
        "Color_Code": colorCode,
      };
}
