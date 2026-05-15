import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WarrentyReportProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: !isWeb
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              title: const Text(
                'Upcoming Warranty Reports',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header & Basic Filters ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (isWeb)
                    Text(
                      'Upcoming Warranty Reports',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (isWeb) const Spacer(),
                  // Search Bar
                  Container(
                    width:
                        isWeb ? 300 : MediaQuery.of(context).size.width * 0.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (query) => _applySearch(reportsProvider),
                      decoration: InputDecoration(
                        hintText: 'Search here....',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                    buttonText: isWeb ? 'Export to Excel' : 'Export',
                    textColor: AppColors.whiteColor,
                    borderColor: AppColors.appViolet,
                    backgroundColor: AppColors.appViolet,
                  ),
                ],
              ),
            ),

            // ── Expanded Filter Bar (Web Style) ───────────────────────────
            if (reportsProvider.isFilter || isWeb)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isWeb
                    ? _buildWebFilterBar(reportsProvider)
                    : _buildMobileFilterBar(reportsProvider),
              ),

            // ── List/Table View ───────────────────────────────────────────
            Expanded(
              child: reportsProvider.upcomingWarrantyReport.isEmpty
                  ? _buildEmptyState()
                  : isWeb
                      ? _buildWebTable(reportsProvider)
                      : _buildMobileList(reportsProvider),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
                  borderRadius: BorderRadius.circular(20)),
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

  Widget _buildMobileFilterBar(WarrentyReportProvider reportsProvider) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applySearch(reportsProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appViolet,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Filter'),
                ),
              ),
              const SizedBox(width: 10),
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
          borderRadius: BorderRadius.circular(12),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No upcoming warranty reports found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<WarrentyReportProvider>(
        builder: (context, reportsProvider, child) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                      style: ElevatedButton.styleFrom(
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
