class ReceiptReportModel {
  String customerName;
  String receiptDate;
  String entryDate;
  String receiptNo;
  String paymentModeName;
  String description;
  String byUserName;
  double amount;

  ReceiptReportModel({
    required this.customerName,
    required this.receiptDate,
    required this.entryDate,
    required this.receiptNo,
    required this.paymentModeName,
    required this.description,
    required this.byUserName,
    required this.amount,
  });

  factory ReceiptReportModel.fromJson(Map<String, dynamic> json) {
    return ReceiptReportModel(
      customerName: json['Customer_Name'] ?? json['Customer_name'] ?? '',
      receiptDate: json['Receipt_Date'] ?? json['Reciept_Date'] ?? json['ReceiptDate'] ?? json['RecieptDate'] ?? '',
      entryDate: json['Entry_Date'] ?? json['Entry_date'] ?? '',
      receiptNo: json['Receipt_No']?.toString() ?? json['Reciept_No']?.toString() ?? json['ReceiptNo']?.toString() ?? '',
      paymentModeName: json['Payment_Mode_Name'] ?? json['Payment_mode_name'] ?? json['Payment_Mode'] ?? json['PaymentModeName'] ?? '',
      description: json['Description'] ?? json['description'] ?? '',
      byUserName: json['By_User_Name'] ?? json['By_User_name'] ?? json['ByUserName'] ?? '',
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
