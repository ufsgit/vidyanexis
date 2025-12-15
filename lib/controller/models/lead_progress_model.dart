// To parse this JSON data, do
//
//     final leadProgressReportModel = leadProgressReportModelFromJson(jsonString);

import 'dart:convert';

List<LeadProgressReportModel> leadProgressReportModelFromJson(String str) =>
    List<LeadProgressReportModel>.from(
        json.decode(str).map((x) => LeadProgressReportModel.fromJson(x)));

String leadProgressReportModelToJson(List<LeadProgressReportModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeadProgressReportModel {
  String? statusName;
  String? colorCode;
  String percentage;
  int count;
  int statusId;

  LeadProgressReportModel({
    required this.statusName,
    required this.colorCode,
    required this.percentage,
    required this.count,
    required this.statusId,
  });

  factory LeadProgressReportModel.fromJson(Map<String, dynamic> json) =>
      LeadProgressReportModel(
        statusName: json["Status_Name"],
        colorCode: json["Color_Code"],
        percentage: json["Percentage"],
        count: int.tryParse(json["Count"]?.toString() ?? "0") ?? 0,
        statusId: int.tryParse(json["Status_Id"]?.toString() ?? "0") ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Status_Name": statusName,
        "Color_Code": colorCode,
        "Percentage": percentage,
        "Count": count,
        "Status_Id": statusId,
      };
}
