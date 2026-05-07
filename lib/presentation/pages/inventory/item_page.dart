import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

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
    final isMobile = !AppStyles.isWebScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          children: [
            Text(
              'Inventory Items',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlue800),
            ),
            const Spacer(),
            if (settingsProvider.menuIsSaveMap[43] == 1)
              CustomOutlinedSvgButton(
                onPressed: () async {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return const AddItemWidget(
                        isEdit: false,
                        editId: 0,
                        item: null,
                      );
                    },
                  );
                },
                svgPath: 'assets/images/Plus.svg',
                label: 'Add Item',
                breakpoint: 600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryBlue,
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
          ],
        ),
        const SizedBox(height: 20),
        expenseProvider.itemList.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenseProvider.itemList.length,
                itemBuilder: (context, index) {
                  final item = expenseProvider.itemList[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportListItem(
                      title: item.itemName,
                      subtitle: 'Item Code: ${item.itemId}',
                      statusColor: AppColors.primaryBlue,
                      description: 'Manage your inventory item details here.',
                      onEdit: settingsProvider.menuIsEditMap[43] == 1
                          ? () {
                              expenseProvider.getItemMaterialList(
                                  item.itemId, context);
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AddItemWidget(
                                      isEdit: true,
                                      editId: item.itemId,
                                      item: item);
                                },
                              );
                            }
                          : null,
                      onDelete: settingsProvider.menuIsDeleteMap[43] == 1
                          ? () {
                              _showDeleteDialog(context, expenseProvider, item.itemId);
                            }
                          : null,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
