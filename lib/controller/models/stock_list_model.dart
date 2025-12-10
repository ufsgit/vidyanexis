class StockEntry {
  final int stockId;
  final int customerId;
  final String customerName;
  final String entryDate;
  final int itemId;
  final String itemName;
  final int unitId;
  final String unitName;
  final int categoryId;
  final String categoryName;
  final String rate;
  final String gst;
  final String quantity;
  final String amount;

  StockEntry({
    required this.stockId,
    required this.customerId,
    required this.customerName,
    required this.entryDate,
    required this.itemId,
    required this.itemName,
    required this.unitId,
    required this.unitName,
    required this.categoryId,
    required this.categoryName,
    required this.rate,
    required this.gst,
    required this.quantity,
    required this.amount,
  });

  // Factory method to parse from a Map (e.g., from JSON)
  factory StockEntry.fromJson(Map<String, dynamic> json) {
    return StockEntry(
      stockId: json['Stock_Id'] ?? 0,
      customerId: json['Customer_Id'] ?? 0,
      customerName: json['Customer_Name'] ?? '',
      entryDate: json['Entry_Date'] ?? '',
      itemId: json['Item_Id'] ?? 0,
      itemName: json['Item_Name'] ?? '',
      unitId: json['Unit_Id'] ?? 0,
      unitName: json['Unit_Name'] ?? '',
      categoryId: json['Category_Id'] ?? 0,
      categoryName: json['Category_Name'] ?? '',
      rate: json['Rate'] ?? '0.00',
      gst: json['GST'] ?? '0.00',
      quantity: json['Quantity'] ?? '0.00',
      amount: json['Amount'] ?? '0.00',
    );
  }

  // Convert model to a Map (e.g., for JSON encoding)
  Map<String, dynamic> toMap() {
    return {
      'Stock_Id': stockId,
      'Customer_Id': customerId,
      'Customer_Name': customerName,
      'Entry_Date': entryDate,
      'Item_Id': itemId,
      'Item_Name': itemName,
      'Unit_Id': unitId,
      'Unit_Name': unitName,
      'Category_Id': categoryId,
      'Category_Name': categoryName,
      'Rate': rate,
      'GST': gst,
      'Quantity': quantity,
      'Amount': amount,
    };
  }
}
