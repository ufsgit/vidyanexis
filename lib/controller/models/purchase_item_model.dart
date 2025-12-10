class PurchaseItemModel {
  final String itemId;
  final String itemName;
  final String categoryId;
  final String categoryName;
  final String unitId;
  final String unitName;
  final double cgst;
  final double sgst;
  final double gst;
  final double igst;
  final double price;
  final double quantity;
  // final double unitPrice;
  final double amount;
  final double discountPercentage;
  final double discount;
  final double netValue;
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String hsnCode;

  PurchaseItemModel({
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    required this.cgst,
    required this.sgst,
    required this.gst,
    required this.igst,
    required this.price,
    required this.quantity,
    // required this.unitPrice,
    required this.amount,
    required this.discountPercentage,
    required this.discount,
    required this.netValue,
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.hsnCode,
  });

  // Convert from JSON (useful for JSON parsing)
  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      itemId: json['Item_Id']?.toString() ?? '',
      itemName: json['Item_Name'] ?? '',
      categoryId: json['Category_Id']?.toString() ?? '',
      categoryName: json['Category_Name'] ?? '',
      unitId: json['Unit_Id']?.toString() ?? '',
      unitName: json['Unit_Name'] ?? '',
      cgst: double.tryParse(json['CGST']?.toString() ?? '0') ?? 0.0,
      sgst: double.tryParse(json['SGST']?.toString() ?? '0') ?? 0.0,
      gst: double.tryParse(json['GST']?.toString() ?? '0') ?? 0.0,
      igst: double.tryParse(json['IGST']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['Price']?.toString() ?? '0') ?? 0.0,
      quantity: double.tryParse(json['Quantity']?.toString() ?? '0') ?? 0.0,
      // unitPrice: double.tryParse(json['UnitPrice']?.toString() ?? '0') ?? 0.0,
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      discountPercentage:
          double.tryParse(json['Discount_Percentage']?.toString() ?? '0') ??
              0.0,
      discount: double.tryParse(json['Discount']?.toString() ?? '0') ?? 0.0,
      netValue: double.tryParse(json['Netvalue']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['GST_Amount']?.toString() ?? '0') ?? 0.0,
      cgstAmount:
          double.tryParse(json['CGST_Amount']?.toString() ?? '0') ?? 0.0,
      sgstAmount:
          double.tryParse(json['SGST_Amount']?.toString() ?? '0') ?? 0.0,
      igstAmount:
          double.tryParse(json['IGST_Amount']?.toString() ?? '0') ?? 0.0,
      totalAmount:
          double.tryParse(json['Total_Amount']?.toString() ?? '0') ?? 0.0,
      hsnCode: json['HSNCode']?.toString() ?? '0',
    );
  }

  // Convert to JSON (useful for saving to database or API request)
  Map<String, dynamic> toJson() {
    return {
      'ItemId': itemId,
      'ItemName': itemName,
      'Category_Id': categoryId,
      'Category_Name': categoryName,
      'Unit_Id': unitId,
      'Unit_Name': unitName,
      'CGST': cgst,
      'SGST': sgst,
      'GST': gst,
      'IGST': igst,
      'Price': price,
      'Quantity': quantity,
      // 'UnitPrice': unitPrice,
      'Amount': amount,
      'Discount_Percentage': discountPercentage,
      'Discount': discount,
      'Netvalue': netValue,
      'GST_Amount': gstAmount,
      'CGST_Amount': cgstAmount,
      'SGST_Amount': sgstAmount,
      'IGST_Amount': igstAmount,
      'Total_Amount': totalAmount,
      'HSNCode': hsnCode,
    };
  }
}
