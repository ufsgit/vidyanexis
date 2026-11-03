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
  int? itemId;
  String? itemName;

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
    this.itemId,
    this.itemName,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final int safeItemId = itemId ?? 0;
    final String safeItemName = (itemName != null && itemName!.isNotEmpty)
        ? itemName!
        : (distributor ?? '');
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
      'Item_Id': safeItemId,
      'Item_Name': safeItemName,
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
      itemId: int.tryParse((json['Item_Id'] ??
              json['ItemId'] ??
              json['item_id'] ??
              0)
          .toString()) ??
          0,
      itemName: (json['Item_Name'] ??
              json['ItemName'] ??
              json['item_name'] ??
              '')
          .toString(),
    );
  }
}