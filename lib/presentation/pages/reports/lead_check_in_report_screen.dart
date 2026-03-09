import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_report_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_check_in_report_mobile.dart';

class LeadCheckInReportScreen extends StatefulWidget {
  const LeadCheckInReportScreen({super.key});

  @override
  _LeadCheckInReportScreenState createState() =>
      _LeadCheckInReportScreenState();
}

class _LeadCheckInReportScreenState extends State<LeadCheckInReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<LeadCheckInReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      // Initialize dates for this month
      DateTime now = DateTime.now();
      DateTime fromDate = DateTime(now.year, now.month, 1);
      DateTime toDate = DateTime(now.year, now.month + 1, 0);
      reportProvider.setDates(fromDate, toDate);

      dropdownProvider.getUserDetails(context);
      reportProvider.fetchReports(context);
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
      appBar: AppBar(
        title: const Text('Check-in Reports',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                reportProvider.toggleFilter();
              },
              icon: const Icon(Icons.filter_list),
              label: Text(reportProvider.isFilter ? 'Hide' : 'Filter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: reportProvider.isFilter
                    ? Colors.white
                    : AppColors.primaryBlue,
                backgroundColor: reportProvider.isFilter
                    ? const Color(0xFF5499D9)
                    : Colors.white,
                side: BorderSide(
                    color: reportProvider.isFilter
                        ? const Color(0xFF5499D9)
                        : AppColors.primaryBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (reportProvider.isFilter)
              _buildFilters(context, reportProvider, dropdownProvider),
            Expanded(
              child: _buildReportTable(context, reportProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context,
      LeadCheckInReportProvider reportProvider,
      DropDownProvider dropdownProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              // Lead Name Search
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lead Name',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        onChanged: (val) => reportProvider.setLeadSearch(val),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          icon: Icon(Icons.search, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Staff Selector
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Staff',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildStaffSelector(dropdownProvider, reportProvider),
                  ],
                ),
              ),
              // Date Range From
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From Date',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildVisibleDatePicker(context, reportProvider, true),
                  ],
                ),
              ),
              // Date Range To
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To Date',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildVisibleDatePicker(context, reportProvider, false),
                  ],
                ),
              ),
              // Action Buttons
              _buildActionButtons(context, reportProvider),
            ],
          ),
          const SizedBox(height: 16),
          // Date Shortcuts
          Row(
            children: [
              const Text('Quick Select:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: List<Widget>.generate(
                      reportProvider.dateButtonTitles.length, (index) {
                    String title = reportProvider.dateButtonTitles[index];
                    return ActionChip(
                      onPressed: () {
                        reportProvider.setDateFilter(title);
                        reportProvider.selectDateFilterOption(index);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      label: Text(title, style: const TextStyle(fontSize: 11)),
                      backgroundColor:
                          reportProvider.selectedDateFilterIndex == index
                              ? AppColors.primaryBlue
                              : Colors.white,
                      labelStyle: TextStyle(
                        color: reportProvider.selectedDateFilterIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisibleDatePicker(
      BuildContext context, LeadCheckInReportProvider provider, bool isFrom) {
    DateTime? date = isFrom ? provider.fromDate : provider.toDate;
    return InkWell(
      onTap: () => provider.selectDate(context, isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(date)
                  : 'Select...',
              style: const TextStyle(fontSize: 13),
            ),
            const Icon(Icons.calendar_month, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffSelector(DropDownProvider dropdownProvider,
      LeadCheckInReportProvider reportProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: reportProvider.selectedUserId,
          hint: const Text('All Staff'),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('All Staff'),
            ),
            ...dropdownProvider.searchUserDetails.map((staff) {
              return DropdownMenuItem<int>(
                value: staff.userDetailsId,
                child: Text(staff.userDetailsName),
              );
            }),
          ],
          onChanged: (val) {
            reportProvider.setUserId(val);
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, LeadCheckInReportProvider reportProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => reportProvider.fetchReports(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Show'),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            reportProvider.clearFilters();
            reportProvider.setLeadSearch('');
            reportProvider.fetchReports(context);
          },
          child: const Text('Reset', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildReportTable(
      BuildContext context, LeadCheckInReportProvider reportProvider) {
    if (reportProvider.isLoading && reportProvider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reportProvider.reports.isEmpty) {
      return const Center(
          child: Text('No reports found for the selected criteria.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
              columns: const [
                DataColumn(
                    label: Text('Staff Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Lead Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Check-in',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Check-in Location',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Check-out',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Check-out Location',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Difference',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: reportProvider.reports.map((record) {
                return DataRow(cells: [
                  DataCell(Text(record.userDetailsName ?? 'N/A')),
                  DataCell(Text(record.leadName ?? 'N/A')),
                  DataCell(Text(_formatDateTime(record.checkinDate))),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        record.checkinLocation ?? 'N/A',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(Text(_formatDateTime(record.checkoutDate))),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        record.checkoutLocation ?? 'N/A',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reportProvider.calculateTimeDifference(record),
                        style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
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
