import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/enquiry_source_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:go_router/go_router.dart';

class EnquirySourceSummaryReportScreen extends StatefulWidget {
  const EnquirySourceSummaryReportScreen({super.key});

  @override
  State<EnquirySourceSummaryReportScreen> createState() =>
      _EnquirySourceSummaryReportScreenState();
}

class _EnquirySourceSummaryReportScreenState
    extends State<EnquirySourceSummaryReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<EnquirySourceProvider>(context, listen: false);
      reportsProvider.resetExpandedStates();
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getEnquirySummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EnquirySourceProvider>(context);

    // Calculate status totals
    Map<String, int> statusTotals = {};
    int totalLeads = 0;

    for (var item in reportsProvider.enquiryReport) {
      if (item.totalLeads != null) {
        if (item.totalLeads is String) {
          totalLeads += int.tryParse(item.totalLeads.toString()) ?? 0;
        } else if (item.totalLeads is num) {
          totalLeads += (item.totalLeads as num).toInt();
        }
      }

      if (item.summaryStatus != null) {
        for (var status in item.summaryStatus!) {
          if (status.statusName != null) {
            final statusName = status.statusName!;
            int statusCount = 0;
            if (status.count != null) {
              if (status.count is String) {
                statusCount = int.tryParse(status.count.toString()) ?? 0;
              } else if (status.count is num) {
                statusCount = (status.count as num).toInt();
              }
            }
            statusTotals[statusName] =
                (statusTotals[statusName] ?? 0) + statusCount;
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Enquiry Source Summary',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        onFilterTap: () => reportsProvider.toggleFilter(),
        showSearch: false,
        onSearch: (p0) {},
      ),
      body: Column(
        children: [
          if (reportsProvider.isFilter)
            _buildFilterPanel(context, reportsProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildReportTable(reportsProvider),
                  const SizedBox(height: 24),
                  _buildSummaryDashboard(totalLeads, statusTotals),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(
      BuildContext context, EnquirySourceProvider reportsProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Filter by Date',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CommonReportDateFilter(
                    fromDate: reportsProvider.fromDate?.toString(),
                    toDate: reportsProvider.toDate?.toString(),
                    formattedFromDate: reportsProvider.formattedFromDate,
                    formattedToDate: reportsProvider.formattedToDate,
                    onTap: () => onClickTopButton(context),
                    label: 'Entry Date',
                  ),
                ),
                if (reportsProvider.fromDate != null ||
                    reportsProvider.toDate != null) ...[
                  const SizedBox(width: 12),
                  CommonReportResetButton(
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
                      reportsProvider.getEnquirySummary(context);
                    },
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTable(EnquirySourceProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.grey),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.grey300.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Enquiry Source',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey3,
                        fontSize: 13,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text('Leads',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey3,
                          fontSize: 13,
                        )),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text('Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey3,
                        fontSize: 13,
                      )),
                ),
              ],
            ),
          ),
          // Rows
          if (provider.enquiryReport.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.enquiryReport.length,
              itemBuilder: (context, index) {
                final item = provider.enquiryReport[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.white
                        : AppColors.scaffoldColor.withOpacity(0.5),
                    border: Border(
                      bottom:
                          BorderSide(color: AppColors.grey.withOpacity(0.5)),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.enquirySourceName ?? '-',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.totalLeads}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: (item.summaryStatus ?? [])
                              .map((status) => _buildStatusTag(
                                  status.statusName ?? '', status.count ?? 0))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String name, dynamic count) {
    Color color = AppColors.primaryBlue;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('converted'))
      color = Colors.green;
    else if (lowerName.contains('not interested'))
      color = Colors.red;
    else if (lowerName.contains('in progress'))
      color = Colors.orange;
    else if (lowerName.contains('follow up')) color = Colors.blue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey3,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryDashboard(int totalLeads, Map<String, int> statusTotals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText('Overall Summary',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Total Leads: $totalLeads',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: statusTotals.length,
            itemBuilder: (context, index) {
              final entry = statusTotals.entries.elementAt(index);
              return _buildDashboardItem(entry.key, entry.value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(String name, int count) {
    Color color = AppColors.primaryBlue;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('converted'))
      color = Colors.green;
    else if (lowerName.contains('not interested'))
      color = Colors.red;
    else if (lowerName.contains('in progress')) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey3,
              ),
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No records found',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16, color: Colors.grey[600])),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<EnquirySourceProvider>(
        builder: (contextx, reportsProvider, child) {
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
                                borderRadius: BorderRadius.circular(15),
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
                          reportsProvider.formatDate();
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
                              assignedTo);
                          reportsProvider.getEnquirySummary(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.getEnquirySummary(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                        ),
                        child: const Text('Clear'),
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
