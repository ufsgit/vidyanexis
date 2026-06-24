class IntervalDetail {
  late String intervalDate;
  late int completedStatus;

  IntervalDetail({
    required this.intervalDate,
    required this.completedStatus,
  });

  IntervalDetail.fromJson(Map<String, dynamic> json) {
    intervalDate = json['Interval_Date'] ?? '';
    completedStatus = json['Completed_Status'] ?? 0;
  }
}

class AmcNotificationModel {
  late String customerName;
  late String amcProductName;
  late String serviceName;
  late String serviceDate;
  late String staffName;
  int? customerId;
  List<IntervalDetail>? intervalDetails;

  AmcNotificationModel({
    required this.customerName,
    required this.amcProductName,
    required this.serviceName,
    required this.serviceDate,
    required this.staffName,
    this.customerId,
    this.intervalDetails,
  });

  AmcNotificationModel.fromJson(Map<String, dynamic> json) {
    customerName = json['Customer_Name'] ?? '';
    amcProductName = json['AMC_Product_Name'] ?? '';
    serviceName = json['Service_Name'] ?? '';
    serviceDate = json['Service_Date'] ?? '';
    staffName = json['Staff_Name'] ?? '';
    customerId = int.tryParse(json['Customer_Id']?.toString() ??
        json['Customer_id']?.toString() ??
        json['customer_id']?.toString() ??
        json['CustomerId']?.toString() ??
        json['customerId']?.toString() ??
        '0');
    if (customerId == 0) customerId = null;
    if (json['Interval_Details'] != null) {
      intervalDetails = <IntervalDetail>[];
      json['Interval_Details'].forEach((v) {
        intervalDetails!.add(IntervalDetail.fromJson(v));
      });
    }
  }
}
