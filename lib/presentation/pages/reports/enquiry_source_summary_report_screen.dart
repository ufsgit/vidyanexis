import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/enquiry_source_provider.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EnquirySourceProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    // Calculate status totals
    Map<String, int> statusTotals = {};
    int totalLeads = 0;

    // Iterate through all enquiry sources
    for (var item in reportsProvider.enquiryReport) {
      // Add to total leads count
      if (item.totalLeads != null) {
        // Handle string or num type for totalLeads
        if (item.totalLeads is String) {
          totalLeads += int.tryParse(item.totalLeads.toString()) ?? 0;
        } else if (item.totalLeads is num) {
          totalLeads += (item.totalLeads as num).toInt();
        }
      }

      // Process status summaries
      if (item.summaryStatus != null) {
        for (var status in item.summaryStatus!) {
          if (status.statusName != null) {
            final statusName = status.statusName!;
            int statusCount = 0;

            // Handle string or num type for count
            if (status.count != null) {
              if (status.count is String) {
                statusCount = int.tryParse(status.count.toString()) ?? 0;
              } else if (status.count is num) {
                statusCount = (status.count as num).toInt();
              }
            }

            // Add to or update the total for this status
            statusTotals[statusName] =
                (statusTotals[statusName] ?? 0) + statusCount;
          }
        }
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              showSearch: false,
              onSearch: (p0) {},
              leadingWidth: 40,
              leadingWidget: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColors.textGrey4,
                  ),
                  iconSize: 24,
                ),
              ),
              title: 'Enquiry Source Summary',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        AppStyles.isWebScreen(context)
                            ? const Text(
                                'Enquiry Source Summary',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(),
                        Flexible(child: Container()),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            reportsProvider.toggleFilter();
                            print(reportsProvider.isFilter);
                          },
                          icon: const Icon(Icons.filter_list),
                          label: Text(
                            MediaQuery.of(context).size.width > 860
                                ? 'Filter'
                                : '',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: reportsProvider.isFilter
                                ? Colors.white
                                : AppColors.primaryBlue,
                            backgroundColor: reportsProvider.isFilter
                                ? const Color(0xFF5499D9)
                                : Colors.white,
                            side: BorderSide(
                              color: reportsProvider.isFilter
                                  ? const Color(0xFF5499D9)
                                  : AppColors.primaryBlue,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (reportsProvider.isFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        onClickTopButton(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: reportsProvider.fromDate != null ||
                                      reportsProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (reportsProvider.fromDate == null &&
                                reportsProvider.toDate == null)
                              const Text('Entry Date: All'),
                            if (reportsProvider.fromDate != null &&
                                reportsProvider.toDate != null)
                              Text(
                                  'Date : ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Colors.black45,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null ||
                        (reportsProvider.selectedStatus != null &&
                            reportsProvider.selectedStatus != 0) ||
                        (reportsProvider.selectedUser != null &&
                            reportsProvider.selectedUser != 0) ||
                        reportsProvider.Search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Enquiry source',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  'Leads',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: ListView.builder(
                          itemCount: reportsProvider.enquiryReport.length,
                          itemBuilder: (context, index) {
                            final item = reportsProvider.enquiryReport[index];

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey[50],
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Source column
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item.enquirySourceName ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  // Count column
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: Text(
                                        '${item.totalLeads}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Details column with status counts
                                  Expanded(
                                    flex: 4,
                                    child: Wrap(
                                      spacing: 16,
                                      children: [
                                        if (item.summaryStatus != null)
                                          ...item.summaryStatus!.map((status) {
                                            // Choose color based on status
                                            Color statusColor =
                                                Colors.blue; // Default color

                                            if (status.statusName
                                                    ?.toLowerCase() ==
                                                'converted') {
                                              statusColor = Colors.green;
                                            } else if (status.statusName
                                                    ?.toLowerCase() ==
                                                'not responding') {
                                              statusColor = Colors.orange;
                                            } else if (status.statusName
                                                    ?.toLowerCase() ==
                                                'closed') {
                                              statusColor = Colors.red;
                                            } else if (status.statusName
                                                    ?.toLowerCase() ==
                                                'switch off') {
                                              statusColor = Colors.purple;
                                            }

                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '${status.statusName} ',
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  '${status.count}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Summary Footer with total counts
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Total Leads: $totalLeads',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: statusTotals.entries.map((entry) {
                                Color statusColor = Colors.blue;
                                final statusName = entry.key.toLowerCase();

                                if (statusName == 'converted') {
                                  statusColor = Colors.green;
                                } else if (statusName == 'not responding') {
                                  statusColor = Colors.orange;
                                } else if (statusName == 'closed') {
                                  statusColor = Colors.red;
                                } else if (statusName == 'switch off') {
                                  statusColor = Colors.purple;
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${entry.value}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

                          print(reportsProvider.formattedFromDate);
                          print(reportsProvider.formattedToDate);

                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
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
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = '';
                          String toDate = '';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getEnquirySummary(context);
                        },
                        style: ElevatedButton.styleFrom(
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
