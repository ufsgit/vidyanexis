import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/dashboard_info_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';

class TaskSummaryPage extends StatefulWidget {
  const TaskSummaryPage({
    super.key,
  });

  @override
  State<TaskSummaryPage> createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {
  // Create scroll controllers for each customer row
  final Map<int, ScrollController> _scrollControllers = {};
  Color _getColorForTask(int status) {
    switch (status) {
      case 1:
        return AppColors.textRed;
      case 0:
        return AppColors.statusGreen;

      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize scroll controllers after data is loaded
      _initializeScrollControllers();
    });
  }

  void _initializeScrollControllers() {
    final dashBoardProvider =
        Provider.of<DashboardProvider>(context, listen: false);

    // Clear existing controllers
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    _scrollControllers.clear();

    // Create new controllers for each customer
    for (int i = 0; i < dashBoardProvider.taskInfoModel.length; i++) {
      _scrollControllers[i] = ScrollController();
    }
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashBoardProvider, child) {
        final List<TaskInfoDashboardModel> taskInfoList =
            dashBoardProvider.taskInfoModel;

        if (taskInfoList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 300,
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: taskInfoList.asMap().entries.map((entry) {
                final index = entry.key;
                final taskInfo = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildCustomerRow(taskInfo, index),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerRow(TaskInfoDashboardModel taskInfo, int customerIndex) {
    // Ensure scroll controller exists for this index
    if (!_scrollControllers.containsKey(customerIndex)) {
      _scrollControllers[customerIndex] = ScrollController();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (taskInfo.customerId != null) {
                      context.push(
                          '${CustomerDetailsScreen.route}${taskInfo.customerId}/false');
                    }
                  },
                  child: CustomText(
                    taskInfo.customerName ?? "Unknown Customer",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 60,
                child: (taskInfo.taskList == null || taskInfo.taskList!.isEmpty)
                    ? Center(
                        child: CustomText(
                          "No tasks available",
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade500,
                        ),
                      )
                    : Scrollbar(
                        controller: _scrollControllers[customerIndex],
                        thumbVisibility: false,
                        trackVisibility: false,
                        child: SingleChildScrollView(
                          controller: _scrollControllers[customerIndex],
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: taskInfo.taskList!.map((task) {
                              return Container(
                                width: 140,
                                margin: const EdgeInsets.only(right: 12),
                                child: _buildTaskCard(task),
                              );
                            }).toList(),
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

  Widget _buildTaskCard(TaskList task) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CustomText(
              task.taskTypeName ?? "Unknown Task",
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getColorForTask(task.followup ?? 0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (task.statusName != null)
                Expanded(
                  child: CustomText(
                    task.statusName.toString(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              // if (task.duration != null)
              //   CustomText(
              //     "${task.duration}",
              //     fontSize: 11,
              //     fontWeight: FontWeight.w500,
              //     color: AppColors.textGrey4,
              //   ),
            ],
          ),
        ],
      ),
    );
  }
}
