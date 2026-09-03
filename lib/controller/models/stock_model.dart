class StockUseModel {
  String date;
  int stockUseId;
  String description;
  List<StockUseItems> items;
  String stockStatus;

  StockUseModel({
    required this.date,
    required this.stockUseId,
    required this.description,
    required this.items,
    required this.stockStatus,
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
      stockStatus: json['Status'] ?? 'Pending',
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
  bool isChecked;
  double total;

  StockUseItems({
    this.stockId,
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
    this.isChecked = false,
    this.total = 0.0,
  });

  // Optional: for JSON serialization if needed
  factory StockUseItems.fromJson(Map<String, dynamic> json) {
    return StockUseItems(
      stockId: int.tryParse(json['Stock_Id']?.toString() ?? '0') ?? 0,
      itemId: int.tryParse(json['Item_Id']?.toString() ?? '0') ?? 0,
      itemName: json['Item_Name'] ?? '',
      categoryId: json['Category_Id'] ?? 0,
      categoryName: json['Category_Name'] ?? '',
      quantity: double.tryParse(json['Qauntity']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['Unit_Price']?.toString() ?? '0') ?? 0.0,
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      isChecked: json['Is_Checked']?.toString() == '1' ||
          json['Is_Checked']?.toString() == 'true' ||
          json['isChecked']?.toString() == '1' ||
          json['isChecked']?.toString() == 'true' ||
          json['ischecked']?.toString() == '1' ||
          json['ischecked']?.toString() == 'true' ||
          json['is_checked']?.toString() == '1' ||
          json['is_checked']?.toString() == 'true' ||
          json['Is_Check_List']?.toString() == '1' ||
          json['Is_Check_List']?.toString() == 'true',
      total: double.tryParse(json['Total']?.toString() ?? '0') ?? 0.0,
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
      'Is_Checked': isChecked ? 1 : 0,
      'ischecked': isChecked ? 1 : 0,
      'Total': total,
    };
  }
}
