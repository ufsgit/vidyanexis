import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/work_report_provider.dart';
import 'package:vidyanexis/controller/work_summary_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class WorkReportPhone extends StatefulWidget {
  static const String route = '/workReport/';
  final String userId;
  final String userName;
  const WorkReportPhone({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<WorkReportPhone> createState() => _WorkReportPhoneState();
}

class _WorkReportPhoneState extends State<WorkReportPhone> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      final reportsProvider =
          Provider.of<WorkReportProvider>(context, listen: false);
      final workSummaryProvider =
          Provider.of<WorkSummaryProvider>(context, listen: false);
      //pass date from work summary to work report
      reportsProvider.selectDateFilterOption(null);

      reportsProvider.formattedFromDate = workSummaryProvider.formattedFromDate;
      reportsProvider.formattedToDate = workSummaryProvider.formattedToDate;
      reportsProvider.setTaskSearchCriteria(
          '',
          reportsProvider.formattedFromDate,
          reportsProvider.formattedToDate,
          '',
          '');
      if (workSummaryProvider.fromDate != null) {
        reportsProvider
            .setFromDate(workSummaryProvider.fromDate ?? DateTime.now());
      }
      if (workSummaryProvider.toDate != null) {
        reportsProvider.setToDate(workSummaryProvider.toDate ?? DateTime.now());
      }
      //
      reportsProvider.getSearchTaskReport(widget.userId, context);
      searchProvider.stopSearch();
      reportsProvider.setFilter(false);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '0');
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final reportsProvider =
          Provider.of<WorkReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria(
        query,
        reportsProvider.fromDateS,
        reportsProvider.toDateS,
        reportsProvider.Status,
        reportsProvider.AssignedTo,
      );
      reportsProvider.getSearchTaskReport(widget.userId, context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WorkReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        leadingWidget: const BackButton(color: Colors.black),
        title: 'Work report of ${widget.userName}',
        showFilterIcon: false,
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
          searchProvider.stopSearch();
          reportsProvider.toggleFilter();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
          );
          reportsProvider.getSearchTaskReport(widget.userId, context);
        },
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.AssignedTo,
          );
          reportsProvider.getSearchTaskReport(widget.userId, context);
        },
        onChanged: _onSearchChanged,
        searchController: searchController,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── FILTER PANEL ────────────────────────────────────────────────
          if (reportsProvider.isFilter)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    CustomText('Status',
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
                          isSelected: reportsProvider.selectedStatus == 0 ||
                              reportsProvider.selectedStatus == null,
                          onTap: () {
                            reportsProvider.setStatus(0);
                          },
                        ),
                        ...provider.followUpData.map((s) => FilterChipWidget(
                              label: s.statusName ?? 'Unknown',
                              isSelected:
                                  reportsProvider.selectedStatus == s.statusId,
                              onTap: () {
                                reportsProvider.setStatus(s.statusId ?? 0);
                              },
                            )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomText('Date Range',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            onClickTopButton(context);
                          },
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.scaffoldColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 200),
                                      child: CustomText(
                                        reportsProvider.fromDate == null &&
                                                reportsProvider.toDate == null
                                            ? 'Date'
                                            : 'Date : ${reportsProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${reportsProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: AppColors.textGrey3, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
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
                            reportsProvider.getSearchTaskReport(
                                widget.userId, context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textRed,
                            elevation: 0,
                            side: BorderSide(color: AppColors.textRed),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── LIST ────────────────────────────────────────────────────────

          if (!reportsProvider.isFilter)
            Expanded(
              child: reportsProvider.taskReport.isEmpty
                  ? const CommonEmptyState(message: 'No work reports found')
                  : Column(
                      children: [
                        CommonReportSummaryBar(
                          totalLabel: 'Total Records',
                          totalCount: reportsProvider.taskReport.length,
                          showingLabel: 'Showing',
                          showingCount: reportsProvider.taskReport.length,
                        ),
                        Expanded(
                          child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider(
                                height: 1,
                                color: AppColors.grey.withAlpha(50),
                              );
                            },
                            itemCount: reportsProvider.taskReport.length,
                            itemBuilder: (context, index) {
                              var service = reportsProvider.taskReport[index];

                              Color statusColor =
                                  service.statusName == "Completed"
                                      ? Colors.green
                                      : service.statusName == "In Progress"
                                          ? Colors.orange
                                          : Colors.red;
                              return ReportListItem(
                                title: service.customer,
                                subtitle: service.statusName,
                                status: service.statusName,
                                statusColor: statusColor,
                                description: service.remark.isEmpty
                                    ? 'No remark provided'
                                    : service.remark,
                                bottomLeftIcon: Icons.person_outline,
                                bottomLeftText: service.assignedTo,
                                bottomRightText:
                                    service.entryDate.toDayMonthYearFormat(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerDetailPageMobile(
                                        customerId: service.customerId,
                                        fromLead: false,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: reportsProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_work_report_filter_fab',
                  onPressed: () {
                    reportsProvider.getSearchTaskReport(widget.userId, context);
                    reportsProvider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false)
                        .stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : null,
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<WorkReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
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
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          backgroundColor: AppColors.textRed.withAlpha(26),
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

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
