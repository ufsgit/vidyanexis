class ReceiptListModel {
  final int receiptId;
  final String entryDate;
  final String description;
  final double amount;
  final int customerId;
  final int deleteStatus;
  final String byUserId;
  final String byUserName;

  ReceiptListModel({
    required this.receiptId,
    required this.entryDate,
    required this.description,
    required this.amount,
    required this.customerId,
    required this.deleteStatus,
    required this.byUserId,
    required this.byUserName,
  });

  // Factory constructor to parse JSON with null checks
  factory ReceiptListModel.fromJson(Map<String, dynamic> json) {
    return ReceiptListModel(
      receiptId: json['Receipt_Id'] ?? 0,
      entryDate: json['Entry_Date'] ?? '',
      description: json['Description'] ?? '',
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      customerId: json['Customer_Id'] ?? 0,
      deleteStatus: json['DeleteStatus'] ?? 0,
      byUserId: json['By_User_Id']?.toString() ?? '',
      byUserName: json['By_User_Name']?.toString() ?? '',
    );
  }

  // Method to convert the model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'Receipt_Id': receiptId,
      'Entry_Date': entryDate,
      'Description': description,
      'Amount': amount.toStringAsFixed(2),
      'Customer_Id': customerId,
      'DeleteStatus': deleteStatus,
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
    };
  }
}
