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
    String rawQuantity = json['Quantity']?.toString() ?? '0';
    // Remove trailing zeros and decimal point (e.g., "1.000" -> "1")
    if (rawQuantity.contains('.')) {
      rawQuantity = rawQuantity.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }

    return StockUseReportModel(
      customerName: json['Customer_Name']?.toString() ?? '',
      entryDate: json['EntryDate']?.toString() ?? '',
      itemName: json['Item_Name']?.toString() ?? '',
      quantity: rawQuantity.isEmpty ? '0' : rawQuantity,
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
