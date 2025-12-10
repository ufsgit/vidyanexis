class PurchaseModel {
  final int purchaseMasterId;
  final int supplierId;
  final String supplierName;
  final String invoiceNo;
  final String entryDate;
  final String purchaseDate;
  final String totalAmount;
  final String totalDiscount;
  final String taxableAmount;
  final String totalCgst;
  final String totalSgst;
  final String totalIgst;
  final String netTotal;
  final String descriptions;
  final String deleteStatus;

  PurchaseModel({
    required this.purchaseMasterId,
    required this.supplierId,
    required this.supplierName,
    required this.invoiceNo,
    required this.entryDate,
    required this.purchaseDate,
    required this.totalAmount,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.netTotal,
    required this.descriptions,
    required this.deleteStatus,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) => PurchaseModel(
        purchaseMasterId: json["Purchase_Master_Id"] ?? 0,
        supplierId: json["Supplier_Id"] ?? 0,
        supplierName: json["Supplier_Name"]?.toString() ?? "",
        invoiceNo: json["Invoice_No"]?.toString() ?? "",
        entryDate: json["EntryDate"]?.toString() ?? "",
        purchaseDate: json["purchase_Date"]?.toString() ?? "",
        totalAmount: json["TotalAmount"]?.toString() ?? "",
        totalDiscount: json["TotalDiscount"]?.toString() ?? "",
        taxableAmount: json["TaxableAmount"]?.toString() ?? "",
        totalCgst: json["Total_CGST"]?.toString() ?? "",
        totalSgst: json["Total_SGST"]?.toString() ?? "",
        totalIgst: json["Total_IGST"]?.toString() ?? "",
        netTotal: json["NetTotal"]?.toString() ?? "",
        descriptions: json["Description"]?.toString() ?? "",
        deleteStatus: json["DeleteStatus"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Purchase_Master_Id": purchaseMasterId,
        "Supplier_Id": supplierId,
        "Supplier_Name": supplierName,
        "Invoice_No": invoiceNo,
        "EntryDate": entryDate,
        "purchase_Date": purchaseDate,
        "TotalAmount": totalAmount,
        "TotalDiscount": totalDiscount,
        "TaxableAmount": taxableAmount,
        "Total_CGST": totalCgst,
        "Total_SGST": totalSgst,
        "Total_IGST": totalIgst,
        "NetTotal": netTotal,
        "Description": descriptions,
        "DeleteStatus": deleteStatus,
      };
}
