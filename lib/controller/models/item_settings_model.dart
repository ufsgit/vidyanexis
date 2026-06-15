class ItemSettings {
  int subItemId; // ID of the material
  int itemMaterialId;
  String itemMaterialName; // Name of the material
  double quantity; // Quantity of the material
  double price;
  int deleteStatus; // Deletion status (0 for active, 1 for deleted)
  String specification;
  String manufacture;
  String unit;
  String priceFrom;
  String priceTo;
  double amount;

  // Constructor
  ItemSettings({
    required this.subItemId,
    required this.itemMaterialId,
    required this.itemMaterialName,
    required this.quantity,
    required this.price,
    required this.deleteStatus,
    required this.specification,
    required this.manufacture,
    required this.unit,
    this.priceFrom = '',
    this.priceTo = '',
    this.amount = 0.0,
  });

  // Factory method to create an instance from a JSON object
  factory ItemSettings.fromJson(Map<String, dynamic> json) {
    return ItemSettings(
      subItemId: json['Sub_Item_Id'] ?? 0,
      itemMaterialId: json["itemMaterialId"] ?? 0,
      itemMaterialName: json['itemMaterialName'] ?? '',
      quantity: json['quantity'] ?? 0.0,
      price: json['price'] ?? 0.0,
      deleteStatus: json['Delete_Status'] ?? 0,
      specification: json['Specification'] ?? '',
      manufacture: json['Manufacture'] ?? '',
      unit: json['Unit'] ?? '',
      priceFrom: json['Price_Range_From']?.toString() ?? '',
      priceTo: json['Price_Range_To']?.toString() ?? '',
      amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Method to convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'Sub_Item_Id': subItemId,
      "itemMaterialId": itemMaterialId,
      'itemMaterialName': itemMaterialName,
      'quantity': quantity,
      "price": price,
      'Delete_Status': deleteStatus,
      'Specification': specification,
      'Manufacture': manufacture,
      'Unit': unit,
      'Price_Range_From': priceFrom,
      'Price_Range_To': priceTo,
      'Amount': amount,
    };
  }
}
