import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/inovoice_report_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

class BillingAndpaymentsReportScreen extends StatefulWidget {
  const BillingAndpaymentsReportScreen({super.key});

  @override
  State<BillingAndpaymentsReportScreen> createState() =>
      _BillingAndpaymentsReportScreenState();
}

class _BillingAndpaymentsReportScreenState
    extends State<BillingAndpaymentsReportScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      final reportsProvider =
          Provider.of<InvoiceReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', "", "");
      reportsProvider.getBillandPaymentsReport(context);
      searchProvider.stopSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<InvoiceReportProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: CustomAppBar(
        onSearchTap: () {
          searchProvider.startSearch();
        },
        leadingWidth: 40,
        leadingWidget: IconButton(
          onPressed: () {
            searchProvider.stopSearch();
            customerProvider.setFilter(false);
            leadProvider.setFilter(false);
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textGrey4,
          ),
          iconSize: 24,
        ),
        title: 'Billing & Payments Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () => reportsProvider.toggleFilter(),
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
            "",
            "",
          );
          reportsProvider.getBillandPaymentsReport(context);
        },
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
              query,
              reportsProvider.fromDateS,
              reportsProvider.toDateS,
              reportsProvider.Status,
              reportsProvider.AssignedTo,
              reportsProvider.enquiryFor,
              reportsProvider.enquirySource);
          reportsProvider.getBillandPaymentsReport(context);
        },
        searchController: searchController,
      ),
      body: Column(
        children: [
          if (reportsProvider.isFilter)
            _buildFilterPanel(context, reportsProvider),
          Expanded(
            child: reportsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSummarySection(reportsProvider),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomText(
                            'Billing Summary',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        reportsProvider.taskReport.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: reportsProvider.taskReport.length,
                                itemBuilder: (context, index) {
                                  final report =
                                      reportsProvider.taskReport[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ReportListItem(
                                      title: report.customerName,
                                      subtitle: 'Inv No: ${report.invoiceNo}',
                                      description:
                                          'Balance: ₹${report.balanceAmount}',
                                      status: '₹${report.invoiceAmount}',
                                      statusColor: AppColors.primaryBlue,
                                      bottomLeftIcon:
                                          Icons.calendar_today_outlined,
                                      bottomLeftText: report.invoiceDate,
                                      bottomRightText:
                                          'Paid: ₹${report.recieptAmount}',
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(InvoiceReportProvider reportsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F7FF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Total Balance",
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: AppColors.textGrey4,
                    ),
                    const SizedBox(height: 4),
                    CustomText(
                      "₹${reportsProvider.balanceTotal}",
                      fontWeight: FontWeight.w700,
                      color: AppColors.bluebutton,
                      fontSize: 24,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bluebutton.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet,
                      color: AppColors.bluebutton),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white, thickness: 1.5),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    "Total Invoiced",
                    "₹${reportsProvider.invoiceTotal}",
                    Colors.black87,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildMiniStat(
                    "Total Received",
                    "₹${reportsProvider.recieptTotal}",
                    AppColors.textGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
          label,
          fontWeight: FontWeight.w400,
          color: AppColors.textGrey4,
          fontSize: 12,
        ),
        const SizedBox(height: 4),
        CustomText(
          value,
          fontWeight: FontWeight.w600,
          color: valueColor,
          fontSize: 16,
        ),
      ],
    );
  }

  Widget _buildFilterPanel(
      BuildContext context, InvoiceReportProvider reportsProvider) {
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
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: reportsProvider.fromDate?.toString(),
              toDate: reportsProvider.toDate?.toString(),
              formattedFromDate: reportsProvider.formattedFromDate,
              formattedToDate: reportsProvider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      reportsProvider.getBillandPaymentsReport(context);
                      reportsProvider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.removeStatus();
                    searchController.clear();
                    reportsProvider.setTaskSearchCriteria(
                      '',
                      '',
                      '',
                      '',
                      '',
                      "",
                      "",
                    );
                    reportsProvider.getBillandPaymentsReport(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No billing records found',
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
      builder: (context) => Consumer<InvoiceReportProvider>(
        builder: (context, reportsProvider, child) {
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
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                                borderRadius: BorderRadius.circular(15),
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
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
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
                      child: TextButton(
                        onPressed: () async {
                          reportsProvider.formatDate();
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              reportsProvider.formattedFromDate,
                              reportsProvider.formattedToDate,
                              reportsProvider.Status,
                              reportsProvider.AssignedTo,
                              reportsProvider.enquiryFor,
                              reportsProvider.enquirySource);
                          await reportsProvider
                              .getBillandPaymentsReport(context);
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
