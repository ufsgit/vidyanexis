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

    final bool isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF334155), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Permissions',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack,
              ),
            ),
            Text(
              'User: ${widget.userName}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textGrey2,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (isWeb) ...[
            Container(
              width: 250,
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
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
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFF64748B)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 32,
                    child: CustomOutlinedSvgButton(
                      showIcon: false,
                      onPressed: () => Navigator.pop(context),
                      svgPath: 'assets/images/Print.svg',
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      label: 'Cancel',
                      breakpoint: 860,
                      foregroundColor: const Color(0xFF64748B),
                      backgroundColor: Colors.white,
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
        ],
      ),
      body: Column(
        children: [
          // On mobile, show the search box at the top of the body
          if (!isWeb)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search menus...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Color(0xFF94A3B8), size: 20),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 24.0 : 16.0,
                vertical: isWeb ? 24.0 : 8.0,
              ),
              child: isWeb
                  ? _buildWebTable(context, filteredMenus, updatePermission)
                  : _buildMobileCards(context, filteredMenus, updatePermission),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWeb
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
                border: const Border(
                  top: BorderSide(color: Color(0xFFF1F5F9)),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Title Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Text(
              'Menu Permissions: Master Control Panel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
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
                      color: const Color(0xFFE2E8F0),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text('No.', style: _headerStyle),
              ),
              SizedBox(
                width: 70,
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
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : const Color(0xFFF8FAFC),
              border:
                  const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
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
                  width: 70,
                  child: Text(
                    '${item.menuId}',
                    style: _rowStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
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
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF475569),
      );

  TextStyle get _rowStyle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF1E293B),
      );

  Widget _buildCheckboxCell(
      bool shouldShow, bool value, ValueChanged<bool?> onChanged) {
    if (!shouldShow) return const SizedBox(width: 60);
    return SizedBox(
      width: 60,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            activeColor: AppColors.primaryBlue,
            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
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
      padding: const EdgeInsets.only(bottom: 16),
      itemBuilder: (context, index) {
        final item = menus[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: Text(
                        'ID: ${item.menuId}',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFEA580C),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.menuName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Color(0xFFF1F5F9), height: 1),
                ),
                Wrap(
                  spacing: 12,
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
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.primaryBlue,
                side: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                value: value,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value ? AppColors.primaryBlue : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
