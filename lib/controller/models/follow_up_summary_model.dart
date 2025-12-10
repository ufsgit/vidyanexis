// To parse this JSON data, do
//
//     final followUpSummaryModel = followUpSummaryModelFromJson(jsonString);

import 'dart:convert';

List<FollowUpSummaryModel> followUpSummaryModelFromJson(String str) => List<FollowUpSummaryModel>.from(json.decode(str).map((x) => FollowUpSummaryModel.fromJson(x)));

String followUpSummaryModelToJson(List<FollowUpSummaryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FollowUpSummaryModel {
    String? toUserName;
    int total;
    String completed;
    String pending;
    String performanceRate;
    int? toUserId;

    FollowUpSummaryModel({
        required this.toUserName,
        required this.total,
        required this.completed,
        required this.pending,
        required this.performanceRate,
        required this.toUserId,
    });

    factory FollowUpSummaryModel.fromJson(Map<String, dynamic> json) => FollowUpSummaryModel(
        toUserName: json["To_User_Name"],
        total: json["Total"],
        completed: json["Completed"],
        pending: json["Pending"],
        performanceRate: json["Performance_Rate"],
        toUserId: json["To_User_Id"],
    );

    Map<String, dynamic> toJson() => {
        "To_User_Name": toUserName,
        "Total": total,
        "Completed": completed,
        "Pending": pending,
        "Performance_Rate": performanceRate,
        "To_User_Id": toUserId,
    };
}
