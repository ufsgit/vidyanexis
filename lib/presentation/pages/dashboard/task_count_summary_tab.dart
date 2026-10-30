import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/task_count_summary_model.dart';
import 'package:vidyanexis/presentation/pages/dashboard/task_status_details_page.dart';

class TaskCountSummaryTab extends StatefulWidget {
  final DashboardProvider dashBoardProvider;

  const TaskCountSummaryTab({
    super.key,
    required this.dashBoardProvider,
  });

  @override
  State<TaskCountSummaryTab> createState() => _TaskCountSummaryTabState();
}

class _TaskCountSummaryTabState extends State<TaskCountSummaryTab> {
  int? _selectedTaskTypeId;
  String? _selectedTaskTypeName;
  int? _selectedTaskStatusId;
  String? _selectedTaskStatusName;

  Color _getStatusColor(String statusName) {
    final lower = statusName.toLowerCase();
    if (lower.contains('complete') ||
        lower.contains('done') ||
        lower.contains('approved') ||
        lower.contains('success')) {
      return const Color(0xFF16A34A); // Green
    } else if (lower.contains('in progress') ||
        lower.contains('progress') ||
        lower.contains('processing')) {
      return const Color(0xFF2563EB); // Blue
    } else if (lower.contains('reject') ||
        lower.contains('cancel') ||
        lower.contains('failed')) {
      return const Color(0xFFDC2626); // Red
    } else if (lower.contains('pending') ||
        lower.contains('hold') ||
        lower.contains('waiting') ||
        lower.contains('need')) {
      return const Color(0xFFD97706); // Amber
    }
    return const Color(0xFF64748B); // Slate Grey
  }

