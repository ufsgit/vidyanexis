class MenuSelectionModel {
  int? userId;
  List<UserMenuSelection>? userMenuSelection;

  MenuSelectionModel({
    this.userId,
    this.userMenuSelection,
  });

  MenuSelectionModel.fromJson(Map<String, dynamic> json) {
    userId = json['User_Id'];
    if (json['User_Menu_Selection'] != null) {
      userMenuSelection = <UserMenuSelection>[];
      json['User_Menu_Selection'].forEach((v) {
        userMenuSelection!.add(UserMenuSelection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['User_Id'] = userId;
    if (userMenuSelection != null) {
      data['User_Menu_Selection'] =
          userMenuSelection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserMenuSelection {
  int? menuId;
  int? isEdit;
  int? isSave;
  int? isDelete;
  int? isView;

  UserMenuSelection({
    this.menuId,
    this.isEdit,
    this.isSave,
    this.isDelete,
    this.isView,
  });

  UserMenuSelection.fromJson(Map<String, dynamic> json) {
    menuId = json['Menu_Id'];
    isEdit = json['IsEdit'];
    isSave = json['IsSave'];
    isDelete = json['IsDelete'];
    isView = json['IsView'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Menu_Id'] = menuId;
    data['IsEdit'] = isEdit;
    data['IsSave'] = isSave;
    data['IsDelete'] = isDelete;
    data['IsView'] = isView;
    return data;
  }
}
