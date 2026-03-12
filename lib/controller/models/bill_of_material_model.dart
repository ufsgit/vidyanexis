class BillOfMaterialItem {
  int? id;
  String description;
  String brand;
  double quantity;
  String uom;
  String? distributor;
  String? comments;

  BillOfMaterialItem({
    this.id,
    required this.description,
    required this.brand,
    required this.quantity,
    required this.uom,
    this.distributor,
    this.comments,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Items_And_Description': description,
      'make': brand,
      'Quantity': quantity,
      'Distributor': distributor,
      'Invoice_No': comments,
      'UOM': uom,
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
      quantity: double.tryParse(json['Quantity']?.toString() ?? '0') ?? 0,
      distributor: json['Distributor'],
      comments: json['Invoice_No'],
      uom: json['UOM'] ?? '',
    );
  }
}
