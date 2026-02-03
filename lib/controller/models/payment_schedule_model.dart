class PaymentScheduleModel {
  final int paymentScheduleId;
  final String scheduleDate;
  final String description;
  final double amount;
  final int customerId;
  final int deleteStatus;
  final String byUserId;
  final String byUserName;

  PaymentScheduleModel({
    required this.paymentScheduleId,
    required this.scheduleDate,
    required this.description,
    required this.amount,
    required this.customerId,
    required this.deleteStatus,
    required this.byUserId,
    required this.byUserName,
  });

  factory PaymentScheduleModel.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleModel(
      paymentScheduleId: json['Payment_Schedule_Id'] ?? 0,
      scheduleDate: json['Schedule_Date'] ?? '',
      description: json['Description'] ?? '',
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      customerId: json['Customer_Id'] ?? 0,
      deleteStatus: json['DeleteStatus'] ?? 0,
      byUserId: json['By_User_Id']?.toString() ?? '',
      byUserName: json['By_User_Name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Payment_Schedule_Id': paymentScheduleId,
      'Schedule_Date': scheduleDate,
      'Description': description,
      'Amount': amount.toStringAsFixed(2),
      'Customer_Id': customerId,
      'DeleteStatus': deleteStatus,
      'By_User_Id': byUserId,
      'By_User_Name': byUserName,
    };
  }
}
