// To parse this JSON data, do
//
//     final followUpReportModel = followUpReportModelFromJson(jsonString);

import 'dart:convert';

List<FollowUpReportModel> followUpReportModelFromJson(String str) =>
    List<FollowUpReportModel>.from(
        json.decode(str).map((x) => FollowUpReportModel.fromJson(x)));

String followUpReportModelToJson(List<FollowUpReportModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FollowUpReportModel {
  int? customerId;
  String? customerName;
  String? phoneNumber;
  String? nextFollowUpDate;
  String? email;
  int? followUp;
  int? userId;
  String? toUserName;
  int? byUserId;
  String? byUserName;
  String? remark;
  int? status;
  String? statusName;

  FollowUpReportModel({
    this.customerId,
    this.customerName,
    this.phoneNumber,
    this.nextFollowUpDate,
    this.email,
    this.followUp,
    this.userId,
    this.toUserName,
    this.byUserId,
    this.byUserName,
    this.remark,
    this.status,
    this.statusName,
  });

  FollowUpReportModel copyWith({
    int? customerId,
    String? customerName,
    String? phoneNumber,
    String? nextFollowUpDate,
    String? email,
    int? followUp,
    int? userId,
    String? toUserName,
    int? byUserId,
    String? byUserName,
    String? remark,
    int? status,
    String? statusName,
  }) =>
      FollowUpReportModel(
        customerId: customerId ?? this.customerId,
        customerName: customerName ?? this.customerName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        nextFollowUpDate: nextFollowUpDate ?? this.nextFollowUpDate,
        email: email ?? this.email,
        followUp: followUp ?? this.followUp,
        userId: userId ?? this.userId,
        toUserName: toUserName ?? this.toUserName,
        byUserId: byUserId ?? this.byUserId,
        byUserName: byUserName ?? this.byUserName,
        remark: remark ?? this.remark,
        status: status ?? this.status,
        statusName: statusName ?? this.statusName,
      );

  factory FollowUpReportModel.fromJson(Map<String, dynamic> json) =>
      FollowUpReportModel(
        customerId: json["Customer_Id"],
        customerName: json["Customer_Name"],
        phoneNumber: json["Phone_Number"],
        nextFollowUpDate: json["Next_FollowUp_date"],
        email: json["Email"],
        followUp: json["FollowUp"],
        userId: json["User_Id"],
        toUserName: json["To_User_Name"],
        byUserId: json["By_User_Id"],
        byUserName: json["By_User_Name"],
        remark: json["Remark"],
        status: json["Status"],
        statusName: json["Status_Name"],
      );

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone_Number": phoneNumber,
        "Next_FollowUp_date": nextFollowUpDate,
        "Email": email,
        "FollowUp": followUp,
        "User_Id": userId,
        "To_User_Name": toUserName,
        "By_User_Id": byUserId,
        "By_User_Name": byUserName,
        "Remark": remark,
        "Status": status,
        "Status_Name": statusName,
      };
}
