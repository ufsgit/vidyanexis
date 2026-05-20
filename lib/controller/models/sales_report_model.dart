class SalesReportModel {
  final String customerName;
  final String enquiryFor;
  final String date;
  final String invoiceNo;
  final String assignedStaff;
  final int totalItems;
  final String totalAmount;

  SalesReportModel({
    required this.customerName,
    required this.enquiryFor,
    required this.date,
    required this.invoiceNo,
    required this.assignedStaff,
    required this.totalItems,
    required this.totalAmount,
  });

  factory SalesReportModel.fromJson(Map<String, dynamic> json) => SalesReportModel(
        customerName: json["Customer_Name"]?.toString() ?? "",
        enquiryFor: json["Enquiry_For"]?.toString() ?? "",
        date: json["Date"]?.toString() ?? "",
        invoiceNo: json["Invoice_No"]?.toString() ?? "",
        assignedStaff: json["Assigned_Staff"]?.toString() ?? "",
        totalItems: json["Total_Items"] ?? 0,
        totalAmount: json["TotalAmount"]?.toString() ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "Customer_Name": customerName,
        "Enquiry_For": enquiryFor,
        "Date": date,
        "Invoice_No": invoiceNo,
        "Assigned_Staff": assignedStaff,
        "Total_Items": totalItems,
        "TotalAmount": totalAmount,
      };
}
