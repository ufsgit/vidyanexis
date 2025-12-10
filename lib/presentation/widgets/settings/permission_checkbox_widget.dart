import 'package:flutter/material.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/models/menu_permission_model.dart';

Widget buildPermissionCheckbox({
  required MenuPermissionsItem item,
  required String permissionType,
  required Function(bool?) onChanged,
}) {
  return SizedBox(
    width: 100,
    child: Center(
      child: Checkbox(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        activeColor: AppColors.primaryBlue,
        value: switch (permissionType) {
          'view' => item.isView,
          'edit' => item.isEdit,
          'save' => item.isSave,
          'delete' => item.isDelete,
          _ => false,
        },
        onChanged: onChanged,
      ),
    ),
  );
}
