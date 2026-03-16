import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class TaskReportModel {
  final int taskId;
  final int taskMasterId;
  final String description;
  final String entryDate;
  final int taskStatusId;
  final String taskStatusName;
  final int toUserId;
  final int customerId;
  final int enquiryForId;
  final int createdBy;
  final int taskTypeId;
  final String taskTypeName;
  final int locationTracking;

  final String taskDate;
  final String taskTime;
  final String? completionDate;
  final String? completionTime;
  final int deleteStatus;
  final String customerName;
  final String mobile;
  final String toUserName;
  final String address1;
  final String address2;
  final String address3;
  final String address4;
  final Color? colorCode;
  final String taskName;
  final String taskDetail;
  final String userDetailsName;
  final String taskDuration;
  final String taskStartDate;
  final String taskEndDate;
  final bool isRepeating;
  final int userDetailsId;

  TaskReportModel({
    required this.taskId,
    required this.locationTracking,
    required this.taskMasterId,
    required this.description,
    required this.entryDate,
    required this.taskStatusId,
    required this.taskStatusName,
    required this.toUserId,
    required this.customerId,
    required this.enquiryForId,
    required this.createdBy,
    required this.taskTypeId,
    required this.taskTypeName,
    required this.taskDate,
    required this.taskTime,
    this.completionDate,
    this.completionTime,
    required this.deleteStatus,
    required this.customerName,
    required this.mobile,
    required this.toUserName,
    required this.address1,
    required this.address2,
    required this.address3,
    required this.address4,
    this.colorCode,
    required this.taskName,
    required this.taskDetail,
    required this.userDetailsName,
    required this.taskDuration,
    required this.taskStartDate,
    required this.taskEndDate,
    required this.isRepeating,
    required this.userDetailsId,
  });

  factory TaskReportModel.fromJson(Map<String, dynamic> json) {
    return TaskReportModel(
      taskId: json['Task_Id'] ?? 0,
      taskMasterId: json['Task_Master_Id'] ?? 0,
      locationTracking: json["Location_Tracking"] ?? 0,
      description: json['Description'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      taskStatusId: json['Task_Status_Id'] ?? 0,
      taskStatusName: json['Task_Status_Name'] ?? 'Unknown',
      toUserId: json['To_User_Id'] ?? 0,
      customerId: json['Customer_Id'] ?? 0,
      enquiryForId: json['Enquiry_For_Id'] ?? 0,
      createdBy: json['Created_By'] ?? 0,
      taskTypeId: json['Task_Type_Id'] ?? 0,
      taskTypeName: json['Task_Type_Name'] ?? '',
      taskDate: json['Task_Date'] ?? '',
      taskTime: json['Task_Time'] ?? '',
      completionDate: json['Completion_Date'] as String?,
      completionTime: json['Completion_Time'] as String?,
      deleteStatus: json['DeleteStatus'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
      mobile: json['Phone_Number'] ?? json['Contact_Number'] ?? '',
      address1: json['Address1'] ?? '',
      address2: json['Address2'] ?? '',
      address3: json['Address3'] ?? '',
      address4: json['Address4'] ?? '',
      toUserName: json['To_User_Name'] ?? '',
      colorCode: json["Color_Code"] == null
          ? Colors.black
          : AppColors.parseColor(json["Color_Code"]),
      taskName: json['Task_Name'] ?? '',
      taskDetail: json['Task_Detail'] ?? '',
      userDetailsName: json['User_Details_Name'] ?? '',
      taskDuration: json['Task_Duration'] ?? '',
      taskStartDate: json['Task_Start_Date'] ?? '',
      taskEndDate: json['Task_End_Date'] ?? '',
      isRepeating: json['Is_Repeating'] ?? false,
      userDetailsId: json['User_Details_Id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Task_Id': taskId,
      'Task_Master_Id': taskMasterId,
      'Description': description,
      'Entry_Date': entryDate,
      'Task_Status_Id': taskStatusId,
      'Task_Status_Name': taskStatusName,
      'To_User_Id': toUserId,
      'Customer_Id': customerId,
      'Created_By': createdBy,
      'Task_Type_Id': taskTypeId,
      'Task_Type_Name': taskTypeName,
      'Task_Date': taskDate,
      'Task_Time': taskTime,
      'Completion_Date': completionDate,
      'Completion_Time': completionTime,
      'DeleteStatus': deleteStatus,
      'Customer_Name': customerName,
      'Contact_Number': mobile,
      'Address1': address1,
      'Address2': address2,
      'Address3': address3,
      'Address4': address4,
      'To_User_Name': toUserName,
    };
  }
}
