class GetMenuPermissionModel {
  int menuId;
  String menuName;
  int isView;
  int isSave;
  int isEdit;
  int isDelete;

  GetMenuPermissionModel({
    required this.menuId,
    required this.menuName,
    required this.isView,
    required this.isSave,
    required this.isEdit,
    required this.isDelete,
  });

  factory GetMenuPermissionModel.fromJson(Map<String, dynamic> json) =>
      GetMenuPermissionModel(
        menuId: json["Menu_Id"],
        menuName: json["Menu_Name"],
        isView: json["IsView"],
        isSave: json["IsSave"],
        isEdit: json["IsEdit"],
        isDelete: json["IsDelete"],
      );

  Map<String, dynamic> toJson() => {
        "Menu_Id": menuId,
        "Menu_Name": menuName,
        "IsView": isView,
        "IsSave": isSave,
        "IsEdit": isEdit,
        "IsDelete": isDelete,
      };

  GetMenuPermissionModel copyWith({
    int? menuId,
    String? menuName,
    int? isView,
    int? isSave,
    int? isEdit,
    int? isDelete,
  }) {
    return GetMenuPermissionModel(
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      isView: isView ?? this.isView,
      isSave: isSave ?? this.isSave,
      isEdit: isEdit ?? this.isEdit,
      isDelete: isDelete ?? this.isDelete,
    );
  }
}
