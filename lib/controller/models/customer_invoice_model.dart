class CustomerInvoice {
  final String customerInvoiceId;
  final String entryDate;
  final String invoiceDescription;
  final String invoiceAmount;
  final String customerId;
  final String byUserId;
  final String byUserName;
  final String deleteStatus;

  CustomerInvoice({
    required this.customerInvoiceId,
    required this.entryDate,
    required this.invoiceDescription,
    required this.invoiceAmount,
    required this.customerId,
    required this.byUserId,
    required this.byUserName,
    required this.deleteStatus,
  });

  factory CustomerInvoice.fromJson(Map<String, dynamic> json) {
    return CustomerInvoice(
      customerInvoiceId: json['customer_invoice_id']?.toString() ?? '',
      entryDate: json['Entry_Date']?.toString() ?? '',
      invoiceDescription: json['Invoice_Description']?.toString() ?? '',
      invoiceAmount: json['Invoice_Amount']?.toString() ?? '',
      customerId: json['Customer_Id']?.toString() ?? '',
      byUserId: json['By_User_Id']?.toString() ?? '',
      byUserName: json['By_User_Name']?.toString() ?? '',
      deleteStatus: json['DeleteStatus']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_invoice_id': customerInvoiceId,
      'Entry_Date': entryDate,
      'Invoice_Description': invoiceDescription,
      'Invoice_Amount': invoiceAmount,
      'Customer_Id': customerId,
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
      'DeleteStatus': deleteStatus,
    };
  }
}
