import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/sales_report_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/pages/reports/sales_report_screen_phone.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();
  TextEditingController invoiceController = TextEditingController();
  Timer? _debounce;

  void _onFilterChanged(String val, SalesReportProvider provider) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.setSearchCriteria(
        search: searchController.text,
        invoiceNo: invoiceController.text,
      );
      provider.getSalesReport(context);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    invoiceController.dispose();
    super.dispose();
  }

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
    if (!AppStyles.isWebScreen(context)) {
      return const SalesReportScreenPhone();
    }

    final provider = Provider.of<SalesReportProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, provider),
          if (provider.isFilter)
            _buildFilterPanel(context, provider, settingsProvider),
          Expanded(child: _buildDataTable(context, provider)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SalesReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Builder(
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
          Text(
            'Sales Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF152D70),
            ),
          ),
          const Spacer(),
          _buildSearchField(provider),
          const SizedBox(width: 12),
          CustomFilterButton(
            onPressed: () => provider.toggleFilter(),
            isFilter: provider.isFilter,
          ),
          const SizedBox(width: 12),
          _buildExportButton(provider),
        ],
      ),
    );
  }

  Widget _buildSearchField(SalesReportProvider provider) {
    return Container(
  width: 280,
  height: 38,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: searchController,
    focusNode: searchFocusNodeWeb,
    textAlignVertical: TextAlignVertical.center,
    onTap: () {
      Future.microtask(() {
        if (searchController.text.isNotEmpty &&
            searchController.selection.baseOffset == 0 &&
            searchController.selection.extentOffset == searchController.text.length) {
          searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
        }
      });
    },
    onSubmitted: (query) {},
    decoration: InputDecoration(
      hintText: 'Search here....',
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      suffixIcon: GestureDetector(
        onTap: () {},
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
);
  }

  Widget _buildExportButton(SalesReportProvider provider) {
    return ElevatedButton.icon(
      onPressed: () {
        if (provider.salesReport.isEmpty) return;
        exportToExcel(
          headers: [
            'Date',
            'Invoice No',
            'Customer',
            'Total Items',
            'Net Total',
            'Staff'
          ],
          data: provider.salesReport
              .map((s) => {
                    'Date': s.date,
                    'Invoice No': s.invoiceNo,
                    'Customer': s.customerName,
                    'Total Items': s.totalItems.toString(),
                    'Net Total': s.totalAmount,
                    'Staff': s.assignedStaff,
                  })
              .toList(),
          fileName: 'Sales_Report',
        );
      },
      icon: const Icon(Icons.download, size: 18),
      label: const Text('Export'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, SalesReportProvider provider,
      SettingsProvider settingsProvider) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          // Date Filter (Kept as original)
          Row(
            children: [
              Expanded(
                child: CommonReportDateFilter(
                  fromDate: provider.fromDate?.toString(),
                  toDate: provider.toDate?.toString(),
                  formattedFromDate: provider.formattedFromDate,
                  formattedToDate: provider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                ),
              ),
              const SizedBox(width: 12),

              // Invoice No
              Expanded(
                child: _buildTextFilter(
                  label: 'Invoice No',
                  controller: invoiceController,
                  hint: 'Enter Invoice No',
                  onChanged: (val) => _onFilterChanged(val, provider),
                  isActive: provider.invoiceNo.isNotEmpty,
                ),
              ),
              const SizedBox(width: 12),

              // Item Name
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Item Name',
                  value: provider.itemName.isEmpty ? null : provider.itemName,
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
                  isActive: provider.itemName.isNotEmpty,
                ),
              ),
              const SizedBox(width: 12),

              // Enquiry For
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Enquiry For',
                  value: provider.enquiryFor.isEmpty ? null : provider.enquiryFor,
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
                  isActive: provider.enquiryFor.isNotEmpty,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CommonReportResetButton(onReset: () {
                provider.resetFilters();
                invoiceController.clear();
                searchController.clear();
                provider.getSalesReport(context);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextFilter({
    required String label,
    required TextEditingController controller,
    String? hint,
    Function(String)? onChanged,
    bool isActive = false,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isActive ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
            width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label: ',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF1E293B))),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF94A3B8), fontSize: 13),
              ),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required ValueChanged<String?> onChanged,
    bool isActive = false,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: isActive ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
            width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label: ',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF1E293B))),
          Expanded(
            child: DropdownButton<String?>(
              value: value,
              hint: Text('All',
                  style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8), fontSize: 13)),
              items: items,
              onChanged: onChanged,
              underline: const SizedBox(),
              isDense: true,
              isExpanded: true,
              iconSize: 18,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, SalesReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.salesReport.isEmpty) {
      return const CommonEmptyState(message: 'No sales found');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            // Takes full available height
            height:
                MediaQuery.of(context).size.height * 0.75, // Adjust if needed
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // Vertical Scroll
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Horizontal Scroll
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    // This makes the table take full width (important for expansion)
                    minWidth: MediaQuery.of(context).size.width - 32,
                  ),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    headingRowHeight: 56,
                    dataRowHeight: 52,
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(
                          label: Text('No.',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Customer Name',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Invoice No',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Total Items',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Total Amount',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Staff',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Enquiry For',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: provider.salesReport.asMap().entries.map((entry) {
                      final index = entry.key;
                      final sale = entry.value;
                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(sale.date)),
                        DataCell(Text(
                          sale.customerName,
                          style: const TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.w600),
                        )),
                        DataCell(Text(sale.invoiceNo)),
                        DataCell(Text(sale.totalItems.toString())),
                        DataCell(Text(
                          NumberFormat.currency(
                            symbol: '₹',
                            decimalDigits: 0,
                          ).format(double.parse(sale.totalAmount)),
                        )),
                        DataCell(Text(sale.assignedStaff)),
                        DataCell(Text(sale.enquiryFor)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<SalesReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            if (reportsProvider.selectedDateFilterIndex == index) {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.setDateFilter('');
                            } else {
                              reportsProvider.setDateFilter(title);
                              reportsProvider.selectDateFilterOption(index);
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportsProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                reportsProvider.selectedDateFilterIndex == index
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.setSearchCriteria(
                            search: searchController.text,
                            invoiceNo: invoiceController.text,
                          );
                          reportsProvider.getSalesReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          reportsProvider.setSearchCriteria(fromDate: '', toDate: '');
                          Navigator.pop(context);
                          reportsProvider.getSalesReport(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
