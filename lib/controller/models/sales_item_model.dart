class SalesItemModel {
  final String itemId;
  final String itemName;
  final String categoryId;
  final String categoryName;
  final String unitId;
  final String unitName;
  final double quantity;
  final double price;
  final double amount;
  final double discount;
  final double discountPercentage;
  final double netValue;
  final double cgst;
  final double sgst;
  final double gst;
  final double igst;
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String hsnCode;

  SalesItemModel({
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.discount,
    required this.discountPercentage,
    required this.netValue,
    required this.cgst,
    required this.sgst,
    required this.gst,
    required this.igst,
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.hsnCode,
  });

  // Fixed toJson with correct field names matching API expectations
  Map<String, dynamic> toJson() {
    return {
      "Item_Id": itemId,
      "Item_Name": itemName,
      "Category_Id": categoryId,
      "Category_Name": categoryName,
      "Unit_Id": unitId,
      "Unit_Name": unitName,
      "Quantity": quantity,
      "Price": price,
      "Amount": amount,
      "Discount_Percentage": discountPercentage,
      "Discount": discount,
      "Netvalue": netValue,
      "CGST": cgst,
      "SGST": sgst,
      "GST": gst,
      "IGST": igst,
      "CGST_Amount": cgstAmount,
      "SGST_Amount": sgstAmount,
      "GST_Amount": gstAmount,
      "IGST_Amount": igstAmount,
      "Total_Amount": totalAmount,
      "HSNCode": hsnCode,
    };
  }

  factory SalesItemModel.fromJson(Map<String, dynamic> json) {
    return SalesItemModel(
      itemId: json['Item_Id']?.toString() ?? '',
      itemName: json['Item_Name']?.toString() ?? '',
      categoryId: json['Category_Id']?.toString() ?? '',
      categoryName: json['Category_Name']?.toString() ?? '',
      unitId: json['Unit_Id']?.toString() ?? '',
      unitName: json['Unit_Name']?.toString() ?? '',
      quantity: double.tryParse(json['Quantity']?.toString() ?? '0') ?? 0.0,
      price: double.tryParse(json['Price']?.toString() ?? '0') ?? 0.0,
      amount: double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['Discount']?.toString() ?? '0') ?? 0.0,
      discountPercentage: double.tryParse(json['Discount_Percentage']?.toString() ?? '0') ?? 0.0,
      netValue: double.tryParse(json['Netvalue']?.toString() ?? '0') ?? 0.0,
      cgst: double.tryParse(json['CGST']?.toString() ?? '0') ?? 0.0,
      sgst: double.tryParse(json['SGST']?.toString() ?? '0') ?? 0.0,
      gst: double.tryParse(json['GST']?.toString() ?? '0') ?? 0.0,
      igst: double.tryParse(json['IGST']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['GST_Amount']?.toString() ?? '0') ?? 0.0,
      cgstAmount: double.tryParse(json['CGST_Amount']?.toString() ?? '0') ?? 0.0,
      sgstAmount: double.tryParse(json['SGST_Amount']?.toString() ?? '0') ?? 0.0,
      igstAmount: double.tryParse(json['IGST_Amount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['Total_Amount']?.toString() ?? '0') ?? 0.0,
      hsnCode: json['HSNCode']?.toString() ?? '',
    );
  }
}