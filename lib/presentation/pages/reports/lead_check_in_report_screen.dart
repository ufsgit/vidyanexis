import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_check_in_report_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class LeadCheckInReportScreen extends StatefulWidget {
  const LeadCheckInReportScreen({super.key});

  @override
  _LeadCheckInReportScreenState createState() =>
      _LeadCheckInReportScreenState();
}

class _LeadCheckInReportScreenState extends State<LeadCheckInReportScreen> {
  TextEditingController searchController = TextEditingController();

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LeadCheckInReportProvider>(
        builder: (context, reportProvider, child) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
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
                            reportProvider.setDateFilter(title);
                            reportProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                reportProvider.selectedDateFilterIndex == index
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
                                reportProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportProvider.fromDate != null
                                  ? '${reportProvider.fromDate!.toLocal()}'
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
                                reportProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportProvider.toDate != null
                                  ? '${reportProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              reportProvider.setDates(null, null);
                              reportProvider.selectDateFilterOption(null);
                              Navigator.pop(context);
                              reportProvider.fetchReports(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.textRed),
                              foregroundColor: AppColors.textRed,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              reportProvider.formatDate();
                              Navigator.pop(context);
                              reportProvider.fetchReports(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<LeadCheckInReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      // Initialize dates for Today
      reportProvider.setDateFilter('Today');
      reportProvider.selectDateFilterOption(1); // 1 is 'Today' index

      dropdownProvider.getUserDetails(context);

      // Initialize with login user before fetching
      reportProvider.initializeWithLoginUser().then((_) {
        reportProvider.fetchReports(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const LeadCheckInReportMobile();
    }

    final reportProvider = Provider.of<LeadCheckInReportProvider>(context);
    final dropdownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              title: const Text('Check-in Reports',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (AppStyles.isWebScreen(context))
              _buildHeader(context, reportProvider),
            if (reportProvider.isFilter)
              _buildFilters(context, reportProvider, dropdownProvider),
            Expanded(
              child: _buildReportList(context, reportProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, LeadCheckInReportProvider reportProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Check-in Reports',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: MediaQuery.of(context).size.width / 4,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
              onSubmitted: (query) {
                reportProvider.setLeadSearch(query);
                reportProvider.fetchReports(context);
              },
              decoration: InputDecoration(
                hintText: 'Search here....',
                hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
                prefixIcon:
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      reportProvider.setLeadSearch(searchController.text);
                      reportProvider.fetchReports(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C7C93),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Search',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CustomFilterButton(
            onPressed: () {
              reportProvider.toggleFilter();
            },
            isFilter: reportProvider.isFilter,
          ),
          const SizedBox(width: 8),
          CustomElevatedButton(
            onPressed: () {
              exportToExcel(
                headers: [
                  'Staff Name',
                  'Lead Name',
                  'Check-in',
                  'Check-in Location',
                  'Check-out',
                  'Check-out Location',
                  'Difference',
                ],
                data: reportProvider.reports.map((record) {
                  return {
                    'Staff Name': record.userDetailsName ??
                        reportProvider.selectedUserName ??
                        'N/A',
                    'Lead Name': record.leadName ?? 'N/A',
                    'Check-in': _formatDateTime(record.checkinDate),
                    'Check-in Location': record.checkinLocation ?? 'N/A',
                    'Check-out': _formatDateTime(record.checkoutDate),
                    'Check-out Location': record.checkoutLocation ?? 'N/A',
                    'Difference':
                        reportProvider.calculateTimeDifference(record),
                  };
                }).toList(),
                fileName: 'Check_in_Reports',
              );
            },
            buttonText: 'Export to Excel',
            textColor: AppColors.whiteColor,
            borderColor: const Color(0xFFEBB12B),
            backgroundColor: const Color(0xFFEBB12B),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context,
      LeadCheckInReportProvider reportProvider,
      DropDownProvider dropdownProvider) {
    if (!AppStyles.isWebScreen(context)) {
      // Return existing mobile filters or a simplified version if needed
      // Currently, we are using LeadCheckInReportMobile for mobile, so this might not be hit if we keep the screen separation.
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: reportProvider.selectedUserId != null
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Text('Staff: '),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: reportProvider.selectedUserId,
                    hint: const Text('All'),
                    items: [
                      if (reportProvider.userType != "1")
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ...dropdownProvider.searchUserDetails
                          .where((staff) =>
                              reportProvider.userType != "1" ||
                              staff.userDetailsId ==
                                  reportProvider.selectedUserId)
                          .map((staff) {
                        return DropdownMenuItem<int>(
                          value: staff.userDetailsId,
                          child: Text(staff.userDetailsName,
                              style: const TextStyle(fontSize: 14)),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      String? name;
                      if (val != null) {
                        name = dropdownProvider.searchUserDetails
                            .firstWhere((s) => s.userDetailsId == val)
                            .userDetailsName;
                      }
                      reportProvider.setUserId(val, userName: name);
                      reportProvider.fetchReports(context);
                    },
                    isDense: true,
                    iconSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => onClickTopButton(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: reportProvider.fromDate != null ||
                          reportProvider.toDate != null
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reportProvider.fromDate == null &&
                      reportProvider.toDate == null)
                    Text('Date: ',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (reportProvider.fromDate == null &&
                      reportProvider.toDate == null)
                    const Text('All',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  if (reportProvider.fromDate != null &&
                      reportProvider.toDate != null)
                    Text('Date: ',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  if (reportProvider.fromDate != null &&
                      reportProvider.toDate != null)
                    Text(
                        '${DateFormat('dd MMM yyyy').format(reportProvider.fromDate!)} - ${DateFormat('dd MMM yyyy').format(reportProvider.toDate!)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 10),
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
          if (reportProvider.fromDate != null ||
              reportProvider.toDate != null ||
              reportProvider.selectedUserId != null ||
              reportProvider.leadSearch.isNotEmpty)
            CommonReportResetButton(
              onReset: () {
                reportProvider.clearFilters();
                reportProvider.setLeadSearch('');
                searchController.clear();
                reportProvider.fetchReports(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: BorderSide(color: AppColors.textRed),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportList(
      BuildContext context, LeadCheckInReportProvider reportProvider) {
    if (reportProvider.isLoading && reportProvider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reportProvider.reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No check-in reports found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Header Row
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Center(
                      child: Text('No.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF607185))),
                    ),
                  ),
                ),
                TableWidget(
                    flex: 2, title: 'Staff Name', color: Color(0xFF607185)),
                TableWidget(
                    flex: 2, title: 'Lead Name', color: Color(0xFF607185)),
                TableWidget(
                    width: 180, title: 'Check-in', color: Color(0xFF607185)),
                TableWidget(
                    flex: 3,
                    title: 'Check-in Location',
                    color: Color(0xFF607185)),
                TableWidget(
                    width: 180, title: 'Check-out', color: Color(0xFF607185)),
                TableWidget(
                    flex: 3,
                    title: 'Check-out Location',
                    color: Color(0xFF607185)),
                TableWidget(
                    width: 120, title: 'Difference', color: Color(0xFF607185)),
              ],
            ),
          ),
          // Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: reportProvider.reports.length,
              itemBuilder: (context, index) {
                var record = reportProvider.reports[index];
                return Container(
                  decoration: BoxDecoration(
                    color:
                        index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: Center(
                          child: Text((index + 1).toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      TableWidget(
                        flex: 2,
                        data: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EDF1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                size: 15,
                                color: Color(0xFF152D70),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  record.userDetailsName ??
                                      reportProvider.selectedUserName ??
                                      'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TableWidget(
                        flex: 2,
                        data: InkWell(
                          onTap: () {
                            if (record.customerId != null) {
                              context.push(
                                  '${CustomerDetailsScreen.route}${record.customerId.toString()}/${'true'}');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9EDF1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 15,
                                  color: Color(0xFF152D70),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    record.leadName ?? 'N/A',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: Color(0xFF152D70),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TableWidget(
                          width: 180,
                          fontSize: 12,
                          title: _formatDateTime(record.checkinDate)),
                      TableWidget(
                          flex: 3,
                          fontSize: 12,
                          title: record.checkinLocation ?? 'N/A'),
                      TableWidget(
                          width: 180,
                          fontSize: 12,
                          title: _formatDateTime(record.checkoutDate)),
                      TableWidget(
                          flex: 3,
                          fontSize: 12,
                          title: record.checkoutLocation ?? 'N/A'),
                      TableWidget(
                        width: 120,
                        data: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(
                                0xFFFFFBE6), // Light yellow for highlight
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reportProvider.calculateTimeDifference(record),
                            style: const TextStyle(
                                color: Color(0xFFFAAD14),
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
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
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
