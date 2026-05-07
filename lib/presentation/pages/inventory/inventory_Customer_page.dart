import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_customer_page.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchInventoryCustomerApi('', context);
      settingsProvider.searchInventoryCustomerController.clear();
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
              'Inventory Customers',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlue800),
            ),
            const Spacer(),
            CustomOutlinedSvgButton(
              onPressed: () async {
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return const AddCustomer(
                      editId: '0',
                      isEdit: false,
                    );
                  },
                );
                if (mounted) {
                  Provider.of<SettingsProvider>(context, listen: false)
                      .searchInventoryCustomerApi('', context);
                }
              },
              svgPath: 'assets/images/Plus.svg',
              label: 'New Customer',
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
        settingsProvider.searchInventoryCustomer.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settingsProvider.searchInventoryCustomer.length,
                itemBuilder: (context, index) {
                  final customer = settingsProvider.searchInventoryCustomer[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportListItem(
                      title: customer.customerName,
                      subtitle: 'ID: ${customer.customerId}',
                      description: 'Inventory customer details.',
                      statusColor: AppColors.primaryBlue,
                      onEdit: () async {
                        await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddCustomer(
                              editId: customer.customerId.toString(),
                              isEdit: true,
                              data: customer,
                            );
                          },
                        );
                        if (mounted) {
                          Provider.of<SettingsProvider>(context, listen: false)
                              .searchInventoryCustomerApi('', context);
                        }
                      },
                      onDelete: () {
                        _showDeleteDialog(context, settingsProvider, customer.customerId);
                      },
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
            Icon(Icons.person_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No customers found',
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
          content: const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                provider.deleteInventoryCustomer(context, id);
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
