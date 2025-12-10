import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/models/dummy_models.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class PermissionHandlingUserWidget extends StatelessWidget {
  final String userName;
  final String userId;
  const PermissionHandlingUserWidget(
      {super.key, required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    void updatePermission(int menuId, String permissionType, bool value) {
      settingsProvider.updateMenuPermission(
          menuId, permissionType, value ? 1 : 0);
    }

    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section remains the same
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Permissions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User: $userName',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table Header remains the same
            if (AppStyles.isWebScreen(context))
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: Text(
                          'No.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Menu name',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ),
                    ...['View', 'Save', 'Edit', 'Delete']
                        .map((label) => SizedBox(
                              // ...['View'].map((label) => SizedBox(
                              width: 100,
                              child: Center(
                                child: Text(
                                  label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textGrey3,
                                  ),
                                ),
                              ),
                            )),
                  ],
                ),
              ),

            // Updated Table Content with working checkboxes
            AppStyles.isWebScreen(context)
                ? Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: settingsProvider.getMenu.length,
                      itemBuilder: (context, index) {
                        final item = settingsProvider.getMenu[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                child: Center(
                                  child: Text(
                                    '${item.menuId}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.menuName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ),
                              settingsProvider.showView[item.menuId] == 1
                                  ? CheckboxCell(
                                      value: item.isView == 1,
                                      onChanged: (value) => updatePermission(
                                          item.menuId,
                                          'isView',
                                          value ?? false),
                                    )
                                  : Container(width: 100),
                              settingsProvider.showSave[item.menuId] == 1
                                  ? CheckboxCell(
                                      value: item.isSave == 1,
                                      onChanged: (value) => updatePermission(
                                          item.menuId,
                                          'isSave',
                                          value ?? false),
                                    )
                                  : Container(width: 100),
                              settingsProvider.showEdit[item.menuId] == 1
                                  ? CheckboxCell(
                                      value: item.isEdit == 1,
                                      onChanged: (value) => updatePermission(
                                          item.menuId,
                                          'isEdit',
                                          value ?? false),
                                    )
                                  : Container(width: 100),
                              settingsProvider.showDelete[item.menuId] == 1
                                  ? CheckboxCell(
                                      value: item.isDelete == 1,
                                      onChanged: (value) => updatePermission(
                                          item.menuId,
                                          'isDelete',
                                          value ?? false),
                                    )
                                  : Container(width: 100),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                //mobile design
                : Expanded(
                    child: ListView.builder(
                      itemCount: settingsProvider.getMenu.length,
                      itemBuilder: (context, index) {
                        final item = settingsProvider.getMenu[index];
                        return Card(
                          color: AppColors.whiteColor,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.menuName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (settingsProvider
                                            .showView[item.menuId] ==
                                        1)
                                      CheckboxCellMobile(
                                        label: 'View',
                                        value: item.isView == 1,
                                        onChanged: (value) => updatePermission(
                                            item.menuId,
                                            'isView',
                                            value ?? false),
                                      ),
                                    if (settingsProvider
                                            .showSave[item.menuId] ==
                                        1)
                                      CheckboxCellMobile(
                                        label: 'Save',
                                        value: item.isSave == 1,
                                        onChanged: (value) => updatePermission(
                                            item.menuId,
                                            'isSave',
                                            value ?? false),
                                      ),
                                    if (settingsProvider
                                            .showEdit[item.menuId] ==
                                        1)
                                      CheckboxCellMobile(
                                        label: 'Edit',
                                        value: item.isEdit == 1,
                                        onChanged: (value) => updatePermission(
                                            item.menuId,
                                            'isEdit',
                                            value ?? false),
                                      ),
                                    if (settingsProvider
                                            .showDelete[item.menuId] ==
                                        1)
                                      CheckboxCellMobile(
                                        label: 'Delete',
                                        value: item.isDelete == 1,
                                        onChanged: (value) => updatePermission(
                                            item.menuId,
                                            'isDelete',
                                            value ?? false),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomOutlinedSvgButton(
                  showIcon: false,
                  onPressed: () => Navigator.pop(context),
                  svgPath: 'assets/images/Print.svg',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  label: 'Cancel',
                  breakpoint: 860,
                  foregroundColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                CustomOutlinedSvgButton(
                  showIcon: false,
                  onPressed: () {
                    final List<UserMenuSelection> permissions =
                        settingsProvider.getMenu
                            .map((item) => UserMenuSelection(
                                  menuId: item.menuId,
                                  isView: item.isView,
                                  isSave: item.isSave,
                                  isEdit: item.isEdit,
                                  isDelete: item.isDelete,
                                ))
                            .toList();

                    settingsProvider.saveMenuPermission(
                      context: context,
                      userId: int.parse(userId),
                      menuPermissions: permissions,
                    );
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  svgPath: 'assets/images/Print.svg',
                  label: 'Save',
                  breakpoint: 860,
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primaryBlue,
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxCellMobile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CheckboxCellMobile({
    super.key,
    this.label = '',
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label.isNotEmpty) Text(label, style: TextStyle(fontSize: 12)),
        Checkbox(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          activeColor: AppColors.primaryBlue,
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Extracted checkbox cell widget for better reusability
class CheckboxCell extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CheckboxCell({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Center(
        child: Checkbox(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          activeColor: AppColors.primaryBlue,
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
