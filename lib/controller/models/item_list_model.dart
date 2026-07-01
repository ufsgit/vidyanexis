import 'package:vidyanexis/controller/models/item_settings_model.dart';

class ItemListModel {
  int itemId; // ID of the item
  String itemName; // Name of the item
  int categoryId; // ID of the category
  String categoryName; // Name of the category
  String quantity; // Name of the category

  int unitId; // ID of the unit
  String unitName; // Name of the unit
  String unitPrice; // Name of the unit
  String cgst; // CGST value
  String sgst; // SGST value
  String gst; // Total GST value
  String igst; // IGST value
  int serviceCheckbox; // IGST value
  int primaryCheckBox; // IGST value
  int stockId;
  String hsnCode;
  String priceFrom;
  String priceTo;
  List<ItemSettings> multiItemMaterials;
  String itemDescription;

  // Constructor
  ItemListModel({
    required this.itemId,
    required this.stockId,
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
    required this.quantity,
    required this.primaryCheckBox,
    this.itemDescription = '',
    this.priceFrom = '',
    this.priceTo = '',
    this.multiItemMaterials = const [],
  });

  // Factory method to create an instance from a JSON object
  factory ItemListModel.fromJson(Map<String, dynamic> json) {
    return ItemListModel(
      quantity: json["quantity"]?.toString() ?? '',
      itemId: json['itemId'] ?? 0,
      stockId: json['Stock_Id'] ?? 0,
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
      primaryCheckBox: json["Is_Primary"] ?? 0,
      hsnCode: json['HSNCode']?.toString() ?? '',
      priceFrom: json['Price_Range_From']?.toString() ?? '',
      priceTo: json['Price_Range_To']?.toString() ?? '',
      multiItemMaterials: (json['itemMaterials'] as List<dynamic>? ?? [])
          .map((material) =>
              ItemSettings.fromJson(material as Map<String, dynamic>))
          .toList(),
      itemDescription: json['Description']?.toString() ?? '',
    );
  }

  // Method to convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'Stock_Id': stockId,
      "quantity": quantity,
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
      'Price_Range_From': priceFrom,
      'Price_Range_To': priceTo,
      'itemMaterials': multiItemMaterials.map((m) => m.toJson()).toList(),
      "Description": itemDescription,
    };
  }
}
