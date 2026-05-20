import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/inventory/sales_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/inventory_list_item.dart';
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
        return Material(
          color: Colors.transparent,
          child: SizedBox(
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
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    if (AppStyles.isWebScreen(context)) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: _buildMobileSearch(expenseProvider),
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
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              onSubmitted: (query) => _handleSearch(provider, query),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textBlue800,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search invoices...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: provider.searchSales.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
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
        InkWell(
          onTap: () => provider.toggleFilterSales(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: provider.isFilterSales ? AppColors.textBlue800 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: provider.isFilterSales ? Colors.white : const Color(0xFF64748B),
              size: 20,
            ),
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
          child: InventoryListItem(
            title: sale.customerName ?? 'Unknown Customer',
            subtitle: 'Inv: ${sale.invoiceNo} • ${formatSalesDate(sale.salesDate)}',
            description: 'Total Amount: ${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(double.parse(sale.netTotal ?? '0'))}',
            onEdit: settingsProvider.menuIsEditMap[87] == 1
                ? () async {
                    await expenseProvider.searchSalesDetails(
                        sale.salesMasterId.toString(), context);
                    _showSalesDialog(context, true, data: sale);
                  }
                : null,
            onDelete: settingsProvider.menuIsDeleteMap[87] == 1
                ? () => _showDeleteDialog(
                    context, expenseProvider, sale.salesMasterId)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(ExpenseProvider provider, SettingsProvider settingsProvider) {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569));
    const cellStyle = TextStyle(fontSize: 13, color: Color(0xFF1E293B));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Header
              Container(
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Expanded(flex: 3, child: Text('Customer Name', style: headerStyle)),
                  Expanded(flex: 2, child: Text('Invoice No', style: headerStyle)),
                  Expanded(flex: 2, child: Text('Sales Date', style: headerStyle)),
                  Expanded(flex: 3, child: Text('Description', style: headerStyle)),
                  Expanded(flex: 2, child: Text('Total Amount', style: headerStyle)),
                  Expanded(flex: 1, child: Text('Actions', style: headerStyle)),
                ]),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
              provider.salesList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(60),
                      child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text('No sales data available',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                        ]),
                      ),
                    )
                  : Column(
                      children: provider.salesList.asMap().entries.map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return Column(children: [
                          Container(
                            color: i.isEven ? Colors.white : const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                            child: Row(children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  s.customerName.isNotEmpty ? s.customerName : '-',
                                  style: cellStyle.copyWith(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(s.invoiceNo.isNotEmpty ? s.invoiceNo : '-',
                                    style: cellStyle, overflow: TextOverflow.ellipsis),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(formatSalesDate(s.salesDate),
                                    style: cellStyle, overflow: TextOverflow.ellipsis),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  s.description.isNotEmpty ? s.description : '-',
                                  style: cellStyle, maxLines: 2, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  NumberFormat.currency(symbol: '\u20b9', decimalDigits: 0)
                                      .format(double.tryParse(s.netTotal) ?? 0),
                                  style: cellStyle.copyWith(
                                    fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  if (settingsProvider.menuIsEditMap[87] == 1)
                                    Tooltip(
                                      message: 'Edit',
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          await provider.searchSalesDetails(
                                              s.salesMasterId.toString(), context);
                                          _showSalesDialog(context, true, data: s);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.edit_outlined,
                                              color: AppColors.primaryBlue, size: 15),
                                        ),
                                      ),
                                    ),
                                  if (settingsProvider.menuIsEditMap[87] == 1 &&
                                      settingsProvider.menuIsDeleteMap[87] == 1)
                                    const SizedBox(width: 6),
                                  if (settingsProvider.menuIsDeleteMap[87] == 1)
                                    Tooltip(
                                      message: 'Delete',
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _showDeleteDialog(
                                            context, provider, s.salesMasterId),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF1F2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.delete_outline,
                                              color: Colors.red, size: 15),
                                        ),
                                      ),
                                    ),
                                ]),
                              ),
                            ]),
                          ),
                          if (i < provider.salesList.length - 1)
                            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                        ]);
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }


  void _showSalesDialog(BuildContext context, bool isEdit, {dynamic data}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SalesWidget(
          editId: isEdit ? data.salesMasterId.toString() : '0',
          isEdit: isEdit,
          data: data,
        ),
      ),
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
