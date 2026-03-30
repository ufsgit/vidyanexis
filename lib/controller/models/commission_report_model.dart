class CommissionReportModel {
  final int customerId;
  final String customerName;
  final String contactNumber;
  final String enquiryFor;
  final String enquirySourceName;
  final String totalProjectCost;
  final String commission;
  final String statusName;
  final String entryDate;
  final String toUserName;

  CommissionReportModel({
    required this.customerId,
    required this.customerName,
    required this.contactNumber,
    required this.enquiryFor,
    required this.enquirySourceName,
    required this.totalProjectCost,
    required this.commission,
    required this.statusName,
    required this.entryDate,
    required this.toUserName,
  });

  factory CommissionReportModel.fromJson(Map<String, dynamic> json) {
    return CommissionReportModel(
      customerId: int.tryParse(json["Customer_Id"]?.toString() ?? "0") ?? 0,
      customerName: json["Customer_Name"]?.toString() ?? '',
      contactNumber: json["Phone"]?.toString() ?? '',
      enquiryFor: json["Enquiry_For_Name"]?.toString() ?? '',
      enquirySourceName: json["Enquiry_Source_Name"]?.toString() ?? '',
      totalProjectCost: json["Project_Cost"]?.toString() ?? '0.00',
      commission: json["Commission_Amount"]?.toString() ?? '0.00',
      statusName: json["Status_Name"]?.toString() ?? '',
      entryDate: json["Registration_Date"]?.toString() ?? '',
      toUserName: json["To_User_Name"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "Customer_Id": customerId,
        "Customer_Name": customerName,
        "Phone_Number": contactNumber,
        "Enquiry_For_Name": enquiryFor,
        "Enquiry_Source_Name": enquirySourceName,
        "Total_Project_Cost": totalProjectCost,
        "Commission": commission,
        "Status_Name": statusName,
        "Entry_Date": entryDate,
        "To_User_Name": toUserName,
      };
}
