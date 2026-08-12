import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/pdf_function.dart';
import 'package:vidyanexis/model/dashboard/user_activity_report_model.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';

class UserActivityTab extends StatefulWidget {
  const UserActivityTab({super.key});

  @override
  State<UserActivityTab> createState() => _UserActivityTabState();
}

class _UserActivityTabState extends State<UserActivityTab> {
  int _userReportCurrentPage = 0;
  int _taskPanelCurrentPage = 0;
  final int _itemsPerPage = 15;

  @override
  Widget build(BuildContext context) {
    final dashBoardProvider = Provider.of<DashboardProvider>(context);

    if (dashBoardProvider.isLoading || !dashBoardProvider.isUserActivityLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = dashBoardProvider.userActivityReport;
    if (report == null || (report.summary == null && (report.userReport == null || report.userReport!.isEmpty))) {
      return const Center(child: Text('No Activity Data Available'));
    }

    final mainContent = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.summary != null) ...[
            _buildSummarySection(context, report),
            const SizedBox(height: 32),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Staff Activity Report'),
              _buildFilterSwitchButton(context),
            ],
          ),
          const SizedBox(height: 12),
          _buildUserReportTable(report.userReport ?? []),
        ],
      ),
    );

    final containerDecoration = BoxDecoration(
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
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: containerDecoration,
              padding: const EdgeInsets.all(12),
              child: mainContent,
            ),
          ),
        if (dashBoardProvider.selectedTaskFilterType != null) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Container(
              decoration: containerDecoration,
              padding: const EdgeInsets.all(12),
              child: _buildRightSideTaskPanel(dashBoardProvider),
            ),
          ),
        ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, UserActivityReportModel report) {
    final summary = report.summary!;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildSummaryCard(context, 'Total Assigned', 'Assigned', summary.totalAssigned?.toString() ?? '0', Colors.blue),
        _buildSummaryCard(context, 'Total Completed', 'Completed', summary.totalCompleted ?? '0', Colors.green),
        _buildSummaryCard(context, 'Total Pending', 'Pending', summary.totalPending ?? '0', Colors.orange),
        _buildSummaryCard(context, 'Total Overdue', 'Overdue', summary.totalOverdue ?? '0', Colors.red),
        _buildSummaryCard(context, 'Performance %', null, summary.performancePercentage ?? '0.00', Colors.purple),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 32,
              child: CommonReportExportButton(
                onPressed: () => _exportToExcel(report),
                label: 'Export to Excel',
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 150,
              height: 32,
              child: ElevatedButton.icon(
                onPressed: () => _exportToPdf(report),
                icon: const Icon(Icons.picture_as_pdf, size: 14),
                label: const Text('Export to PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSwitchButton(BuildContext context) {
    final dashBoardProvider = Provider.of<DashboardProvider>(context);
    final activeFilter = dashBoardProvider.userActivityDateType;

    Widget buildOption(String title, String value) {
      final isActive = activeFilter == value;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            dashBoardProvider.setUserActivityDateType(context, value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: isActive
                  ? const Border(bottom: BorderSide(color: Colors.blue, width: 2))
                  : const Border(bottom: BorderSide(color: Colors.transparent, width: 2)),
            ),
            child: Text(
              title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildOption('TaskDate', 'TaskDate'),
        const SizedBox(width: 8),
        buildOption('Estimated', 'Estimated'),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String? filterType, String value, Color color) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: filterType != null 
            ? () {
                Provider.of<DashboardProvider>(context, listen: false)
                    .fetchAdminDashboardTaskList(filterType);
                setState(() {
                  _taskPanelCurrentPage = 0;
                });
              }
            : null,
        hoverColor: color.withOpacity(0.2),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightSideTaskPanel(DashboardProvider provider) {
    if (provider.isAdminDashboardTasksLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tasks = provider.adminDashboardTasks ?? [];
    final int totalItems = tasks.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int startIndex = _taskPanelCurrentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage > totalItems) ? totalItems : (startIndex + _itemsPerPage);
    final paginatedTasks = tasks.isNotEmpty ? tasks.sublist(startIndex, endIndex) : [];

    List<dynamic> visibleKeys = [];
    if (tasks.isNotEmpty) {
      final hiddenKeyPatterns = [
        'taskid', 'customerid', 'tasktypeid', 'taskstatusid', 'priorityid', 'userdetailsid'
      ];
      visibleKeys = tasks.first.keys.where((key) {
        final normalizedKey = key.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '');
        return !hiddenKeyPatterns.contains(normalizedKey);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.selectedTaskFilterType} Tasks',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
            Row(
              children: [
                if (tasks.isNotEmpty) ...[
                  SizedBox(
                    height: 32,
                    child: CommonReportExportButton(
                      onPressed: () => _exportTasksToExcel(tasks, visibleKeys, provider.selectedTaskFilterType ?? 'Tasks'),
                      label: 'Export to Excel',
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: () => _exportTasksToPdf(tasks, visibleKeys, provider.selectedTaskFilterType ?? 'Tasks'),
                      icon: const Icon(Icons.picture_as_pdf, size: 14),
                      label: const Text('Export to PDF', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  'Total: $totalItems',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    provider.clearAdminDashboardTasks();
                    setState(() {
                      _taskPanelCurrentPage = 0;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No tasks found.')),
          )
        else if (visibleKeys.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No data to display.')),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 56.0 + (paginatedTasks.length * 48.0) + 20.0,
                child: DataTable2(
                  fixedLeftColumns: 1,
                  fixedTopRows: 1,
                  minWidth: visibleKeys.length * 200.0,
                  headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                  columns: visibleKeys
                      .map<DataColumn>((key) => DataColumn2(
                            size: ColumnSize.L,
                            label: Text(
                              key.toString().replaceAll('_', ' '),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  rows: paginatedTasks.map<DataRow>((task) {
                    return DataRow(
                      cells: visibleKeys
                          .map<DataCell>((key) {
                            final isCustomerName = key.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') == 'customername';
                            
                            return DataCell(
                              Tooltip(
                                message: task[key]?.toString() ?? '',
                                child: Text(
                                  task[key]?.toString() ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: isCustomerName
                                      ? const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600,
                                        )
                                      : null,
                                ),
                              ),
                              onTap: isCustomerName
                                  ? () {
                                      final customerIdKey = task.keys.firstWhere(
                                          (k) => k.toString().toLowerCase().replaceAll('_', '').replaceAll(' ', '') == 'customerid',
                                          orElse: () => '');
                                      if (customerIdKey.isNotEmpty) {
                                        final customerId = int.tryParse(task[customerIdKey]?.toString() ?? '');
                                        if (customerId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CustomerDetailsScreen(
                                                customerId: customerId.toString(),
                                                report: 'true',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                            );
                          }).toList(),
                    );
                  }).toList(),
                ),
              ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _taskPanelCurrentPage > 0
                              ? () {
                                  setState(() {
                                    _taskPanelCurrentPage--;
                                  });
                                }
                              : null,
                        ),
                        Text('Page ${_taskPanelCurrentPage + 1} of $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _taskPanelCurrentPage < totalPages - 1
                              ? () {
                                  setState(() {
                                    _taskPanelCurrentPage++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
      ],
    );
  }

  Widget _buildUserReportTable(List<UserReportModel> reportData) {
    if (reportData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('No staff activity data')),
      );
    }
    final int totalItems = reportData.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int startIndex = _userReportCurrentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage > totalItems) ? totalItems : (startIndex + _itemsPerPage);
    final paginatedData = reportData.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56.0 + (paginatedData.length * 48.0) + 20.0,
          child: DataTable2(
            minWidth: 700,
            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
            columns: const [
              DataColumn2(label: Text('Staff Name'), size: ColumnSize.L),
              DataColumn2(label: Text('Assigned'), size: ColumnSize.S),
              DataColumn2(label: Text('Completed'), size: ColumnSize.S),
              DataColumn2(label: Text('Pending'), size: ColumnSize.S),
              DataColumn2(label: Text('Overdue'), size: ColumnSize.S),
              DataColumn2(label: Text('Avg Completion (mins)'), size: ColumnSize.L),
              DataColumn2(label: Text('Productivity'), size: ColumnSize.S),
            ],
            rows: paginatedData.map((data) {
              return DataRow(cells: [
                DataCell(Text(data.userDetailsName ?? '')),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: HoverableLinkText(
                      text: data.assigned?.toString() ?? '0',
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    Provider.of<DashboardProvider>(context, listen: false)
                        .fetchAdminDashboardTaskList('Assigned', userId: data.userDetailsId);
                    setState(() {
                      _taskPanelCurrentPage = 0;
                    });
                  },
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: HoverableLinkText(
                      text: data.completed ?? '0',
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    Provider.of<DashboardProvider>(context, listen: false)
                        .fetchAdminDashboardTaskList('Completed', userId: data.userDetailsId);
                    setState(() {
                      _taskPanelCurrentPage = 0;
                    });
                  },
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: HoverableLinkText(
                      text: data.pending ?? '0',
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    Provider.of<DashboardProvider>(context, listen: false)
                        .fetchAdminDashboardTaskList('Pending', userId: data.userDetailsId);
                    setState(() {
                      _taskPanelCurrentPage = 0;
                    });
                  },
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: HoverableLinkText(
                      text: data.overdue ?? '0',
                      color: Colors.blue,
                    ),
                  ),
                  onTap: () {
                    Provider.of<DashboardProvider>(context, listen: false)
                        .fetchAdminDashboardTaskList('Overdue', userId: data.userDetailsId);
                    setState(() {
                      _taskPanelCurrentPage = 0;
                    });
                  },
                ),
                DataCell(Text(data.averageCompletionMinutes ?? '')),
                DataCell(Text(data.productivity ?? '')),
              ]);
            }).toList(),
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _userReportCurrentPage > 0
                      ? () {
                          setState(() {
                            _userReportCurrentPage--;
                          });
                        }
                      : null,
                ),
                Text('Page ${_userReportCurrentPage + 1} of $totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _userReportCurrentPage < totalPages - 1
                      ? () {
                          setState(() {
                            _userReportCurrentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _exportTasksToExcel(List<dynamic> tasks, List<dynamic> visibleKeys, String filterType) {
    if (tasks.isEmpty) return;
    
    final headers = visibleKeys.map((k) => k.toString().replaceAll('_', ' ')).toList();
    final data = tasks.map((task) {
      final map = <String, dynamic>{};
      for (var key in visibleKeys) {
        map[key.toString().replaceAll('_', ' ')] = task[key]?.toString() ?? '';
      }
      return map;
    }).toList();

    exportToExcel(
      headers: headers,
      data: data,
      fileName: '${filterType}Tasks',
    );
  }

  void _exportTasksToPdf(List<dynamic> tasks, List<dynamic> visibleKeys, String filterType) {
    if (tasks.isEmpty) return;
    
    final headers = visibleKeys.map((k) => k.toString().replaceAll('_', ' ')).toList();
    final data = tasks.map((task) {
      final map = <String, dynamic>{};
      for (var key in visibleKeys) {
        map[key.toString().replaceAll('_', ' ')] = task[key]?.toString() ?? '';
      }
      return map;
    }).toList();

    exportToPDF(
      headers: headers,
      data: data,
      fileName: '${filterType}Tasks',
    );
  }

  List<String> get _exportHeaders => [
        'Staff Name',
        'Assigned',
        'Completed',
        'Pending',
        'Overdue',
        'Avg Completion (mins)',
        'Productivity'
      ];

  List<Map<String, dynamic>> _getExportData(UserActivityReportModel report) {
    final data = <Map<String, dynamic>>[];
    for (var d in report.userReport ?? <UserReportModel>[]) {
      data.add({
        'Staff Name': d.userDetailsName ?? '',
        'Assigned': d.assigned ?? 0,
        'Completed': d.completed ?? '0',
        'Pending': d.pending ?? '0',
        'Overdue': d.overdue ?? '0',
        'Avg Completion (mins)': d.averageCompletionMinutes ?? '',
        'Productivity': d.productivity ?? '',
      });
    }
    return data;
  }

  void _exportToExcel(UserActivityReportModel report) {
    exportToExcel(
      headers: _exportHeaders,
      data: _getExportData(report),
      fileName: 'UserActivityReport',
    );
  }

  void _exportToPdf(UserActivityReportModel report) {
    exportToPDF(
      headers: _exportHeaders,
      data: _getExportData(report),
      fileName: 'UserActivityReport',
    );
  }
}

class HoverableLinkText extends StatefulWidget {
  final String text;
  final Color color;

  const HoverableLinkText({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  State<HoverableLinkText> createState() => _HoverableLinkTextState();
}

class _HoverableLinkTextState extends State<HoverableLinkText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Text(
        widget.text,
        style: TextStyle(
          color: widget.color,
          decoration: _isHovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: widget.color,
          fontWeight: _isHovered ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }
}
