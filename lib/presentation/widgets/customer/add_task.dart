import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/controller/models/task_details_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';

class TaskCreationWidget extends StatefulWidget {
  bool isEdit;
  String taskId;
  TaskCustomerModel? task;
  TaskDetails? taskDetails;

  TaskCreationWidget({
    super.key,
    required this.isEdit,
    required this.taskId,
    this.task,
    this.taskDetails,
  });

  @override
  State<TaskCreationWidget> createState() => _TaskCreationWidgetState();
}

class _TaskCreationWidgetState extends State<TaskCreationWidget> {
  String _selectedTaskTypeId = '';
  List<SearchUserDetails> _filteredUsers = [];
  bool isSingleSelect = true;
  bool _showMore = false;

  void _updateFilteredUsers() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType != null) {
      try {
        final selectedTaskTypeModel = dropDownProvider.taskType.firstWhere(
          (task) => task.taskTypeId == customerDetailsProvider.selectedTaskType,
        );

        setState(() {
          _filteredUsers = dropDownProvider.searchUserDetails
              .where((user) =>
                  user.workingStatus == "1" &&
                  user.departmentId.toString() ==
                      selectedTaskTypeModel.departmentIds.toString())
              .toList();

          if (_filteredUsers.length == 1) {
            final worker = _filteredUsers.first;
            final userInTask = UserInTaskModel(
                userDetailsId: worker.userDetailsId,
                userDetailsName: worker.userDetailsName);
            customerDetailsProvider.addTaskModel.taskUser?.clear();
            customerDetailsProvider.addAssignedWorker(userInTask);
          }
        });
      } catch (e) {
        setState(() {
          _filteredUsers = [];
        });
      }
    } else {
      setState(() {
        _filteredUsers = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      provider.getTaskType(context);

      if (!widget.isEdit) {
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      }

      if (customerDetailsProvider.selectedTaskType != null) {
        final taskTypeId = customerDetailsProvider.selectedTaskType.toString();
        setState(() {
          _selectedTaskTypeId = taskTypeId;
        });
        _updateFilteredUsers();
      }

      if (widget.isEdit) {
        customerDetailsProvider.commissionController.text =
            widget.taskDetails?.commissionNumber.toString() ??
                widget.task?.commissionNumber.toString() ??
                '';
        customerDetailsProvider.taskDescriptionController.text =
            widget.taskDetails?.description ?? widget.task?.description ?? '';

        if (widget.taskDetails?.taskDate != null &&
            widget.taskDetails!.taskDate.isNotEmpty) {
          try {
            DateTime date = DateTime.parse(widget.taskDetails!.taskDate);
            customerDetailsProvider.taskChoosedateController.text =
                DateFormat('dd MMM yyyy').format(date);
          } catch (e) {
            // Handle parsing error
          }
        } else if (widget.task?.taskDate != null) {
          customerDetailsProvider.taskChoosedateController.text =
              DateFormat('dd MMM yyyy').format(widget.task!.taskDate);
        }
      }
    });
  }

  Future<void> _handleSave() async {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType != null &&
        customerDetailsProvider.addTaskModel.taskUser != null &&
        customerDetailsProvider.addTaskModel.taskUser!.isNotEmpty) {
      if (customerDetailsProvider.taskChoosedateController.text.isEmpty) {
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      }

      if (customerDetailsProvider.selectedAMCStatus == 0) {
        customerDetailsProvider.updateAMCStatus(1, 'Not Started');
      }

      await customerDetailsProvider.saveTask(
        widget.task?.taskId.toString() ??
            widget.taskDetails?.taskId.first.toString() ??
            '0',
        widget.task?.taskMasterId.toString() ??
            widget.taskDetails?.taskMasterId.toString() ??
            '0',
        customerDetailsProvider.selectedTaskType.toString(),
        customerDetailsProvider.taskDescriptionController.text.toString(),
        customerDetailsProvider.taskChoosedateController.text.toString(),
        customerDetailsProvider.taskChoosetimeController.text.toString(),
        customerDetailsProvider.selectedAssignWorker.toString(),
        context,
        widget.isEdit,
        [],
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.appViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Please select a Task Type and at least one Assignee.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.appViolet,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    final double dialogWidth = AppStyles.isWebScreen(context)
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.width * 0.9;

    return AlertDialog(
      scrollable: true,
      backgroundColor: const Color(0xFFF8F9FB),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isEdit ? 'Edit Task' : 'Create Task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E232C),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                customerDetailsProvider.clearTaskDetails();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT TASK TYPE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: dropDownProvider.taskType
                              .where((taskType) =>
                                  taskType.manualCreation == 1 ||
                                  (widget.isEdit &&
                                      customerDetailsProvider
                                              .selectedTaskType ==
                                          taskType.taskTypeId))
                              .map((taskType) {
                            bool isSelected =
                                customerDetailsProvider.selectedTaskType ==
                                    taskType.taskTypeId;
                            return InkWell(
                              onTap: () {
                                if (customerDetailsProvider
                                        .addTaskModel.taskUser !=
                                    null) {
                                  customerDetailsProvider.addTaskModel.taskUser!
                                      .clear();
                                }
                                customerDetailsProvider.updateTaskType(
                                    taskType.taskTypeId, taskType.taskTypeName);

                                final defaultStatusId =
                                    taskType.defaultStatusId;
                                customerDetailsProvider.updateAMCStatus(
                                    defaultStatusId != 0 ? defaultStatusId : 1,
                                    '');

                                _updateFilteredUsers();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton
                                      : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  taskType.taskTypeName ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  setState(() {
                    _showMore = !_showMore;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showMore ? 'Less' : 'More',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bluebutton,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showMore
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.bluebutton,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showMore) const SizedBox(height: 16),
              if (_showMore)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            customerDetailsProvider.taskDescriptionController,
                        maxLines: 3,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E232C),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter task description...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.bluebutton.withOpacity(0.5)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              if (customerDetailsProvider.selectedTaskType != null &&
                  dropDownProvider.taskType.any((element) =>
                      element.taskTypeId ==
                          customerDetailsProvider.selectedTaskType &&
                      element.commissionNumber == 1))
                const SizedBox(height: 16),
              if (customerDetailsProvider.selectedTaskType != null &&
                  dropDownProvider.taskType.any((element) =>
                      element.taskTypeId ==
                          customerDetailsProvider.selectedTaskType &&
                      element.commissionNumber == 1))
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AMOUNT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            customerDetailsProvider.commissionController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E232C),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter amount...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_showMore) const SizedBox(height: 16),
              if (_showMore)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASK DATE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            customerDetailsProvider
                                    .taskChoosedateController.text =
                                DateFormat('dd MMM yyyy').format(picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                customerDetailsProvider
                                        .taskChoosedateController.text.isEmpty
                                    ? 'Select Date'
                                    : customerDetailsProvider
                                        .taskChoosedateController.text,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1E232C),
                                ),
                              ),
                              Icon(Icons.calendar_today,
                                  color: AppColors.bluebutton, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSIGN TO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _filteredUsers.map((worker) {
                            bool isSelected = customerDetailsProvider
                                    .addTaskModel.taskUser
                                    ?.any((u) =>
                                        u.userDetailsId ==
                                        worker.userDetailsId) ??
                                false;
                            return InkWell(
                              onTap: () {
                                final userInTask = UserInTaskModel(
                                    userDetailsId: worker.userDetailsId,
                                    userDetailsName: worker.userDetailsName);
                                // to multiselect change to false
                                if (isSingleSelect) {
                                  if (isSelected) {
                                    customerDetailsProvider
                                        .removeAssignedWorker(userInTask);
                                  } else {
                                    customerDetailsProvider
                                        .addTaskModel.taskUser
                                        ?.clear();
                                    customerDetailsProvider
                                        .addAssignedWorker(userInTask);
                                  }
                                } else {
                                  if (isSelected) {
                                    customerDetailsProvider
                                        .removeAssignedWorker(userInTask);
                                  } else {
                                    customerDetailsProvider
                                        .addAssignedWorker(userInTask);
                                  }
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton
                                      : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  worker.userDetailsName ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluebutton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isEdit ? 'Update Task' : 'Create Task',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.add, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
