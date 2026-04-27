class CustomerOutstandingReportModel {
  final int customerId;
  final String customerName;
  final String phone;
  final String enquirySource;
  final String projectCost;
  final String received;
  final String balance;

  CustomerOutstandingReportModel({
    required this.customerId,
    required this.customerName,
    required this.enquirySource,
    required this.phone,
    required this.projectCost,
    required this.received,
    required this.balance,
  });

  factory CustomerOutstandingReportModel.fromJson(Map<String, dynamic> json) {
    return CustomerOutstandingReportModel(
      customerId: int.tryParse(json["Customer_Id"]?.toString() ?? "0") ?? 0,
      customerName: json["Customer_Name"]?.toString() ?? '',
      phone: json["Phone_Number"]?.toString() ?? '',
      enquirySource: json["Enquiry_Source_Name"]?.toString() ?? '',
      projectCost: json["Project_Cost"]?.toString() ?? '0.00',
      received: json["Total_Received"]?.toString() ?? '0.00',
      balance: json["Balance"]?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone": phone,
        "Enquiry_Source_Name": enquirySource,
        "Project_Cost": projectCost,
        "Received": received,
        "Balance": balance,
      };
}
