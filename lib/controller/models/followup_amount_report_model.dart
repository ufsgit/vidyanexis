import 'dart:convert';

List<FollowupAmountReportModel> followupAmountReportModelFromJson(String str) =>
    List<FollowupAmountReportModel>.from(
        json.decode(str).map((x) => FollowupAmountReportModel.fromJson(x)));

String followupAmountReportModelToJson(List<FollowupAmountReportModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FollowupAmountReportModel {
  final String nextFollowUpDate;
  final String customerName;
  final String leadCreationDate;
  final String registeredDate;
  final String statusName;
  final String amount;
  final String toUserName;

  FollowupAmountReportModel({
    required this.nextFollowUpDate,
    required this.customerName,
    required this.leadCreationDate,
    required this.registeredDate,
    required this.statusName,
    required this.amount,
    required this.toUserName,
  });

  factory FollowupAmountReportModel.fromJson(Map<String, dynamic> json) =>
      FollowupAmountReportModel(
        nextFollowUpDate: json["Next_FollowUp_date"]?.toString() ?? '',
        customerName: json["Customer_Name"]?.toString() ?? '',
        leadCreationDate: json["Lead_Creation_Date"]?.toString() ?? '',
        registeredDate: json["Registered_Date"]?.toString() ?? '',
        statusName: json["Status_Name"]?.toString() ?? '',
        amount: json["Amount"]?.toString() ?? '0.00',
        toUserName: json["To_User_Name"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Next_FollowUp_date": nextFollowUpDate,
        "Customer_Name": customerName,
        "Lead_Creation_Date": leadCreationDate,
        "Registered_Date": registeredDate,
        "Status_Name": statusName,
        "Amount": amount,
        "To_User_Name": toUserName,
      };
}
