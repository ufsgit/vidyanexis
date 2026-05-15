class LeadCustomerModel {
  final int customerId;
  final String customerName;
  final String address;

  LeadCustomerModel({
    required this.customerId,
    required this.customerName,
    required this.address,
  });

  factory LeadCustomerModel.fromJson(Map<String, dynamic> json) {
    return LeadCustomerModel(
      customerId: json['Customer_Id'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'address': address,
    };
  }
}
