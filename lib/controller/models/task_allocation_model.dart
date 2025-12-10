// To parse this JSON data, do
//
//     final taskAllocationSummaryModel = taskAllocationSummaryModelFromJson(jsonString);

import 'dart:convert';

List<TaskAllocationSummaryModel> taskAllocationSummaryModelFromJson(String str) => List<TaskAllocationSummaryModel>.from(json.decode(str).map((x) => TaskAllocationSummaryModel.fromJson(x)));

String taskAllocationSummaryModelToJson(List<TaskAllocationSummaryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskAllocationSummaryModel {
    int toUserId;
    String userDetailsName;
    String totalTasks;
    StatusBreakdown statusBreakdown;

    TaskAllocationSummaryModel({
        required this.toUserId,
        required this.userDetailsName,
        required this.totalTasks,
        required this.statusBreakdown,
    });

    factory TaskAllocationSummaryModel.fromJson(Map<String, dynamic> json) => TaskAllocationSummaryModel(
        toUserId: json["To_User_Id"],
        userDetailsName: json["User_Details_Name"],
        totalTasks: json["Total_Tasks"],
        statusBreakdown: StatusBreakdown.fromJson(json["Status_Breakdown"]),
    );

    Map<String, dynamic> toJson() => {
        "To_User_Id": toUserId,
        "User_Details_Name": userDetailsName,
        "Total_Tasks": totalTasks,
        "Status_Breakdown": statusBreakdown.toJson(),
    };
}

class StatusBreakdown {
    int? completed;
    int? inProgress;
    int notStarted;

    StatusBreakdown({
        this.completed,
        this.inProgress,
        required this.notStarted,
    });

    factory StatusBreakdown.fromJson(Map<String, dynamic> json) => StatusBreakdown(
        completed: json["Completed"]??0,
        inProgress: json["In Progress"]??0,
        notStarted: json["Not Started"]??0,
    );

    Map<String, dynamic> toJson() => {
        "Completed": completed,
        "In Progress": inProgress,
        "Not Started": notStarted,
    };
}

List<TaskAllocationStatusModel> taskAllocationStatusModelFromJson(String str) => List<TaskAllocationStatusModel>.from(json.decode(str).map((x) => TaskAllocationStatusModel.fromJson(x)));

String taskAllocationStatusModelToJson(List<TaskAllocationStatusModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskAllocationStatusModel {
    String taskStatusName;
    int count;

    TaskAllocationStatusModel({
        required this.taskStatusName,
        required this.count,
    });

    factory TaskAllocationStatusModel.fromJson(Map<String, dynamic> json) => TaskAllocationStatusModel(
        taskStatusName: json["Task_Status_Name"],
        count: json["Count"],
    );

    Map<String, dynamic> toJson() => {
        "Task_Status_Name": taskStatusName,
        "Count": count,
    };
}
