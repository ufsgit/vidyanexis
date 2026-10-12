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
        menuId: int.tryParse(json["Menu_Id"]?.toString() ??
                json["menu_id"]?.toString() ??
                "0") ??
            0,
        menuName: json["Menu_Name"]?.toString() ??
            json["menu_name"]?.toString() ??
            "",
        isView: int.tryParse(json["IsView"]?.toString() ??
                json["is_view"]?.toString() ??
                json["isView"]?.toString() ??
                "0") ??
            0,
        isSave: int.tryParse(json["IsSave"]?.toString() ??
                json["is_save"]?.toString() ??
                json["isSave"]?.toString() ??
                "0") ??
            0,
        isEdit: int.tryParse(json["IsEdit"]?.toString() ??
                json["is_edit"]?.toString() ??
                json["isEdit"]?.toString() ??
                "0") ??
            0,
        isDelete: int.tryParse(json["IsDelete"]?.toString() ??
                json["is_delete"]?.toString() ??
                json["isDelete"]?.toString() ??
                "0") ??
            0,
        deleteStatus: int.tryParse(json["DeleteStatus"]?.toString() ??
                json["delete_status"]?.toString() ??
                "0") ??
            0,
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
