import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/sales_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

import '../../../controller/expense_provider.dart';
import '../../../controller/settings_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.getSalesMaster(context);
      await expenseProvider.searchItemListPurchase(context);
      expenseProvider.resetPurchaseItems();
      expenseProvider.clearPurchaseItemFields();
      expenseProvider.resetPurchaseValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, expenseProvider, settingsProvider),
              if (expenseProvider.isFilterSales) _buildFilterPanel(context, expenseProvider, settingsProvider),
              const SizedBox(height: 10),
              AppStyles.isWebScreen(context)
                  ? _buildDesktopTable(expenseProvider, settingsProvider)
                  : _buildMobileList(expenseProvider, settingsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    if (AppStyles.isWebScreen(context)) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              'Sales',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlue800),
            ),
            const Spacer(),
            _buildDesktopSearch(expenseProvider),
            const SizedBox(width: 16),
            CustomFilterButton(
              onPressed: () => expenseProvider.toggleFilterSales(),
              isFilter: expenseProvider.isFilterSales,
            ),
            const SizedBox(width: 16),
            if (settingsProvider.menuIsSaveMap[87] == 1)
              CustomOutlinedSvgButton(
                onPressed: () => _showSalesDialog(context, false),
                svgPath: 'assets/images/Plus.svg',
                label: 'New Sales',
                breakpoint: 860,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryBlue,
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
            const SizedBox(width: 16),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Sales',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlue800,
                  ),
                ),
                const Spacer(),
                if (settingsProvider.menuIsSaveMap[87] == 1)
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () => _showSalesDialog(context, false),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMobileSearch(expenseProvider),
          ],
        ),
      );
    }
  }

  Widget _buildDesktopSearch(ExpenseProvider provider) {
    return Container(
      width: 250,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: searchController,
        onSubmitted: (query) => _handleSearch(provider, query),
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildMobileSearch(ExpenseProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 3)],
            ),
            child: TextField(
              controller: searchController,
              onSubmitted: (query) => _handleSearch(provider, query),
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: provider.searchSales.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          searchController.clear();
                          _handleSearch(provider, '');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => provider.toggleFilterSales(),
          icon: Icon(
            Icons.filter_list,
            color: provider.isFilterSales ? Colors.white : AppColors.primaryBlue,
          ),
          style: IconButton.styleFrom(
            backgroundColor: provider.isFilterSales ? AppColors.primaryBlue : Colors.white,
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ],
    );
  }

  void _handleSearch(ExpenseProvider provider, String query) {
    provider.setSearchCriteriaSales(query, provider.fromDateS, provider.toDateS, provider.status, provider.enquiryForS);
    provider.getSalesMaster(context);
  }

  Widget _buildFilterPanel(BuildContext context, ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date Filter', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          CommonReportDateFilter(
            fromDate: expenseProvider.fromDateSales?.toString(),
            toDate: expenseProvider.toDateSales?.toString(),
            formattedFromDate: expenseProvider.formattedFromDateSales,
            formattedToDate: expenseProvider.formattedToDateSales,
            onTap: () => _showDateDialog(context, expenseProvider),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    expenseProvider.getSalesMaster(context);
                    expenseProvider.toggleFilterSales();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
              const SizedBox(width: 12),
              CommonReportResetButton(
                onReset: () => _resetFilters(expenseProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resetFilters(ExpenseProvider provider) {
    provider.selectDateFilterOptionSales(null);
    searchController.clear();
    provider.setSearchCriteriaSales('', '', '', '', '');
    provider.getSalesMaster(context);
  }

  void _showDateDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (contextx) => Consumer<ExpenseProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Date', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: ['Yesterday', 'Today', 'Tomorrow', 'This Week', 'This Month']
                      .asMap()
                      .entries
                      .map((e) => ActionChip(
                            label: Text(e.value),
                            onPressed: () {
                              reportsProvider.setDateFilterSales(e.value);
                              reportsProvider.selectDateFilterOptionSales(e.key);
                            },
                            backgroundColor: reportsProvider.selectedDateFilterIndexSales == e.key ? AppColors.primaryBlue : Colors.white,
                            labelStyle: TextStyle(color: reportsProvider.selectedDateFilterIndexSales == e.key ? Colors.white : Colors.black),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  onTap: () => reportsProvider.selectDateSales(context, true),
                  decoration: InputDecoration(
                    labelText: 'Pick a date',
                    hintText: reportsProvider.fromDateSales != null ? reportsProvider.formattedFromDateSales : 'Select',
                    suffixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      reportsProvider.getSalesMaster(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    child: const Text('Apply'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: expenseProvider.salesList.length,
      itemBuilder: (context, index) {
        final sale = expenseProvider.salesList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ReportListItem(
            title: sale.customerName ?? 'Unknown Customer',
            subtitle: 'Invoice: ${sale.invoiceNo}',
            description: sale.description ?? 'No description provided.',
            status: NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(double.parse(sale.netTotal ?? '0')),
            statusColor: AppColors.primaryBlue,
            bottomLeftText: formatSalesDate(sale.salesDate),
            bottomLeftIcon: Icons.calendar_today,
            onEdit: settingsProvider.menuIsEditMap[87] == 1 ? () async {
              await expenseProvider.searchSalesDetails(sale.salesMasterId.toString(), context);
              _showSalesDialog(context, true, data: sale);
            } : null,
            onDelete: settingsProvider.menuIsDeleteMap[87] == 1 ? () => _showDeleteDialog(context, expenseProvider, sale.salesMasterId) : null,
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(ExpenseProvider provider, SettingsProvider settingsProvider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey),
      ),
      child: const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Desktop Table view'))),
    );
  }

  void _showSalesDialog(BuildContext context, bool isEdit, {dynamic data}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SalesWidget(
          editId: isEdit ? data.salesMasterId.toString() : '0',
          isEdit: isEdit,
          data: data,
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseProvider provider, dynamic id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this sale?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                await provider.deleteSalesItem(context, id);
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String formatSalesDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      DateTime dt = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }
}
