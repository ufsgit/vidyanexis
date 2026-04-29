class StockUseReportModel {
  final String customerName;
  final String entryDate;
  final String itemName;
  final String quantity;

  StockUseReportModel({
    required this.customerName,
    required this.entryDate,
    required this.itemName,
    required this.quantity,
  });

  factory StockUseReportModel.fromJson(Map<String, dynamic> json) {
    return StockUseReportModel(
      customerName: json['Customer_Name']?.toString() ?? '',
      entryDate: json['EntryDate']?.toString() ?? '',
      itemName: json['Item_Name']?.toString() ?? '',
      quantity: json['Quantity']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Customer_Name': customerName,
      'EntryDate': entryDate,
      'Item_Name': itemName,
      'Quantity': quantity,
    };
  }
}
