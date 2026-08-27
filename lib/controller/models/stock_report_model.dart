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
      itemName: json['Item_Name']?.toString() ?? json['item_name']?.toString() ?? '',
      categoryName: json['Category_Name']?.toString() ?? json['category_name']?.toString() ?? '',
      unitName: json['Unit_Name']?.toString() ?? json['unit_name']?.toString() ?? json['Unit']?.toString() ?? '',
      unitPrice: json['Unit_Price']?.toString() ?? json['unit_price']?.toString() ?? json['Price']?.toString() ?? '',
      purchaseRate: json['PurchaseRate']?.toString() ??
          json['Purchase_Rate']?.toString() ??
          json['purchase_rate']?.toString() ??
          json['Rate']?.toString() ??
          json['rate']?.toString() ??
          '',
      cgst: json['CGST']?.toString() ?? json['cgst']?.toString() ?? json['Cgst']?.toString() ?? '',
      sgst: json['SGST']?.toString() ?? json['sgst']?.toString() ?? json['Sgst']?.toString() ?? '',
      quantity: json['Quantity']?.toString() ??
          json['quantity']?.toString() ??
          json['Qty']?.toString() ??
          json['qty']?.toString() ??
          json['Stock_Quantity']?.toString() ??
          json['stock_quantity']?.toString() ??
          json['Total_Qty']?.toString() ??
          json['Current_Stock']?.toString() ??
          json['Stock']?.toString() ??
          json['stock']?.toString() ??
          json['Stock_Qty']?.toString() ??
          json['stock_qty']?.toString() ??
          '',
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
