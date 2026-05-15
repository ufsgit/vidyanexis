class LeadCustomerModel {
  final int customerId;
  final String customerName;

  LeadCustomerModel({
    required this.customerId,
    required this.customerName,
  });

  factory LeadCustomerModel.fromJson(Map<String, dynamic> json) {
    return LeadCustomerModel(
      customerId: json['Customer_Id'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Id': customerId,
      'Customer_Name': customerName,
    };
  }
}
