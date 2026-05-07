import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_supplier_page.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchSupplierApi('', context);
      settingsProvider.searchSupplierController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          children: [
            Text(
              'Inventory Suppliers',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlue800),
            ),
            const Spacer(),
            if (settingsProvider.menuIsSaveMap[45] == 1)
              CustomOutlinedSvgButton(
                onPressed: () async {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return const AddSupplier(
                        editId: '0',
                        isEdit: false,
                      );
                    },
                  );
                },
                svgPath: 'assets/images/Plus.svg',
                label: 'New Supplier',
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
        settingsProvider.searchSupplier.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settingsProvider.searchSupplier.length,
                itemBuilder: (context, index) {
                  final supplier = settingsProvider.searchSupplier[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportListItem(
                      title: supplier.supplierName,
                      subtitle: 'Supplier ID: ${supplier.supplierId}',
                      description: 'Supplier for inventory procurement.',
                      statusColor: AppColors.primaryBlue,
                      onEdit: settingsProvider.menuIsEditMap[45] == 1
                          ? () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AddSupplier(
                                    editId: supplier.supplierId.toString(),
                                    isEdit: true,
                                    data: supplier,
                                  );
                                },
                              );
                            }
                          : null,
                      onDelete: settingsProvider.menuIsDeleteMap[45] == 1
                          ? () {
                              _showDeleteDialog(context, settingsProvider, supplier.supplierId);
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
            Icon(Icons.business_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No suppliers found',
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

  void _showDeleteDialog(BuildContext context, SettingsProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this supplier?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                provider.deleteSupplier(context, id);
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
