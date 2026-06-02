class BillOfMaterialItem {
  int? id;
  String description;
  String brand;
  String quantity;
  String uom;
  String? distributor;
  String? comments;
  String? price;
  String? amount;
  String? priceFrom;
  String? priceTo;

  BillOfMaterialItem({
    this.id,
    required this.description,
    required this.brand,
    required this.quantity,
    required this.uom,
    this.distributor,
    this.comments,
    this.price,
    this.amount,
    this.priceFrom,
    this.priceTo,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'Items_And_Description': description,
      'make': brand,
      'Quantity': quantity,
      'Distributor': distributor ?? '',
      'Invoice_No': comments ?? '',
      'UOM': uom,
      'Price': price ?? '',
      'Amount': amount ?? '',
      'Price_Range_From': priceFrom ?? '',
      'Price_Range_To': priceTo ?? '',
    };
  }

  // Create from JSON
  factory BillOfMaterialItem.fromJson(Map<String, dynamic> json) {
    return BillOfMaterialItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      description: json['Items_And_Description'] ?? '',
      brand: json['make'] ?? '',
      quantity: json['Quantity']?.toString() ?? '',
      distributor: json['Distributor'],
      comments: json['Invoice_No'],
      uom: json['UOM'] ?? '',
      price: json['Price']?.toString() ?? '',
      amount: json['Amount']?.toString() ?? '',
      priceFrom: json['Price_Range_From']?.toString() ?? '',
      priceTo: json['Price_Range_To']?.toString() ?? '',
    );
  }
}
