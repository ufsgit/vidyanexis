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
      itemName: (json['Item_Name'] ??
                  json['item_Name'] ??
                  json['ItemName'] ??
                  json['itemName'])
              ?.toString() ??
          '',
      categoryName: (json['Category_Name'] ??
                  json['category_Name'] ??
                  json['CategoryName'] ??
                  json['categoryName'])
              ?.toString() ??
          '',
      unitName: (json['Unit_Name'] ??
                  json['unit_Name'] ??
                  json['UnitName'] ??
                  json['unitName'])
              ?.toString() ??
          '',
      unitPrice: (json['Unit_Price'] ??
                  json['unit_Price'] ??
                  json['UnitPrice'] ??
                  json['unitPrice'])
              ?.toString() ??
          '',
      purchaseRate: (json['PurchaseRate'] ??
                  json['purchaseRate'] ??
                  json['Purchase_Rate'] ??
                  json['purchase_Rate'])
              ?.toString() ??
          '',
      cgst: (json['CGST'] ?? json['cgst'] ?? json['Cgst'])?.toString() ?? '',
      sgst: (json['SGST'] ?? json['sgst'] ?? json['Sgst'])?.toString() ?? '',
      quantity: (json['Quantity'] ?? json['quantity'])?.toString() ?? '',
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
