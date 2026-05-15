import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/dashboard_task_model.dart';

class TaskOverviewTab extends StatefulWidget {
  const TaskOverviewTab({super.key});

  @override
  State<TaskOverviewTab> createState() => _TaskOverviewTabState();
}

class _TaskOverviewTabState extends State<TaskOverviewTab> {
  // Track which departments are expanded
  final Set<int> _expandedDepartmentIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      dashBoardProvider.fetchDashBoardTaskData();
    });
  }

  // Define curated task colors
  final Map<String, Color> _taskColors = {
    "File Opening": const Color(0xFF60A5FA), // Blue
    "Installation": const Color(0xFF34D399), // Green
    "Payment 1": const Color(0xFFFB923C), // Orange
    "KSEB Feasibility": const Color(0xFFF472B6), // Pink
    "Courtesy Call": const Color(0xFF818CF8), // Indigo
    "Load Enhancement": const Color(0xFFFBBF24), // Amber
    "Name change": const Color(0xFF2DD4BF), // Teal
    "Loan": const Color(0xFFA78BFA), // Violet
    "Subsidy Reg": const Color(0xFF22D3EE), // Cyan
    "Subsidy Registration": const Color(0xFF22D3EE),
  };

  Color _getColorForTask(String? taskType) {
    if (taskType == null) return AppColors.secondaryBlue;
    return _taskColors[taskType] ?? _taskColors.values.elementAt(taskType.hashCode % _taskColors.length);
  }

  int _calculateTotalTasks(List<Department> departments) {
    return departments.fold(0, (sum, dept) => sum + (dept.taskCount ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return _buildLoadingState();
        }

        final departments = dashboardProvider.departments ?? [];

        if (departments.isEmpty) {
          return _buildEmptyState("No task data available");
        }

        final totalTasks = _calculateTotalTasks(departments);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Header
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Departments",
                    value: departments.length.toString(),
                    icon: Icons.lan_rounded,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Tasks",
                    value: totalTasks.toString(),
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFF818CF8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Department List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: departments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final department = departments[index];
                return _buildDepartmentSection(department);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
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
        borderRadius: BorderRadius.circular(16),
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
              borderRadius: BorderRadius.circular(10),
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

  Widget _buildDepartmentSection(Department department) {
    final isExpanded = _expandedDepartmentIds.contains(department.departmentId);
    final tasks = department.tasks ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? AppColors.secondaryBlue.withOpacity(0.3) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedDepartmentIds.remove(department.departmentId);
                } else {
                  if (department.departmentId != null) {
                    _expandedDepartmentIds.add(department.departmentId!);
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.business_rounded, 
                      size: 20, color: AppColors.secondaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          department.departmentName ?? 'Unknown Department',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        Text(
                          "${department.taskCount ?? 0} task categories",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textGrey3,
                  ),
                ],
              ),
            ),
          ),
          
          // Task List
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: tasks.isEmpty
                ? _buildEmptyTasksState()
                : Column(
                    children: tasks.map((task) => _buildTaskItem(task)).toList(),
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: _getColorForTask(task.taskTypeName),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.taskTypeName ?? 'Unknown Task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Text(
              task.subTaskCount?.toString() ?? '0',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.secondaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          "No task categories found",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textGrey3,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(4, (index) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: AppColors.textGrey2.withOpacity(0.5)),
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
