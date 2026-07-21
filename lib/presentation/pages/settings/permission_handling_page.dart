import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/get_menu_permsiion_model.dart';
import 'package:vidyanexis/controller/models/dummy_models.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class PermissionHandlingPage extends StatefulWidget {
  final String userName;
  final String userId;
  final bool isPrintPermission;

  const PermissionHandlingPage({
    super.key,
    required this.userName,
    required this.userId,
    this.isPrintPermission = false,
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

  void _openDuplicateDialog(
      BuildContext context, SettingsProvider settingsProvider) async {
    final selectedUser = await showDialog<SearchUserDetails>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DuplicatePermissionsDialog(
        isPrintPermission: widget.isPrintPermission,
        currentUserName: widget.userName,
      ),
    );

    if (selectedUser != null && mounted) {
      try {
        Loader.showLoader(context);
        if (widget.isPrintPermission) {
          await settingsProvider.getMenuPermissionDataPrint(
            selectedUser.userDetailsId.toString(),
            context,
          );
        } else {
          await settingsProvider.getMenuPermissionData(
            selectedUser.userDetailsId.toString(),
            context,
          );
        }
      } finally {
        if (mounted) {
          Loader.stopLoader(context);
          String sourceUserName = selectedUser.userDetailsName.isNotEmpty
              ? selectedUser.userDetailsName
              : '${selectedUser.firstName ?? ''} ${selectedUser.lastName ?? ''}'.trim();
          if (sourceUserName.isEmpty) {
            sourceUserName = 'selected user';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Permissions duplicated from $sourceUserName',
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        }
      }
    }
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
              widget.isPrintPermission
                  ? 'Enquiry For: ${widget.userName}'
                  : 'User: ${widget.userName}',
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
                borderRadius: BorderRadius.circular(4),
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
                      onPressed: () =>
                          _openDuplicateDialog(context, settingsProvider),
                      svgPath: 'assets/images/Print.svg',
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      label: 'Duplicate',
                      breakpoint: 860,
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      borderSide:
                          const BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: CustomOutlinedSvgButton(
                      showIcon: false,
                      onPressed: () {
                        settingsProvider.clearAllPermissions();
                      },
                      svgPath: 'assets/images/Print.svg',
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      label: 'Clear',
                      breakpoint: 860,
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.white,
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        borderRadius: BorderRadius.circular(4),
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
                        if (widget.isPrintPermission) {
                          settingsProvider.saveMenuPermissionPrint(
                            context: context,
                            userId: int.parse(widget.userId),
                            menuPermissions: permissions,
                          );
                        } else {
                          settingsProvider.saveMenuPermission(
                            context: context,
                            userId: int.parse(widget.userId),
                            menuPermissions: permissions,
                          );
                        }
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
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
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
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
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () =>
                                _openDuplicateDialog(context, settingsProvider),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primaryBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: Text(
                              'Duplicate',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              settingsProvider.clearAllPermissions();
                            },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
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
                            if (widget.isPrintPermission) {
                              settingsProvider.saveMenuPermissionPrint(
                                context: context,
                                userId: int.parse(widget.userId),
                                menuPermissions: permissions,
                              );
                            } else {
                              settingsProvider.saveMenuPermission(
                                context: context,
                                userId: int.parse(widget.userId),
                                menuPermissions: permissions,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
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
                  ],
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                  widget.isPrintPermission
                      ? settingsProvider.showViewPrint[item.menuId] == 1
                      : settingsProvider.showView[item.menuId] == 1,
                  item.isView == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isView', value ?? false),
                ),
                _buildCheckboxCell(
                  widget.isPrintPermission
                      ? settingsProvider.showSavePrint[item.menuId] == 1
                      : settingsProvider.showSave[item.menuId] == 1,
                  item.isSave == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isSave', value ?? false),
                ),
                _buildCheckboxCell(
                  widget.isPrintPermission
                      ? settingsProvider.showEditPrint[item.menuId] == 1
                      : settingsProvider.showEdit[item.menuId] == 1,
                  item.isEdit == 1,
                  (value) =>
                      updatePermission(item.menuId, 'isEdit', value ?? false),
                ),
                _buildCheckboxCell(
                  widget.isPrintPermission
                      ? settingsProvider.showDeletePrint[item.menuId] == 1
                      : settingsProvider.showDelete[item.menuId] == 1,
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
              borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                        borderRadius: BorderRadius.circular(4),
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
                    if (widget.isPrintPermission
                        ? settingsProvider.showViewPrint[item.menuId] == 1
                        : settingsProvider.showView[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'View',
                          item.isView == 1,
                          (v) => updatePermission(
                              item.menuId, 'isView', v ?? false)),
                    if (widget.isPrintPermission
                        ? settingsProvider.showSavePrint[item.menuId] == 1
                        : settingsProvider.showSave[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'Save',
                          item.isSave == 1,
                          (v) => updatePermission(
                              item.menuId, 'isSave', v ?? false)),
                    if (widget.isPrintPermission
                        ? settingsProvider.showEditPrint[item.menuId] == 1
                        : settingsProvider.showEdit[item.menuId] == 1)
                      _buildMobileCheckbox(
                          'Edit',
                          item.isEdit == 1,
                          (v) => updatePermission(
                              item.menuId, 'isEdit', v ?? false)),
                    if (widget.isPrintPermission
                        ? settingsProvider.showDeletePrint[item.menuId] == 1
                        : settingsProvider.showDelete[item.menuId] == 1)
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
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(4),
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

class _DuplicatePermissionsDialog extends StatefulWidget {
  final bool isPrintPermission;
  final String currentUserName;

  const _DuplicatePermissionsDialog({
    required this.isPrintPermission,
    required this.currentUserName,
  });

  @override
  State<_DuplicatePermissionsDialog> createState() =>
      __DuplicatePermissionsDialogState();
}

class __DuplicatePermissionsDialogState
    extends State<_DuplicatePermissionsDialog> {
  List<DepartmentModel> _departments = [];
  List<SearchUserDetails> _users = [];

  DepartmentModel? _selectedDepartment;
  SearchUserDetails? _selectedUser;

  bool _isLoadingDepartments = true;
  bool _isLoadingUsers = false;
  String? _departmentError;
  String? _userError;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _isLoadingDepartments = true;
      _departmentError = null;
    });

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.searchDepartment}?Search_department=',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['success'] == true &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          List<dynamic> list = data['data'][0];
          setState(() {
            _departments =
                list.map((item) => DepartmentModel.fromJson(item)).toList();
            _isLoadingDepartments = false;
          });
          return;
        }
      }
      setState(() {
        _isLoadingDepartments = false;
        _departmentError = 'Failed to load departments';
      });
    } catch (e) {
      setState(() {
        _isLoadingDepartments = false;
        _departmentError = 'Error loading departments';
      });
    }
  }

  Future<void> _fetchUsersForDepartment(int departmentId) async {
    setState(() {
      _isLoadingUsers = true;
      _users = [];
      _selectedUser = null;
      _userError = null;
    });

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.searchUserDetails}?user_details_Name=&Department_Id=$departmentId',
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> userList = [];
        final data = response.data;
        if (data is List) {
          userList = data;
        } else if (data['data'] != null) {
          if (data['data'] is List &&
              (data['data'] as List).isNotEmpty &&
              data['data'][0] is List) {
            userList = data['data'][0];
          } else if (data['data'] is List) {
            userList = data['data'];
          }
        }

        setState(() {
          _users =
              userList.map((item) => SearchUserDetails.fromJson(item)).toList();
          _isLoadingUsers = false;
        });
        return;
      }
      setState(() {
        _isLoadingUsers = false;
        _userError = 'No users found for this department';
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
        _userError = 'Error loading users';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.copy_rounded,
                    color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Duplicate Permissions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a department and user to copy menu permissions to ${widget.currentUserName}.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Department Dropdown
            Text(
              'Select Department *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            _isLoadingDepartments
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : CommonDropdown<DepartmentModel>(
                    hintText: 'Choose Department',
                    selectedValue: _selectedDepartment,
                    items: _departments
                        .map((dept) => DropdownItem<DepartmentModel>(
                              id: dept,
                              name: dept.departmentName,
                            ))
                        .toList(),
                    onItemSelected: (dept) {
                      setState(() {
                        _selectedDepartment = dept;
                      });
                      if (dept.departmentId != null) {
                        _fetchUsersForDepartment(dept.departmentId!);
                      }
                    },
                  ),
            if (_departmentError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _departmentError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),

            // User Dropdown
            Text(
              'Select User *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            _isLoadingUsers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : CommonDropdown<SearchUserDetails>(
                    hintText: _selectedDepartment == null
                        ? 'Select a department first'
                        : (_users.isEmpty
                            ? 'No users found'
                            : 'Choose User'),
                    selectedValue: _selectedUser,
                    items: _users.map((user) {
                      String name = user.userDetailsName;
                      if ((user.firstName != null && user.firstName!.isNotEmpty) ||
                          (user.lastName != null && user.lastName!.isNotEmpty)) {
                        name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
                      }
                      if (name.isEmpty) {
                        name = 'User #${user.userDetailsId}';
                      }
                      return DropdownItem<SearchUserDetails>(
                        id: user,
                        name: name,
                      );
                    }).toList(),
                    onItemSelected: (user) {
                      setState(() {
                        _selectedUser = user;
                      });
                    },
                  ),
            if (_userError != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _userError!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _selectedUser == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedUser);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'Duplicate',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
