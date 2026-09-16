class IntervalDetail {
  late String intervalDate;
  late int completedStatus;
  int? intervalDetailsId;
  String? taskStatusName;
  String? taskTypeName;

  IntervalDetail({
    required this.intervalDate,
    required this.completedStatus,
    this.intervalDetailsId,
    this.taskStatusName,
    this.taskTypeName,
  });

  IntervalDetail.fromJson(Map<String, dynamic> json) {
    intervalDate = json['Interval_Date'] ?? '';
    completedStatus = json['Completed_Status'] ?? 0;
    intervalDetailsId = int.tryParse(json['Interval_Details_Id']?.toString() ?? '0');
    taskStatusName = json['Task_Status_Name']?.toString() ?? '';
    taskTypeName = json['Task_Type_Name']?.toString() ?? '';
  }
}

class AmcNotificationModel {
  late String customerName;
  late String amcProductName;
  late String serviceName;
  late String serviceDate;
  late String staffName;
  late String taskStatusName;
  late String taskTypeName;
  int? customerId;
  List<IntervalDetail>? intervalDetails;
  Map<String, dynamic>? rawJson;

  AmcNotificationModel({
    required this.customerName,
    required this.amcProductName,
    required this.serviceName,
    required this.serviceDate,
    required this.staffName,
    required this.taskStatusName,
    required this.taskTypeName,
    this.customerId,
    this.intervalDetails,
    this.rawJson,
  });

  AmcNotificationModel.fromJson(Map<String, dynamic> json) {
    rawJson = json;
    customerName = json['Customer_Name'] ?? '';
    amcProductName = json['AMC_Product_Name'] ?? '';
    serviceName = json['Service_Name'] ?? '';
    serviceDate = json['Service_Date'] ?? '';
    staffName = json['Staff_Name'] ?? '';
    taskStatusName = '';
    taskTypeName = '';
    customerId = int.tryParse(json['Customer_Id']?.toString() ??
        json['Customer_id']?.toString() ??
        json['customer_id']?.toString() ??
        json['CustomerId']?.toString() ??
        json['customerId']?.toString() ??
        json['Customer_ID']?.toString() ??
        json['Lead_Id']?.toString() ??
        json['Enquiry_Id']?.toString() ??
        json['Enquiry_id']?.toString() ??
        json['Id']?.toString() ??
        '0');
    if (customerId == 0) customerId = null;
    if (json['Interval_Details'] != null) {
      intervalDetails = <IntervalDetail>[];
      json['Interval_Details'].forEach((v) {
        intervalDetails!.add(IntervalDetail.fromJson(v));
      });
      if (intervalDetails!.isNotEmpty) {
        taskStatusName = intervalDetails!.first.taskStatusName ?? '';
        taskTypeName = intervalDetails!.first.taskTypeName ?? '';
      }
    }
  }
}
