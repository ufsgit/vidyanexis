class RefundData {
  final int? refundId;
  final int? customerId;
  final String? electricalSection;
  final String? place;
  final String? consumerNumber;
  final String? kwCapacity;
  final String? accountHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? byUserName; // Keeping string as per user API format
  final String? createdDate;
  final int? deletedStatus;

  RefundData({
    this.refundId,
    this.customerId,
    this.electricalSection,
    this.place,
    this.consumerNumber,
    this.kwCapacity,
    this.accountHolderName,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
    this.byUserName,
    this.createdDate,
    this.deletedStatus,
  });

  factory RefundData.fromJson(Map<String, dynamic> json) {
    return RefundData(
      refundId: json['Refund_Id'] is int
          ? json['Refund_Id']
          : int.tryParse(json['Refund_Id']?.toString() ?? ''),
      customerId: json['Customer_Id'] is int
          ? json['Customer_Id']
          : int.tryParse(json['Customer_Id']?.toString() ?? ''),
      electricalSection: json['Electrical_Section']?.toString(),
      place: json['Place']?.toString(),
      consumerNumber: json['Consumer_Number']?.toString(),
      kwCapacity: json['KW_Capacity']?.toString(),
      accountHolderName: json['Account_Holder_Name']?.toString(),
      accountNumber: json['Account_Number']?.toString(),
      bankName: json['Bank_Name']?.toString(),
      ifscCode: json['IFSC_Code']?.toString(),
      byUserName: json['By_User_Name']?.toString(),
      createdDate: json['Created_Date']?.toString(),
      deletedStatus: json['Deleted_Status'] is int
          ? json['Deleted_Status']
          : int.tryParse(json['Deleted_Status']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Refund_Id': refundId,
      'Customer_Id': customerId,
      'Electrical_Section': electricalSection,
      'Place': place,
      'Consumer_Number': consumerNumber,
      'KW_Capacity': kwCapacity,
      'Account_Holder_Name': accountHolderName,
      'Account_Number': accountNumber,
      'Bank_Name': bankName,
      'IFSC_Code': ifscCode,
      'By_User_Name': byUserName,
      'Created_Date': createdDate,
      'Deleted_Status': deletedStatus,
    };
  }
}
