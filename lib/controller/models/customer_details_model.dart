class CustomerModel {
  String customerId;
  String customerName;
  String isRegistered;

  CustomerModel({
    required this.customerId,
    required this.customerName,
    required this.isRegistered,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
      customerId: json["Customer_Id"]?.toString() ?? '',
      customerName: json["Customer_Name"] ?? '',
      isRegistered: json["Is_Registered"]?.toString() ?? '');

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Is_Registered": isRegistered
      };
}
