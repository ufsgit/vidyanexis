import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/stock_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class StockReport extends StatefulWidget {
  static const String route = '/stock-report';
  const StockReport({super.key});

  @override
  State<StockReport> createState() => _StockReportState();
}

class _StockReportState extends State<StockReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<StockReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchWorkSummary(context);

      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();

      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.searchItemListStock(context);

      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.searchCategoryApi('', context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<StockReportProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Stock Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
              showFilterIcon: false,
              searchHintText: 'Search by item...',
              searchController: searchController,
              onSearchTap: () {
                searchProvider.startSearch();
              },
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                searchProvider.stopSearch();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  reportsProvider.formattedFromDate,
                  reportsProvider.formattedToDate,
                  reportsProvider.selectedStatus?.toString() ?? '',
                  reportsProvider.selectedUser?.toString() ?? '',
                );
                reportsProvider.getSearchWorkSummary(context);
              },
              onSearch: (value) {
                reportsProvider.setTaskSearchCriteria(
                  value,
                  reportsProvider.formattedFromDate,
                  reportsProvider.formattedToDate,
                  reportsProvider.selectedStatus?.toString() ?? '',
                  reportsProvider.selectedUser?.toString() ?? '',
                );
                reportsProvider.getSearchWorkSummary(context);
              },
              onChanged: (value) {
                reportsProvider.setTaskSearchCriteria(
                  value,
                  reportsProvider.formattedFromDate,
                  reportsProvider.formattedToDate,
                  reportsProvider.selectedStatus?.toString() ?? '',
                  reportsProvider.selectedUser?.toString() ?? '',
                );
                reportsProvider.getSearchWorkSummary(context);
              },
              showExcel: true,
              onExcelTap: () {
                exportToExcel(
                  headers: [
                    'item Name',
                    'Category Name',
                    'Unit Name',
                    'Unit Price',
                    'Purchase Rate',
                    'CGST',
                    'SGST',
                    'Quantity',
                  ],
                  data: reportsProvider.taskReport.map((item) {
                    return {
                      'item Name': item.itemName,
                      'Category Name': item.categoryName,
                      'Unit Name': item.unitName,
                      'Unit Price': item.unitPrice,
                      'Purchase Rate': item.purchaseRate,
                      'CGST': item.cgst,
                      'SGST': item.sgst,
                      'Quantity': item.quantity,
                    };
                  }).toList(),
                  fileName: 'Stock_Report',
                );
              },
            ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Web Header ──
            if (isWeb)
              Padding(
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
                      'Stock Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF152D70),
                      ),
                    ),
                    const Spacer(),
                    CustomFilterButton(
                      onPressed: () {
                        reportsProvider.toggleFilter();
                      },
                      isFilter: reportsProvider.isFilter,
                    ),
                    const SizedBox(width: 12),
                    CommonReportExportButton(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'item Name',
                            'Category Name',
                            'Unit Name',
                            'Unit Price',
                            'Purchase Rate',
                            'CGST',
                            'SGST',
                            'Quantity',
                          ],
                          data: reportsProvider.taskReport.map((item) {
                            return {
                              'item Name': item.itemName,
                              'Category Name': item.categoryName,
                              'Unit Name': item.unitName,
                              'Unit Price': item.unitPrice,
                              'Purchase Rate': item.purchaseRate,
                              'CGST': item.cgst,
                              'SGST': item.sgst,
                              'Quantity': item.quantity,
                            };
                          }).toList(),
                          fileName: 'Stock_Report',
                        );
                      },
                      label: 'Export to Excel',
                    ),
                  ],
                ),
              ),

            // ── Web Filters ──
            if (isWeb && reportsProvider.isFilter)
              _buildWebFilters(
                  context, reportsProvider, settingsProvider, expenseProvider),

            // ── Mobile Filters Panel ──
            if (!isWeb && reportsProvider.isFilter)
              _buildMobileFilterPanel(
                  context, reportsProvider, settingsProvider, expenseProvider),

            // ── Summary Bar (when filters are not open on mobile) ──
            if (!isWeb &&
                !reportsProvider.isFilter &&
                reportsProvider.taskReport.isNotEmpty)
              CommonReportSummaryBar(
                totalLabel: 'Total Stock Items',
                totalCount: reportsProvider.taskReport.length,
                showingLabel: 'Showing',
                showingCount: reportsProvider.taskReport.length,
              ),

            // ── Main Content Area ──
            Expanded(
              child: reportsProvider.taskReport.isEmpty
                  ? _buildEmptyState()
                  : isWeb
                      ? _buildWebTable(reportsProvider)
                      : _buildMobileList(reportsProvider),
            ),
          ],
        ),
      ),
      // ── Floating Action Buttons for Mobile Filters ──
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (!isWeb && reportsProvider.isFilter)
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.removeStatus();
                          searchController.clear();
                          reportsProvider.setTaskSearchCriteria(
                              '', '', '', '', '');
                          reportsProvider.getSearchWorkSummary(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getSearchWorkSummary(context);
                          reportsProvider.toggleFilter();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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

  // ── Web Filters Widget ──
  Widget _buildWebFilters(
    BuildContext context,
    StockReportProvider reportsProvider,
    SettingsProvider settingsProvider,
    ExpenseProvider expenseProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item Select Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: reportsProvider.selectedStatus != null &&
                        reportsProvider.selectedStatus != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Item: ',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: reportsProvider.selectedStatus,
                    hint: Text('All',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    items: [
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text('All', style: TextStyle(fontSize: 13)),
                          ),
                        ] +
                        expenseProvider.itemListStock
                            .map((item) => DropdownMenuItem<int>(
                                  value: item.itemId,
                                  child: Text(item.itemName,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        reportsProvider.setStatus(newValue);
                      }
                    },
                    isDense: true,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Category Select Dropdown
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: reportsProvider.selectedUser != null &&
                        reportsProvider.selectedUser != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Category: ',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: reportsProvider.selectedUser,
                    hint: Text('All',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    items: [
                          const DropdownMenuItem<int>(
                            value: 0,
                            child: Text('All', style: TextStyle(fontSize: 13)),
                          ),
                        ] +
                        settingsProvider.searchCategory
                            .map((category) => DropdownMenuItem<int>(
                                  value: category.categoryId,
                                  child: Text(category.categoryName,
                                      style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        reportsProvider.setUserFilterStatus(newValue);
                      }
                    },
                    isDense: true,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Date Range picker
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
            label: 'Date',
          ),
          const SizedBox(width: 16),
          // Search Button
          ElevatedButton(
            onPressed: () {
              String status = reportsProvider.selectedStatus.toString();
              String assignedTo = reportsProvider.selectedUser.toString();
              String fromDate = reportsProvider.formattedFromDate;
              String toDate = reportsProvider.formattedToDate;
              reportsProvider.setTaskSearchCriteria(
                reportsProvider.Search,
                fromDate,
                toDate,
                status,
                assignedTo,
              );
              reportsProvider.getSearchWorkSummary(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Search',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Spacer(),
          // Reset Button
          if (reportsProvider.fromDate != null ||
              reportsProvider.toDate != null ||
              (reportsProvider.selectedStatus != null &&
                  reportsProvider.selectedStatus != 0) ||
              (reportsProvider.selectedUser != null &&
                  reportsProvider.selectedUser != 0))
            CommonReportResetButton(
              onReset: () {
                reportsProvider.selectDateFilterOption(null);
                reportsProvider.removeStatus();
                searchController.clear();
                reportsProvider.setTaskSearchCriteria('', '', '', '', '');
                reportsProvider.getSearchWorkSummary(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: const BorderSide(color: AppColors.textRed),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Mobile Filters Panel Widget ──
  Widget _buildMobileFilterPanel(
    BuildContext context,
    StockReportProvider reportsProvider,
    SettingsProvider settingsProvider,
    ExpenseProvider expenseProvider,
  ) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Item Filter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: reportsProvider.selectedStatus,
                  hint: CustomText('All Items', color: AppColors.textGrey3),
                  isExpanded: true,
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All Items'),
                        ),
                      ] +
                      expenseProvider.itemListStock
                          .map((item) => DropdownMenuItem<int>(
                                value: item.itemId,
                                child: Text(item.itemName),
                              ))
                          .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      reportsProvider.setStatus(newValue);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomText(
              'Category Filter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
            const SizedBox(height: 8),
            Container(
              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: reportsProvider.selectedUser,
                  hint:
                      CustomText('All Categories', color: AppColors.textGrey3),
                  isExpanded: true,
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All Categories'),
                        ),
                      ] +
                      settingsProvider.searchCategory
                          .map((category) => DropdownMenuItem<int>(
                                value: category.categoryId,
                                child: Text(category.categoryName),
                              ))
                          .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      reportsProvider.setUserFilterStatus(newValue);
                    }
                  },
                ),
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
                onClickTopButton(context);
              },
              child: Container(
                height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomText(
                        reportsProvider.formattedFromDate.isEmpty &&
                                reportsProvider.formattedToDate.isEmpty
                            ? 'Select Date Range'
                            : '${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                        fontSize: 14,
                        color: AppColors.textBlack,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textGrey3, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mobile Stock List Widget ──
  Widget _buildMobileList(StockReportProvider reportsProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: reportsProvider.taskReport.length,
      itemBuilder: (context, index) {
        final task = reportsProvider.taskReport[index];
        final itemName =
            task.itemName.trim().isEmpty ? 'Unnamed Item' : task.itemName;
        final categoryName =
            task.categoryName.trim().isEmpty ? 'General' : task.categoryName;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
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
            borderRadius: BorderRadius.circular(4),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left color indicator bar
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
                              if (task.unitName.isNotEmpty)
                                Container(
                                  height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    task.unitName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categoryName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'UNIT PRICE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      task.unitPrice.isEmpty
                                          ? '₹0.00'
                                          : '₹${task.unitPrice}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PURCHASE RATE',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      task.purchaseRate.isEmpty
                                          ? '₹0.00'
                                          : '₹${task.purchaseRate}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (task.cgst.isNotEmpty)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'CGST: ${task.cgst}%',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  if (task.sgst.isNotEmpty)
                                    Container(
                                      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'SGST: ${task.sgst}%',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Container(
                                height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFDCFCE7)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 14,
                                      color: Color(0xFF15803D),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Qty: ${task.quantity.isEmpty ? '0' : task.quantity}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF15803D),
                                      ),
                                    ),
                                  ],
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

  // ── Web Table Widget ──
  Widget _buildWebTable(StockReportProvider reportsProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 25.0),
                        child: Text(
                          'No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF607185)),
                        ),
                      ),
                    ),
                    TableWidget(
                        flex: 2, title: 'Item Name', color: Color(0xFF607185)),
                    TableWidget(
                        flex: 2,
                        title: 'Category Name',
                        color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1, title: 'Unit Name', color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1, title: 'Unit Price', color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1,
                        title: 'Purchase Rate',
                        color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1, title: 'CGST', color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1, title: 'SGST', color: Color(0xFF607185)),
                    TableWidget(
                        flex: 1, title: 'Quantity', color: Color(0xFF607185)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: reportsProvider.taskReport.length,
                  itemBuilder: (context, index) {
                    var task = reportsProvider.taskReport[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 2 == 0
                            ? Colors.white
                            : const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 25.0),
                              child: Text(
                                (index + 1).toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          TableWidget(
                            flex: 2,
                            data: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                task.itemName.isEmpty
                                    ? 'Unnamed Item'
                                    : task.itemName,
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
                            flex: 2,
                            title: task.categoryName.isEmpty
                                ? 'General'
                                : task.categoryName,
                          ),
                          TableWidget(flex: 1, title: task.unitName),
                          TableWidget(flex: 1, title: '₹${task.unitPrice}'),
                          TableWidget(flex: 1, title: '₹${task.purchaseRate}'),
                          TableWidget(flex: 1, title: '${task.cgst}%'),
                          TableWidget(flex: 1, title: '${task.sgst}%'),
                          TableWidget(flex: 1, title: task.quantity),
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

  // ── Empty State Widget ──
  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No stock records found');
  }

  // ── Date Chooser Dialog picker ──
  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<StockReportProvider>(
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
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        final bool isSelected =
                            reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
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
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
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
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
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
                          reportsProvider.formatDate();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
