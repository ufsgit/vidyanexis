// To parse this JSON data, do
//
//     final addTaskModel = addTaskModelFromJson(jsonString);

import 'dart:convert';

import 'package:techtify/controller/models/task_customer_model.dart';

AddTaskModel addTaskModelFromJson(String str) =>
    AddTaskModel.fromJson(json.decode(str));

String addTaskModelToJson(AddTaskModel data) => json.encode(data.toJson());

class AddTaskModel {
  int? taskMasterId;
  int? taskStatusId;
  String? taskStatusName;
  List<UserInTaskModel>? taskUser;
  int? customerId;
  int? createdBy;
  DateTime? taskDate;
  int? taskTypeId;
  String? taskTypeName;
  String? description;
  String? taskTime;
  String? completionDate;
  List<TaskFile>? taskFiles; // Add this field

  String? completionTime;

  AddTaskModel({
    this.taskMasterId,
    this.taskStatusId,
    this.taskStatusName,
    this.taskUser,
    this.customerId,
    this.createdBy,
    this.taskDate,
    this.taskTypeId,
    this.taskTypeName,
    this.description,
    this.taskTime,
    this.completionDate,
    this.completionTime,
    this.taskFiles, // Add this to constructor
  });

  AddTaskModel copyWith({
    int? taskMasterId,
    int? taskStatusId,
    String? taskStatusName,
    List<UserInTaskModel>? taskUser,
    int? customerId,
    int? createdBy,
    DateTime? taskDate,
    int? taskTypeId,
    String? taskTypeName,
    String? description,
    String? taskTime,
    String? completionDate,
    String? completionTime,
    List<TaskFile>? taskFiles, // Add this field
  }) =>
      AddTaskModel(
        taskMasterId: taskMasterId ?? this.taskMasterId,
        taskStatusId: taskStatusId ?? this.taskStatusId,
        taskStatusName: taskStatusName ?? this.taskStatusName,
        taskUser: taskUser ?? this.taskUser,
        customerId: customerId ?? this.customerId,
        createdBy: createdBy ?? this.createdBy,
        taskDate: taskDate ?? this.taskDate,
        taskTypeId: taskTypeId ?? this.taskTypeId,
        taskTypeName: taskTypeName ?? this.taskTypeName,
        description: description ?? this.description,
        taskTime: taskTime ?? this.taskTime,
        completionDate: completionDate ?? this.completionDate,
        completionTime: completionTime ?? this.completionTime,
        taskFiles: taskFiles ?? this.taskFiles,
      );

  factory AddTaskModel.fromJson(Map<String, dynamic> json) => AddTaskModel(
        taskMasterId: json["Task_Master_Id"],
        taskStatusId: json["Task_Status_Id"],
        taskStatusName: json["Task_Status_Name"],
        taskUser: List<UserInTaskModel>.from(
            json["Task_user"].map((x) => UserInTaskModel.fromJson(x))),
        customerId: json["Customer_Id"],
        createdBy: json["Created_By"],
        taskDate: DateTime.parse(json["Task_Date"]),
        taskTypeId: json["Task_Type_Id"],
        taskTypeName: json["Task_Type_Name"],
        description: json["Description"],
        taskTime: json["Task_Time"],
        completionDate: json["Completion_Date"],
        completionTime: json["Completion_Time"],
      );

  Map<String, dynamic> toJson() => {
        "Task_Master_Id": taskMasterId,
        "Task_Status_Id": taskStatusId,
        "Task_Status_Name": taskStatusName,
        "Task_user": List<dynamic>.from(taskUser!.map((x) => x.toJson())),
        "Customer_Id": customerId,
        "Created_By": createdBy,
        "Task_Date":
            "${taskDate!.year.toString().padLeft(4, '0')}-${taskDate!.month.toString().padLeft(2, '0')}-${taskDate!.day.toString().padLeft(2, '0')}",
        "Task_Type_Id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "Description": description,
        "Task_Time": taskTime,
        "Completion_Date": completionDate,
        "Completion_Time": completionTime,
        "Task_Files": taskFiles != null
            ? List<dynamic>.from(taskFiles!.map((x) => x.toJson()))
            : [], // Add this to JSON
      };
}

class UserInTaskModel {
  int? userDetailsId;
  String? userDetailsName;

  UserInTaskModel({
    this.userDetailsId,
    this.userDetailsName,
  });

  UserInTaskModel copyWith({
    int? userDetailsId,
  }) =>
      UserInTaskModel(
        userDetailsId: userDetailsId ?? this.userDetailsId,
      );

  factory UserInTaskModel.fromJson(Map<String, dynamic> json) =>
      UserInTaskModel(
        userDetailsId: json["User_Details_Id"],
        userDetailsName: json["User_Details_Name"],
      );

  Map<String, dynamic> toJson() => {
        "User_Details_Id": userDetailsId,
        "User_Details_Name": userDetailsName,
      };
}

class TaskFileModel {
  String? filePath;
  String? fileName;
  String? fileType;

  TaskFileModel({
    this.filePath,
    this.fileName,
    this.fileType,
  });

  Map<String, dynamic> toJson() => {
        "File_Path": filePath,
        "File_Name": fileName,
        "File_Type": fileType,
      };
}
