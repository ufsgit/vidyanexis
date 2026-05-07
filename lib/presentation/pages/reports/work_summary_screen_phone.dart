import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/work_summary_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/work_report_screen_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class WorkSummaryPhone extends StatefulWidget {
  const WorkSummaryPhone({super.key});

  @override
  State<WorkSummaryPhone> createState() => _WorkSummaryPhoneState();
}

class _WorkSummaryPhoneState extends State<WorkSummaryPhone> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<WorkSummaryProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchWorkSummary(context);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      searchProvider.stopSearch();
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      reportsProvider.setFilter(false);

      //search
      // searchController.addListener(() {
      //   reportsProvider.selectDateFilterOption(null);
      //   reportsProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   reportsProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WorkSummaryProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    // final customerDetailsProvider =
    //     Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              searchProvider.stopSearch();
              customerProvider.setFilter(false);
              leadProvider.setFilter(false);
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: 'Work Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          reportsProvider.toggleFilter();
        },
        onSearchTap: () {
          searchProvider.startSearch();
          reportsProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          reportsProvider.toggleFilter();

          searchProvider.stopSearch();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
          );
          reportsProvider.getSearchWorkSummary(context);
        },
        showFilterIcon: false,
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.AssignedTo,
          );
          reportsProvider.getSearchWorkSummary(context);
        },
        searchController: searchController,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FILTER PANEL ────────────────────────────────────────────────
          if (reportsProvider.isFilter)
            SingleChildScrollView(
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
                  CommonReportDateFilter(
                    fromDate: reportsProvider.fromDate?.toString(),
                    toDate: reportsProvider.toDate?.toString(),
                    formattedFromDate: reportsProvider.formattedFromDate,
                    formattedToDate: reportsProvider.formattedToDate,
                    onTap: () => onClickTopButton(context),
                  ),
                  const SizedBox(height: 16),
                  CustomText('Staff',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      FilterChipWidget(
                        label: 'All',
                        isSelected: reportsProvider.selectedUser == 0 ||
                            reportsProvider.selectedUser == null,
                        onTap: () {
                          reportsProvider.setUserFilterStatus(0);
                          reportsProvider.getSearchWorkSummary(context);
                        },
                      ),
                      ...provider.searchUserDetails.map((u) => FilterChipWidget(
                            label: u.userDetailsName ?? 'Unknown',
                            isSelected:
                                reportsProvider.selectedUser == u.userDetailsId,
                            onTap: () {
                              reportsProvider
                                  .setUserFilterStatus(u.userDetailsId);
                              reportsProvider.getSearchWorkSummary(context);
                            },
                          )),
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
                              '', '', '', '', '');
                          reportsProvider.getSearchWorkSummary(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          elevation: 0,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ── LIST ────────────────────────────────────────────────────────

          Expanded(
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
              itemCount: reportsProvider.taskReport.length,
              itemBuilder: (context, index) {
                var lead = reportsProvider.taskReport[index];
                return ReportListItem(
                  title: lead.toStaff,
                  subtitle: '${lead.noOfFollowUp} Follow-Ups >',
                  status: '',
                  statusColor: getAvatarColor(lead.toStaff),
                  bottomLeftIcon: Icons.person_outline,
                  bottomLeftText: 'Staff Member',
                  description:
                      'View detailed work and follow-up reports for ${lead.toStaff}',
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkReportPhone(
                            userId: lead.userDetailsId.toString(),
                            userName: lead.toStaff.toString(),
                          ),
                        ));
                  },
                );
              },
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
      builder: (contextx) => Consumer<WorkSummaryProvider>(
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
                          reportsProvider.getSearchWorkSummary(context);
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
                      child: CommonReportResetButton(
                        onReset: () {
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
                          reportsProvider.getSearchWorkSummary(context);
                        },
                        label: 'Clear',
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
