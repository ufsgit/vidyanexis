class CustomerOutstandingReportModel {
  final int customerId;
  final String customerName;
  final String phone;
  final String enquirySource;
  final String projectCost;
  final String received;
  final String balance;
  final String? projectStartDate;
  final int expectedDuration;
  final int? actualDuration;
  final int? difference;

  CustomerOutstandingReportModel({
    required this.customerId,
    required this.customerName,
    required this.enquirySource,
    required this.phone,
    required this.projectCost,
    required this.received,
    required this.balance,
    this.projectStartDate,
    required this.expectedDuration,
    this.actualDuration,
    this.difference,
  });

  factory CustomerOutstandingReportModel.fromJson(Map<String, dynamic> json) {
    return CustomerOutstandingReportModel(
      customerId: int.tryParse(json["Customer_Id"]?.toString() ?? "0") ?? 0,
      customerName: json["Customer_Name"]?.toString() ?? '',
      phone: json["Phone_Number"]?.toString() ?? '',
      enquirySource: json["Enquiry_Source_Name"]?.toString() ??
          json["Enquiry_Source"]?.toString() ??
          '',
      projectCost: json["Project_Cost"]?.toString() ?? '0.00',
      received: json["Total_Received"]?.toString() ?? '0.00',
      balance: json["Balance"]?.toString() ?? '0.00',
      projectStartDate: json["Project_Start_Date"]?.toString(),
      expectedDuration: int.tryParse(json["Expected_Duration"]?.toString() ?? "0") ?? 0,
      actualDuration: int.tryParse(json["Actual_Duration"]?.toString() ?? ""),
      difference: int.tryParse(json["Difference"]?.toString() ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone": phone,
        "Enquiry_Source": enquirySource,
        "Enquiry_Source_Name": enquirySource,
        "Project_Cost": projectCost,
        "Received": received,
        "Balance": balance,
        "Project_Start_Date": projectStartDate,
        "Expected_Duration": expectedDuration,
        "Actual_Duration": actualDuration,
        "Difference": difference,
      };
}
