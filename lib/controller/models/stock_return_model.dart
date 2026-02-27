class StockReturnModel {
  String? entryDate;
  String returnDate;
  int stockReturnId;
  int userId;
  String description;
  String? searchEntryDate;
  List<StockReturnItems> items;

  StockReturnModel({
    this.entryDate,
    required this.returnDate,
    required this.stockReturnId,
    required this.userId,
    required this.description,
    this.searchEntryDate,
    required this.items,
  });

  // Optional: toJson & fromJson methods if you plan to send/receive data from API
  factory StockReturnModel.fromJson(Map<String, dynamic> json) {
    return StockReturnModel(
      stockReturnId: json['Stock_Return_Master_Id'] ?? 0,
      entryDate: json['EntryDate']?.toString(),
      returnDate: json['ReturnDate']?.toString() ?? '',
      userId: json['User_Id'] ?? 0,
      searchEntryDate: json['search_Entrydate']?.toString(),
      description: json['Description']?.toString() ?? '',
      items: (json['stock_return_details'] != null &&
              json['stock_return_details'] is List)
          ? (json['stock_return_details'] as List<dynamic>)
              .map((item) => StockReturnItems.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'EntryDate': entryDate,
      'ReturnDate': returnDate,
      'User_Id': userId,
      'Description': description,
      'search_Entrydate': searchEntryDate,
      'stock_return_details': items.map((e) => e.toJson()).toList(),
    };
  }
}

class StockReturnItems {
  int? stockReturnId;
  int itemId;
  String itemName;
  int categoryId;
  String categoryName;
  double quantity;
  double unitPrice;
  double amount;

  StockReturnItems({
    this.stockReturnId,
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  // Optional: for JSON serialization if needed
  factory StockReturnItems.fromJson(Map<String, dynamic> json) {
    return StockReturnItems(
      stockReturnId: json['Stock_Id'] ?? 0,
      itemId: json['Item_Id'] ?? 0,
      itemName: json['Item_Name'] ?? '',
      categoryId: json['Category_Id'] ?? 0,
      categoryName: json['Category_Name'] ?? '',
      quantity: json['Quantity'] ?? 0,
      unitPrice: json['Unit_Price'] ?? 0.0,
      amount: json['Amount'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Stock_Id': stockReturnId,
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
