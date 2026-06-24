import 'package:vidyanexis/controller/models/item_settings_model.dart';

class AddedMultiItem {
  final int itemId;
  final String itemName;
  double quantity;
  final String make;
  final String unitName;
  final String itemTypeId;
  final List<ItemSettings> materials;

  AddedMultiItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.make,
    required this.unitName,
    required this.materials,
    required this.itemTypeId,
  });

  // Factory constructor for JSON deserialization
  factory AddedMultiItem.fromJson(Map<String, dynamic> json) {
    return AddedMultiItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      make: json['make']?.toString() ?? '',
      unitName: json['unitName']?.toString() ?? '',
      materials: (json['materials'] as List<dynamic>? ?? [])
          .map((mat) => ItemSettings.fromJson(mat as Map<String, dynamic>))
          .toList(),
      itemTypeId: json['Item_Type_Id']?.toString() ?? '0',
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'make': make,
      'unitName': unitName,
      'Item_Type_Id': itemTypeId,
      'materials': materials.map((mat) => mat.toJson()).toList(),
    };
  }
}
