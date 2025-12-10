class MenuPermissionsItem {
  final int menuId;
  bool isEdit;
  bool isSave;
  bool isDelete;
  bool isView;

  MenuPermissionsItem({
    required this.menuId,
    this.isEdit = false,
    this.isSave = false,
    this.isDelete = false,
    this.isView = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'Menu_Id': menuId,
      'IsEdit': isEdit ? 1 : 0,
      'IsSave': isSave ? 1 : 0,
      'IsDelete': isDelete ? 1 : 0,
      'IsView': isView ? 1 : 0,
    };
  }
}
