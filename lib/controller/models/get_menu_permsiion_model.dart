class GetMenuPermissionModel {
  int menuId;
  String menuName;
  int isView;
  int isSave;
  int isEdit;
  int isDelete;
  int? deleteStatus;

  GetMenuPermissionModel({
    required this.menuId,
    required this.menuName,
    required this.isView,
    required this.isSave,
    required this.isEdit,
    required this.isDelete,
    this.deleteStatus,
  });

  factory GetMenuPermissionModel.fromJson(Map<String, dynamic> json) =>
      GetMenuPermissionModel(
        menuId: json["Menu_Id"],
        menuName: json["Menu_Name"],
        isView: json["IsView"],
        isSave: json["IsSave"],
        isEdit: json["IsEdit"],
        isDelete: json["IsDelete"],
        deleteStatus: json["DeleteStatus"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Menu_Id": menuId,
        "Menu_Name": menuName,
        "IsView": isView,
        "IsSave": isSave,
        "IsEdit": isEdit,
        "IsDelete": isDelete,
        "DeleteStatus": deleteStatus,
      };

  GetMenuPermissionModel copyWith({
    int? menuId,
    String? menuName,
    int? isView,
    int? isSave,
    int? isEdit,
    int? isDelete,
    int? deleteStatus,
  }) {
    return GetMenuPermissionModel(
      menuId: menuId ?? this.menuId,
      menuName: menuName ?? this.menuName,
      isView: isView ?? this.isView,
      isSave: isSave ?? this.isSave,
      isEdit: isEdit ?? this.isEdit,
      isDelete: isDelete ?? this.isDelete,
      deleteStatus: deleteStatus ?? this.deleteStatus,
    );
  }
}
