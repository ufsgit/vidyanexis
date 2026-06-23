import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/sales_report_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class SalesReportScreenPhone extends StatefulWidget {
  const SalesReportScreenPhone({super.key});

  @override
  State<SalesReportScreenPhone> createState() => _SalesReportScreenPhoneState();
}

class _SalesReportScreenPhoneState extends State<SalesReportScreenPhone> {
  final TextEditingController invoiceController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SalesReportProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      provider.getSalesReport(context);
      settingsProvider.searchEnquiryForData('', context);
      expenseProvider.searchItemList(context: context, isFilter: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SalesReportProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              ScaffoldState? parent;
              context.visitAncestorElements((element) {
                if (element is StatefulElement &&
                    element.state is ScaffoldState) {
                  ScaffoldState scaffold = element.state as ScaffoldState;
                  if (scaffold.hasDrawer) {
                    parent = scaffold;
                    return false;
                  }
                }
                return true;
              });
              parent?.openDrawer();
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.sort,
                size: 20,
                color: AppColors.secondaryBlue,
              ),
            ),
          ),
        ),
        title: const Text('Sales Report'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF152D70),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context, provider),
          Expanded(child: _buildList(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showFilterBottomSheet(context, provider, settingsProvider),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.filter_list_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilter(
      BuildContext context, SalesReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (val) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            provider.setSearchCriteria(search: val);
            provider.getSalesReport(context);
          });
        },
        onSubmitted: (val) {
          provider.setSearchCriteria(search: val);
          provider.getSalesReport(context);
        },
        decoration: InputDecoration(
          hintText: 'Search customer...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildList(SalesReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.salesReport.isEmpty) {
      return const CommonEmptyState(message: 'No records found');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: provider.salesReport.length,
      itemBuilder: (context, index) {
        final sale = provider.salesReport[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sale.customerName,
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Text(
                      NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                          .format(double.tryParse(sale.totalAmount) ?? 0),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.receipt_long,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Inv: ${sale.invoiceNo}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                    const Spacer(),
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(sale.date,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Staff: ${sale.assignedStaff}',
                        style: const TextStyle(fontSize: 13)),
                    const Spacer(),
                    Text('Items: ${sale.totalItems}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context,
      SalesReportProvider provider, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final expenseProvider = Provider.of<ExpenseProvider>(context);
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildDateRow(context, provider),
                const SizedBox(height: 12),
                _buildFilterField(invoiceController, 'Invoice No',
                    onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    provider.setSearchCriteria(invoiceNo: val);
                    provider.getSalesReport(context);
                  });
                }),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: provider.itemName.isEmpty ? null : provider.itemName,
                  decoration: InputDecoration(
                    labelText: 'Item Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Items')),
                    ...expenseProvider.itemList.map((e) => DropdownMenuItem(
                          value: e.itemId.toString(),
                          child: Text(e.itemName),
                        )),
                  ],
                  onChanged: (val) {
                    provider.setSearchCriteria(itemName: val ?? '');
                    provider.getSalesReport(context);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value:
                      provider.enquiryFor.isEmpty ? null : provider.enquiryFor,
                  decoration: InputDecoration(
                    labelText: 'Enquiry For',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('All Enquiry For')),
                    ...settingsProvider.searchEnquiryFor
                        .map((e) => DropdownMenuItem(
                              value: e.enquiryForId.toString(),
                              child: Text(e.enquiryForName),
                            )),
                  ],
                  onChanged: (val) {
                    provider.setSearchCriteria(enquiryFor: val ?? '');
                    provider.getSalesReport(context);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.setSearchCriteria(
                        invoiceNo: invoiceController.text,
                      );
                      provider.getSalesReport(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    provider.resetFilters();
                    invoiceController.clear();
                    provider.getSalesReport(context);
                    Navigator.pop(context);
                  },
                  child: const Center(
                      child: Text('Reset Filters',
                          style: TextStyle(color: Colors.red))),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRow(BuildContext context, SalesReportProvider provider) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await provider.selectDate(context, true);
              provider.getSalesReport(context);
            },
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(provider.fromDate == null
                ? 'From Date'
                : provider.formattedFromDate),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await provider.selectDate(context, false);
              provider.getSalesReport(context);
            },
            icon: const Icon(Icons.calendar_month, size: 18),
            label: Text(
                provider.toDate == null ? 'To Date' : provider.formattedToDate),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterField(TextEditingController? controller, String label,
      {Function(String)? onChanged}) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
