import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/dashboard_info_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TaskSummaryPage extends StatefulWidget {
  const TaskSummaryPage({super.key});

  @override
  State<TaskSummaryPage> createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {
  final Map<int, ScrollController> _scrollControllers = {};

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Color _getStatusColor(dynamic followup) {
    // Logic from previous version: 1 is Red (pending), 0 is Green (completed)
    if (followup == 1 || followup == "1") {
      return const Color(0xFFF87171); // Red
    } else if (followup == 0 || followup == "0") {
      return const Color(0xFF34C759); // Green
    }
    return AppColors.textGrey3;
  }

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return '??';
    final parts = cleanName.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashBoardProvider, child) {
        final List<TaskInfoDashboardModel> taskInfoList =
            dashBoardProvider.pagedTaskInfoModel;

        if (taskInfoList.isEmpty && dashBoardProvider.isDashBoardLoading) {
          return _buildLoadingState();
        }

        // Calculate height similar to existing implementation
        final double screenHeight = MediaQuery.of(context).size.height;
        final double headerOffset = 250;
        final double taskSectionHeight =
            (screenHeight - headerOffset).clamp(400.0, 2000.0);

        return SizedBox(
          height: taskSectionHeight,
          child: Column(
            children: [
              // Summary Section
              _buildSummaryHeader(dashBoardProvider),
              const SizedBox(height: 20),

              // Customer List
              Expanded(
                child: taskInfoList.isEmpty
                    ? _buildEmptyState("No tasks found")
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: taskInfoList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final taskInfo = taskInfoList[index];
                          return _buildCustomerCard(taskInfo, index);
                        },
                      ),
              ),

              // Pagination
              _buildPaginationControls(context, dashBoardProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryHeader(DashboardProvider provider) {
    int totalCustomers = provider.taskTotalCount;
    // We don't easily have total tasks across all pages without more API info,
    // but we can show stats for current page
    int currentTasks = 0;
    for (var info in provider.pagedTaskInfoModel) {
      currentTasks += info.taskList?.length ?? 0;
    }

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: "Total Customers",
            value: totalCustomers.toString(),
            icon: Icons.people_alt_rounded,
            color: AppColors.secondaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: "Active Tasks",
            value: currentTasks.toString(),
            icon: Icons.task_alt_rounded,
            color: const Color(0xFFFBBF24),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(TaskInfoDashboardModel taskInfo, int index) {
    if (!_scrollControllers.containsKey(index)) {
      _scrollControllers[index] = ScrollController();
    }

    final tasks = taskInfo.taskList ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: getAvatarColor(taskInfo.customerName ?? '')
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(taskInfo.customerName ?? '??'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: getAvatarColor(taskInfo.customerName ?? ''),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    taskInfo.customerName ?? "Unknown Customer",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onPressed: () {
                    if (taskInfo.customerId != null) {
                      context.push(
                          '${CustomerDetailPageMobile.route}${taskInfo.customerId}/false');
                    }
                  },
                  visualDensity: VisualDensity.compact,
                  color: AppColors.secondaryBlue,
                ),
              ],
            ),
          ),

          // Tasks
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: tasks.isEmpty
                ? _buildEmptyTasksState()
                : SizedBox(
                    height: 70,
                    child: Scrollbar(
                      controller: _scrollControllers[index],
                      thumbVisibility: false,
                      child: ListView.separated(
                        controller: _scrollControllers[index],
                        scrollDirection: Axis.horizontal,
                        itemCount: tasks.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, taskIndex) {
                          return _buildTaskItemCard(tasks[taskIndex]);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItemCard(TaskList task) {
    final statusColor = _getStatusColor(task.followup);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.taskTypeName ?? "Unknown",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            task.statusName?.toString() ?? "Pending",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "No tasks assigned",
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: AppColors.textGrey3,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaginationControls(
      BuildContext context, DashboardProvider provider) {
    int startItem = provider.taskStartLimit;
    int endItem = provider.taskEndLimit;
    int total = provider.taskTotalCount;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: provider.taskCurrentPage > 0
                ? () => provider.fetchPreviousPageTasks(context)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Showing $startItem - $endItem of $total',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
            ),
          ),
          _buildPaginationButton(
            icon: Icons.arrow_forward_ios_rounded,
            onPressed:
                (provider.taskCurrentPage + 1) * provider.taskItemsPerPage <
                        provider.taskTotalCount
                    ? () => provider.fetchNextPageTasks(context)
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(
      {required IconData icon, required VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppColors.secondaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon,
            size: 16,
            color: onPressed != null
                ? AppColors.secondaryBlue
                : AppColors.textGrey2),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_ind_outlined,
              size: 64, color: AppColors.textGrey2.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
        ],
      ),
    );
  }
}
