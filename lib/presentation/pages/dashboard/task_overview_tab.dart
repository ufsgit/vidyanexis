import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/dashboard_task_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class TaskOverviewTab extends StatefulWidget {
  const TaskOverviewTab({super.key});

  @override
  State<TaskOverviewTab> createState() => _TaskOverviewTabState();
}

class _TaskOverviewTabState extends State<TaskOverviewTab> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      dashBoardProvider.fetchDashBoardTaskData();
    });

    super.initState();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Define task colors
  final Map<String, Color> taskColors = {
    "File Opening": Colors.blue,
    "Installation": Colors.green,
    "Payment 1": Colors.orange,
    "KSEB Feasibility": Colors.pink,
    "Courtesy Call": Colors.purple,
    "Load Enhancement": Colors.amber,
    "Name change": Colors.teal,
    "Loan": Colors.indigo,
    "Subsidy Reg": Colors.cyan,
  };

  Color _getColorForTask(String? taskType) {
    return taskColors[taskType] ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        if (dashboardProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final departments = dashboardProvider.departments;

        if (departments == null || departments.isEmpty) {
          return const Center(
            child: Text('No department data available'),
          );
        }

        return Container(
          height: MediaQuery.sizeOf(context).height / 1.7,
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Scrollbar(
                        controller: _verticalScrollController,
                        thumbVisibility: false,
                        trackVisibility: false,
                        child: SingleChildScrollView(
                          controller: _verticalScrollController,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 30,
                            ),
                            child: Scrollbar(
                              controller: _horizontalScrollController,
                              scrollbarOrientation: ScrollbarOrientation.bottom,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: departments.map((department) {
                                    final width =
                                        constraints.maxWidth / 6.0 < 250
                                            ? 250.0
                                            : constraints.maxWidth / 6.0;

                                    return SizedBox(
                                      width: width,
                                      child: _buildDepartmentColumn(
                                        department: department,
                                        maxHeight: constraints.maxHeight - 100,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDepartmentColumn({
    required Department department,
    required double maxHeight,
  }) {
    final tasks = department.tasks ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey300.withOpacity(.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: CustomText(
                      department.departmentName ?? 'Unknown Department',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText(
                    '${department.taskCount ?? 0}',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGrey3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: tasks.isEmpty
                    ? [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const CustomText(
                            'No tasks available',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ]
                    : tasks.map((task) => _buildTaskItem(task)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent, // Important for the InkWell to work properly
        child: InkWell(
          onTap: () {},
          hoverColor: AppColors.lightBlueColor,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.grey300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 45,
                    decoration: BoxDecoration(
                      color: _getColorForTask(task.taskTypeName),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          task.taskTypeName ?? 'Unknown Task',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          '${task.subTaskCount ?? 0}',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
