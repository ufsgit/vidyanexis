import 'package:vidyanexis/controller/models/maintenance_model.dart';

class AmcReportModeld {
  int amcId;
  String amcNo;
  DateTime? date; // Made nullable
  int amcStatusId;
  String amcStatusName;
  String productName;
  String serviceName;
  String description;
  String amount;
  int createdBy;
  int customerId;
  String fromDate;
  String toDate;
  int deleteStatus;
  String createdByName;
  String customerName;
  final String mobile;
  final String address1;
  final String periodIntervalName;
  final int periodIntervalId;
  final int periodIntervalNo;
  final String totalDurationName;
  final int totalDurationId;
  final int totalDurationNo;
  List<MaintenanceDate> maintenanceDate;

  AmcReportModeld({
    required this.amcId,
    required this.amcNo,
    this.date, // Nullable
    required this.amcStatusId,
    required this.amcStatusName,
    required this.productName,
    required this.serviceName,
    required this.description,
    required this.amount,
    required this.createdBy,
    required this.customerId,
    required this.fromDate,
    required this.toDate,
    required this.deleteStatus,
    required this.createdByName,
    required this.customerName,
    required this.mobile,
    required this.address1,
    required this.periodIntervalId,
    required this.periodIntervalNo,
    required this.periodIntervalName,
    required this.totalDurationId,
    required this.totalDurationNo,
    required this.totalDurationName,
    required this.maintenanceDate,
  });

  factory AmcReportModeld.fromJson(Map<String, dynamic> json) =>
      AmcReportModeld(
        amcId: json["AMC_Id"] ?? 0,
        amcNo: json["AMC_No"] ?? '',
        date: json["Date"] != null ? DateTime.tryParse(json["Date"]) : null,
        amcStatusId: json["AMC_Status_Id"] ?? 0,
        amcStatusName: json["AMC_Status_Name"] ?? '',
        productName: json["Product_Name"] ?? '',
        serviceName: json["Service_Name"] ?? '',
        description: json["Description"] ?? '',
        amount: json["Amount"] ?? '',
        createdBy: json["Created_By"] ?? 0,
        customerId: json["Customer_Id"] ?? 0,
        fromDate: json["From_Date"]?.toString() ?? '',
        toDate: json["To_Date"]?.toString() ?? '',
        deleteStatus: json["DeleteStatus"] ?? 0,
        createdByName: json["Created_By_Name"] ?? '',
        customerName: json["Customer_Name"] ?? '',
        mobile: json['Contact_Number'] ?? '',
        address1: json['address'] ?? '',
        periodIntervalId: json['Interval_Id'] ?? 0,
        periodIntervalNo: json['Intervals_No'] ?? 0,
        periodIntervalName: json['Interval_Name'] ?? '',
        totalDurationId: json['Duration_Id'] ?? 0,
        totalDurationNo: json['Duration_No'] ?? 0,
        totalDurationName: json['Duration_Name'] ?? '',
        maintenanceDate: json['interval_details'] != null
            ? (json['interval_details'] as List)
                .map((item) => MaintenanceDate.fromJson(item))
                .toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        "AMC_Id": amcId,
        "AMC_No": amcNo,
        "Date": date?.toIso8601String(), // Null-aware operator
        "AMC_Status_Id": amcStatusId,
        "AMC_Status_Name": amcStatusName,
        "Product_Name": productName,
        "Service_Name": serviceName,
        "Description": description,
        "Amount": amount,
        "Created_By": createdBy,
        "Customer_Id": customerId,
        "From_Date": fromDate,
        "To_Date": toDate,
        "DeleteStatus": deleteStatus,
        "Created_By_Name": createdByName,
        "Customer_Name": customerName,
        'Contact_Number': mobile,
        'Address1': address1,
      };
}
