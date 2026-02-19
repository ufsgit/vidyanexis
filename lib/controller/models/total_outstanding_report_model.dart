class TotalOutstandingReportModel {
  late int customerId;
  late String customerName;
  late double totalScheduleAmount;
  late double totalPaidAmount;
  late double totalOutstandingAmount;

  TotalOutstandingReportModel({
    required this.customerId,
    required this.customerName,
    required this.totalScheduleAmount,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
  });

  TotalOutstandingReportModel.fromJson(Map<String, dynamic> json) {
    customerId = json['Customer_Id'] ?? 0;
    customerName = json['Customer_Name'] ?? '';
    totalScheduleAmount =
        double.tryParse(json['Total_Schedule_Amount'].toString()) ?? 0.0;
    totalPaidAmount =
        double.tryParse(json['Total_Paid_Amount'].toString()) ?? 0.0;
    totalOutstandingAmount =
        double.tryParse(json['Total_Outstanding_Amount'].toString()) ?? 0.0;
  }
}
