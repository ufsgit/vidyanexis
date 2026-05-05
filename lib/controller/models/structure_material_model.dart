class StructureMaterialItem {
  int? id;
  String items;
  String qty;
  String brand;

  StructureMaterialItem({
    this.id,
    required this.items,
    required this.qty,
    required this.brand,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Items': items,
      'Qty': qty,
      'Brand': brand,
    };
  }

  // Create from JSON
  factory StructureMaterialItem.fromJson(Map<String, dynamic> json) {
    return StructureMaterialItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      items: json['Items'] ?? '',
      qty: json['Qty']?.toString() ?? '',
      brand: json['Brand'] ?? '',
    );
  }
}
