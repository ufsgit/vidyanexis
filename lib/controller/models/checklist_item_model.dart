// To parse this JSON data, do
//
//     final checkListItemModel = checkListItemModelFromJson(jsonString);

import 'dart:convert';

CheckListItemModel checkListItemModelFromJson(String str) => CheckListItemModel.fromJson(json.decode(str));

String checkListItemModelToJson(CheckListItemModel data) => json.encode(data.toJson());

class CheckListItemModel {
  int? checkListItemId;
  String? checkListItemName;
  int? checkListCategoryId;
  String? checkListCategoryName;
  bool? isChecked;

  CheckListItemModel({
    this.checkListItemId,
    this.checkListItemName,
    this.checkListCategoryId,
    this.checkListCategoryName,
    this.isChecked,
  });

  CheckListItemModel copyWith({
    int? checkListItemId,
    String? checkListItemName,
    int? checkListCategoryId,
    String? checkListCategoryName,
    bool? isChecked,
  }) =>
      CheckListItemModel(
        checkListItemId: checkListItemId ?? this.checkListItemId,
        checkListItemName: checkListItemName ?? this.checkListItemName,
        checkListCategoryId: checkListCategoryId ?? this.checkListCategoryId,
        checkListCategoryName: checkListCategoryName ?? this.checkListCategoryName,
        isChecked: isChecked ?? this.isChecked,
      );

  factory CheckListItemModel.fromJson(Map<String, dynamic> json) => CheckListItemModel(
    checkListItemId: json["Check_List_Item_Id"],
    checkListItemName: json["Check_List_Item_Name"],
    checkListCategoryId: json["Check_List_Category_Id"],
    checkListCategoryName: json["Check_List_Category_Name"],
    isChecked: json["Is_Check_List"],
  );

  Map<String, dynamic> toJson() => {
    "Check_List_Item_Id": checkListItemId,
    "Check_List_Item_Name": checkListItemName,
    "Check_List_Category_Id": checkListCategoryId,
    "Check_List_Category_Name": checkListCategoryName,
    "Is_Check_List": (isChecked??false)?1:0,
  };
}
