import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_item.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/inventory/item_document_upload_alert.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.searchItemList(context: context, isFilter: false);
      expenseProvider.searchItemTypeDropdownList(context: context);
      expenseProvider.searchitemNameController.clear();
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);

    if (isMobile) {
      return _buildMobileLayout(expenseProvider, settingsProvider);
    }
    return _buildDesktopLayout(expenseProvider, settingsProvider);
  }

  // -------------------------------------------------------------
  // MOBILE LAYOUT
  // -------------------------------------------------------------
  Widget _buildMobileLayout(
      ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    final query = _searchQuery.trim().toLowerCase();
    final filteredList = expenseProvider.itemList.where((item) {
      if (query.isEmpty) return true;
      final matchName = item.itemName.toLowerCase().contains(query);
      final matchCode = item.itemId.toString().contains(query);
      final matchCategory = item.categoryName.toLowerCase().contains(query);
      return matchName || matchCode || matchCategory;
    }).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileSearch(),
          const SizedBox(height: 12),
          if (expenseProvider.itemList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    query.isNotEmpty
                        ? 'Found ${filteredList.length} items'
                        : 'Total Items: ${filteredList.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          if (filteredList.isEmpty)
            _buildEmptyState(isSearch: query.isNotEmpty)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildMobileCard(
                  context: context,
                  item: item,
                  expenseProvider: expenseProvider,
                  settingsProvider: settingsProvider,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMobileSearch() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.textBlue800,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search items by name, code...',
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMobileCard({
    required BuildContext context,
    required ItemListModel item,
    required ExpenseProvider expenseProvider,
    required SettingsProvider settingsProvider,
  }) {
    String itemTypeName = '';
    if (item.primaryCheckBox != 0) {
      try {
        final type = expenseProvider.itemTypeDropdownList.firstWhere(
            (element) => element.itemTypeId == item.primaryCheckBox);
        itemTypeName = type.itemTypeName;
      } catch (e) {
        // ignore
      }
    }

    Color itemTypeColor = const Color(0xFF2563EB);
    Color itemTypeBgColor = const Color(0xFFEFF6FF);
    final lowerName = itemTypeName.toLowerCase();
    if (lowerName.contains('primary')) {
      itemTypeColor = const Color(0xFFDC2626);
      itemTypeBgColor = const Color(0xFFFEF2F2);
    } else if (lowerName.contains('secondary')) {
      itemTypeColor = const Color(0xFF16A34A);
      itemTypeBgColor = const Color(0xFFF0FDF4);
    } else if (lowerName.contains('individual')) {
      itemTypeColor = const Color(0xFF2563EB);
      itemTypeBgColor = const Color(0xFFEFF6FF);
    }

    final canEdit = settingsProvider.menuIsEditMap[43] == 1;
    final canDelete = settingsProvider.menuIsDeleteMap[43] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Icon + Name & Code/Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.secondaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Code: #${item.itemId}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                          if (itemTypeName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: itemTypeBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                itemTypeName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: itemTypeColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Details bar (Total Qty & Category)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.layers_outlined,
                        size: 15,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Total Qty: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        item.total,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (item.unitName.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          item.unitName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.categoryName.isNotEmpty)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.category_outlined,
                            size: 14,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.categoryName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () => _handleUploadDocuments(context, item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Upload Documents',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleEdit(context, expenseProvider, item),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ),
                ],
                if (canDelete) ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showDeleteDialog(
                          context, expenseProvider, item.itemId),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // DESKTOP LAYOUT
  // -------------------------------------------------------------
  Widget _buildDesktopLayout(
      ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: expenseProvider.itemList.isEmpty
              ? _buildEmptyState()
              : Column(
                  children:
                      expenseProvider.itemList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;

                    String itemTypeName = '';
                    if (item.primaryCheckBox != 0) {
                      try {
                        final type = expenseProvider.itemTypeDropdownList.firstWhere(
                            (element) => element.itemTypeId == item.primaryCheckBox);
                        itemTypeName = type.itemTypeName;
                      } catch (e) {
                        // ignore
                      }
                    }

                    Color? itemTypeColor;
                    final lowerName = itemTypeName.toLowerCase();
                    if (lowerName.contains('primary')) {
                      itemTypeColor = Colors.red;
                    } else if (lowerName.contains('secondary')) {
                      itemTypeColor = Colors.green;
                    } else if (lowerName.contains('individual')) {
                      itemTypeColor = Colors.blue;
                    }

                    return Column(
                      children: [
                        _buildRow(
                          context: context,
                          index: i,
                          title: item.itemName,
                          subtitle:
                              'Code: ${item.itemId}  |  Total Qty: ${item.total}',
                          itemTypeName: itemTypeName,
                          itemTypeColor: itemTypeColor,
                          item: item,
                          onEdit: settingsProvider.menuIsEditMap[43] == 1
                              ? () =>
                                  _handleEdit(context, expenseProvider, item)
                              : null,
                          onDelete: settingsProvider.menuIsDeleteMap[43] == 1
                              ? () => _showDeleteDialog(
                                  context, expenseProvider, item.itemId)
                              : null,
                        ),
                        if (i < expenseProvider.itemList.length - 1)
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFE2E8F0)),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required int index,
    required String title,
    String? subtitle,
    String? itemTypeName,
    Color? itemTypeColor,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    required ItemListModel item,
  }) {
    return Container(
      color: index.isEven ? Colors.white : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: itemTypeColor ?? const Color(0xFF1E293B),
                      ),
                    ),
                    if (itemTypeName != null && itemTypeName.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        itemTypeName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleUploadDocuments(context, item),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Upload Documents'),
          ),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                foregroundColor: const Color(0xFFD97706),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Edit',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
          if (onDelete != null)
            TextButton(
              onPressed: onDelete,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                foregroundColor: Colors.red,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SHARED ACTIONS AND HELPERS
  // -------------------------------------------------------------
  void _handleEdit(
      BuildContext context, ExpenseProvider expenseProvider, ItemListModel item) async {
    expenseProvider.getItemMaterialList(item.itemId, context);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddItemWidget(
          isEdit: true,
          editId: item.itemId,
          item: item,
        ),
      ),
    );
    if (context.mounted) {
      expenseProvider.searchItemList(context: context, isFilter: false);
    }
  }

  void _handleUploadDocuments(BuildContext context, ItemListModel item) {
    showDialog(
      context: context,
      builder: (context) => ItemDocumentUploadAlert(
        itemId: item.itemId,
        itemName: item.itemName,
      ),
    );
  }

  Widget _buildEmptyState({bool isSearch = false}) {
    if (isSearch) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 10),
              Text(
                'No items found matching "$_searchQuery"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const CommonEmptyState(message: 'No items found');
  }

  void _showDeleteDialog(
      BuildContext context, ExpenseProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                provider.deleteItemApi(context, id);
              },
              child: const Text(
                'Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
