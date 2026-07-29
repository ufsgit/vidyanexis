// To parse this JSON data, do
//
//     final taskTypeModel = taskTypeModelFromJson(jsonString);

import 'dart:convert';

List<TaskTypeModel> taskTypeModelFromJson(String str) =>
    List<TaskTypeModel>.from(
        json.decode(str).map((x) => TaskTypeModel.fromJson(x)));

String taskTypeModelToJson(List<TaskTypeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TaskTypeModel {
  int taskTypeId;
  String taskTypeName;
  String taskTypeColor;
  String taskTypeImage;
  int deleteStatus;
  dynamic departmentIds;
  dynamic branchIds;
  int defaultStatusId;
  int duration;
  int conversionTask;
  int locationTracking;
  int commissionNumber;
  int manualCreation;
  int orderBy;
  String? description;

  String? departmentName;
  List<Status> statuses;
  List<EnquiryFor>? enquiryFor;
  int enquiryForVisible;
  int showUser;
  String dailyTarget;
  String monthlyTarget;

  TaskTypeModel(
      {required this.taskTypeId,
      required this.taskTypeName,
      required this.taskTypeColor,
      required this.taskTypeImage,
      required this.deleteStatus,
      required this.departmentIds,
      required this.branchIds,
      required this.defaultStatusId,
      required this.duration,
      required this.conversionTask,
      required this.locationTracking,
      required this.commissionNumber,
      required this.manualCreation,
      required this.orderBy,
      required this.statuses,
      required this.departmentName,
      this.enquiryFor,
      required this.enquiryForVisible,
      required this.showUser,
      required this.dailyTarget,
      required this.monthlyTarget,
      this.description});

  factory TaskTypeModel.fromJson(Map<String, dynamic> json) => TaskTypeModel(
      taskTypeId: json["Task_Type_Id"] ?? 0,
      taskTypeName: json["Task_Type_Name"] ?? '',
      taskTypeColor: json["Task_Type_Color"] ?? '',
      taskTypeImage: json["Task_Type_Image"] ?? '',
      deleteStatus: json["DeleteStatus"] ?? 0,
      departmentIds: json["Department_Ids"] ?? '',
      branchIds: json["Branch_Ids"] ?? '',
      defaultStatusId: json["default_status_id"] ?? 0,
      duration: json["Duration"] ?? 0,
      conversionTask: json["Is_Active"] is bool
          ? (json["Is_Active"] as bool ? 1 : 0)
          : int.tryParse(json["Is_Active"]?.toString() ?? json["is_active"]?.toString() ?? '0') ??
              0,
      locationTracking: json["Location_Tracking"] is bool
          ? (json["Location_Tracking"] as bool ? 1 : 0)
          : int.tryParse(json["Location_Tracking"]?.toString() ?? json["location_tracking"]?.toString() ?? '0') ??
              0,
      commissionNumber: json["Commission_Number"] is bool
          ? (json["Commission_Number"] as bool ? 1 : 0)
          : json["CommissionNumber"] is bool
              ? (json["CommissionNumber"] as bool ? 1 : 0)
              : int.tryParse(json["Commission_Number"]?.toString() ??
                      json["CommissionNumber"]?.toString() ??
                      json["commission_number"]?.toString() ??
                      json["commision_number"]?.toString() ??
                      json["Commision_Number"]?.toString() ??
                      '0') ??
                  0,
      manualCreation: (json["Manual_Creation"] == true ||
              json["Manual_Creation"] == 1 ||
              json["Manual_Creation"] == "1" ||
              json["manual_creation"] == true ||
              json["manual_creation"] == 1 ||
              json["manual_creation"] == "1" ||
              json["ManualCreation"] == true ||
              json["ManualCreation"] == 1 ||
              json["ManualCreation"] == "1" ||
              json["manualCreation"] == true ||
              json["manualCreation"] == 1 ||
              json["manualCreation"] == "1")
          ? 1
          : 0,
      orderBy:
          int.tryParse(json["Order_By"]?.toString() ?? json["order_by"]?.toString() ?? '0') ??
              0,
      dailyTarget: json["Daily_Target"]?.toString() ?? '0',
      monthlyTarget: json["Monthly_Target"]?.toString() ?? '0',
      statuses: json["Statuses"] == null
          ? []
          : List<Status>.from(json["Statuses"].map((x) => Status.fromJson(x))),
      enquiryFor: json["Enquiry_For_Ids"] == null
          ? []
          : List<EnquiryFor>.from(json["Enquiry_For_Ids"].map((x) => EnquiryFor.fromJson(x))),
      enquiryForVisible: int.tryParse(json["Enquiry_For_Visible"]?.toString() ?? json["enquiry_for_visible"]?.toString() ?? '0') ?? 0,
      departmentName: json["Department_Name"],
      showUser: int.tryParse(json["Show_User"]?.toString() ?? json["show_user"]?.toString() ?? '0') ?? 0,
      description: json["Description"]?.toString());

  bool get isEnabled => conversionTask == 1 && deleteStatus == 0;

  Map<String, dynamic> toJson() => {
        "Task_Type_Id": taskTypeId,
        "Task_Type_Name": taskTypeName,
        "Task_Type_Color": taskTypeColor,
        "Task_Type_Image": taskTypeImage,
        "DeleteStatus": deleteStatus,
        "Department_Ids": departmentIds,
        "Branch_Ids": branchIds,
        "default_status_id": defaultStatusId,
        "Duration": duration,
        "Is_Active": conversionTask,
        "Location_Tracking": locationTracking,
        "Commission_Number": commissionNumber,
        "Manual_Creation": manualCreation,
        "Order_By": orderBy,
        "Statuses": List<dynamic>.from(statuses.map((x) => x.toJson())),
        "Enquiry_For_Ids": enquiryFor == null
            ? []
            : List<dynamic>.from(enquiryFor!.map((x) => x.toJson())),
        "Enquiry_For_Visible": enquiryForVisible,
        "Department_Name": departmentName,
        "Description": description,
      };
}

class EnquiryFor {
  int enquiryForId;

  EnquiryFor({
    required this.enquiryForId,
  });

  factory EnquiryFor.fromJson(Map<String, dynamic> json) => EnquiryFor(
        enquiryForId: json["EnquiryFor_Id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Enquiry_For_Id": enquiryForId,
      };
}

class Status {
  int statusId;

  Status({
    required this.statusId,
  });

  factory Status.fromJson(Map<String, dynamic> json) => Status(
        statusId: json["Status_Id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
      };
}
