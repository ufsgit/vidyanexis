import 'package:vidyanexis/controller/models/item_settings_model.dart';

class AddedMultiItem {
  final int itemId;
  final String itemName;
  double quantity;
  final List<ItemSettings> materials;

  AddedMultiItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.materials,
  });

  // Factory constructor for JSON deserialization
  factory AddedMultiItem.fromJson(Map<String, dynamic> json) {
    return AddedMultiItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      materials: (json['materials'] as List<dynamic>? ?? [])
          .map((mat) => ItemSettings.fromJson(mat as Map<String, dynamic>))
          .toList(),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'materials': materials.map((mat) => mat.toJson()).toList(),
    };
  }
}