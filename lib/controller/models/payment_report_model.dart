class PaymentReportModel {
  String customerName;
  String paymentDate;
  String paymentModeName;
  double payingAmount;

  PaymentReportModel({
    required this.customerName,
    required this.paymentDate,
    required this.paymentModeName,
    required this.payingAmount,
  });

  factory PaymentReportModel.fromJson(Map<String, dynamic> json) {
    return PaymentReportModel(
      customerName: json['Customer_Name'] ?? '',
      paymentDate: json['Payment_Date'] ?? '',
      paymentModeName: json['Payment_Mode_Name'] ?? '',
      payingAmount: double.tryParse(json['Paying_Amount'].toString()) ?? 0.0,
    );
  }
}
