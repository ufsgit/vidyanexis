import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:provider/provider.dart';

import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';

class ProcessFlowDialog extends StatefulWidget {
  final TaskReportModel task;

  const ProcessFlowDialog({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<ProcessFlowDialog> createState() => ProcessFlowDialogState();
}

class ProcessFlowDialogState extends State<ProcessFlowDialog> {
  late Future<List<TaskTypeStatusModel>> statusOptionsFuture;
  late TaskTypeStatusModel selectedStatus;
  bool isSaving = false;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();

    statusOptionsFuture = getStatusType(widget.task.taskTypeId.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<TaskPageProvider>(context, listen: false);
      reportsProvider.clearDescription();
    });
  }

  @override
  void dispose() {
    // Clear description on close
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final reportsProvider =
            Provider.of<TaskPageProvider>(context, listen: false);
        reportsProvider.clearDescription();
      }
    });
    super.dispose();
  }

  Future<List<TaskTypeStatusModel>> getStatusType(String taskTypeId) async {
    DropDownProvider provider = DropDownProvider();
    return provider.getStatusByTaskTypeId(context, taskTypeId, '3');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsProvider =
        Provider.of<TaskPageProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => ImageUploadAlert(
                      customerId: widget.task.customerId.toString()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.upload_file, size: 20),
              label: const Text('+ Documents'),
            ),
          ],
        ),
      ),
      appBar: CustomAppBarWidget(
        title: 'Update Status',
        titleFontSize: 14,
        richText: '\n${widget.task.customerName}',
        richText2: '\n${widget.task.taskTypeName}',
        onLeadingPressed: () {
          Navigator.of(context).pop(false);
        },
        isRichTextClickable: true,
        onRichTextPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return CustomerDetailPageMobile(
                  fromLead: false, customerId: widget.task.customerId);
            },
          ));
        },
        onSavePressed: () async {
          if (isSaving) return;

          // Check if there are required statuses that need to be completed
          if (reportsProvider.statusData.isNotEmpty) {
            // Get list of required statuses that aren't completed
            List<String> incompleteStatuses = reportsProvider.statusData
                .map((status) =>
                    "${status.taskTypeName}-${status.requiredStatuses}")
                .toList();

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Required Status Incomplete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  content: Container(
                    width: 450,
                    constraints:
                        const BoxConstraints(maxWidth: 400, maxHeight: 700),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          "Any one of the following required statuses must be completed for the corresponding task before saving:",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...incompleteStatuses
                            .map((status) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(status)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
            return;
          }

          if (reportsProvider.documentTypeModel.isEmpty) {
            setState(() {
              isSaving = true;
            });

            try {
              bool isSuccess = await reportsProvider.changeTaskStatus(
                  context,
                  selectedStatus,
                  widget.task.taskId,
                  widget.task.locationTracking == 1
                      ? await reportsProvider.getCurrentLocation()
                      : null);

              if (isSuccess) {
                Navigator.of(context).pop(true);
              } else {
                setState(() {
                  isSaving = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update status')),
                );
              }
            } catch (e) {
              setState(() {
                isSaving = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Failed to update status: ${e.toString()}')),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Unable to Save",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Documents Not Uploaded",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                      ),
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      body: FutureBuilder<List<TaskTypeStatusModel>>(
        future: statusOptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading status options...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading status options',
                      style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error loading status options',
                      style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          } else {
            final statusOptions = snapshot.data!;

            if (!isInitialized) {
              selectedStatus = statusOptions.firstWhere(
                (status) => status.statusId == widget.task.taskStatusId,
                orElse: () => statusOptions.first,
              );
              isInitialized = true;

              int statusId = selectedStatus.statusId ?? 0;
              int tasktypeId = selectedStatus.taskTypeId ?? 0;
              int customerId = widget.task.customerId;
              int enquiryForId = widget.task.enquiryForId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                reportsProvider.fetchTaskTypes(
                    tasktypeId, statusId, customerId, enquiryForId, context);
              });
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ListView(
                children: [
                  // Current Status Section
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'Current Status',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.grey),
                            color: AppColors.whiteColor,
                          ),
                          child: DropdownButtonFormField<TaskTypeStatusModel>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: Icon(Icons.arrow_drop_down,
                                color: theme.primaryColor),
                            dropdownColor: theme.cardColor,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            onChanged: (TaskTypeStatusModel? newValue) async {
                              if (newValue != null) {
                                setState(() {
                                  selectedStatus = newValue;
                                });

                                int statusId = selectedStatus.statusId ?? 0;
                                int tasktypeId = selectedStatus.taskTypeId ?? 0;
                                int customerId = widget.task.customerId;
                                int enquiryForId = widget.task.enquiryForId;

                                await reportsProvider.fetchTaskTypes(
                                    tasktypeId,
                                    statusId,
                                    customerId,
                                    enquiryForId,
                                    context);
                              }
                            },
                            items: statusOptions
                                .map<DropdownMenuItem<TaskTypeStatusModel>>(
                              (TaskTypeStatusModel status) {
                                Color statusColor =
                                    status.colorCode ?? Colors.black;

                                return DropdownMenuItem<TaskTypeStatusModel>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      CustomText(status.statusName ?? ''),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // New Task Section
                  Consumer<TaskPageProvider>(
                    builder: (context, reportsProvider, child) {
                      if (reportsProvider.taskTypeModel.isNotEmpty) {
                        return Card(
                          margin: const EdgeInsets.only(top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    border: Border.all(color: AppColors.grey),
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        'New Task',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    CustomText(
                                      'Department',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBlack,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                child: ListView(
                                  shrinkWrap: true,
                                  children:
                                      reportsProvider.taskTypeModel.map((task) {
                                    return CheckboxListTile(
                                      contentPadding: const EdgeInsets.all(0),
                                      title: Row(
                                        children: [
                                          Expanded(
                                              child: CustomText(
                                                  task.taskTypeName)),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: CustomText(
                                                task.departmentName ?? ""),
                                          ),
                                        ],
                                      ),
                                      value: reportsProvider.selectedTaskTypeIds
                                          .contains(task.taskTypeId.toString()),
                                      onChanged: (bool? value) {
                                        reportsProvider.toggleTaskTypeSelection(
                                            task.taskTypeId.toString());
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  // FollowUp Section
                  if (selectedStatus.followup == 1)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          'FollowUp Date',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.grey),
                            color: AppColors.whiteColor,
                          ),
                          child: TextField(
                            controller: reportsProvider.followUpDateController,
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                reportsProvider.followUpDateController.text =
                                    DateFormat('dd MMM yyyy').format(picked);
                              }
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: InputBorder.none,
                              hintText: 'Enter FollowUp Date',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Description Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Description',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey),
                          color: AppColors.whiteColor,
                        ),
                        child: TextField(
                          controller: reportsProvider.descriptionController,
                          maxLines: 4,
                          minLines: 3,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                            hintText: 'Enter description',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pending Documents Section
                  Consumer<TaskPageProvider>(
                    builder: (context, reportsProvider, child) {
                      if (reportsProvider.documentTypeModel.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              'Pending Documents',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    reportsProvider.documentTypeModel.length,
                                itemBuilder: (context, index) {
                                  var document =
                                      reportsProvider.documentTypeModel[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    leading: Container(
                                      width: 35,
                                      child: Text((index + 1).toString() + "."),
                                    ),
                                    title:
                                        CustomText(document.documentTypeName),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Mandatory Tasks Section
                  Consumer<TaskPageProvider>(
                    builder: (context, reportsProvider, child) {
                      if (reportsProvider.statusData.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              'Mandatory Tasks',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlack,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: reportsProvider.statusData.length,
                                itemBuilder: (context, index) {
                                  var task = reportsProvider.statusData[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    leading: Container(
                                      width: 35,
                                      child: CustomText(
                                          (index + 1).toString() + "."),
                                    ),
                                    title: CustomText(
                                        "${task.taskTypeName}-${task.requiredStatuses}"),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
