class ItemSettings {
  int itemMaterialId; // ID of the material
  String itemMaterialName; // Name of the material
  double quantity; // Quantity of the material
  int deleteStatus; // Deletion status (0 for active, 1 for deleted)

  // Constructor
  ItemSettings({
    required this.itemMaterialId,
    required this.itemMaterialName,
    required this.quantity,
    required this.deleteStatus,
  });

  // Factory method to create an instance from a JSON object
  factory ItemSettings.fromJson(Map<String, dynamic> json) {
    return ItemSettings(
      itemMaterialId: json['itemMaterialId'] ?? 0,
      itemMaterialName: json['itemMaterialName'] ?? '',
      quantity: json['quantity'] ?? 0.0,
      deleteStatus: json['Delete_Status'] ?? 0,
    );
  }

  // Method to convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'itemMaterialId': itemMaterialId,
      'itemMaterialName': itemMaterialName,
      'quantity': quantity,
      'Delete_Status': deleteStatus,
    };
  }
}
