class SalesModel {
  final int salesMasterId;
  final int customerId;
  final String customerName;
  final String invoiceNo;
  final String entryDate;
  final String salesDate;
  final String totalAmount;
  final String totalDiscount;
  final String taxableAmount;
  final String totalCgst;
  final String totalSgst;
  final String totalIgst;
  final String netTotal;
  final String description;

  SalesModel({
    required this.salesMasterId,
    required this.customerId,
    required this.customerName,
    required this.invoiceNo,
    required this.entryDate,
    required this.salesDate,
    required this.totalAmount,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.netTotal,
    required this.description,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) => SalesModel(
    salesMasterId: json["Sales_Master_Id"] ?? 0,
    customerId: json["Customer_Id"] ?? 0,
    customerName: json["Customer_Name"]?.toString() ?? "",
    invoiceNo: json["Invoice_No"]?.toString() ?? "",
    entryDate: json["EntryDate"]?.toString() ?? "",
    salesDate: json["Sales_Date"]?.toString() ?? "",
    totalAmount: json["TotalAmount"]?.toString() ?? "",
    totalDiscount: json["TotalDiscount"]?.toString() ?? "",
    taxableAmount: json["TaxableAmount"]?.toString() ?? "",
    totalCgst: json["Total_CGST"]?.toString() ?? "",
    totalSgst: json["Total_SGST"]?.toString() ?? "",
    totalIgst: json["Total_IGST"]?.toString() ?? "",
    netTotal: json["NetTotal"]?.toString() ?? "",
    description: json["Description"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Sales_Master_Id": salesMasterId,
    "Customer_Id": customerId,
    "Customer_Name": customerName,
    "Invoice_No": invoiceNo,
    "EntryDate": entryDate,
    "Sales_Date": salesDate,
    "TotalAmount": totalAmount,
    "TotalDiscount": totalDiscount,
    "TaxableAmount": taxableAmount,
    "Total_CGST": totalCgst,
    "Total_SGST": totalSgst,
    "Total_IGST": totalIgst,
    "NetTotal": netTotal,
    "Description": description,
  };
}