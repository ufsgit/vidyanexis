class OutstandingReportModel {
  late String customerName;
  late String scheduleDate;
  late double outstandingAmount;

  OutstandingReportModel({
    required this.customerName,
    required this.scheduleDate,
    required this.outstandingAmount,
  });

  OutstandingReportModel.fromJson(Map<String, dynamic> json) {
    customerName = json['Customer_Name'] ?? '';
    scheduleDate = json['Schedule_Date'] ?? '';
    outstandingAmount =
        double.tryParse(json['Outstanding_Amount'].toString()) ?? 0.0;
  }
}
