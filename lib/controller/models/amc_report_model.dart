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
  final String intervalDate;
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
    required this.intervalDate,
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
        amcId: int.tryParse(json["AMC_Id"].toString()) ?? 0,
        amcNo: json["AMC_No"]?.toString() ?? '',
        date: json["Date"] != null
            ? DateTime.tryParse(json["Date"].toString())
            : null,
        amcStatusId: int.tryParse(json["AMC_Status_Id"].toString()) ?? 0,
        amcStatusName: json["Completed_Status"]?.toString() ?? '',
        productName: json["Product_Name"]?.toString() ?? '',
        serviceName: json["Service_Name"]?.toString() ?? '',
        description: json["Description"]?.toString() ?? '',
        amount: json["Amount"]?.toString() ?? '',
        createdBy: int.tryParse(json["Created_By"].toString()) ?? 0,
        customerId: int.tryParse(json["Customer_Id"].toString()) ?? 0,
        fromDate: json["From_Date"]?.toString() ?? '',
        toDate: json["To_Date"]?.toString() ?? '',
        deleteStatus: int.tryParse(json["DeleteStatus"].toString()) ?? 0,
        createdByName: json["Created_By_Name"]?.toString() ?? '',
        customerName: json["Customer_Name"]?.toString() ?? '',
        mobile: json['Contact_Number']?.toString() ?? '',
        address1: json['address']?.toString() ?? '',
        intervalDate: json['Interval_Date']?.toString() ?? '',
        periodIntervalId: int.tryParse(json['Interval_Id'].toString()) ?? 0,
        periodIntervalNo: int.tryParse(json['Intervals_No'].toString()) ?? 0,
        periodIntervalName: json['Interval_Name']?.toString() ?? '',
        totalDurationId: int.tryParse(json['Duration_Id'].toString()) ?? 0,
        totalDurationNo: int.tryParse(json['Duration_No'].toString()) ?? 0,
        totalDurationName: json['Duration_Name']?.toString() ?? '',
        maintenanceDate: (json['interval_details'] is List)
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
        "Interval_Date": intervalDate,
      };
  String get displayStatus {
    if (amcStatusName == '1') {
      return 'Completed';
    } else if (amcStatusName == '0') {
      return 'Pending';
    }
    return amcStatusName;
  }
}
