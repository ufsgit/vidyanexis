// To parse this JSON data, do
//
//     final workSummaryReportModel = workSummaryReportModelFromJson(jsonString);

import 'dart:convert';

List<List<WorkSummaryReportModel>> workSummaryReportModelFromJson(String str) => List<List<WorkSummaryReportModel>>.from(json.decode(str).map((x) => List<WorkSummaryReportModel>.from(x.map((x) => WorkSummaryReportModel.fromJson(x)))));

String workSummaryReportModelToJson(List<List<WorkSummaryReportModel>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))));

class WorkSummaryReportModel {
    String? taskStatusName;
    String? percentage;
    int? customerCount;

    WorkSummaryReportModel({
        this.taskStatusName,
        this.percentage,
        this.customerCount,
    });

    factory WorkSummaryReportModel.fromJson(Map<String, dynamic> json) => WorkSummaryReportModel(
        taskStatusName: json["Task_Status_Name"],
        percentage: json["Percentage"],
        customerCount: json["Customer_Count"],
    );

    Map<String, dynamic> toJson() => {
        "Task_Status_Name": taskStatusName,
        "Percentage": percentage,
        "Customer_Count": customerCount,
    };
}
