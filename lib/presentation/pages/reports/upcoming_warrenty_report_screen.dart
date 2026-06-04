import 'dart:async';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class UpcomingWarrentyReportScreen extends StatefulWidget {
  const UpcomingWarrentyReportScreen({super.key});

  @override
  State<UpcomingWarrentyReportScreen> createState() =>
      _UpcomingWarrentyReportScreen();
}

class _UpcomingWarrentyReportScreen
    extends State<UpcomingWarrentyReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final reportsProvider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria(
        query,
        reportsProvider.fromDateS,
        reportsProvider.toDateS,
        reportsProvider.Status,
        reportsProvider.AssignedTo,
      );
      reportsProvider.getSearchUpcomingWarrantyReport(context);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchUpcomingWarrantyReport(context);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WarrentyReportProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    final isMobile = !isWeb;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? const SidebarDrawer() : null,
      appBar: isMobile
          ? CustomAppBar(
              title: 'Upcoming Warranty Reports',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              showFilterIcon: false,
              searchHintText: 'Search Reports...',
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onSearchTap: () {
                Provider.of<SidebarProvider>(context, listen: false).startSearch();
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                reportsProvider.toggleFilter();
                Provider.of<SidebarProvider>(context, listen: false).stopSearch();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchUpcomingWarrantyReport(context);
              },
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchUpcomingWarrantyReport(context);
              },
              onChanged: _onSearchChanged,
              searchController: searchController,
              showExcel: true,
              onExcelTap: () {
                _exportExcel(reportsProvider);
              },
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header & Basic Filters (WEB ONLY) ───────────────────────────
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
                      'Upcoming Warranty Reports',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Search Bar
                    Container(
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
    onSubmitted: (query) => _applySearch(reportsProvider),
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
        onTap: () { _applySearch(reportsProvider); },
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
),
                    const SizedBox(width: 12),
                    CustomFilterButton(
                      onPressed: () => reportsProvider.toggleFilter(),
                      isFilter: reportsProvider.isFilter,
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      onPressed: () => _exportExcel(reportsProvider),
                      buttonText: 'Export to Excel',
                      textColor: AppColors.whiteColor,
                      borderColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.primaryBlue,
                          radius: 4,
                    ),
                  ],
                ),
              ),

            // ── Expanded Filter Bar (Web Style) ───────────────────────────
            if (isWeb && reportsProvider.isFilter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildWebFilterBar(reportsProvider),
              ),

            // ── MOBILE FILTER PANEL ────────────────────────────────────────────────
            if (isMobile && reportsProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomText('Date Range',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 200),
                                        child: CustomText(
                                          reportsProvider.fromDate == null && reportsProvider.toDate == null
                                              ? 'Date'
                                              : 'Date : ${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textBlack,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey3, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null ||
                          (reportsProvider.selectedStatus != null &&
                              reportsProvider.selectedStatus != 0) ||
                          (reportsProvider.selectedUser != null &&
                              reportsProvider.selectedUser != 0) ||
                          reportsProvider.Search.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              searchController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                '',
                                '',
                                '',
                                '',
                                '',
                              );
                              reportsProvider.getSearchUpcomingWarrantyReport(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // ── List/Table View ───────────────────────────────────────────
            if (isWeb || !reportsProvider.isFilter)
              Expanded(
                child: reportsProvider.upcomingWarrantyReport.isEmpty
                    ? _buildEmptyState()
                    : isWeb
                        ? _buildWebTable(reportsProvider)
                        : Column(
                            children: [
                              CommonReportSummaryBar(
                                totalLabel: 'Total Records',
                                totalCount: reportsProvider.upcomingWarrantyReport.length,
                                showingLabel: 'Showing',
                                showingCount: reportsProvider.upcomingWarrantyReport.length,
                              ),
                              Expanded(
                                child: _buildMobileList(reportsProvider),
                              ),
                            ],
                          ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: (isMobile && reportsProvider.isFilter)
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_upcomingwarrenty_report_filter_fab',
                  onPressed: () {
                    reportsProvider.getSearchUpcomingWarrantyReport(context);
                    reportsProvider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false).stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : null,
      ),
    );
  }

  void _applySearch(WarrentyReportProvider reportsProvider) {
    reportsProvider.setTaskSearchCriteria(
      searchController.text,
      reportsProvider.fromDateS,
      reportsProvider.toDateS,
      reportsProvider.Status,
      reportsProvider.AssignedTo,
    );
    reportsProvider.getSearchUpcomingWarrantyReport(context);
  }

  void _exportExcel(WarrentyReportProvider reportsProvider) {
    exportToExcel(
      headers: ['No', 'Customer Name', 'Phone Number', 'Warranty Date'],
      data: reportsProvider.upcomingWarrantyReport.asMap().entries.map((entry) {
        var index = entry.key;
        var item = entry.value;
        return {
          'No': (index + 1).toString(),
          'Customer Name': item.customerName,
          'Phone Number': item.contactNumber,
          'Warranty Date': item.expiryDate.toDayMonthYearFormat(),
        };
      }).toList(),
      fileName: 'Upcoming_Warranty_Report',
    );
  }

  Widget _buildWebFilterBar(WarrentyReportProvider reportsProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _applySearch(reportsProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appViolet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Apply'),
          ),
          const SizedBox(width: 12),
          if (reportsProvider.fromDate != null ||
              searchController.text.isNotEmpty)
            CommonReportResetButton(
              onReset: () {
                reportsProvider.selectDateFilterOption(null);
                searchController.clear();
                reportsProvider.setTaskSearchCriteria('', '', '', '', '');
                reportsProvider.getSearchUpcomingWarrantyReport(context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWebTable(WarrentyReportProvider reportsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
        child: Column(
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2F5),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                      width: 60,
                      child: Text('No.',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 3,
                      child: Text('Customer Name',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('Phone Number',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('Warranty Date',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Data Rows
            Expanded(
              child: ListView.builder(
                itemCount: reportsProvider.upcomingWarrantyReport.length,
                itemBuilder: (context, index) {
                  final item = reportsProvider.upcomingWarrantyReport[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: Colors.grey[100]!)),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 60, child: Text('${index + 1}')),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () {
                              context.push(
                                  '${CustomerDetailsScreen.route}${item.customerId}/true');
                            },
                            child: Text(
                              item.customerName,
                              style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(flex: 2, child: Text(item.contactNumber)),
                        Expanded(
                            flex: 2,
                            child:
                                Text(item.expiryDate.toDayMonthYearFormat())),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(WarrentyReportProvider reportsProvider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: reportsProvider.upcomingWarrantyReport.length,
      itemBuilder: (context, index) {
        final item = reportsProvider.upcomingWarrantyReport[index];
        return ReportListItem(
          title: item.customerName,
          subtitle: item.contactNumber,
          bottomRightText:
              'Warranty Date: ${item.expiryDate.toDayMonthYearFormat()}',
          status: 'Upcoming Warranty',
          statusColor: AppColors.appViolet,
          onTap: () {
            context
                .push('${CustomerDetailsScreen.route}${item.customerId}/true');
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No upcoming warranty reports found');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<WarrentyReportProvider>(
        builder: (context, reportsProvider, child) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose Date',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      'Yesterday',
                      'Today',
                      'Tomorrow',
                      'This Week',
                      'This Month'
                    ].map((title) {
                      final index = [
                        'Yesterday',
                        'Today',
                        'Tomorrow',
                        'This Week',
                        'This Month'
                      ].indexOf(title);
                      return ActionChip(
                        label: Text(title),
                        onPressed: () {
                          reportsProvider.setDateFilter(title);
                          reportsProvider.selectDateFilterOption(index);
                        },
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
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () =>
                              reportsProvider.selectDate(context, true),
                          decoration: InputDecoration(
                            hintText: reportsProvider.fromDate != null
                                ? reportsProvider.formattedFromDate
                                : 'From',
                            suffixIcon: const Icon(Icons.calendar_month),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () =>
                              reportsProvider.selectDate(context, false),
                          decoration: InputDecoration(
                            hintText: reportsProvider.toDate != null
                                ? reportsProvider.formattedToDate
                                : 'To',
                            suffixIcon: const Icon(Icons.calendar_month),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        reportsProvider.formatDate();
                        _applySearch(reportsProvider);
                      },
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                          backgroundColor: AppColors.appViolet,
                          foregroundColor: Colors.white),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
