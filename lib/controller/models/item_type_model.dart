class ItemTypeModel {
  final int itemTypeId;
  final String itemTypeName;

  ItemTypeModel({
    required this.itemTypeId,
    required this.itemTypeName,
  });

  factory ItemTypeModel.fromJson(Map<String, dynamic> json) {
    return ItemTypeModel(
      itemTypeId: json['Item_Type_Id'] ?? 0,
      itemTypeName: json['Item_Type_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item_Type_Id': itemTypeId,
      'Item_Type_Name': itemTypeName,
    };
  }
}
