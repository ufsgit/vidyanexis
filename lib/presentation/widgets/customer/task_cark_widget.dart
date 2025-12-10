import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/task_customer_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_task.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';

class TaskCard extends StatelessWidget {
  final String taskId;
  final String taskMasterId;
  final String customerId;
  final String category;
  final String title;
  final String assignedTo;
  final String date;
  final String time;
  final String posted;
  final String status;
  final String toUser;
  TaskCustomerModel task;

  TaskCard({
    super.key,
    required this.taskId,
    required this.taskMasterId,
    required this.customerId,
    required this.category,
    required this.title,
    required this.assignedTo,
    required this.date,
    required this.time,
    required this.posted,
    required this.status,
    required this.toUser,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    Color statusColor = status == "Completed"
        ? Colors.green
        : status == "In Progress"
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Image.asset(
                //   category == "1"
                //       ? 'assets/images/Task type=Site Visit.png'
                //       : category == "2"
                //           ? 'assets/images/Task type=Installation.png'
                //           : category == "3"
                //               ? 'assets/images/Task type=Service.png'
                //               : 'assets/images/Task type=AMC.png',
                //   height: 25,
                // ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.green.withOpacity(.3)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      task.taskTypeName,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Image.asset(
                  'assets/images/calendar-03.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  date != 'null' && date.isNotEmpty
                      ? DateFormat('MMM dd, yyyy . ')
                          .format(DateTime.parse(date))
                      : '',
                ),
                Text(
                  time,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Task icon
                Image.asset(
                  'assets/images/task-02.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 5),

                // Task title - always expanded to take available space
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Responsive section based on screen type
                if (AppStyles.isWebScreen(context))
                  // Web layout
                  Row(
                    mainAxisSize:
                        MainAxisSize.min, // Ensure row takes only needed space
                    children: [
                      // Action buttons, status and navigation - wrapped in a container with constraints
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (settingsProvider.menuIsEditMap[13] == 1)
                              IconButton(
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  customerDetailsProvider.customerId =
                                      customerId;

                                  await customerDetailsProvider
                                      .getTaskUsers(task.taskMasterId);
                                  customerDetailsProvider.setTaskEditDropDown(
                                    task.taskTypeId,
                                    task.taskTypeName,
                                    task.toUserId,
                                    task.toUsername,
                                    task.taskStatusId,
                                    task.taskStatusName,
                                  );
                                  customerDetailsProvider
                                          .taskDescriptionController.text =
                                      task.description?.toString() ?? '';
                                  customerDetailsProvider
                                          .taskChoosedateController.text =
                                      task.taskDate?.toString() != 'null' &&
                                              task.taskDate
                                                      ?.toString()
                                                      ?.isNotEmpty ==
                                                  true
                                          ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(
                                                  task.taskDate.toString()))
                                          : '';
                                  customerDetailsProvider
                                      .taskChoosetimeController
                                      .text = task.taskTime?.toString() ?? '';

                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return TaskCreationWidget(
                                        isEdit: true,
                                        taskId: taskMasterId,
                                        task: task,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined, size: 20),
                              ),

                            if (settingsProvider.menuIsDeleteMap[13] == 1)
                              IconButton(
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  showConfirmationDialog(
                                    isLoading:
                                        customerDetailsProvider.isDeleteLoading,
                                    context: context,
                                    title: 'Confirm Deletion',
                                    content:
                                        'Are you sure you want to delete this task?',
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                    onConfirm: () {
                                      customerDetailsProvider.deleteTask(
                                        taskId,
                                        customerId,
                                        context,
                                      );
                                      Navigator.of(context).pop();
                                    },
                                    confirmButtonText: 'Delete',
                                    confirmButtonColor: Colors.red,
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: AppColors.textRed,
                                  size: 20,
                                ),
                              ),

                            // Created date with safe null handling
                            Flexible(
                              child: Text(
                                'Created On: ${_formatDate(posted)}',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 5),

                            const Icon(
                              Icons.navigate_next_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  // Mobile layout
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8, // Horizontal space between items
                      runSpacing: 10, // Vertical space between lines
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Calendar icon and date/time
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/calendar-03.png',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              date != 'null' && date.isNotEmpty
                                  ? DateFormat('MMM dd, yyyy . ')
                                      .format(DateTime.parse(date))
                                  : '',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              time,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        if (settingsProvider.menuIsEditMap[13] == 1)
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                customerDetailsProvider.customerId = customerId;
                                await customerDetailsProvider
                                    .getTaskUsers(task.taskMasterId);

                                customerDetailsProvider.setTaskEditDropDown(
                                  task.taskTypeId,
                                  task.taskTypeName,
                                  task.toUserId,
                                  task.toUsername,
                                  task.taskStatusId,
                                  task.taskStatusName,
                                );
                                customerDetailsProvider
                                    .taskDescriptionController
                                    .text = task.description?.toString() ?? '';
                                customerDetailsProvider.taskChoosedateController
                                    .text = task.taskDate?.toString() !=
                                            'null' &&
                                        task.taskDate?.toString()?.isNotEmpty ==
                                            true
                                    ? DateFormat('dd MMM yyyy').format(
                                        DateTime.parse(
                                            task.taskDate.toString()))
                                    : '';
                                customerDetailsProvider.taskChoosetimeController
                                    .text = task.taskTime?.toString() ?? '';

                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TaskCreationWidget(
                                      isEdit: true,
                                      taskId: taskMasterId,
                                      task: task,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.edit_outlined, size: 18),
                            ),
                          ),
                        if (settingsProvider.menuIsDeleteMap[13] == 1)
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showConfirmationDialog(
                                  isLoading:
                                      customerDetailsProvider.isDeleteLoading,
                                  context: context,
                                  title: 'Confirm Deletion',
                                  content:
                                      'Are you sure you want to delete this task?',
                                  onCancel: () {
                                    Navigator.of(context).pop();
                                  },
                                  onConfirm: () {
                                    customerDetailsProvider.deleteTask(
                                      taskId,
                                      customerId,
                                      context,
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  confirmButtonText: 'Delete',
                                  confirmButtonColor: Colors.red,
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: AppColors.textRed,
                                size: 18,
                              ),
                            ),
                          ),

                        // Created date
                        Flexible(
                          child: Text(
                            'Created On: ${_formatDate(posted)}',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                          width: 30,
                          child: Icon(
                            Icons.navigate_next_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      // If the date is not empty and valid
      if (date.isNotEmpty) {
        DateTime parsedDate =
            DateTime.parse(date); // Parse the string into DateTime
        return DateFormat('MMM dd, yyyy')
            .format(parsedDate); // Format into dd MMM yyyy format
      } else {
        return ''; // Return empty string if no date is provided
      }
    } catch (e) {
      return ''; // Return empty string in case of invalid date format
    }
  }
}
