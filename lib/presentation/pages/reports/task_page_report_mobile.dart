import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class TaskPageReportMobile extends StatefulWidget {
  const TaskPageReportMobile({super.key});

  @override
  State<TaskPageReportMobile> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPageReportMobile> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria(
        query,
        reportsProvider.fromDateS,
        reportsProvider.toDateS,
        reportsProvider.Status,
        reportsProvider.selectedUser?.toString() ?? '0',
        reportsProvider.selectedTaskType?.toString() ?? '0',
      );
      _refreshData();
    });
  }

  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      reportsProvider.setTaskSearchCriteria('', '', '', '', '', '');
      hasMoreData = true;
      reportsProvider.getSearchTaskReport(context);
      searchProvider.stopSearch();
      reportsProvider.setFilter(false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "3");
    });
  }

  void _refreshData() {
    setState(() {
      hasMoreData = true;
    });
    Provider.of<TaskReportProvider>(context, listen: false)
        .getSearchTaskReport(context);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      loadMoreTasks();
    }
  }

  Future<void> loadMoreTasks() async {
    final reportsProvider =
        Provider.of<TaskReportProvider>(context, listen: false);

    setState(() {
      isLoadingMore = true;
    });

    reportsProvider.nextPage();

    bool isEmpty =
        await reportsProvider.getSearchTaskReport(context, isLoadMore: true);
    if (isEmpty) {
      hasMoreData = false;
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<TaskReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    // final customerDetailsProvider =
    //     Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Task Report',
        showFilterIcon: false,
        onSearchTap: () {
          searchProvider.startSearch();
          reportsProvider.setFilter(true);
        },
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          reportsProvider.toggleFilter();
          print(reportsProvider.isFilter);
        },
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          reportsProvider.setFilter(false);

          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
            '',
          );
          _refreshData();
        },
        onSearch: (query) {
          // reportsProvider.selectDateFilterOption(null);
          // reportsProvider.removeStatus();
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.selectedUser?.toString() ?? '0',
            reportsProvider.selectedTaskType?.toString() ?? '0',
          );
          _refreshData();
        },
        onChanged: _onSearchChanged,
        onExcelTap: () async {
          final allTasks =
              await reportsProvider.fetchAllTasksForExport(context);
          if (allTasks.isNotEmpty) {
            exportToExcel(
              headers: [
                'Customer Name',
                'Phone Number',
                'Address',
                'Task',
                'Enquiry for',
                'Assigned To',
                'Description',
                'Date',
                'Location',
                'Status'
              ],
              data: allTasks.map((task) {
                return {
                  'Customer Name': task.customerName,
                  'Phone Number': task.mobile,
                  'Address':
                      '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                  'Task': task.taskTypeName,
                  'Enquiry for': task.enquiryForName,
                  'Assigned To': task.toUserName,
                  'Description': task.description,
                  'Date': task.entryDate.isNotEmpty
                      ? DateFormat('dd MMM yyyy')
                          .format(DateTime.parse(task.entryDate))
                      : '',
                  'Location': task.location,
                  'Status': task.taskStatusName,
                };
              }).toList(),
              fileName: 'Task_Report',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No data found')),
            );
          }
        },
        showExcel: true,
        searchController: searchController,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── FILTER PANEL ────────────────────────────────────────────────
            if (reportsProvider.isFilter)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
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
                            onTap: () => reportsProvider.toggleStatus(0),
                          ),
                          ...provider.followUpData.map((s) => FilterChipWidget(
                                label: s.statusName ?? 'Unknown',
                                isSelected: reportsProvider.selectedStatus ==
                                    s.statusId,
                                onTap: () => reportsProvider
                                    .toggleStatus(s.statusId ?? 0),
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
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textGrey3,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Assigned Staff',
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
                            onTap: () => reportsProvider.setUserFilterStatus(0),
                          ),
                          ...provider.searchUserDetails
                              .map((u) => FilterChipWidget(
                                    label: u.userDetailsName ?? 'Unknown',
                                    isSelected: reportsProvider.selectedUser ==
                                        u.userDetailsId,
                                    onTap: () =>
                                        reportsProvider.setUserFilterStatus(
                                            u.userDetailsId ?? 0),
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Task Type',
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
                            isSelected: reportsProvider.selectedTaskType == 0 ||
                                reportsProvider.selectedTaskType == null,
                            onTap: () => reportsProvider.setTaskType(0),
                          ),
                          ...provider.taskType.map((t) => FilterChipWidget(
                                label: t.taskTypeName,
                                isSelected: reportsProvider.selectedTaskType ==
                                    t.taskTypeId,
                                onTap: () =>
                                    reportsProvider.setTaskType(t.taskTypeId),
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
                          (reportsProvider.selectedTaskType != null &&
                              reportsProvider.selectedTaskType != 0))
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              searchController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                  '', '', '', '', '', '');
                              _refreshData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

            // ── SUMMARY BAR ──────────────────────────────────────────────────
            if (reportsProvider.taskReport.isNotEmpty &&
                !reportsProvider.isFilter)
              CommonReportSummaryBar(
                totalLabel: 'Total Tasks',
                totalCount: reportsProvider.totalSize,
                showingLabel: 'Showing',
                showingCount: reportsProvider.taskReport.length,
              ),

            // ── LIST ────────────────────────────────────────────────────────

            if (!reportsProvider.isFilter)
              Expanded(
                child: reportsProvider.taskReport.isEmpty
                    ? const CommonEmptyState(message: 'No task reports found')
                    : SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            ListView.separated(
                              separatorBuilder: (context, index) {
                                return Divider(
                                  height: 1,
                                  color: AppColors.grey.withOpacity(0.5),
                                );
                              },
                              itemCount: reportsProvider.taskReport.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final task = reportsProvider.taskReport[index];

                                Color statusColor =
                                    task.taskStatusName == "Completed"
                                        ? Colors.green
                                        : task.taskStatusName == "In Progress"
                                            ? Colors.orange
                                            : Colors.red;

                                return ReportListItem(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return TaskDetailsPagePhone(
                                            taskId: task.taskId.toString(),
                                            taskMasterId:
                                                task.taskMasterId.toString(),
                                            customerId:
                                                task.customerId.toString());
                                      },
                                    ));
                                  },
                                  title: task.taskTypeName,
                                  subtitle: task.customerName,
                                  id: task.taskId.toString(),
                                  status: task.taskStatusName,
                                  statusColor: statusColor,
                                  description: task.description,
                                  locationText: task.location.isEmpty ? 'No Location' : task.location,
                                  bottomLeftIcon: Icons.calendar_month_outlined,
                                  bottomLeftText: task.taskDate
                                      .toString()
                                      .toFormattedDate(),
                                  bottomRightText:
                                      task.entryDate.toString().toTimeAgo(),
                                );
                              },
                            ),
                            if (isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: reportsProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_task_report_filter_fab',
                  onPressed: () {
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.fromDateS,
                      reportsProvider.toDateS,
                      reportsProvider.Status,
                      reportsProvider.selectedUser?.toString() ?? '0',
                      reportsProvider.selectedTaskType?.toString() ?? '0',
                    );
                    searchProvider.stopSearch();
                    reportsProvider.getSearchTaskReport(context);
                    reportsProvider.setFilter(false);
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
      builder: (contextx) => Consumer<TaskReportProvider>(
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

                          print(reportsProvider.formattedFromDate);
                          print(reportsProvider.formattedToDate);

                          String status = reportsProvider.Status;
                          String assignedTo = reportsProvider.selectedUser?.toString() ?? '0';
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          String taskType = reportsProvider.selectedTaskType?.toString() ?? '0';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          _refreshData();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          String status = reportsProvider.Status;
                          String assignedTo = reportsProvider.selectedUser?.toString() ?? '0';
                          String fromDate = '';
                          String toDate = '';
                          String taskType = reportsProvider.selectedTaskType?.toString() ?? '0';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          _refreshData();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          backgroundColor: AppColors.textRed.withAlpha(25),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildStatusFilter(
      TaskReportProvider reportsProvider, DropDownProvider dropDownProvider) {
    final bool hasSelection = reportsProvider.selectedStatusIds.isNotEmpty &&
        reportsProvider.selectedStatusIds.first != 0;

    // Build label text from selected statuses
    String labelText = 'All';
    if (hasSelection) {
      final selectedNames = dropDownProvider.followUpData
          .where((s) => reportsProvider.selectedStatusIds.contains(s.statusId))
          .map((s) => s.statusName ?? '')
          .toList();
      labelText = selectedNames.join(', ');
    }

    return Container(
      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasSelection ? AppColors.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (ctx) {
                  return _StatusMultiSelectDialog(
                    allStatuses: dropDownProvider.followUpData,
                    selectedIds:
                        List<int>.from(reportsProvider.selectedStatusIds),
                    onApply: (selectedIds) {
                      if (selectedIds.isEmpty || selectedIds.contains(0)) {
                        reportsProvider.toggleStatus(0);
                      } else {
                        reportsProvider.toggleStatus(0); // Reset first
                        for (final id in selectedIds) {
                          reportsProvider.toggleStatus(id);
                        }
                      }
                      reportsProvider.setTaskSearchCriteria(
                        reportsProvider.Search,
                        reportsProvider.fromDateS,
                        reportsProvider.toDateS,
                        reportsProvider.Status,
                        reportsProvider.selectedUser?.toString() ?? '0',
                        reportsProvider.selectedTaskType?.toString() ?? '0',
                      );
                      _refreshData();
                    },
                  );
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.4),
                  child: Text(
                    'Status: $labelText',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          hasSelection ? AppColors.primaryBlue : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: hasSelection ? AppColors.primaryBlue : Colors.black45,
                ),
              ],
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                reportsProvider.toggleStatus(0); // Reset to All
                reportsProvider.setTaskSearchCriteria(
                  reportsProvider.Search,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.selectedUser?.toString() ?? '0',
                  reportsProvider.selectedTaskType?.toString() ?? '0',
                );
                _refreshData();
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select Status dialog (Adapted for Task Report)
// ---------------------------------------------------------------------------
class _StatusMultiSelectDialog extends StatefulWidget {
  final List allStatuses;
  final List<int> selectedIds;
  final void Function(List<int>) onApply;

  const _StatusMultiSelectDialog({
    required this.allStatuses,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<_StatusMultiSelectDialog> createState() =>
      _StatusMultiSelectDialogState();
}

class _StatusMultiSelectDialogState extends State<_StatusMultiSelectDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = List<int>.from(widget.selectedIds);
    _tempSelected.remove(0);
  }

  void _toggle(int id) {
    setState(() {
      if (_tempSelected.contains(id)) {
        _tempSelected.remove(id);
      } else {
        _tempSelected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Status',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allStatuses.length,
                itemBuilder: (ctx, idx) {
                  final status = widget.allStatuses[idx];
                  final id = status.statusId;
                  final name = status.statusName ?? '';
                  final isSelected = _tempSelected.contains(id);

                  return InkWell(
                    onTap: () => _toggle(id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(name,
                                  style: const TextStyle(fontSize: 14))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
