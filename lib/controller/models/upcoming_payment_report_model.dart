class UpcomingPaymentReportModel {
  String scheduleDate;
  String customerName;
  double scheduleAmount;

  UpcomingPaymentReportModel({
    required this.scheduleDate,
    required this.customerName,
    required this.scheduleAmount,
  });

  factory UpcomingPaymentReportModel.fromJson(Map<String, dynamic> json) {
    return UpcomingPaymentReportModel(
      scheduleDate: json['Schedule_Date'] ?? '',
      customerName: json['Customer_Name'] ?? '',
      scheduleAmount:
          double.tryParse(json['Schedule_Amount'].toString()) ?? 0.0,
    );
  }
}
