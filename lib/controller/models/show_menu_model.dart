class MenuPermissionModel {
  int menuId;
  String menuName;
  int menuOrder;
  int menuOrderSub;
  int isEdit;
  int isSave;
  int isDelete;
  int isView;
  int menuStatus;
  int menuType;

  // Constructor
  MenuPermissionModel({
    required this.menuId,
    required this.menuName,
    required this.menuOrder,
    required this.menuOrderSub,
    required this.isEdit,
    required this.isSave,
    required this.isDelete,
    required this.isView,
    required this.menuStatus,
    required this.menuType,
  });

  // Factory constructor to create the model from JSON data with default values for nulls
  factory MenuPermissionModel.fromJson(Map<String, dynamic> json) {
    return MenuPermissionModel(
      menuId: json['Menu_Id'] ?? 0, // Defaults to 0 if null
      menuName: json['Menu_Name'] ?? '', // Defaults to empty string if null
      menuOrder: json['Menu_Order'] ?? 0, // Defaults to 0 if null
      menuOrderSub: json['Menu_Order_Sub'] ?? 0, // Defaults to 0 if null
      isEdit: json['IsEdit'] ?? 0, // Defaults to 0 if null
      isSave: json['IsSave'] ?? 0, // Defaults to 0 if null
      isDelete: json['IsDelete'] ?? 0, // Defaults to 0 if null
      isView: json['IsView'] ?? 0, // Defaults to 0 if null
      menuStatus: json['Menu_Status'] ?? 0, // Defaults to 0 if null
      menuType: json['Menu_Type'] ?? 0, // Defaults to 0 if null
    );
  }

  // Method to convert the model to JSON map
  Map<String, dynamic> toJson() {
    return {
      'Menu_Id': menuId, // No need for null check since menuId is non-nullable
      'Menu_Name': menuName, // No need for null check
      'Menu_Order': menuOrder, // No need for null check
      'Menu_Order_Sub': menuOrderSub, // No need for null check
      'IsEdit': isEdit, // No need for null check
      'IsSave': isSave, // No need for null check
      'IsDelete': isDelete, // No need for null check
      'IsView': isView, // No need for null check
      'Menu_Status': menuStatus, // No need for null check
      'Menu_Type': menuType, // No need for null check
    };
  }
}
