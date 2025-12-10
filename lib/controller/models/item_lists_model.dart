class ItemListStock {
  final int stockId;
  final int itemId;
  final String itemName;
  final int categoryId;
  final String categoryName;
  final String unitPrice;

  ItemListStock({
    required this.stockId,
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.unitPrice,
  });

  factory ItemListStock.fromJson(Map<String, dynamic> json) {
    return ItemListStock(
      stockId: json['Stock_Id'],
      itemId: json['Item_Id'],
      itemName: json['Item_Name'],
      categoryId: json['Category_Id'],
      categoryName: json['Category_Name'],
      unitPrice: json['Unit_Price']?.toString() ?? "0.0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Stock_Id': stockId,
      'Item_Id': itemId,
      'Item_Name': itemName,
      'Category_Id': categoryId,
      'Category_Name': categoryName,
      'Unit_Price': unitPrice,
    };
  }
}
