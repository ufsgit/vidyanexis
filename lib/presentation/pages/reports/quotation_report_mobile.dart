import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/quotation_report_provider.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/extensions.dart';

class QuotationReportMobile extends StatefulWidget {
  const QuotationReportMobile({super.key});

  @override
  State<QuotationReportMobile> createState() => _QuotationReportMobile();
}

class _QuotationReportMobile extends State<QuotationReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<QuotationReportProvider>(context, listen: false);
      reportsProvider.setQuotationSearch('', '', '', '');
      // reportsProvider.getQuotationReports(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "1");
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    Color getAvatarColor(String name) {
      final colors = [
        Colors.blue.withOpacity(.75),
        Colors.purple.withOpacity(.75),
        Colors.orange.withOpacity(.75),
        Colors.teal.withOpacity(.75),
        Colors.pink.withOpacity(.75),
        Colors.indigo.withOpacity(.75),
        Colors.green.withOpacity(.75),
        Colors.deepOrange.withOpacity(.75),
        Colors.cyan.withOpacity(.75),
        Colors.brown.withOpacity(.75),
      ];
      final nameHash = name.hashCode.abs();
      return colors[nameHash % colors.length];
    }

    final searchProvider = Provider.of<SidebarProvider>(context);

    final provider = Provider.of<DropDownProvider>(context);
    final quotationProvider = Provider.of<QuotationReportProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldColor,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        showExcel: true,
        onExcelTap: () {
          exportToExcel(
            headers: [
              'Customer Name',
              'Product Name',
              'Phone No',
              'Date',
              'Status'
            ],
            data: quotationProvider.quotationReports.map((task) {
              return {
                'Customer Name': task.customerName ?? '',
                'Product Name': task.productName ?? '',
                'Phone No': task.phoneNumber.toString(),
                'Date': task.entryDate!.isNotEmpty
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(task.entryDate.toString() ?? ''))
                    : '',
                'Status': task.quotationStatusName ?? '',
              };
            }).toList(),
            fileName: 'Quotation_Report',
          );
        },
        title: 'Quotation Report',
        onSearchTap: () {
          searchProvider.startSearch();
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          quotationProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          quotationProvider.setQuotationSearch('', '', '', '');
          quotationProvider.getQuotationReports(context);
        },
        onSearch: (query) {
          quotationProvider.setQuotationSearch(
            query,
            quotationProvider.fromDateS,
            quotationProvider.toDateS,
            quotationProvider.Status,
          );
          quotationProvider.getQuotationReports(context);
        },
        searchController: searchController,
      ),
      body: Column(
        children: [
          if (quotationProvider.isFilter) _buildFilterPanel(context, quotationProvider, provider),
          Expanded(
            child: !quotationProvider.hasFetched
                ? _buildInitialState()
                : quotationProvider.quotationReports.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quotationProvider.quotationReports.length,
                        itemBuilder: (context, index) {
                          final quotation = quotationProvider.quotationReports[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReportListItem(
                              title: quotation.customerName ?? 'No Name',
                              subtitle: quotation.productName ?? 'No Product',
                              description: 'Phone: ${quotation.phoneNumber ?? "-"}',
                              status: quotation.quotationStatusName ?? 'Pending',
                              statusColor: getAvatarColor(quotation.quotationStatusName ?? ''),
                              bottomLeftIcon: Icons.calendar_today_outlined,
                              bottomLeftText: quotation.entryDate.toString().toFormattedDate(),
                              bottomRightText: '₹ ${quotation.totalAmount}',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, QuotationReportProvider quotationProvider, DropDownProvider provider) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Status',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                FilterChipWidget(
                  label: 'All',
                  isSelected: quotationProvider.selectedStatus == 0 || quotationProvider.selectedStatus == null,
                  onTap: () => quotationProvider.setStatus(0),
                ),
                FilterChipWidget(
                  label: 'Pending',
                  isSelected: quotationProvider.selectedStatus == 1,
                  onTap: () => quotationProvider.setStatus(1),
                ),
                FilterChipWidget(
                  label: 'Approved',
                  isSelected: quotationProvider.selectedStatus == 2,
                  onTap: () => quotationProvider.setStatus(2),
                ),
                FilterChipWidget(
                  label: 'Rejected',
                  isSelected: quotationProvider.selectedStatus == 3,
                  onTap: () => quotationProvider.setStatus(3),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: quotationProvider.fromDate?.toString(),
              toDate: quotationProvider.toDate?.toString(),
              formattedFromDate: quotationProvider.formattedFromDate,
              formattedToDate: quotationProvider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      quotationProvider.getQuotationReports(context);
                      quotationProvider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    quotationProvider.selectDateFilterOption(null);
                    quotationProvider.removeStatus();
                    searchController.clear();
                    quotationProvider.setQuotationSearch('', '', '', '');
                    quotationProvider.getQuotationReports(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Select a date range to view reports',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => onClickTopButton(context),
            icon: const Icon(Icons.date_range),
            label: const Text('Choose Date'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
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
            'No reports found for the selected range',
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

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<QuotationReportProvider>(
        builder: (context, quotationProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
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
                            quotationProvider.setDateFilter(title);
                            quotationProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              quotationProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: quotationProvider.selectedDateFilterIndex ==
                                    index
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
                                quotationProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: quotationProvider.fromDate != null
                                  ? '${quotationProvider.fromDate!.toLocal()}'
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
                                quotationProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: quotationProvider.toDate != null
                                  ? '${quotationProvider.toDate!.toLocal()}'
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
                        onPressed: () async {
                          quotationProvider.formatDate();
                          String status =
                              quotationProvider.selectedStatus.toString();

                          String fromDate = quotationProvider.formattedFromDate;
                          String toDate = quotationProvider.formattedToDate;
                          quotationProvider.setQuotationSearch(
                              quotationProvider.Search,
                              fromDate,
                              toDate,
                              status);
                          await quotationProvider.getQuotationReports(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
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
