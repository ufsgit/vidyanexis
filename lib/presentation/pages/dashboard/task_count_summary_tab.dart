import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
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

  static const List<Color> _cardAccentColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF9333EA), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFF6366F1), // Indigo
    Color(0xFF14B8A6), // Teal
    Color(0xFFEC4899), // Pink
    Color(0xFFF59E0B), // Amber/Orange
  ];

  Color _getStatusColor(String statusName) {
    final lower = statusName.toLowerCase();
    if (lower.contains('complete') ||
        lower.contains('done') ||
        lower.contains('approved') ||
        lower.contains('success')) {
      return const Color(0xFF10B981); // Emerald Green
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
      return const Color(0xFFF59E0B); // Amber
    }
    return const Color(0xFF94A3B8); // Slate Grey
  }

  IconData _getTaskIcon(String taskName) {
    final lower = taskName.toLowerCase();
    if (lower.contains('visit') || lower.contains('site')) {
      return Icons.event_note_outlined;
    } else if (lower.contains('quotation') && lower.contains('gen')) {
      return Icons.format_quote_rounded;
    } else if (lower.contains('quotation') || lower.contains('quote')) {
      return Icons.description_outlined;
    } else if (lower.contains('enquiry') || lower.contains('inquiry')) {
      return Icons.description_outlined;
    } else if (lower.contains('registration') || lower.contains('online')) {
      return Icons.person_outline_rounded;
    } else if (lower.contains('bank') || lower.contains('disbursement')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('loan')) {
      return Icons.request_quote_outlined;
    } else if (lower.contains('payment') ||
        lower.contains('advance') ||
        lower.contains('charge') ||
        lower.contains('kseb')) {
      return Icons.payments_outlined;
    } else if (lower.contains('document') ||
        lower.contains('doc') ||
        lower.contains('copy') ||
        lower.contains('copies')) {
      return Icons.article_outlined;
    }
    return Icons.assignment_outlined;
  }

  int _getCrossAxisCount(double maxWidth) {
    if (maxWidth >= 1100) return 4;
    if (maxWidth >= 780) return 3;
    if (maxWidth >= 500) return 2;
    return 1;
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 1. Extract all unique statuses from the response
    final Set<String> statusSet = {};
    for (var taskType in allItems) {
      for (var sc in taskType.statusCounts) {
        final s = sc.statusName.trim();
        if (s.isNotEmpty) statusSet.add(s);
      }
    }

    final sortedStatuses = statusSet.toList();

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Task Type Cards Grid
          _buildTaskCardsGrid(
            context: context,
            taskItems: allItems,
          ),
          const SizedBox(height: 20),
          // Total Summary Card
          _buildTotalSummaryCard(
            taskTypeCount: allItems.length,
            sortedStatuses: sortedStatuses,
            statusTotals: statusTotals,
            grandTotal: grandTotal,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCardsGrid({
    required BuildContext context,
    required List<TaskTypeSummaryModel> taskItems,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        const double spacing = 16.0;
        final int rowCount = (taskItems.length / crossAxisCount).ceil();

        return Column(
          children: List.generate(rowCount, (rowIndex) {
            final int startIndex = rowIndex * crossAxisCount;
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < rowCount - 1 ? spacing : 0,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(crossAxisCount, (colIndex) {
                    final int itemIndex = startIndex + colIndex;
                    final bool hasItem = itemIndex < taskItems.length;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: colIndex < crossAxisCount - 1 ? spacing : 0,
                        ),
                        child: hasItem
                            ? _buildTaskTypeCard(
                                context: context,
                                taskItem: taskItems[itemIndex],
                                accentColor: _cardAccentColors[
                                    itemIndex % _cardAccentColors.length],
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTaskTypeCard({
    required BuildContext context,
    required TaskTypeSummaryModel taskItem,
    required Color accentColor,
  }) {
    final taskName = taskItem.taskTypeName.trim().isEmpty
        ? 'Unknown Task'
        : taskItem.taskTypeName.trim();
    final rowTotal = taskItem.totalCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored top accent bar
            Container(
              height: 3.5,
              color: accentColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Icon badge + Task Type Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTaskIcon(taskName),
                            size: 17,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            taskName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E293B),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Status Rows (only statuses present in this task type's response)
                    ...taskItem.statusCounts
                        .where((sc) => sc.statusName.trim().isNotEmpty)
                        .map((sc) {
                      final status = sc.statusName.trim();
                      final count = sc.count;
                      final statusId = sc.taskStatusId;
                      final statusColor = _getStatusColor(status);
                      final isClickable = count > 0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Tooltip(
                          message: isClickable
                              ? 'View $count $status tasks for $taskName'
                              : '',
                          waitDuration: const Duration(milliseconds: 300),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(6),
                              hoverColor: statusColor.withValues(alpha: 0.08),
                              splashColor: statusColor.withValues(alpha: 0.16),
                              mouseCursor: isClickable
                                  ? SystemMouseCursors.click
                                  : SystemMouseCursors.basic,
                              onTap: isClickable
                                  ? () {
                                      setState(() {
                                        _selectedTaskTypeId =
                                            taskItem.taskTypeId;
                                        _selectedTaskTypeName = taskName;
                                        _selectedTaskStatusId = statusId;
                                        _selectedTaskStatusName =
                                            sc.statusName.isNotEmpty
                                                ? sc.statusName
                                                : status;
                                      });
                                    }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        status,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF475569),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      count.toString(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: count > 0
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: count > 0
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),
                    const SizedBox(height: 14),

                    // Footer: Total label + Big colored total value
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          rowTotal.toString(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSummaryCard({
    required int taskTypeCount,
    required List<String> sortedStatuses,
    required Map<String, int> statusTotals,
    required int grandTotal,
  }) {
    const Color summaryAccent = Color(0xFF1E293B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 3.5,
              color: AppColors.primaryBlue,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isCompact = constraints.maxWidth < 700;

                  final titleSection = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.functions_rounded,
                          size: 19,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Summary',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: summaryAccent,
                            ),
                          ),
                          Text(
                            '$taskTypeCount ${taskTypeCount == 1 ? 'Task Type' : 'Task Types'}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  final statusChips = Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: sortedStatuses.map((status) {
                      final count = statusTotals[status] ?? 0;
                      final color = _getStatusColor(status);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              count.toString(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );

                  final grandTotalSection = Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Grand Total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        grandTotal.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          height: 1.0,
                        ),
                      ),
                    ],
                  );

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleSection,
                            grandTotalSection,
                          ],
                        ),
                        const SizedBox(height: 14),
                        statusChips,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      titleSection,
                      const SizedBox(width: 24),
                      Expanded(child: statusChips),
                      const SizedBox(width: 20),
                      grandTotalSection,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        const double spacing = 16.0;
        final int skeletonCount = crossAxisCount * 2;
        final int rowCount = (skeletonCount / crossAxisCount).ceil();

        return Column(
          children: List.generate(rowCount, (rowIndex) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: rowIndex < rowCount - 1 ? spacing : 0,
              ),
              child: Row(
                children: List.generate(crossAxisCount, (colIndex) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: colIndex < crossAxisCount - 1 ? spacing : 0,
                      ),
                      child: Container(
                        height: 185,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 3.5,
                                color: Colors.grey.shade200,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            height: 14,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    ...List.generate(
                                      3,
                                      (_) => Container(
                                        height: 12,
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                        Container(
                                          width: 44,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}
