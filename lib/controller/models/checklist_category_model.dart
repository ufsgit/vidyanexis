// To parse this JSON data, do
//
//     final checkListCategoryModel = checkListCategoryModelFromJson(jsonString);

import 'dart:convert';

import 'package:vidyanexis/controller/models/checklist_item_model.dart';

CheckListCategoryModel checkListCategoryModelFromJson(String str) =>
    CheckListCategoryModel.fromJson(json.decode(str));

String checkListCategoryModelToJson(CheckListCategoryModel data) =>
    json.encode(data.toJson());

class CheckListCategoryModel {
  int? checkListCategoryId;
  String? checkListCategoryName;
  List<CheckListItemModel>? items;

  CheckListCategoryModel({
    this.checkListCategoryId,
    this.checkListCategoryName,
    this.items,
  });

  CheckListCategoryModel copyWith(
          {int? checkListCategoryId,
          String? checkListCategoryName,
          List<CheckListItemModel>? items}) =>
      CheckListCategoryModel(
        checkListCategoryId: checkListCategoryId ?? this.checkListCategoryId,
        checkListCategoryName:
            checkListCategoryName ?? this.checkListCategoryName,
        items: items ?? this.items,
      );

  factory CheckListCategoryModel.fromJson(Map<String, dynamic> json) =>
      CheckListCategoryModel(
        checkListCategoryId: json["Check_List_Category_Id"],
        checkListCategoryName: json["Check_List_Category_Name"],
        items: json["items"] == null
            ? []
            : List<CheckListItemModel>.from(
                json["items"]!.map((x) => CheckListItemModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Check_List_Category_Id": checkListCategoryId,
        "Check_List_Category_Name": checkListCategoryName,
        "items": items == null
            ? []
            : List<CheckListItemModel>.from(items ?? [].map((x) => x.toJson())),
      };
}
