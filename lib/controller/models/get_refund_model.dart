// Generated model for: service/Get_Refund_Details/:Customer_Id
// Adjust fields to match the actual API response if needed.

class RefundModel {
  final bool? success;
  final String? message;
  final List<RefundDetail>? data;

  RefundModel({this.success, this.message, this.data});

  factory RefundModel.fromJson(Map<String, dynamic> json) {
    return RefundModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? List<RefundDetail>.from(
              (json['data'] as List).map((e) => RefundDetail.fromJson(e)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class RefundDetail {
  final String? refundId;
  final String? customerId;
  final String? electricalSection;
  final String? place;
  final String? consumerNumber;
  final String? kwCapacity;
  final String? accountHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? byUserId;
  final String? byUserName;

  RefundDetail({
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
    this.byUserId,
    this.byUserName,
  });

  factory RefundDetail.fromJson(Map<String, dynamic> json) {
    return RefundDetail(
      refundId: json['Refund_Id']?.toString(),
      customerId: json['Customer_Id']?.toString(),
      electricalSection: json['Electrical_Section']?.toString(),
      place: json['Place']?.toString(),
      consumerNumber: json['Consumer_Number']?.toString(),
      kwCapacity: json['KW_Capacity']?.toString(),
      accountHolderName: json['Account_Holder_Name']?.toString(),
      accountNumber: json['Account_Number']?.toString(),
      bankName: json['Bank_Name']?.toString(),
      ifscCode: json['IFSC_Code']?.toString(),
      byUserId: json['By_User_Id']?.toString(),
      byUserName: json['By_User_Name']?.toString(),
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
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
    };
  }
}
