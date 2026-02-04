class BalanceReportModel {
  final String customerName;
  final String phone;
  final String address;
  final double totalPaymentSchedule;
  final double totalReceipt;
  final double balance;

  BalanceReportModel({
    required this.customerName,
    required this.phone,
    required this.address,
    required this.totalPaymentSchedule,
    required this.totalReceipt,
    required this.balance,
  });

  factory BalanceReportModel.fromJson(Map<String, dynamic> json) {
    return BalanceReportModel(
      customerName: json['Customer_Name'] ?? '',
      phone: json['Contact_Number'] ?? '',
      address: json['Address1'] ?? '',
      totalPaymentSchedule:
          double.tryParse(json['Total_Payment_Schedule']?.toString() ?? '0') ??
              0.0,
      totalReceipt:
          double.tryParse(json['Total_Receipt']?.toString() ?? '0') ?? 0.0,
      balance: double.tryParse(json['Balance']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Name': customerName,
      'Contact_Number': phone,
      'Address1': address,
      'Total_Payment_Schedule': totalPaymentSchedule,
      'Total_Receipt': totalReceipt,
      'Balance': balance,
    };
  }
}
