class InvoicePrintItemModel {
  final String hsnCode;
  final String itemNames;
  final String totalQuantity;
  final String totalGst;
  final String totalRate;
  final String totalAmount;

  InvoicePrintItemModel({
    required this.hsnCode,
    required this.itemNames,
    required this.totalQuantity,
    required this.totalGst,
    required this.totalRate,
    required this.totalAmount,
  });

  factory InvoicePrintItemModel.fromJson(Map<String, dynamic> json) {
    return InvoicePrintItemModel(
      hsnCode: json['hsn_code']?.toString() ?? '',
      itemNames: json['item_names']?.toString() ?? '',
      totalQuantity: json['total_quantity']?.toString() ?? '',
      totalGst: json['total_gst']?.toString() ?? '',
      totalRate: json['total_rate']?.toString() ?? '',
      totalAmount: json['total_amount']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hsn_code': hsnCode,
      'item_names': itemNames,
      'total_quantity': totalQuantity,
      'total_gst': totalGst,
      'total_rate': totalRate,
      'total_amount': totalAmount,
    };
  }
}
