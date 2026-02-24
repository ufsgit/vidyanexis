class StockReportModel {
  final String itemName;
  final String categoryName;
  final String unitName;
  final String unitPrice;
  final String purchaseRate;
  final String cgst;
  final String sgst;
  final String quantity;

  StockReportModel({
    required this.itemName,
    required this.categoryName,
    required this.unitName,
    required this.unitPrice,
    required this.purchaseRate,
    required this.cgst,
    required this.sgst,
    required this.quantity,
  });

  factory StockReportModel.fromJson(Map<String, dynamic> json) {
    return StockReportModel(
      itemName: json['Item_Name']?.toString() ?? '',
      categoryName: json['Category_Name']?.toString() ?? '',
      unitName: json['Unit_Name']?.toString() ?? '',
      unitPrice: json['Unit_Price']?.toString() ?? '',
      purchaseRate: json['PurchaseRate']?.toString() ?? '',
      cgst: json['CGST']?.toString() ?? '',
      sgst: json['SGST']?.toString() ?? '',
      quantity: json['Quantity']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item_Name': itemName,
      'Category_Name': categoryName,
      'Unit_Name': unitName,
      'Unit_Price': unitPrice,
      'PurchaseRate': purchaseRate,
      'CGST': cgst,
      'SGST': sgst,
      'Quantity': quantity,
    };
  }
}
