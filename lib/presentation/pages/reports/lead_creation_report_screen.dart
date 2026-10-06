import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_creation_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_creation_summary_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_creation_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_creation_details_screen.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class LeadCreationReportScreen extends StatefulWidget {
  static const String route = '/leadCreationReport';
  const LeadCreationReportScreen({super.key});

  @override
  _LeadCreationReportScreenState createState() =>
      _LeadCreationReportScreenState();
}

class _LeadCreationReportScreenState extends State<LeadCreationReportScreen> {
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
                    Center(child: Text('Choose Date',
                        style: GoogleFonts.plusJakartaSans(
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
                    Text('Pick a date',
                      style:
                          GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<LeadCreationReportProvider>(context, listen: false);

      reportProvider.setDateFilter('This Month');
      reportProvider.selectDateFilterOption(4); 
      reportProvider.fetchReports(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const LeadCreationReportMobile();
    }

    final reportProvider = Provider.of<LeadCreationReportProvider>(context);

    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              title: Text('Lead Creation Report',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
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
              _buildFilters(context, reportProvider),
            Expanded(
              child: _buildReportList(context, reportProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, LeadCreationReportProvider reportProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                ScaffoldState? parent;
                context.visitAncestorElements((element) {
                  if (element is StatefulElement &&
                      element.state is ScaffoldState) {
                    ScaffoldState scaffold = element.state as ScaffoldState;
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
            'Lead Creation Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          CustomFilterButton(
            onPressed: () {
              reportProvider.toggleFilter();
            },
            isFilter: reportProvider.isFilter,
          ),
          const SizedBox(width: 8),
          CommonReportExportButton(
            onPressed: () {
              exportToExcel(
                headers: [
                  'Employee Name',
                  'Lead Count',
                ],
                data: reportProvider.reports.map((record) {
                  return {
                    'Employee Name': record.employeeName,
                    'Lead Count': record.leadCount,
                  };
                }).toList(),
                fileName: 'Lead_Creation_Report',
              );
            },
            label: 'Export to Excel',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
      BuildContext context,
      LeadCreationReportProvider reportProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
            fromDate: reportProvider.fromDate?.toString(),
            toDate: reportProvider.toDate?.toString(),
            formattedFromDate: reportProvider.formattedFromDate,
            formattedToDate: reportProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          const Spacer(),
          if (reportProvider.fromDate != null ||
              reportProvider.toDate != null)
            CommonReportResetButton(
              onReset: () {
                reportProvider.clearFilters();
                reportProvider.fetchReports(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: BorderSide(color: AppColors.textRed),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebTableHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Center(
                    child: Text('No.',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF607185))),
                  ),
                ),
              ),
              const TableWidget(
                  flex: 3, title: 'Employee Name', color: Color(0xFF607185)),
              const TableWidget(
                  flex: 2, title: 'Lead Count', color: Color(0xFF607185)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebTableRow(
      LeadCreationSummaryModel record, int index, LeadCreationReportProvider reportProvider, BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Center(
                    child: Text((index + 1).toString(),
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              TableWidget(
                flex: 3,
                data: Row(
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
                          record.employeeName.isEmpty ? 'N/A' : record.employeeName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TableWidget(
                flex: 2,
                data: InkWell(
                  onTap: () {
                    final fromDate = reportProvider.formattedFromDate.isEmpty ? 'empty' : reportProvider.formattedFromDate;
                    final toDate = reportProvider.formattedToDate.isEmpty ? 'empty' : reportProvider.formattedToDate;
                    context.push('${LeadCreationDetailsScreen.route}/${record.employeeId}/$fromDate/$toDate');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            record.leadCount.toString(),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColors.primaryBlue,
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
  }

  Widget _buildReportList(
      BuildContext context, LeadCreationReportProvider reportProvider) {
    if (reportProvider.isLoading && reportProvider.reports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildWebTableHeader(),
        Expanded(
          child: reportProvider.reports.isEmpty
              ? const CommonEmptyState(message: 'No lead creation reports found')
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: reportProvider.reports.length,
                  itemBuilder: (context, index) {
                    var record = reportProvider.reports[index];
                    return _buildWebTableRow(record, index, reportProvider, context);
                  },
                ),
        ),
        if (reportProvider.reports.isNotEmpty)
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Container(
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
            ),
          ),
      ],
    );
  }
}