  @override
  Widget build(BuildContext context) {
    // If a status count was clicked, display the details view in this marked section
    if (_selectedTaskStatusId != null) {
      return TaskStatusDetailsView(
        taskTypeId: _selectedTaskTypeId,
        taskTypeName: _selectedTaskTypeName ?? '',
        taskStatusId: _selectedTaskStatusId,
        taskStatusName: _selectedTaskStatusName ?? '',
        fromDate: widget.dashBoardProvider.formattedFromDate,
        toDate: widget.dashBoardProvider.formattedToDate,
        user: widget.dashBoardProvider.selectedUser,
        onBack: () {
          setState(() {
            _selectedTaskTypeId = null;
            _selectedTaskTypeName = null;
            _selectedTaskStatusId = null;
            _selectedTaskStatusName = null;
          });
        },
      );
    }

    final provider = widget.dashBoardProvider;
    final allItems = provider.taskCountSummaryList;

    if (allItems.isEmpty &&
        (provider.isTaskCountSummaryLoading || provider.isDashBoardLoading)) {
      return _buildSkeleton(context);
    }

    if (allItems.isEmpty) {
      return Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_late_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No Task Count Summary Data Available',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey3,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => provider.getTaskCountSummaryData(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 1. Extract all unique statuses and sort logically
    final Set<String> statusSet = {};
    for (var taskType in allItems) {
      for (var sc in taskType.statusCounts) {
        final s = sc.statusName.trim();
        if (s.isNotEmpty) statusSet.add(s);
      }
    }

    final standardPriority = [
      'pending',
      'in progress',
      'completed',
      'rejected',
      'on hold',
      'cancelled'
    ];
    final sortedStatuses = statusSet.toList()
      ..sort((a, b) {
        final aLower = a.toLowerCase();
        final bLower = b.toLowerCase();
        int aIdx = standardPriority.indexWhere((p) => aLower.contains(p));
        int bIdx = standardPriority.indexWhere((p) => bLower.contains(p));
        if (aIdx == -1) aIdx = 999;
        if (bIdx == -1) bIdx = 999;
        if (aIdx != bIdx) return aIdx.compareTo(bIdx);
        return a.compareTo(b);
      });

    // 2. Calculate status totals and grand total
    final Map<String, int> statusTotals = {};
    for (var status in sortedStatuses) {
      statusTotals[status] = 0;
    }

    int grandTotal = 0;

    for (var taskType in allItems) {
      for (var sc in taskType.statusCounts) {
        final statusName = sc.statusName.trim();
        final count = sc.count;
        statusTotals[statusName] = (statusTotals[statusName] ?? 0) + count;
        grandTotal += count;
      }
    }

    final isWeb = AppStyles.isWebScreen(context);
    final double screenH = MediaQuery.of(context).size.height;
    final double minCardHeight =
        isWeb && screenH > 500 ? (screenH - 110.0) : 450.0;

    return Container(
      constraints: BoxConstraints(minHeight: minCardHeight),
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
      padding: const EdgeInsets.all(16),
      child: _buildTaskList(
        context: context,
        taskItems: allItems,
        sortedStatuses: sortedStatuses,
        statusTotals: statusTotals,
        grandTotal: grandTotal,
      ),
    );
  }

  Widget _buildTaskList({
    required BuildContext context,
    required List<TaskTypeSummaryModel> taskItems,
    required List<String> sortedStatuses,
    required Map<String, int> statusTotals,
    required int grandTotal,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minTaskTypeWidth = 240.0;
        const double minStatusWidth = 110.0;
        const double minTotalWidth = 90.0;

        final double totalColumnsWidth = minTaskTypeWidth +
            (sortedStatuses.length * minStatusWidth) +
            minTotalWidth +
            ((sortedStatuses.length + 1) * 8.0);

        final bool requiresHorizontalScroll =
            constraints.maxWidth < totalColumnsWidth;

        final content = Column(
          children: [
            // 1. Column Headers
            _buildHeadersRow(sortedStatuses),
            const SizedBox(height: 10),

            // 2. Data Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: taskItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final taskItem = taskItems[index];

                return _buildTaskRow(
                  context: context,
                  taskItem: taskItem,
                  sortedStatuses: sortedStatuses,
                );
              },
            ),

            const SizedBox(height: 14),
            // 3. Bottom Summary / Total Row
            _buildSummaryRow(
              sortedStatuses: sortedStatuses,
              statusTotals: statusTotals,
              grandTotal: grandTotal,
            ),
          ],
        );

        if (requiresHorizontalScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalColumnsWidth,
              child: content,
            ),
          );
        }

        return content;
      },
    );
  }

  Widget _buildHeadersRow(List<String> sortedStatuses) {
    return Row(
      children: [
        // Task Type Header
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              'TASK TYPE',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF475569),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Status Headers
        ...sortedStatuses.map((status) {
          final color = _getStatusColor(status);
          return Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      status.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Total Header
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: Text(
              'TOTAL',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryBlue,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskRow({
    required BuildContext context,
    required TaskTypeSummaryModel taskItem,
    required List<String> sortedStatuses,
  }) {
    final taskName = taskItem.taskTypeName.trim().isEmpty
        ? 'Unknown Task'
        : taskItem.taskTypeName.trim();
    final rowTotal = taskItem.totalCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Blue Field: Represents Task Type
        Expanded(
          flex: 4,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryBlue.withOpacity(0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.assignment_rounded,
                      size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    taskName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$rowTotal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Status Count Columns
        ...sortedStatuses.map((status) {
          StatusCountModel? matchingSc;
          for (var sc in taskItem.statusCounts) {
            if (sc.statusName.trim().toLowerCase() ==
                status.trim().toLowerCase()) {
              matchingSc = sc;
              break;
            }
          }

          final count = matchingSc?.count ?? 0;
          final statusId = matchingSc?.taskStatusId;
          final color = _getStatusColor(status);
          final isClickable = count > 0;

          return Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: isClickable
                    ? 'View $count $status tasks for $taskName'
                    : '',
                waitDuration: const Duration(milliseconds: 300),
                child: Material(
                  color: count > 0 ? color.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    hoverColor: color.withOpacity(0.12),
                    splashColor: color.withOpacity(0.2),
                    mouseCursor: isClickable
                        ? SystemMouseCursors.click
                        : SystemMouseCursors.basic,
                    onTap: isClickable
                        ? () {
                            setState(() {
                              _selectedTaskTypeId = taskItem.taskTypeId;
                              _selectedTaskTypeName = taskName;
                              _selectedTaskStatusId = statusId;
                              _selectedTaskStatusName =
                                  matchingSc?.statusName.isNotEmpty == true
                                      ? matchingSc!.statusName
                                      : status;
                            });
                          }
                        : null,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: count > 0
                              ? color.withOpacity(0.25)
                              : const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        count > 0 ? count.toString() : '-',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: count > 0 ? 15 : 13,
                          fontWeight:
                              count > 0 ? FontWeight.w800 : FontWeight.w500,
                          color: count > 0 ? color : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // Total Column
        Expanded(
          flex: 2,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.secondaryBlue.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              rowTotal.toString(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required List<String> sortedStatuses,
    required Map<String, int> statusTotals,
    required int grandTotal,
  }) {
    final isWeb = AppStyles.isWebScreen(context);
    final double screenH = MediaQuery.of(context).size.height;
    final double minCardHeight =
        isWeb && screenH > 500 ? (screenH - 110.0) : 450.0;

    return Container(
      constraints: BoxConstraints(minHeight: minCardHeight),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Total Summary Blue Field
          Expanded(
            flex: 4,
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.functions_rounded,
                      size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'TOTAL SUMMARY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Total for each status
          ...sortedStatuses.map((status) {
            final count = statusTotals[status] ?? 0;
            final color = _getStatusColor(status);

            return Expanded(
              flex: 2,
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: color.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  count.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            );
          }),

          // Grand Total
          Expanded(
            flex: 2,
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                grandTotal.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    final double screenH = MediaQuery.of(context).size.height;
    final double minCardHeight =
        isWeb && screenH > 500 ? (screenH - 110.0) : 450.0;

    return Container(
      constraints: BoxConstraints(minHeight: minCardHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header skeleton
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),
          // Row skeletons
          ...List.generate(
            6,
            (index) => Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
