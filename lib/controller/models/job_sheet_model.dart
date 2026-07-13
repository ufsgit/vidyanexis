import 'package:flutter/material.dart';

class SystemComponentCheck {
  final String component;
  int? componentStatus; // 0, 1, or null
  final TextEditingController remarkController;

  SystemComponentCheck({
    required this.component,
    this.componentStatus,
    TextEditingController? remarkController,
  }) : remarkController = remarkController ?? TextEditingController();

  Map<String, dynamic> toJson() {
    return {
      'component_name': component,
      'component_status': componentStatus,
      'component_remark': remarkController.text,
    };
  }

  factory SystemComponentCheck.fromJson(Map<String, dynamic> json) {
    return SystemComponentCheck(
      component: json['component_name'] ?? json['component'] ?? '',
      componentStatus: json['component_status'] ?? json['componentStatus'],
      remarkController: TextEditingController(text: json['component_remark'] ?? json['remark'] ?? ''),
    );
  }
}

class MaintenanceTask {
  final String taskName;
  int isYes;
  int isNo;
  int notApplicable;

  MaintenanceTask({
    required this.taskName,
    this.isYes = 0,
    this.isNo = 0,
    this.notApplicable = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'task_name': taskName,
      'is_yes': isYes,
      'is_no': isNo,
      'not_applicable': notApplicable,
    };
  }

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      taskName: json['task_name'] ?? json['taskName'] ?? '',
      isYes: json['is_yes'] ?? json['isYes'] ?? 0,
      isNo: json['is_no'] ?? json['isNo'] ?? 0,
      notApplicable: json['not_applicable'] ?? json['notApplicable'] ?? 0,
    );
  }
}

class JobSheetData {
  int jobSheetId;
  int taskId;
  String serviceType;
  int serviceTypeId;
  String weatherCondition;
  String actionTaken;
  String observation;
  String nextScheduledDate;
  int nextScheduledDateType;
  String nextScheduledDateName;
  String customerOverallSatisfactionName;
  int customerOverallSatisfactionId;
  String additionalRemark;
  String nextMeterReading;
  String customerSignature;
  String technicianSignature;
  String customerSignatureDate;
  String technicianSignatureDate;
  List<SystemComponentCheck> systemPerformanceCheck;
  List<MaintenanceTask> cleaningMaintenanceTask;

  JobSheetData({
    required this.jobSheetId,
    required this.taskId,
    required this.serviceType,
    required this.serviceTypeId,
    required this.weatherCondition,
    required this.actionTaken,
    required this.observation,
    required this.nextScheduledDate,
    required this.nextScheduledDateType,
    required this.nextScheduledDateName,
    required this.customerOverallSatisfactionName,
    required this.customerOverallSatisfactionId,
    required this.additionalRemark,
    required this.nextMeterReading,
    required this.customerSignature,
    required this.technicianSignature,
    required this.customerSignatureDate,
    required this.technicianSignatureDate,
    required this.systemPerformanceCheck,
    required this.cleaningMaintenanceTask,
  });

  Map<String, dynamic> toJson() {
    return {
      'job_sheet_id': jobSheetId,
      'task_id': taskId,
      'service_type': serviceType,
      'service_type_id': serviceTypeId,
      'weather_condition': weatherCondition,
      'action_taken': actionTaken,
      'observation': observation,
      'next_scheduled_date': nextScheduledDate,
      'next_scheduled_date_type': nextScheduledDateType,
      'next_scheduled_date_name': nextScheduledDateName,
      'customer_overall_satisfaction_name': customerOverallSatisfactionName,
      'customer_overall_satisfaction_id': customerOverallSatisfactionId,
      'additional_remark': additionalRemark,
      'net_meter_reading': nextMeterReading,
      'customer_signature': customerSignature,
      'technician_signature': technicianSignature,
      'customer_signature_date': customerSignatureDate,
      'technician_signature_date': technicianSignatureDate,
      'system_performance_check':
          systemPerformanceCheck.map((e) => e.toJson()).toList(),
      'cleaning_maintenance_task':
          cleaningMaintenanceTask.map((e) => e.toJson()).toList(),
    };
  }

  factory JobSheetData.fromJson(Map<String, dynamic> json) {
    return JobSheetData(
      jobSheetId: json['job_sheet_id'] ?? json['jobSheetId'] ?? 0,
      taskId: json['task_id'] ?? json['taskId'] ?? 0,
      serviceType: json['service_type'] ?? json['serviceType'] ?? '',
      serviceTypeId: json['service_type_id'] ?? json['serviceTypeId'] ?? 0,
      weatherCondition: json['weather_condition'] ?? json['weatherCondition'] ?? '',
      actionTaken: json['action_taken'] ?? json['actionTaken'] ?? '',
      observation: json['observation'] ?? '',
      nextScheduledDate: json['next_scheduled_date'] ?? json['nextScheduledDate'] ?? '',
      nextScheduledDateType: json['next_scheduled_date_type'] ?? json['nextScheduledDateType'] ?? 0,
      nextScheduledDateName: json['next_scheduled_date_name'] ?? json['nextScheduledDateName'] ?? '',
      customerOverallSatisfactionName: json['customer_overall_satisfaction_name'] ?? json['customerOverallSatisfactionName'] ?? '',
      customerOverallSatisfactionId: json['customer_overall_satisfaction_id'] ?? json['customerOverallSatisfactionId'] ?? 0,
      additionalRemark: json['additional_remark'] ?? json['additionalRemark'] ?? '',
      nextMeterReading: json['net_meter_reading'] ?? json['nextMeterReading'] ?? '',
      customerSignature: json['customer_signature'] ?? json['customerSignature'] ?? '',
      technicianSignature: json['technician_signature'] ?? json['technicianSignature'] ?? '',
      customerSignatureDate: json['customer_signature_date'] ?? json['customerSignatureDate'] ?? '',
      technicianSignatureDate: json['technician_signature_date'] ?? json['technicianSignatureDate'] ?? '',
      systemPerformanceCheck: ((json['system_performance_check'] ?? json['systemPerformanceCheck']) as List<dynamic>?)
              ?.map((e) => SystemComponentCheck.fromJson(e))
              .toList() ??
          [],
      cleaningMaintenanceTask: ((json['cleaning_maintenance_task'] ?? json['cleaningMaintenanceTask']) as List<dynamic>?)
              ?.map((e) => MaintenanceTask.fromJson(e))
              .toList() ??
          [],
    );
  }
}
