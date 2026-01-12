import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/user_info_card_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class TaskDetailsWidget extends StatefulWidget {
  final String taskId;
  final String customerId;
  final bool showEdit;

  const TaskDetailsWidget(
      {super.key,
      required this.taskId,
      required this.customerId,
      this.showEdit = true});

  @override
  State<TaskDetailsWidget> createState() => _TaskDetailsWidgetState();
}

class _TaskDetailsWidgetState extends State<TaskDetailsWidget> {
  @override
  void initState() {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(listen: false, context);
    customerDetailsProvider.taskDetails.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final isWeb = AppStyles.isWebScreen(context);
    final dialogWidth = isWeb
        ? MediaQuery.of(context).size.width * 0.65
        : MediaQuery.of(context).size.width;
    final dialogHeight = MediaQuery.sizeOf(context).height / 1.5;

    return AlertDialog(
      scrollable: false, // Changed to false as we manage scrolling inside
      backgroundColor: Colors.white,
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Task Details',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                if (settingsProvider.menuIsEditMap[13] == 1 && widget.showEdit)
                  IconButton(
                    onPressed: () async {
                      if (customerDetailsProvider.taskDetails.isEmpty) return;
                      customerDetailsProvider.customerId = widget.customerId;
                      await customerDetailsProvider.getTaskUsers(
                          customerDetailsProvider.taskDetails[0].taskMasterId);

                      customerDetailsProvider.setTaskEditDropDown(
                          customerDetailsProvider.taskDetails[0].taskTypeId,
                          customerDetailsProvider.taskDetails[0].taskTypeName,
                          customerDetailsProvider.taskDetails[0].toUserId,
                          customerDetailsProvider.taskDetails[0].toUserName,
                          customerDetailsProvider.taskDetails[0].taskStatusId,
                          customerDetailsProvider
                              .taskDetails[0].taskStatusName);
                      customerDetailsProvider.taskDescriptionController.text =
                          customerDetailsProvider.taskDetails[0].description
                              .toString();
                      customerDetailsProvider.taskChoosedateController.text =
                          customerDetailsProvider.taskDetails[0].taskDate
                                          .toString() !=
                                      'null' &&
                                  customerDetailsProvider
                                      .taskDetails[0].taskDate
                                      .toString()
                                      .isNotEmpty
                              ? DateFormat('dd MMM yyyy').format(DateTime.parse(
                                  customerDetailsProvider
                                      .taskDetails[0].taskDate
                                      .toString()))
                              : '';
                      customerDetailsProvider.taskChoosetimeController.text =
                          customerDetailsProvider.taskDetails[0].taskTime
                              .toString();

                      if (!mounted) return;
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return TaskCreationWidget(
                              taskDetails:
                                  customerDetailsProvider.taskDetails[0],
                              isEdit: true,
                              taskId: customerDetailsProvider
                                  .taskDetails[0].taskMasterId
                                  .toString());
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Task',
                  ),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20))
              ],
            ),
            if (customerDetailsProvider.taskDetails.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Created on : ${_formatDate(customerDetailsProvider.taskDetails[0].entryDate)}',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textGrey3,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: customerDetailsProvider.isLoadingDetails ||
                customerDetailsProvider.taskDetails.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              isAssignee: true,
                              label: 'Customer',
                              value: customerDetailsProvider
                                  .taskDetails[0].customerName,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Service Type',
                              value: customerDetailsProvider
                                  .taskDetails[0].taskTypeName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Assigned To',
                              value: customerDetailsProvider
                                  .taskDetails[0].toUserName,
                            ),
                            const SizedBox(height: 16),
                            TaskLabelValue(
                              colorUser: AppColors.grey,
                              label: 'Status',
                              value: customerDetailsProvider
                                  .taskDetails[0].taskStatusName,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TaskLabelValue(
                    colorUser: AppColors.grey,
                    label: 'Description',
                    value: customerDetailsProvider.taskDetails[0].description,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Text(
                    'Task Logs (${customerDetailsProvider.taskDetails[0].taskDocuments.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (customerDetailsProvider
                      .taskDetails[0].taskDocuments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No task logs found.',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: customerDetailsProvider
                          .taskDetails[0].taskDocuments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final docGroup = customerDetailsProvider
                            .taskDetails[0].taskDocuments[index];
                        return UserInfoCard(
                          name: docGroup.userDetailsName,
                          category: 'Assignee',
                          items: docGroup.documents,
                          notes: docGroup.documents.isNotEmpty
                              ? docGroup.documents[0].taskNote
                              : '',
                          taskId: int.tryParse(widget.taskId) ?? 0,
                        );
                      },
                    ),
                ],
              ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      if (date.isNotEmpty) {
        DateTime parsedDate = DateTime.parse(date);
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
      return '';
    } catch (e) {
      return '';
    }
  }
}
