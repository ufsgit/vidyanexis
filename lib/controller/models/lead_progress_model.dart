// To parse this JSON data, do
//
//     final leadProgressReportModel = leadProgressReportModelFromJson(jsonString);

import 'dart:convert';

List<LeadProgressReportModel> leadProgressReportModelFromJson(String str) => List<LeadProgressReportModel>.from(json.decode(str).map((x) => LeadProgressReportModel.fromJson(x)));

String leadProgressReportModelToJson(List<LeadProgressReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LeadProgressReportModel {
    String? statusName;
    String? colorCode;
    String percentage;

    LeadProgressReportModel({
        required this.statusName,
        required this.colorCode,
        required this.percentage,
    });

    factory LeadProgressReportModel.fromJson(Map<String, dynamic> json) => LeadProgressReportModel(
        statusName: json["Status_Name"],
        colorCode: json["Color_Code"],
        percentage: json["Percentage"],
    );

    Map<String, dynamic> toJson() => {
        "Status_Name": statusName,
        "Color_Code": colorCode,
        "Percentage": percentage,
    };
}
