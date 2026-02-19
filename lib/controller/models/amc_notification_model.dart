class AmcNotificationModel {
  late String customerName;
  late String amcProductName;
  late String serviceName;
  late String serviceDate;
  late String staffName;

  AmcNotificationModel({
    required this.customerName,
    required this.amcProductName,
    required this.serviceName,
    required this.serviceDate,
    required this.staffName,
  });

  AmcNotificationModel.fromJson(Map<String, dynamic> json) {
    customerName = json['Customer_Name'] ?? '';
    amcProductName = json['AMC_Product_Name'] ?? '';
    serviceName = json['Service_Name'] ?? '';
    serviceDate = json['Service_Date'] ?? '';
    staffName = json['Staff_Name'] ?? '';
  }
}
