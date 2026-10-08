import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_deadline_report_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/task_deadline_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class TaskDeadlineReportScreen extends StatefulWidget {
  static const String route = '/taskDeadlineReport';
  final bool fromDashBoard;

  const TaskDeadlineReportScreen({super.key, this.fromDashBoard = false});

  @override
  State<TaskDeadlineReportScreen> createState() =>
      _TaskDeadlineReportScreenState();
}

class _TaskDeadlineReportScreenState extends State<TaskDeadlineReportScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<TaskDeadlineReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      dropDownProvider.getUserDetails(context);
      dropDownProvider.getTaskType(context);
      settingsProvider.searchDepartment('', context);

      reportProvider.fetchReports(context);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNodeWeb.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'done':
      case 'closed':
        return const Color(0xFF10B981);
      case 'pending':
      case 'in progress':
      case 'open':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  void _exportData(TaskDeadlineReportProvider provider) {
    final headers = [
      'S.No',
      'Task ID',
      'Customer ID',
      'Customer Name',
      'Phone Number',
      'Task Type',
      'Duration (Days)',
      'Status',
      'Assigned To',
      'Entry Date',
      'Days Pending',
      'Overdue Days',
    ];

    final data = provider.filteredReports.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return {
        'S.No': index,
        'Task ID': item.taskId?.toString() ?? '-',
        'Customer ID': item.customerId?.toString() ?? '-',
        'Customer Name': item.customerName ?? '',
        'Phone Number': item.phoneNumber ?? '',
        'Task Type': item.taskTypeName ?? '',
        'Duration (Days)': item.duration?.toString() ?? '0',
        'Status': item.taskStatusName ?? '',
        'Assigned To': item.toUserName ?? '',
        'Entry Date': item.entryDate ?? '',
        'Days Pending': item.daysPending?.toString() ?? '0',
        'Overdue Days': item.overdueDays?.toString() ?? '0',
      };
    }).toList();

    exportToExcel(
      headers: headers,
      data: data,
      fileName: 'Task_Deadline_Report_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<TaskDeadlineReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Task Deadline Report',
              onSearchTap: () {
                sideProvider.startSearch();
              },
              onSearch: (query) {
                reportProvider.setSearchQuery(query);
              },
              onClearTap: () {
                searchController.clear();
                sideProvider.stopSearch();
                reportProvider.setSearchQuery('');
              },
              searchController: searchController,
              showExcel: true,
              onExcelTap: () => _exportData(reportProvider),
            ),
      body: isWeb
          ? _buildWebBody(
              context, reportProvider, dropDownProvider, settingsProvider)
          : _buildMobileBody(
              context, reportProvider, dropDownProvider, settingsProvider),
      bottomNavigationBar: _buildPaginationControls(context),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEB VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildWebBody(
    BuildContext context,
    TaskDeadlineReportProvider reportProvider,
    DropDownProvider dropDownProvider,
    SettingsProvider settingsProvider,
  ) {
    final reports = reportProvider.paginatedReports;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildWebHeader(context, reportProvider),
          ),
          if (reportProvider.isFilter)
            SliverToBoxAdapter(
              child: _buildWebFilter(
                  context, reportProvider, dropDownProvider, settingsProvider),
            ),
          SliverToBoxAdapter(
            child: _buildSummaryCards(reportProvider),
          ),
          SliverToBoxAdapter(
            child: _buildTableHeader(),
          ),
          if (reportProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (reports.isEmpty)
            const SliverFillRemaining(
              child: CommonEmptyState(
                  message: 'No task deadline report records found'),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = reports[index];
                  final globalIndex = (reportProvider.currentPage - 1) *
                          reportProvider.pageSize +
                      index;
                  return _buildTableRow(item, globalIndex);
                },
                childCount: reports.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(
      BuildContext context, TaskDeadlineReportProvider reportProvider) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (widget.fromDashBoard) ...[
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                size: 24,
                color: Color(0xFF152D70),
              ),
            ),
            const SizedBox(width: 8),
          ] else ...[
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () {
                  ScaffoldState? parent;
                  ctx.visitAncestorElements((element) {
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
          ],
          Text(
            'Task Deadline Report',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              color: const Color(0xFF152D70),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: 280,
            height: 38,
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
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNodeWeb,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                reportProvider.setSearchQuery(val);
              },
              decoration: InputDecoration(
                hintText: 'Search customer, task, user...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                suffixIcon: const Icon(Icons.search,
                    color: Color(0xFF64748B), size: 18),
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
          const SizedBox(width: 16),
          CommonReportExportButton(
            onPressed: () => _exportData(reportProvider),
            label: 'Export',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TaskDeadlineReportProvider reportProvider) {
    final all = reportProvider.filteredReports;
    final totalTasks = all.length;
    final overdueTasks = all.where((t) => (t.overdueDays ?? 0) > 0).length;
    final pendingTasks = all
        .where((t) => (t.daysPending ?? 0) > 0 && (t.overdueDays ?? 0) <= 0)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildSummaryChip(
            title: 'Total Tasks',
            count: totalTasks.toString(),
            color: const Color(0xFF3B82F6),
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(width: 12),
          _buildSummaryChip(
            title: 'Overdue Tasks',
            count: overdueTasks.toString(),
            color: const Color(0xFFEF4444),
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(width: 12),
          _buildSummaryChip(
            title: 'Pending On-Time',
            count: pendingTasks.toString(),
            color: const Color(0xFFF59E0B),
            icon: Icons.timelapse_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                count,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWebFilter(
    BuildContext context,
    TaskDeadlineReportProvider reportProvider,
    DropDownProvider dropDownProvider,
    SettingsProvider settingsProvider,
  ) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Task Type Filter
            _buildDropdownContainer(
              label: 'Task Type: ',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: reportProvider.selectedTaskTypeId,
                  items: [
                    DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('All Task Types',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                    ...dropDownProvider.taskType.map((type) {
                      return DropdownMenuItem<int?>(
                        value: type.taskTypeId,
                        child: Text(type.taskTypeName,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    reportProvider.setTaskTypeId(val, context);
                  },
                  isDense: true,
                  iconSize: 20,
                ),
              ),
            ),

            // To User Filter
            _buildDropdownContainer(
              label: 'Assigned To: ',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: reportProvider.selectedToUserId,
                  items: [
                    DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('All Users',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                    ...dropDownProvider.searchUserDetails.map((user) {
                      return DropdownMenuItem<int?>(
                        value: user.userDetailsId,
                        child: Text(user.userDetailsName,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    reportProvider.setToUserId(val, context);
                  },
                  isDense: true,
                  iconSize: 20,
                ),
              ),
            ),

            // Department Filter
            _buildDropdownContainer(
              label: 'Department: ',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: reportProvider.selectedDepartmentId,
                  items: [
                    DropdownMenuItem<int?>(
                      value: 0,
                      child: Text('All Departments',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                    ),
                    ...settingsProvider.departmentModel.map((dept) {
                      return DropdownMenuItem<int?>(
                        value: dept.departmentId,
                        child: Text(dept.departmentName,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    reportProvider.setDepartmentId(val, context);
                  },
                  isDense: true,
                  iconSize: 20,
                ),
              ),
            ),

            CommonReportResetButton(
              onReset: () {
                searchController.clear();
                reportProvider.clearFilters(context);
              },
              label: 'Reset',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownContainer(
      {required String label, required Widget child}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: const Row(
            children: [
              TableWidget(title: 'S.No', flex: 1, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Task ID', flex: 1, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Customer Name', flex: 3, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Phone Number', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Task Type', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Duration', flex: 1, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Status', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Assigned To', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Entry Date', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Days Pending', flex: 2, fontWeight: FontWeight.bold),
              TableWidget(
                  title: 'Overdue Days', flex: 2, fontWeight: FontWeight.bold),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(TaskDeadlineReportModel item, int index) {
    final isEven = index % 2 == 0;
    final statusColor = _statusColor(item.taskStatusName);
    final isOverdue = (item.overdueDays ?? 0) > 0;

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isEven ? Colors.white : const Color(0xFFF8FAFC),
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            TableWidget(title: '${index + 1}', flex: 1),
            TableWidget(title: '${item.taskId ?? '-'}', flex: 1),
            TableWidget(
              title: item.customerName?.isNotEmpty == true
                  ? item.customerName!
                  : '-',
              flex: 3,
              fontWeight: FontWeight.w600,
            ),
            TableWidget(title: item.phoneNumber ?? '-', flex: 2),
            TableWidget(
              title: item.taskTypeName ?? '-',
              flex: 2,
              fontWeight: FontWeight.w500,
            ),
            TableWidget(title: '${item.duration ?? 0} d', flex: 1),

            // Status Badge
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      item.taskStatusName ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            TableWidget(title: item.toUserName ?? '-', flex: 2),
            TableWidget(title: item.entryDate ?? '-', flex: 2),

            // Days Pending
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${item.daysPending ?? 0} days',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
            ),

            // Overdue Days Badge
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? const Color(0xFFEF4444).withOpacity(0.12)
                          : const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isOverdue
                            ? const Color(0xFFEF4444).withOpacity(0.4)
                            : const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      isOverdue ? '${item.overdueDays} days late' : 'On Time',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE VIEW
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildMobileBody(
    BuildContext context,
    TaskDeadlineReportProvider reportProvider,
    DropDownProvider dropDownProvider,
    SettingsProvider settingsProvider,
  ) {
    final reports = reportProvider.paginatedReports;

    return Column(
      children: [
        // Mobile Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  // Task Type Dropdown
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: reportProvider.selectedTaskTypeId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: 0,
                              child: Text('All Task Types',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12)),
                            ),
                            ...dropDownProvider.taskType.map((type) {
                              return DropdownMenuItem<int?>(
                                value: type.taskTypeId,
                                child: Text(type.taskTypeName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12)),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            reportProvider.setTaskTypeId(val, context);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // User Dropdown
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: reportProvider.selectedToUserId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: 0,
                              child: Text('All Users',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12)),
                            ),
                            ...dropDownProvider.searchUserDetails.map((user) {
                              return DropdownMenuItem<int?>(
                                value: user.userDetailsId,
                                child: Text(user.userDetailsName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12)),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            reportProvider.setToUserId(val, context);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Department Dropdown
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          isExpanded: true,
                          value: reportProvider.selectedDepartmentId,
                          items: [
                            DropdownMenuItem<int?>(
                              value: 0,
                              child: Text('All Departments',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12)),
                            ),
                            ...settingsProvider.departmentModel.map((dept) {
                              return DropdownMenuItem<int?>(
                                value: dept.departmentId,
                                child: Text(dept.departmentName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12)),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            reportProvider.setDepartmentId(val, context);
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      searchController.clear();
                      reportProvider.clearFilters(context);
                    },
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          'Clear',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Count Banner
        if (reportProvider.totalCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${reportProvider.startLimit}–${reportProvider.endLimit} of ${reportProvider.totalCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey3,
                  ),
                ),
                Text(
                  'Overdue: ${reportProvider.filteredReports.where((t) => (t.overdueDays ?? 0) > 0).length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),

        // List
        Expanded(
          child: reportProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reports.isEmpty
                  ? const CommonEmptyState(
                      message: 'No task deadline report records found')
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      itemCount: reports.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = reports[index];
                        return _buildMobileCard(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildMobileCard(TaskDeadlineReportModel item) {
    final statusColor = _statusColor(item.taskStatusName);
    final isOverdue = (item.overdueDays ?? 0) > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOverdue
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Customer Name & Task ID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.customerName?.isNotEmpty == true
                      ? item.customerName!
                      : 'Unknown Customer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Task #${item.taskId ?? '-'}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Phone & Task Type
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.textGrey3),
              const SizedBox(width: 4),
              Text(
                item.phoneNumber?.isNotEmpty == true ? item.phoneNumber! : '-',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textGrey2,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.label_outline,
                  size: 14, color: AppColors.textGrey3),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.taskTypeName ?? '-',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Assigned to & Entry date
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 14, color: AppColors.textGrey3),
              const SizedBox(width: 4),
              Text(
                'To: ${item.toUserName ?? '-'}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textGrey2,
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textGrey3),
              const SizedBox(width: 4),
              Text(
                item.entryDate ?? '-',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textGrey3,
                ),
              ),
            ],
          ),
          const Divider(height: 16),

          // Row 4: Status & Overdue Badges
          Row(
            children: [
              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  item.taskStatusName ?? '-',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Duration
              Text(
                'Duration: ${item.duration ?? 0}d',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.textGrey3,
                ),
              ),
              const Spacer(),
              // Overdue / Days Pending
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? const Color(0xFFEF4444).withOpacity(0.12)
                      : const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isOverdue
                        ? const Color(0xFFEF4444).withOpacity(0.3)
                        : const Color(0xFF10B981).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 12,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOverdue
                          ? '${item.overdueDays}d overdue (${item.daysPending}d pend)'
                          : '${item.daysPending}d pending',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOverdue
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION CONTROLS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPaginationControls(BuildContext context) {
    final reportProvider = Provider.of<TaskDeadlineReportProvider>(context);

    if (reportProvider.totalCount == 0) return const SizedBox.shrink();

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16),
            onPressed: reportProvider.hasPreviousPage
                ? () => reportProvider.fetchPreviousPage()
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Showing ${reportProvider.startLimit} – ${reportProvider.endLimit} of ${reportProvider.totalCount}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: reportProvider.hasNextPage
                ? () => reportProvider.fetchNextPage()
                : null,
          ),
        ],
      ),
    );
  }
}
