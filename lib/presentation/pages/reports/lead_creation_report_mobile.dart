import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/lead_creation_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_creation_details_screen.dart';

class LeadCreationReportMobile extends StatelessWidget {
  const LeadCreationReportMobile({super.key});

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LeadCreationReportProvider>(
        builder: (context, reportProvider, child) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
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
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(
                          reportProvider.dateButtonTitles.length, (index) {
                        String title = reportProvider.dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            reportProvider.setDateFilter(title);
                            reportProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: GoogleFonts.plusJakartaSans(
                            color:
                                reportProvider.selectedDateFilterIndex == index
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Pick a date',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16, fontWeight: FontWeight.w700),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Creation Report',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<LeadCreationReportProvider>(
        builder: (context, reportProvider, child) {
          return Column(
            children: [
              _buildFilterSection(context, reportProvider),
              Expanded(
                child: _buildReportList(context, reportProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, LeadCreationReportProvider reportProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: CommonReportDateFilter(
                  fromDate: reportProvider.fromDate?.toString(),
                  toDate: reportProvider.toDate?.toString(),
                  formattedFromDate: reportProvider.formattedFromDate,
                  formattedToDate: reportProvider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                ),
              ),
            ],
          ),
          if (reportProvider.fromDate != null ||
              reportProvider.toDate != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                onReset: () {
                  reportProvider.clearFilters();
                  reportProvider.fetchReports(context);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReportList(
      BuildContext context, LeadCreationReportProvider reportProvider) {
    if (reportProvider.isLoading && reportProvider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reportProvider.reports.isEmpty) {
      return const CommonEmptyState(message: 'No lead creation reports found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reportProvider.reports.length,
      itemBuilder: (context, index) {
        var record = reportProvider.reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Employee: ${record.employeeName}',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bar_chart, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Lead Count: ${record.leadCount}',
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('${LeadCreationDetailsScreen.route}/${record.employeeId}/${reportProvider.formattedFromDate}/${reportProvider.formattedToDate}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text('View Details', style: GoogleFonts.plusJakartaSans(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
