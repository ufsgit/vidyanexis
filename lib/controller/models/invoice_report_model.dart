class InvoiceReportModel {
  String invoiceNo;
  String invoiceDate;
  String customerName;
  String contactNumber;
  String registeredDate;
  int customerId;
  int tp;
  String invoiceAmount;
  String balanceAmount;
  String recieptAmount;
  final String address1;

  InvoiceReportModel({
    required this.invoiceNo,
    required this.invoiceDate,
    required this.customerName,
    required this.contactNumber,
    required this.registeredDate,
    required this.customerId,
    required this.tp,
    required this.invoiceAmount,
    required this.balanceAmount,
    required this.recieptAmount,
    required this.address1,
  });

  factory InvoiceReportModel.fromJson(Map<String, dynamic> json) {
    return InvoiceReportModel(
      invoiceNo: json["Invoice_No"] ?? '', // Provide a default value
      invoiceDate: json["Invoice_Date"] ?? '', // Use an empty string if null
      customerName: json["Customer_Name"] ?? '', // Default if null
      contactNumber: json["Contact_Number"] ?? '', // Default if null
      registeredDate: json["Registered_Date"] ?? '', // Empty string if null
      customerId: json["Customer_Id"] ?? 0, // Empty string if null
      invoiceAmount: json["Invoice_Amount"] ?? '0', // Empty string if null
      recieptAmount:
          json["Total_Receipt_Amount"] ?? '0', // Empty string if null
      balanceAmount: json["Balance_Amount"] ?? '0', // Empty string if null
      tp: json["tp"] ?? 0, // Empty string if null
      address1: json['Address1'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Invoice_No": invoiceNo,
      "Invoice_Date": invoiceDate,
      "Customer_Name": customerName,
      "Contact_Number": contactNumber,
      "Registered_Date": registeredDate,
      "Customer_Id": customerId,
      "Invoice_Amount": invoiceAmount,
      "Total_Receipt_Amount": recieptAmount,
      "Balance_Amount": balanceAmount,
      "tp": tp,
      'Address1': address1,
    };
  }
}
