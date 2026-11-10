import 'dart:math';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/task_report_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

class TaskPageReport extends StatefulWidget {
  final bool fromDashBoard;

  const TaskPageReport({super.key, this.fromDashBoard = false});

  @override
  State<TaskPageReport> createState() => _tasksPageReportState();
}

class _tasksPageReportState extends State<TaskPageReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskReportProvider>(context, listen: false);
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1);
      reportsProvider.getSearchTaskReport(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "3");
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<TaskReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    if (!AppStyles.isWebScreen(context)) {
      return const TaskPageReportMobile();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: _buildPaginationControls(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(context, reportsProvider),

          // KPI Summary Cards
          _buildKpiSection(reportsProvider),

          // Filter Panel (collapsible)
          if (reportsProvider.isFilter)
            _buildFilterPanel(reportsProvider, provider),

          // Main Table Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width < 1650
                            ? 1650
                            : MediaQuery.of(context).size.width - 32,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Table Header Row
                            _buildTableHeader(),

                            // Table Data Rows
                            if (reportsProvider.taskReport.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(48.0),
                                child: Center(
                                  child: CommonEmptyState(
                                    message: 'No task reports found',
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: List.generate(
                                  reportsProvider.taskReport.length,
                                  (index) {
                                    final task =
                                        reportsProvider.taskReport[index];
                                    return _TaskTableRowItem(
                                      index: index,
                                      child: _buildTableRowContent(
                                        context,
                                        index,
                                        task,
                                        reportsProvider,
                                        customerDetailsProvider,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header Area
  // ---------------------------------------------------------------------------
  Widget _buildHeader(
      BuildContext context, TaskReportProvider reportsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          if (widget.fromDashBoard) ...[
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 20,
                  color: Color(0xFF152D70),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
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
                    borderRadius: BorderRadius.circular(8),
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
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Task Report',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF152D70),
                ),
              ),
              Text(
                'Track assignments, progress, and team performance',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Modern Search Box
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNodeWeb,
              textAlignVertical: TextAlignVertical.center,
              onTap: () {
                Future.microtask(() {
                  if (searchController.text.isNotEmpty &&
                      searchController.selection.baseOffset == 0 &&
                      searchController.selection.extentOffset ==
                          searchController.text.length) {
                    searchController.selection = TextSelection.collapsed(
                        offset: searchController.text.length);
                  }
                });
              },
              onSubmitted: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.selectedUser?.toString() ?? '0',
                  reportsProvider.selectedTaskType?.toString() ?? '0',
                );
                reportsProvider.getSearchTaskReport(context, resetPage: true);
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Search customer, phone, staff...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 18),
                suffixIcon: searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchController.clear();
                          reportsProvider.setTaskSearchCriteria(
                            '',
                            reportsProvider.fromDateS,
                            reportsProvider.toDateS,
                            reportsProvider.Status,
                            reportsProvider.selectedUser?.toString() ?? '0',
                            reportsProvider.selectedTaskType?.toString() ?? '0',
                          );
                          reportsProvider.getSearchTaskReport(context,
                              resetPage: true);
                        },
                        child: const Icon(Icons.close,
                            color: Color(0xFF94A3B8), size: 16),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Filter Toggle Button
          CustomFilterButton(
            onPressed: () {
              reportsProvider.toggleFilter();
            },
            isFilter: reportsProvider.isFilter,
          ),
          const SizedBox(width: 10),

          // Export Button
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: TextButton.icon(
              onPressed: () async {
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
                    const SnackBar(content: Text('No data found to export')),
                  );
                }
              },
              icon: const Icon(
                Icons.file_download_outlined,
                size: 18,
                color: Color(0xFF152D70),
              ),
              label: Text(
                'Export',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF152D70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // KPI Summary Metric Strip
  // ---------------------------------------------------------------------------
  Widget _buildKpiSection(TaskReportProvider reportsProvider) {
    final tasks = reportsProvider.taskReport;
    final totalCount = reportsProvider.totalSize > 0
        ? reportsProvider.totalSize
        : tasks.length;
    final completedCount = tasks
        .where((t) => t.taskStatusName.toLowerCase().contains('complete'))
        .length;
    final confirmedCount = tasks
        .where((t) =>
            t.taskStatusName.toLowerCase().contains('confirm') &&
            !t.taskStatusName.toLowerCase().contains('complete'))
        .length;
    final otherCount = (tasks.length - completedCount - confirmedCount)
        .clamp(0, tasks.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: _buildKpiCard(
              title: 'Total Tasks',
              value: totalCount.toString(),
              subtitle: 'Logged records',
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFEFF6FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              title: 'Completed',
              value: completedCount.toString(),
              subtitle: 'On this page',
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              title: 'Confirmed',
              value: confirmedCount.toString(),
              subtitle: 'In pipeline',
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF4F46E5),
              iconBg: const Color(0xFFEEF2FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildKpiCard(
              title: 'Action / In Progress',
              value: otherCount.toString(),
              subtitle: 'Requires review',
              icon: Icons.pending_actions_rounded,
              iconColor: const Color(0xFFD97706),
              iconBg: const Color(0xFFFFFBEB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '($subtitle)',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Filter Panel
  // ---------------------------------------------------------------------------
  Widget _buildFilterPanel(
      TaskReportProvider reportsProvider, DropDownProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildStatusFilter(reportsProvider, provider),
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          _buildUserDropdown(reportsProvider, provider),
          _buildTaskTypeDropdown(reportsProvider, provider),
          if (reportsProvider.fromDate != null ||
              reportsProvider.toDate != null ||
              (reportsProvider.selectedStatus != null &&
                  reportsProvider.selectedStatus != 0) ||
              (reportsProvider.selectedUser != null &&
                  reportsProvider.selectedUser != 0) ||
              (reportsProvider.selectedTaskType != null &&
                  reportsProvider.selectedTaskType != 0) ||
              reportsProvider.Search.isNotEmpty)
            CommonReportResetButton(
              onReset: () {
                reportsProvider.selectDateFilterOption(null);
                reportsProvider.toggleStatus(0); // Reset to All
                searchController.clear();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  '',
                  '',
                  '0',
                  '',
                  '',
                );
                reportsProvider.getSearchTaskReport(context, resetPage: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                foregroundColor: const Color(0xFFDC2626),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFFECACA)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserDropdown(
      TaskReportProvider reportsProvider, DropDownProvider provider) {
    final isSelected = reportsProvider.selectedUser != null &&
        reportsProvider.selectedUser != 0;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline_rounded,
              size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            'Assigned to: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
          DropdownButton<int>(
            value: reportsProvider.selectedUser,
            hint: Text('All',
                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('All',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ),
                ] +
                provider.searchUserDetails
                    .map((status) => DropdownMenuItem<int>(
                          value: status.userDetailsId,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              status.userDetailsName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          ),
                        ))
                    .toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                reportsProvider.setUserFilterStatus(newValue);
              }
              reportsProvider.setTaskSearchCriteria(
                reportsProvider.Search,
                reportsProvider.formattedFromDate,
                reportsProvider.formattedToDate,
                reportsProvider.Status,
                reportsProvider.selectedUser?.toString() ?? '0',
                reportsProvider.selectedTaskType?.toString() ?? '0',
              );
              reportsProvider.getSearchTaskReport(context, resetPage: true);
            },
            underline: const SizedBox.shrink(),
            isDense: true,
            iconSize: 18,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTypeDropdown(
      TaskReportProvider reportsProvider, DropDownProvider provider) {
    final isSelected = reportsProvider.selectedTaskType != null &&
        reportsProvider.selectedTaskType != 0;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment_outlined,
              size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            'Task Type: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
          DropdownButton<int>(
            value: reportsProvider.selectedTaskType,
            hint: Text('All',
                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            items: [
                  DropdownMenuItem<int>(
                    value: 0,
                    child: Text('All',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                  ),
                ] +
                provider.taskType
                    .map((status) => DropdownMenuItem<int>(
                          value: status.taskTypeId,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              status.taskTypeName,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            ),
                          ),
                        ))
                    .toList(),
            onChanged: (int? newValue) {
              if (newValue != null) {
                reportsProvider.setTaskType(newValue);
              }
              reportsProvider.setTaskSearchCriteria(
                reportsProvider.Search,
                reportsProvider.formattedFromDate,
                reportsProvider.formattedToDate,
                reportsProvider.Status,
                reportsProvider.selectedUser?.toString() ?? '0',
                reportsProvider.selectedTaskType?.toString() ?? '0',
              );
              reportsProvider.getSearchTaskReport(context, resetPage: true);
            },
            underline: const SizedBox.shrink(),
            isDense: true,
            iconSize: 18,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF64748B), size: 18),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Table Header Row
  // ---------------------------------------------------------------------------
  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('No.', 55),
          _buildHeaderCell('Customer Name', 190),
          _buildHeaderCell('Phone Number', 130),
          _buildHeaderCell('Address', 160),
          _buildHeaderCell('Task', 170),
          _buildHeaderCell('Enquiry for', 120),
          _buildHeaderCell('Staff', 150),
          _buildHeaderCell('Description', 180),
          _buildHeaderCell('Date', 120),
          _buildHeaderCell('Location', 160),
          _buildHeaderCell('Status', 140, alignment: Alignment.center),
          _buildHeaderCell('Details', 100, alignment: Alignment.center),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, double width,
      {Alignment alignment = Alignment.centerLeft}) {
    return SizedBox(
      width: width,
      child: Align(
        alignment: alignment,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: const Color(0xFF475569),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Table Row Content
  // ---------------------------------------------------------------------------
  Widget _buildTableRowContent(
    BuildContext context,
    int index,
    TaskReportModel task,
    TaskReportProvider reportsProvider,
    CustomerDetailsProvider customerDetailsProvider,
  ) {
    final rowNumber =
        (reportsProvider.pageIndex - 1) * reportsProvider.pageSize + index + 1;

    final fullAddress = [
      task.address1,
      task.address2,
      task.address3,
      task.address4,
    ].where((e) => e.trim().isNotEmpty).join(', ');

    return Row(
      children: [
        // No.
        SizedBox(
          width: 55,
          child: Text(
            rowNumber.toString(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),

        // Customer Name
        SizedBox(
          width: 190,
          child: Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: const Color(0xFFEFF6FF),
                child: Text(
                  task.customerName.trim().isNotEmpty
                      ? task.customerName.trim()[0].toUpperCase()
                      : 'C',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Tooltip(
                  message: task.customerName,
                  child: InkWell(
                    onTap: () {
                      context.push(
                          '${CustomerDetailsScreen.route}${task.customerId.toString()}/true');
                    },
                    child: Text(
                      task.customerName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D4ED8),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF93C5FD),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Phone Number
        SizedBox(
          width: 130,
          child: Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  task.mobile.isEmpty ? '—' : task.mobile,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF334155),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        // Address
        SizedBox(
          width: 160,
          child: fullAddress.isEmpty
              ? Text('—',
                  style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFCBD5E1)))
              : Tooltip(
                  message: fullAddress,
                  child: Text(
                    fullAddress,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),

        // Task Type
        SizedBox(
          width: 170,
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: task.parsedTaskTypeColor ?? const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Tooltip(
                  message: task.taskTypeName,
                  child: Text(
                    task.taskTypeName.isEmpty ? '—' : task.taskTypeName,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Enquiry For
        SizedBox(
          width: 120,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.enquiryForName.toUpperCase().contains('SOLAR')
                  ? const Color(0xFFFFFBEB)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: task.enquiryForName.toUpperCase().contains('SOLAR')
                    ? const Color(0xFFFDE68A)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (task.enquiryForName.toUpperCase().contains('SOLAR')) ...[
                  const Icon(Icons.wb_sunny_rounded,
                      size: 12, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    task.enquiryForName.isEmpty ? 'General' : task.enquiryForName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: task.enquiryForName.toUpperCase().contains('SOLAR')
                          ? const Color(0xFFB45309)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Staff
        SizedBox(
          width: 150,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFFF3E8FF),
                child: Text(
                  task.toUserName.trim().isNotEmpty
                      ? task.toUserName.trim()[0].toUpperCase()
                      : 'S',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7E22CE),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.toUserName.isEmpty ? 'Unassigned' : task.toUserName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: task.toUserName.isEmpty
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Description
        SizedBox(
          width: 180,
          child: task.description.isEmpty
              ? Text('—',
                  style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFCBD5E1)))
              : Tooltip(
                  message: task.description,
                  child: Text(
                    task.description,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),

        // Date
        SizedBox(
          width: 120,
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              Text(
                task.entryDate.isNotEmpty
                    ? DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(task.entryDate))
                    : '—',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),

        // Location
        SizedBox(
          width: 160,
          child: Builder(builder: (context) {
            final loc = task.locationName.isNotEmpty
                ? task.locationName
                : (task.location.isEmpty ? 'No Location' : task.location);
            final hasLoc = loc.isNotEmpty && loc != 'No Location';
            return Tooltip(
              message: loc,
              child: Row(
                children: [
                  Icon(
                    hasLoc ? Icons.place_outlined : Icons.location_off_outlined,
                    size: 14,
                    color: hasLoc
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      loc,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontStyle:
                            hasLoc ? FontStyle.normal : FontStyle.italic,
                        color: hasLoc
                            ? const Color(0xFF334155)
                            : const Color(0xFF94A3B8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),

        // Status Badge
        SizedBox(
          width: 140,
          child: Center(
            child: _buildStatusBadge(task.taskStatusName, task.taskStatusId),
          ),
        ),

        // Details Button
        SizedBox(
          width: 100,
          child: Center(
            child: InkWell(
              onTap: () async {
                String taskId = task.taskMasterId.toString();
                String customerId = task.customerId.toString();
                customerDetailsProvider.getTaskDetails(taskId, context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return TaskDetailsWidget(
                      taskId: taskId,
                      customerId: customerId,
                      showEdit: false,
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.visibility_outlined,
                        size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(
                      'Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Status Badge Pill with Indicator Dot & Pastel Colors
  // ---------------------------------------------------------------------------
  Widget _buildStatusBadge(String statusName, int statusId) {
    final nameLower = statusName.trim().toLowerCase();

    Color bg;
    Color text;
    Color dot;

    if (nameLower.contains('complete') ||
        nameLower.contains('done') ||
        nameLower.contains('finish')) {
      bg = const Color(0xFFECFDF5);
      text = const Color(0xFF065F46);
      dot = const Color(0xFF10B981);
    } else if (nameLower.contains('work confirm')) {
      bg = const Color(0xFFF0FDFA);
      text = const Color(0xFF115E59);
      dot = const Color(0xFF14B8A6);
    } else if (nameLower.contains('confirm')) {
      bg = const Color(0xFFEEF2FF);
      text = const Color(0xFF3730A3);
      dot = const Color(0xFF6366F1);
    } else if (nameLower.contains('progress') ||
        nameLower.contains('visit') ||
        nameLower.contains('pending')) {
      bg = const Color(0xFFFFFBEB);
      text = const Color(0xFF92400E);
      dot = const Color(0xFFF59E0B);
    } else if (nameLower.contains('cancel') ||
        nameLower.contains('reject') ||
        nameLower.contains('failed')) {
      bg = const Color(0xFFFEF2F2);
      text = const Color(0xFF991B1B);
      dot = const Color(0xFFEF4444);
    } else if (nameLower.contains('feasibility') ||
        nameLower.contains('verify') ||
        nameLower.contains('file')) {
      bg = const Color(0xFFF5F3FF);
      text = const Color(0xFF5B21B6);
      dot = const Color(0xFF8B5CF6);
    } else {
      bg = const Color(0xFFF1F5F9);
      text = const Color(0xFF334155);
      dot = const Color(0xFF94A3B8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dot.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              statusName.isEmpty ? 'Pending' : statusName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.plusJakartaSans(
                color: text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Date Picker Dialog
  // ---------------------------------------------------------------------------
  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<TaskReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(24),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(dateButtonTitles.length,
                        (index) {
                      String title = dateButtonTitles[index];
                      final isSelected =
                          reportsProvider.selectedDateFilterIndex == index;
                      return ChoiceChip(
                        label: Text(title),
                        selected: isSelected,
                        onSelected: (_) {
                          reportsProvider.setDateFilter(title);
                          reportsProvider.selectDateFilterOption(index);
                        },
                        selectedColor: AppColors.primaryBlue,
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Custom Date Range',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () =>
                              reportsProvider.selectDate(context, true),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1)),
                            ),
                            hintText: reportsProvider.fromDate != null
                                ? '${reportsProvider.fromDate!.toLocal()}'
                                    .split(' ')[0]
                                : 'From Date',
                            hintStyle: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8)),
                            suffixIcon: const Icon(Icons.calendar_month,
                                size: 18, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () =>
                              reportsProvider.selectDate(context, false),
                          style: GoogleFonts.plusJakartaSans(fontSize: 13),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Color(0xFFCBD5E1)),
                            ),
                            hintText: reportsProvider.toDate != null
                                ? '${reportsProvider.toDate!.toLocal()}'
                                    .split(' ')[0]
                                : 'To Date',
                            hintStyle: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8)),
                            suffixIcon: const Icon(Icons.calendar_month,
                                size: 18, color: Color(0xFF64748B)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            reportsProvider.selectDateFilterOption(null);
                            reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              '',
                              '',
                              reportsProvider.Status,
                              reportsProvider.selectedUser?.toString() ?? '0',
                              reportsProvider.selectedTaskType?.toString() ??
                                  '0',
                            );
                            reportsProvider.getSearchTaskReport(context,
                                resetPage: true);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Clear',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            reportsProvider.formatDate();
                            reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              reportsProvider.formattedFromDate,
                              reportsProvider.formattedToDate,
                              reportsProvider.Status,
                              reportsProvider.selectedUser?.toString() ?? '0',
                              reportsProvider.selectedTaskType?.toString() ??
                                  '0',
                            );
                            reportsProvider.getSearchTaskReport(context,
                                resetPage: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

  // ---------------------------------------------------------------------------
  // Status Filter Pill & Modal
  // ---------------------------------------------------------------------------
  Widget _buildStatusFilter(
      TaskReportProvider reportsProvider, DropDownProvider dropDownProvider) {
    final bool hasSelection = reportsProvider.selectedStatusIds.isNotEmpty &&
        reportsProvider.selectedStatusIds.first != 0;

    String labelText = 'All';
    if (hasSelection) {
      final selectedNames = dropDownProvider.taskStatuses
          .where((s) => reportsProvider.selectedStatusIds.contains(s.statusId))
          .map((s) => s.statusName ?? '')
          .toList();
      labelText = selectedNames.join(', ');
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasSelection ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () async {
              await showDialog(
                context: context,
                barrierColor: Colors.black26,
                builder: (ctx) {
                  return _StatusMultiSelectDialog(
                    allStatuses: dropDownProvider.taskStatuses,
                    selectedIds:
                        List<int>.from(reportsProvider.selectedStatusIds),
                    onApply: (selectedIds) {
                      if (selectedIds.isEmpty || selectedIds.contains(0)) {
                        reportsProvider.toggleStatus(0);
                      } else {
                        reportsProvider.toggleStatus(0);
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
                      reportsProvider.getSearchTaskReport(context,
                          resetPage: true);
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
                      maxWidth: MediaQuery.of(context).size.width * 0.18),
                  child: Text(
                    'Status: $labelText',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: hasSelection
                          ? AppColors.primaryBlue
                          : const Color(0xFF334155),
                      fontWeight:
                          hasSelection ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: hasSelection
                      ? AppColors.primaryBlue
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                reportsProvider.toggleStatus(0);
                reportsProvider.setTaskSearchCriteria(
                  reportsProvider.Search,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.selectedUser?.toString() ?? '0',
                  reportsProvider.selectedTaskType?.toString() ?? '0',
                );
                reportsProvider.getSearchTaskReport(context, resetPage: true);
              },
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pagination Bar
  // ---------------------------------------------------------------------------
  Widget _buildPaginationControls(BuildContext context) {
    return Consumer<TaskReportProvider>(
      builder: (context, provider, child) {
        if (provider.totalPages <= 0 || provider.taskReport.isEmpty) {
          return const SizedBox.shrink();
        }

        final startItem = (provider.pageIndex - 1) * provider.pageSize + 1;
        final totalItems = provider.totalSize > 0
            ? provider.totalSize
            : provider.taskReport.length;
        final endItem = min(provider.pageIndex * provider.pageSize, totalItems);

        return Container(
          height: 64,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $startItem to $endItem of $totalItems tasks',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPageNavButton(
                    icon: Icons.chevron_left_rounded,
                    isEnabled: provider.pageIndex > 1,
                    onTap: () {
                      provider.previousPage();
                      provider.getSearchTaskReport(context);
                    },
                  ),
                  const SizedBox(width: 4),
                  ...List.generate(provider.totalPages, (index) {
                    int page = index + 1;
                    if (provider.totalPages > 7) {
                      if (index > 1 &&
                          index < provider.totalPages - 2 &&
                          (page < provider.pageIndex - 1 ||
                              page > provider.pageIndex + 1)) {
                        if (page == provider.pageIndex - 2 ||
                            page == provider.pageIndex + 2) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '...',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                    }

                    bool isSelected = page == provider.pageIndex;
                    return InkWell(
                      onTap: () {
                        if (!isSelected) {
                          provider.goToPage(page);
                          provider.getSearchTaskReport(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$page',
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF334155),
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 4),
                  _buildPageNavButton(
                    icon: Icons.chevron_right_rounded,
                    isEnabled: provider.pageIndex < provider.totalPages,
                    onTap: () {
                      provider.nextPage();
                      provider.getSearchTaskReport(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageNavButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isEnabled ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isEnabled ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Hoverable Table Row
// ---------------------------------------------------------------------------
class _TaskTableRowItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _TaskTableRowItem({
    required this.index,
    required this.child,
  });

  @override
  State<_TaskTableRowItem> createState() => _TaskTableRowItemState();
}

class _TaskTableRowItemState extends State<_TaskTableRowItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? const Color(0xFFF1F5F9)
              : (widget.index % 2 == 0
                  ? Colors.white
                  : const Color(0xFFF8FAFC)),
          border: Border(
            bottom: BorderSide(
              color: _isHovered
                  ? const Color(0xFFCBD5E1)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Multi-select Status Dialog
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter by Status',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Select one or multiple statuses to filter tasks',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600),
                    ),
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
