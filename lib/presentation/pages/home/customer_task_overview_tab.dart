import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/dashboard_task_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class CustomerTaskOverviewTab extends StatefulWidget {
  final String customerId;
  const CustomerTaskOverviewTab({super.key, required this.customerId});

  @override
  State<CustomerTaskOverviewTab> createState() =>
      _CustomerTaskOverviewTabState();
}

class _CustomerTaskOverviewTabState extends State<CustomerTaskOverviewTab> {
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getCustomerTaskOverview(widget.customerId);
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  // Define task colors (copied from TaskOverviewTab)
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
    if (taskType == null) return Colors.blue;
    // Simple matching or default
    return taskColors[taskType] ?? Colors.blueAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isTaskOverviewLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final departments = provider.customerTaskDepartments;

        if (departments.isEmpty) {
          return const Center(
            child: Text('No task data available for this customer'),
          );
        }

        return Container(
          // Match height logic from TaskOverviewTab if needed, or let it expand
          padding: const EdgeInsets.all(8.0),
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
                                  // Adjust width logic as per original tab
                                  final width = constraints.maxWidth / 6.0 < 250
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
                      department.departmentName ?? 'Unknown',
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
          // We limit height to avoid infinite height issues in scroll views
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight > 0 ? maxHeight : 300,
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
        color: Colors.transparent,
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
