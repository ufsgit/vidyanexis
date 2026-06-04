import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_customer_page.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

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
          child: settingsProvider.searchInventoryCustomer.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: settingsProvider.searchInventoryCustomer
                      .asMap()
                      .entries
                      .map((entry) {
                    final i = entry.key;
                    final customer = entry.value;
                    return Column(
                      children: [
                        _buildRow(
                          context: context,
                          index: i,
                          title: customer.customerName,
                          onEdit: () async {
                            await showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) => AddCustomer(
                                editId: customer.customerId.toString(),
                                isEdit: true,
                                data: customer,
                              ),
                            );
                            if (mounted) {
                              Provider.of<SettingsProvider>(context,
                                      listen: false)
                                  .searchInventoryCustomerApi('', context);
                            }
                          },
                          onDelete: () => _showDeleteDialog(
                              context, settingsProvider, customer.customerId),
                        ),
                        if (i <
                            settingsProvider.searchInventoryCustomer.length - 1)
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
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      color: index.isEven ? Colors.white : const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          if (onEdit != null)
            TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
              style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No customers found');
  }

  void _showDeleteDialog(
      BuildContext context, SettingsProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this customer?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                provider.deleteInventoryCustomer(context, id);
                Navigator.pop(context);
              },
              child: const Text('Delete',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
