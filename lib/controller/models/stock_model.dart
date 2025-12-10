class StockUseModel {
  String date;
  int stockUseId;
  String description;
  List<StockUseItems> items;

  StockUseModel({
    required this.date,
    required this.stockUseId,
    required this.description,
    required this.items,
  });

  // Optional: toJson & fromJson methods if you plan to send/receive data from API
  factory StockUseModel.fromJson(Map<String, dynamic> json) {
    return StockUseModel(
      stockUseId: json['Stock_Use_Master_Id'] ?? 0,
      date: json['EntryDate']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      items: (json['stock_use_details'] != null &&
              json['stock_use_details'] is List)
          ? (json['stock_use_details'] as List<dynamic>)
              .map((item) => StockUseItems.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EntryDate': date,
      'Descripton': description,
      'stock_use_details': items.map((e) => e.toJson()).toList(),
    };
  }
}

class StockUseItems {
  int? stockId;
  int itemId;
  String itemName;
  int categoryId;
  String categoryName;
  double quantity;
  double unitPrice;
  double amount;

  StockUseItems({
    this.stockId,
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  // Optional: for JSON serialization if needed
  factory StockUseItems.fromJson(Map<String, dynamic> json) {
    return StockUseItems(
      stockId: json['Stock_Id'] ?? 0,
      itemId: json['Item_Id'] ?? 0,
      itemName: json['Item_Name'] ?? '',
      categoryId: json['Category_Id'] ?? 0,
      categoryName: json['Category_Name'] ?? '',
      quantity: json['Qauntity'] ?? 0,
      unitPrice: json['Unit_Price'] ?? 0.0,
      amount: json['Amount'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Stock_Id': stockId,
      'Item_Id': itemId,
      'Item_Name': itemName,
      'Category_Id': categoryId,
      'Category_Name': categoryName,
      'Quantity': quantity,
      'Unit_Price': unitPrice,
      'Amount': amount,
    };
  }
}
