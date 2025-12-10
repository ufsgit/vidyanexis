import 'package:flutter/material.dart';

class MenuModel {
  final int menuId;
  final String menuName;
  int isView;
  int isSave;
  int isEdit;
  int isDelete;
  Widget? widget;

  MenuModel({
    required this.menuId,
    required this.menuName,
    this.isView = 0,
    this.isSave = 0,
    this.isEdit = 0,
    this.isDelete = 0,
    this.widget,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      menuId: json['Menu_Id'] ?? 0,
      menuName: json['Menu_Name'] ?? '',
      isView: json['IsView'] ?? 0,
      isSave: json['IsSave'] ?? 0,
      isEdit: json['IsEdit'] ?? 0,
      isDelete: json['IsDelete'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Menu_Id': menuId,
      'Menu_Name': menuName,
      'IsView': isView,
      'IsSave': isSave,
      'IsEdit': isEdit,
      'IsDelete': isDelete,
    };
  }

  MenuModel copyWith({
    int? menuId,
    String? menuName,
    int? isView,
    int? isSave,
    int? isEdit,
    int? isDelete,
  }) {
    return MenuModel(
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      isView: isView ?? this.isView,
      isSave: isSave ?? this.isSave,
      isEdit: isEdit ?? this.isEdit,
      isDelete: isDelete ?? this.isDelete,
    );
  }
}
