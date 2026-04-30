import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/get_menu_permsiion_model.dart';
import 'package:vidyanexis/controller/models/dummy_models.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class PermissionHandlingPage extends StatefulWidget {
  final String userName;
  final String userId;

  const PermissionHandlingPage({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  State<PermissionHandlingPage> createState() => _PermissionHandlingPageState();
}

class _PermissionHandlingPageState extends State<PermissionHandlingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Filter menus based on search query
    final filteredMenus = settingsProvider.getMenu.where((item) {
      return item.menuName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    void updatePermission(int menuId, String permissionType, bool value) {
      settingsProvider.updateMenuPermission(
          menuId, permissionType, value ? 1 : 0);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Permissions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'User: ${widget.userName}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 250,
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search menus...',
                prefixIcon: const Icon(Icons.search, size: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  child: CustomOutlinedSvgButton(
                    showIcon: false,
                    onPressed: () => Navigator.pop(context),
                    svgPath: 'assets/images/Print.svg',
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    label: 'Cancel',
                    breakpoint: 860,
                    foregroundColor: AppColors.primaryBlue,
                    backgroundColor: Colors.white,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 28,
                  child: CustomOutlinedSvgButton(
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
                        userId: int.parse(widget.userId),
                        menuPermissions: permissions,
                      );
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    svgPath: 'assets/images/Print.svg',
                    label: 'Save Changes',
                    breakpoint: 860,
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryBlue,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AppStyles.isWebScreen(context)
                  ? _buildWebTable(context, filteredMenus, updatePermission)
                  : _buildMobileCards(context, filteredMenus, updatePermission),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWebTable(
      BuildContext context,
      List<GetMenuPermissionModel> menus,
      Function(int, String, bool) updatePermission) {
    if (menus.isEmpty) return const SizedBox();

    int half = (menus.length / 2).ceil();
    final firstHalf = menus.sublist(0, half);
    final secondHalf = menus.sublist(half);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Title Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Menu Permissions: Master Control Panel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1F36),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Column
                    Expanded(
                      child: _buildPermissionColumn(
                          context, firstHalf, updatePermission,
                          startIndex: 1),
                    ),
                    // Subtle Divider
                    Container(
                      width: 1,
                      color: Colors.grey[200],
                    ),
                    // Second Column
                    Expanded(
                      child: _buildPermissionColumn(
                          context, secondHalf, updatePermission,
                          startIndex: half + 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionColumn(
      BuildContext context,
      List<GetMenuPermissionModel> menus,
      Function(int, String, bool) updatePermission,
      {required int startIndex}) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Column(
      children: [
        // Column Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('No.', style: _headerStyle),
              ),
              SizedBox(
                width: 60,
                child: Text('Menu ID', style: _headerStyle),
              ),
              Expanded(
                child: Text('Menu Name', style: _headerStyle),
              ),
              ...['View', 'Save', 'Edit', 'Delete'].map((label) => SizedBox(
                    width: 60,
                    child: Center(child: Text(label, style: _headerStyle)),
                  )),
            ],
          ),
        ),
        // Column rows
        ...List.generate(menus.length, (index) {
          final item = menus[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '${startIndex + index}',
                    style: _rowStyle,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${item.menuId}',
                    style: _rowStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.menuName,
                    style: _rowStyle,
                  ),
                ),
                _buildCheckboxCell(
                  settingsProvider.showView[item.menuId] == 1,
                  item.isView == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isView', value ?? false),
                ),
                _buildCheckboxCell(
                  settingsProvider.showSave[item.menuId] == 1,
                  item.isSave == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isSave', value ?? false),
                ),
                _buildCheckboxCell(
                  settingsProvider.showEdit[item.menuId] == 1,
                  item.isEdit == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isEdit', value ?? false),
                ),
                _buildCheckboxCell(
                  settingsProvider.showDelete[item.menuId] == 1,
                  item.isDelete == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isDelete', value ?? false),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  TextStyle get _headerStyle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF4F566B),
      );

  TextStyle get _rowStyle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1A1F36),
      );

  Widget _buildCheckboxCell(
      bool shouldShow, bool value, ValueChanged<bool?> onChanged) {
    if (!shouldShow) return const SizedBox(width: 60);
    return SizedBox(
      width: 60,
      child: Center(
        child: Transform.scale(
          scale: 0.85,
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: const Color(
                0xFFF6AD55), // Match the orange/yellow color in screenshot
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCards(
      BuildContext context,
      List<GetMenuPermissionModel> menus,
      Function(int, String, bool) updatePermission) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return ListView.builder(
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final item = menus[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ID: ${item.menuId}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.menuName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(),
                ),
                Wrap(
                  spacing: 20,
                  runSpacing: 12,
                  children: [
                    if (settingsProvider.showView[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'View',
                          item.isView == 1,
                          (v) => updatePermission(
                              item.menuId, 'isView', v ?? false)),
                    if (settingsProvider.showSave[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'Save',
                          item.isSave == 1,
                          (v) => updatePermission(
                              item.menuId, 'isSave', v ?? false)),
                    if (settingsProvider.showEdit[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'Edit',
                          item.isEdit == 1,
                          (v) => updatePermission(
                              item.menuId, 'isEdit', v ?? false)),
                    if (settingsProvider.showDelete[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'Delete',
                          item.isDelete == 1,
                          (v) => updatePermission(
                              item.menuId, 'isDelete', v ?? false)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCheckbox(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          activeColor: AppColors.primaryBlue,
          value: value,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
