class ItemListModel {
  int itemId; // ID of the item
  String itemName; // Name of the item
  int categoryId; // ID of the category
  String categoryName; // Name of the category
  int unitId; // ID of the unit
  String unitName; // Name of the unit
  String unitPrice; // Name of the unit
  String cgst; // CGST value
  String sgst; // SGST value
  String gst; // Total GST value
  String igst; // IGST value
  int serviceCheckbox; // IGST value
  String hsnCode;

  // Constructor
  ItemListModel({
    required this.itemId,
    required this.itemName,
    required this.categoryId,
    required this.categoryName,
    required this.unitId,
    required this.unitName,
    required this.unitPrice,
    required this.cgst,
    required this.sgst,
    required this.gst,
    required this.igst,
    required this.serviceCheckbox,
    required this.hsnCode,
  });

  // Factory method to create an instance from a JSON object
  factory ItemListModel.fromJson(Map<String, dynamic> json) {
    return ItemListModel(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName']?.toString() ?? '',
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName']?.toString() ?? '',
      unitId: json['unitId'] ?? 0,
      unitName: json['unitName']?.toString() ?? '',
      unitPrice: json['Unit_Price']?.toString() ?? '0',
      cgst: json['cgst']?.toString() ?? '0.00',
      sgst: json['sgst']?.toString() ?? '0.00',
      gst: json['gst']?.toString() ?? '0.00',
      igst: json['igst']?.toString() ?? '0.00',
      serviceCheckbox: json['Service_CheckBox'] ?? 0,
      hsnCode: json['HSNCode']?.toString() ?? '',
    );
  }

  // Method to convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'unitId': unitId,
      'unitName': unitName,
      'Unit_Price': unitPrice,
      'cgst': cgst,
      'sgst': sgst,
      'gst': gst,
      'igst': igst,
      'Service_CheckBox': serviceCheckbox,
    };
  }
}
