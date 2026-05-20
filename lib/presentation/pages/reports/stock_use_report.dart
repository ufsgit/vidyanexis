import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/stock_use_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class StockUseReport extends StatefulWidget {
  static const String route = '/stock-use-report';
  const StockUseReport({super.key});

  @override
  State<StockUseReport> createState() => _StockUseReportState();
}

class _StockUseReportState extends State<StockUseReport> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<StockUseReportProvider>(context, listen: false);
      provider.clearFilters();
      provider.fetchStockDetails(context);
      provider.fetchCustomers(context);
      provider.searchReport(context);

      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
    });
  }

  @override
  void dispose() {
    customerController.dispose();
    itemController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockUseReportProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final isSmallScreen = !AppStyles.isWebScreen(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isSmallScreen ? const SidebarDrawer() : null,
      appBar: isSmallScreen
          ? CustomAppBar(
              title: 'Stock Use Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
              showFilterIcon: false,
              searchHintText: 'Search by customer...',
              searchController: customerController,
              onSearchTap: () {
                searchProvider.startSearch();
              },
              onFilterTap: () {
                provider.toggleFilter();
              },
              onClearTap: () {
                customerController.clear();
                searchProvider.stopSearch();
                provider.setCustomerName('');
                provider.searchReport(context);
              },
              onSearch: (value) {
                provider.setCustomerName(value);
                provider.searchReport(context);
              },
              onChanged: (value) {
                provider.setCustomerName(value);
                provider.searchReport(context);
              },
              showExcel: true,
              onExcelTap: () {
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
                  fileName: 'Stock_Use_Report',
                );
              },
            )
          : null,
      body: Column(
        children: [
          if (!isSmallScreen) _buildWebHeader(provider),
          
          if (isSmallScreen && !provider.isFilter && provider.reportList.isNotEmpty)
            CommonReportSummaryBar(
              totalLabel: 'Total Records',
              totalCount: provider.reportList.length,
              showingLabel: 'Showing',
              showingCount: provider.reportList.length,
            ),
            
          if (!isSmallScreen && provider.isFilter) _buildFilters(provider),
          if (isSmallScreen && provider.isFilter) _buildMobileFilterPanel(context, provider),
          
          if (!provider.isFilter || !isSmallScreen)
            Expanded(
              child: isSmallScreen
                  ? _buildMobileList(provider)
                  : _buildWebTable(provider),
            ),
        ],
      ),
      // ── Floating Action Buttons for Mobile Filters ──
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (isSmallScreen && provider.isFilter)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          customerController.clear();
                          itemController.clear();
                          provider.clearFilters();
                          provider.searchReport(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.searchReport(context);
                          provider.toggleFilter();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildMobileSearchHeader(StockUseReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
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
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  'Search',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebHeader(StockUseReportProvider provider) {
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
                    ScaffoldState scaffold =
                        element.state as ScaffoldState;
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
                  borderRadius: BorderRadius.circular(12),
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
            'Stock Use Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF152D70),
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width / 4,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey[300]!),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: Text(
                      'Search',
                      style: GoogleFonts.plusJakartaSans(
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
                fileName: 'Stock_Use_Report',
              );
            },
            icon: const Icon(Icons.download, size: 18),
            label: const Text('Export'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(StockUseReportProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          CommonReportDateFilter(
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
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            height: 48,
            child: CommonDropdown<String>(
              hintText: 'Customer Name',
              selectedValue:
                  provider.customerName.isEmpty ? null : provider.customerName,
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
          const SizedBox(width: 12),
          SizedBox(
            width: 250,
            height: 48,
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
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              provider.searchReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildMobileFilterPanel(BuildContext context, StockUseReportProvider provider) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Customer Filter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: CommonDropdown<String>(
                hintText: 'Select Customer',
                selectedValue:
                    provider.customerName.isEmpty ? null : provider.customerName,
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
                borderRadius: 12,
                borderColor: provider.customerName.isNotEmpty
                    ? AppColors.primaryBlue
                    : Colors.grey[200]!,
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              'Item Filter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: CommonDropdown<String>(
                hintText: 'Select Item',
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
                borderRadius: 12,
                borderColor: provider.itemName.isNotEmpty
                    ? AppColors.primaryBlue
                    : Colors.grey[200]!,
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              'Date Range',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showDateFilterDialog(context, provider);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomText(
                        provider.formattedFromDate.isEmpty && provider.formattedToDate.isEmpty
                            ? 'Select Date Range'
                            : '${provider.formattedFromDate.toString().toDayMonthYearFormat()} - ${provider.formattedToDate.toString().toDayMonthYearFormat()}',
                        fontSize: 14,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey3, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTable(StockUseReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.reportList.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    TableWidget(title: 'Sl No', width: 80, flex: 0, color: Color(0xFF607185)),
                    TableWidget(title: 'Customer Name', flex: 3, color: Color(0xFF607185)),
                    TableWidget(title: 'Date', flex: 2, color: Color(0xFF607185)),
                    TableWidget(title: 'Item Name', flex: 3, color: Color(0xFF607185)),
                    TableWidget(title: 'Quantity', flex: 1, color: Color(0xFF607185)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: provider.reportList.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final item = provider.reportList[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          TableWidget(
                            width: 80,
                            flex: 0,
                            data: Center(
                              child: Text((index + 1).toString(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlack,
                                  )),
                            ),
                          ),
                          TableWidget(
                            flex: 3,
                            data: Text(
                              item.customerName.isEmpty ? 'N/A' : item.customerName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TableWidget(
                            flex: 2,
                            data: Text(item.entryDate.toDayMonthYearFormat()),
                          ),
                          TableWidget(
                            flex: 3,
                            data: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.itemName.isEmpty ? 'Unnamed Item' : item.itemName,
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
                          TableWidget(
                            flex: 1,
                            data: Text(
                              item.quantity,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileList(StockUseReportProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.reportList.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.reportList.length,
      itemBuilder: (context, index) {
        final item = provider.reportList[index];
        final itemName = item.itemName.trim().isEmpty ? 'Unnamed Item' : item.itemName;
        final customerName = item.customerName.trim().isEmpty ? 'N/A' : item.customerName;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: AppColors.primaryBlue,
                  ),
                  Expanded(
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
                                  itemName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFDBEAFE)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 14,
                                      color: AppColors.primaryBlue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                              const SizedBox(width: 6),
                              Text(
                                item.entryDate.toDayMonthYearFormat(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(
      BuildContext context, StockUseReportProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<StockUseReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Choose Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(
                          reportsProvider.dateButtonTitles.length, (index) {
                        String title = reportsProvider.dateButtonTitles[index];
                        final bool isSelected = reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilterByIndex(index);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey[300]!,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pick a custom date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'.split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon: const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'.split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon: const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.searchReport(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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
}
