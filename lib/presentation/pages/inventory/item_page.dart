import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_item.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.searchItemList(context: context, isFilter: false);
      expenseProvider.searchitemNameController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  children: expenseProvider.itemList.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _buildRow(
                          context: context,
                          index: i,
                          title: item.itemName,
                          subtitle: 'Code: ${item.itemId}',
                          onEdit: settingsProvider.menuIsEditMap[43] == 1
                              ? () {
                                  expenseProvider.getItemMaterialList(
                                      item.itemId, context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddItemWidget(
                                        isEdit: true,
                                        editId: item.itemId,
                                        item: item,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          onDelete: settingsProvider.menuIsDeleteMap[43] == 1
                              ? () => _showDeleteDialog(
                                  context, expenseProvider, item.itemId)
                              : null,
                        ),
                        if (i < expenseProvider.itemList.length - 1)
                          const Divider(
                              height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
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
    VoidCallback? onEdit,
    VoidCallback? onDelete,
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
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
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
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                foregroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No items found');
  }

  void _showDeleteDialog(
      BuildContext context, ExpenseProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                provider.deleteItemApi(context, id);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
