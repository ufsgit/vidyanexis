import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import '../../../../controller/models/task_customer_model.dart';
// import '../../home/custom_text_widget.dart'; // Removed as it seems unused or path is wrong

class TaskCard extends StatelessWidget {
  final TaskCustomerModel task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Status Color Logic
    // Status Color Logic
    Color statusColor = Colors.grey;
    try {
      statusColor = StatusUtils.getTaskColor(task.taskStatusId);
    } catch (e) {
      statusColor = task.taskStatusName == "Completed"
          ? Colors.green
          : task.taskStatusName == "Pending"
              ? Colors.orange
              : Colors.red;
    }

    // Calculate relative time
    String timeAgo = '';
    if (task.entryDate != null) {
      final now = DateTime.now();
      final difference = now.difference(task.entryDate!);
      if (difference.inDays > 365) {
        timeAgo =
            '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        timeAgo =
            '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        timeAgo =
            '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        timeAgo =
            '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        timeAgo =
            '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return GestureDetector(
      onTap: () async {
        if (settingsProvider.menuIsEditMap[13] != 1) return;

        customerDetailsProvider.customerId = task.customerId.toString();
        // Fix: getTaskUsers expects int or String? Checking model.
        // taskMasterId is int in model. toString() is correct if API expects String.
        await customerDetailsProvider
            .getTaskUsers(task.taskMasterId.toString() as int);

        customerDetailsProvider.setTaskEditDropDown(
          task.taskTypeId,
          task.taskTypeName,
          task.toUserId,
          task.toUsername,
          task.taskStatusId,
          task.taskStatusName,
        );
        customerDetailsProvider.taskDescriptionController.text =
            task.description;
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(task.taskDate);
        customerDetailsProvider.taskChoosetimeController.text = task.taskTime;

        customerDetailsProvider.addTaskModel.taskUser = task.taskUser
            .map((e) => UserInTaskModel(
                  userDetailsId: e.toUserId,
                  userDetailsName: e.toUsername,
                ))
            .toList();

        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return TaskCreationWidget(
              isEdit: true,
              taskId: task.taskId.toString(),
              task: task,
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Task Type (Left)
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.red, // Or dynamic color based on type
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.taskTypeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),

                // Status Chip (Right)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    task.taskStatusName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date (Left)
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('EEE, MMM d').format(task.taskDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // Relative Time (Right)
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
