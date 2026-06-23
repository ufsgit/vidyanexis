import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/stock_return_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class StockReturnReport extends StatefulWidget {
  static const String route = '/stock-return-report';
  const StockReturnReport({super.key});

  @override
  State<StockReturnReport> createState() => _StockReturnReportState();
}

class _StockReturnReportState extends State<StockReturnReport> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<StockReturnReportProvider>(context, listen: false);
      provider.clearFilters();
      provider.fetchStockDetails(context);
      provider.fetchCustomers(context);
      provider.searchReport(context);
    });
  }

  @override
  void dispose() {
    customerController.dispose();
    itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockReturnReportProvider>(context);
    final isSmallScreen = !AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      drawer: isSmallScreen ? const SidebarDrawer() : null,
      appBar: isSmallScreen
          ? CustomAppBar(
              title: 'Stock Return Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
              onFilterTap: () {
                provider.toggleFilter();
              },
              showSearch: false,
              onSearch: (q) {},
            )
          : null,
      body: Column(
        children: [
          if (!isSmallScreen) _buildWebHeader(provider),
          if (isSmallScreen) _buildMobileSearchHeader(provider),
          if (provider.isFilter) _buildFilters(provider),
          Expanded(
            child: isSmallScreen
                ? _buildMobileList(provider)
                : _buildWebTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileSearchHeader(StockReturnReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 48,
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
          controller: customerController,
          onChanged: (value) => provider.setCustomerName(value),
          onSubmitted: (value) => provider.searchReport(context),
          decoration: InputDecoration(
            hintText: 'Search by Customer Name...',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[400],
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => provider.searchReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB03B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(StockReturnReportProvider provider) {
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
          const SizedBox(width: 8),
          Text(
            'Stock Return Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlue800,
            ),
          ),
          const Spacer(),
          // Top Search Bar
          Container(
            width: MediaQuery.of(context).size.width / 4,
            height: 48,
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
              onChanged: (value) => provider.setCustomerName(value),
              onSubmitted: (value) => provider.searchReport(context),
              decoration: InputDecoration(
                hintText: 'Search by Customer Name...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () => provider.searchReport(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBB03B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CustomFilterButton(
            onPressed: () => provider.toggleFilter(),
            isFilter: provider.isFilter,
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              exportToExcel(
                headers: ['Customer Name', 'Date', 'Item Name', 'Quantity'],
                data: provider.reportList.map((item) {
                  return {
                    'Customer Name': item.customerName,
                    'Date': item.entryDate,
                    'Item Name': item.itemName,
                    'Quantity': item.quantity,
                  };
                }).toList(),
                fileName: 'Stock_Return_Report',
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(StockReturnReportProvider provider) {
    final isMobile = !AppStyles.isWebScreen(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date Filter
              SizedBox(
                width: isMobile ? MediaQuery.of(context).size.width - 32 : 200,
                child: CommonReportDateFilter(
                  fromDate: provider.formattedFromDate.isEmpty
                      ? null
                      : provider.formattedFromDate,
                  toDate: provider.formattedToDate.isEmpty
                      ? null
                      : provider.formattedToDate,
                  formattedFromDate: provider.formattedFromDate,
                  formattedToDate: provider.formattedToDate,
                  onTap: () => _showDateFilterDialog(context, provider),
                  label: 'Date',
                ),
              ),
              // Customer Name Dropdown
              SizedBox(
                width: isMobile ? MediaQuery.of(context).size.width - 32 : 250,
                child: CommonDropdown<String>(
                  hintText: 'Customer Name',
                  selectedValue: provider.customerName.isEmpty
                      ? null
                      : provider.customerName,
                  items: [
                    DropdownItem(id: '', name: 'All Customers'),
                    ...provider.customers.map((c) => DropdownItem(
                          id: c.name,
                          name: c.name,
                        )),
                  ],
                  onItemSelected: (value) {
                    provider.setCustomerName(value);
                  },
                  borderRadius: 30,
                  borderColor: provider.customerName.isNotEmpty
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!,
                ),
              ),
              // Item Name Dropdown
              SizedBox(
                width: isMobile ? MediaQuery.of(context).size.width - 32 : 250,
                child: CommonDropdown<String>(
                  hintText: 'Item Name',
                  selectedValue:
                      provider.itemName.isEmpty ? null : provider.itemName,
                  items: [
                    DropdownItem(id: '', name: 'All Items'),
                    ...provider.stockItems.map((item) => DropdownItem(
                          id: item.itemName,
                          name: item.itemName,
                        )),
                  ],
                  onItemSelected: (value) {
                    provider.setItemName(value);
                  },
                  borderRadius: 30,
                  borderColor: provider.itemName.isNotEmpty
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!,
                ),
              ),
              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      provider.searchReport(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CommonReportResetButton(
                    onReset: () {
                      customerController.clear();
                      itemController.clear();
                      provider.clearFilters();
                      provider.searchReport(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebTable(StockReturnReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.reportList.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEFF2F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: const Row(
                children: [
                  TableWidget(title: 'Sl No', width: 80, flex: 0),
                  TableWidget(title: 'Customer Name', flex: 3),
                  TableWidget(title: 'Date', flex: 2),
                  TableWidget(title: 'Item Name', flex: 3),
                  TableWidget(title: 'Quantity', flex: 1),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: provider.reportList.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Colors.grey[200]),
                itemBuilder: (context, index) {
                  final item = provider.reportList[index];
                  return Row(
                    children: [
                      TableWidget(
                        width: 80,
                        flex: 0,
                        data: Center(
                          child: Text((index + 1).toString(),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                              )),
                        ),
                      ),
                      TableWidget(title: item.customerName, flex: 3),
                      TableWidget(title: item.entryDate, flex: 2),
                      TableWidget(
                        flex: 3,
                        data: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EDF1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.itemName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      TableWidget(title: item.quantity, flex: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(StockReturnReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.reportList.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reportList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = provider.reportList[index];
        return ReportListItem(
          title: item.itemName,
          subtitle: item.customerName,
          status: 'Qty: ${item.quantity}',
          statusColor: AppColors.primaryBlue,
          description: 'Date: ${item.entryDate}',
          bottomLeftIcon: Icons.calendar_today,
          bottomLeftText: item.entryDate,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No records found');
  }

  void _showDateFilterDialog(
      BuildContext context, StockReturnReportProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<StockReturnReportProvider>(
        builder: (context, reportsProvider, child) {
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
                      children: [
                        'Today',
                        'Yesterday',
                        'This Week',
                        'This Month',
                        'This Year'
                      ].asMap().entries.map((entry) {
                        int index = entry.key;
                        String title = entry.value;
                        return ActionChip(
                          onPressed: () {
                            _setDateFilterByIndex(index, reportsProvider);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportsProvider.fromDate != null && index != -1
                                  ? AppColors.primaryBlue
                                  : Colors.white, // simplified for now
                          labelStyle: const TextStyle(
                            color: Colors.black,
                          ),
                        );
                      }).toList(),
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
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                reportsProvider.setFromDate(picked);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(reportsProvider.fromDate!)
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                reportsProvider.setToDate(picked);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(reportsProvider.toDate!)
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
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.searchReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
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
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.clearFilters();
                          reportsProvider.searchReport(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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

  void _setDateFilterByIndex(int index, StockReturnReportProvider provider) {
    final now = DateTime.now();
    switch (index) {
      case 0: // Today
        provider.setFromDate(now);
        provider.setToDate(now);
        break;
      case 1: // Yesterday
        final yesterday = now.subtract(const Duration(days: 1));
        provider.setFromDate(yesterday);
        provider.setToDate(yesterday);
        break;
      case 2: // This Week
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        provider.setFromDate(firstDayOfWeek);
        provider.setToDate(now);
        break;
      case 3: // This Month
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        provider.setFromDate(firstDayOfMonth);
        provider.setToDate(now);
        break;
      case 4: // This Year
        final firstDayOfYear = DateTime(now.year, 1, 1);
        provider.setFromDate(firstDayOfYear);
        provider.setToDate(now);
        break;
    }
  }
}
