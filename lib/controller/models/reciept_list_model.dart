class ReceiptListModel {
  final int receiptId;
  final String entryDate;
  final String receiptDate;
  final String receiptNo;

  final String description;
  final double amount;
  final int customerId;
  final int deleteStatus;
  final String byUserId;
  final String byUserName;
  final int paymentModeId;
  final String paymentModeName;
  final String reportPath;
  final int adminApproval;
  final String? approvedBy;
  final String? approvedByName;
  final String? approvedAt;
  final int isRejected;
  final String? rejectedBy;
  final String? rejectedByName;
  final String? rejectionReason;
  final String? rejectedAt;

  ReceiptListModel({
    required this.paymentModeId,
    required this.paymentModeName,
    required this.receiptDate,
    required this.receiptNo,
    required this.receiptId,
    required this.entryDate,
    required this.description,
    required this.amount,
    required this.customerId,
    required this.deleteStatus,
    required this.byUserId,
    required this.byUserName,
    this.reportPath = '',
    this.adminApproval = 0,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.isRejected = 0,
    this.rejectedBy,
    this.rejectedByName,
    this.rejectionReason,
    this.rejectedAt,
  });

  // Factory constructor to parse JSON with null checks
  factory ReceiptListModel.fromJson(Map<String, dynamic> json) {
    return ReceiptListModel(
      paymentModeId: json['Payment_mode_id'] ?? 0,
      paymentModeName: json['Payment_mode_name']?.toString() ?? '',
      receiptDate: json['Reciept_Date'] ?? '',
      receiptNo: json['Reciept_No']?.toString() ?? '',
      receiptId: json['Receipt_Id'] ?? 0,
      entryDate: json['Entry_Date'] ?? '',
      description: json['Description'] ?? '',
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      customerId: json['Customer_Id'] ?? 0,
      deleteStatus: json['DeleteStatus'] ?? 0,
      byUserId: json['By_User_Id']?.toString() ?? '',
      byUserName: json['By_User_Name']?.toString() ?? '',
      reportPath: json['Report_Path']?.toString() ?? '',
      adminApproval: int.tryParse(json['admin_approval']?.toString() ??
              json['Admin_Approval']?.toString() ??
              '') ??
          0,
      approvedBy: json['approved_by']?.toString() ??
          json['Approved_By']?.toString(),
      approvedByName: json['approved_by_name']?.toString() ??
          json['Approved_By_Name']?.toString(),
      approvedAt: json['approved_at']?.toString() ??
          json['Approved_At']?.toString() ??
          json['Approved_Date']?.toString(),
      isRejected: int.tryParse(json['is_rejected']?.toString() ??
              json['Is_rejected']?.toString() ??
              json['Is_Rejected']?.toString() ??
              '') ??
          0,
      rejectedBy: json['rejected_by']?.toString() ??
          json['Rejected_By']?.toString(),
      rejectedByName: json['rejected_by_name']?.toString() ??
          json['Rejected_By_Name']?.toString(),
      rejectionReason: json['rejection_reason']?.toString() ??
          json['Rejection_Reason']?.toString() ??
          json['reason']?.toString() ??
          json['Reason']?.toString() ??
          json['reject_reason']?.toString() ??
          json['Reject_Reason']?.toString(),
      rejectedAt: json['rejected_at']?.toString() ??
          json['Rejected_At']?.toString() ??
          json['Rejected_Date']?.toString(),
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
      'Report_Path': reportPath,
      'Admin_Approval': adminApproval,
      'Approved_By': approvedBy,
      'Approved_By_Name': approvedByName,
      'Approved_At': approvedAt,
      'Is_Rejected': isRejected,
      'Rejected_By': rejectedBy,
      'Rejected_By_Name': rejectedByName,
      'Rejection_Reason': rejectionReason,
      'Rejected_At': rejectedAt,
    };
  }
}
