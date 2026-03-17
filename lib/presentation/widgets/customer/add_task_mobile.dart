import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/task_details_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';

class AddTaskMobile extends StatefulWidget {
  final bool isEdit;
  final String taskId;
  final TaskDetails? task;

  const AddTaskMobile(
      {super.key, required this.isEdit, required this.taskId, this.task});

  @override
  State<AddTaskMobile> createState() => _AddTaskMobileState();
}

class _AddTaskMobileState extends State<AddTaskMobile> {
  String _selectedTaskTypeId = '';
  List<SearchUserDetails> _filteredUsers = [];

  void _updateFilteredUsers() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType != null) {
      try {
        final selectedTaskTypeModel = dropDownProvider.taskType.firstWhere(
          (task) =>
              task.taskTypeId == customerDetailsProvider.selectedTaskType,
        );

        setState(() {
          _filteredUsers = dropDownProvider.searchUserDetails
              .where((user) =>
                  user.departmentId.toString() ==
                  selectedTaskTypeModel.departmentIds.toString())
              .toList();
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
        widget.taskId.toString(),
        customerDetailsProvider.selectedTaskType.toString(),
        customerDetailsProvider.taskDescriptionController.text.toString(),
        customerDetailsProvider.taskChoosedateController.text.toString(),
        customerDetailsProvider.taskChoosetimeController.text.toString(),
        customerDetailsProvider.selectedAssignWorker.toString(),
        context,
        widget.isEdit,
        [],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(widget.isEdit
                  ? 'Task edited successfully!'
                  : 'Task added successfully!'),
            ],
          ),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.grey),
          onPressed: () {
            customerDetailsProvider.clearTaskDetails();
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.isEdit ? 'Edit Task' : 'Create Task',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E232C),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.25,
                          ),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: dropDownProvider.taskType.map((taskType) {
                                bool isSelected = customerDetailsProvider
                                        .selectedTaskType ==
                                    taskType.taskTypeId;
                                return InkWell(
                                  onTap: () {
                                    if (customerDetailsProvider.addTaskModel.taskUser !=
                                        null) {
                                      customerDetailsProvider.addTaskModel.taskUser!
                                          .clear();
                                    }
                                    customerDetailsProvider.updateTaskType(
                                        taskType.taskTypeId, taskType.taskTypeName);

                                    final defaultStatusId = taskType.defaultStatusId;
                                    customerDetailsProvider.updateAMCStatus(
                                        defaultStatusId != 0 ? defaultStatusId : 1, '');
                                    
                                    _updateFilteredUsers();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.bluebutton
                                          : const Color(0xFFF3F5F7),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      taskType.taskTypeName ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
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
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                            fontSize: 12,
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
                            child: Column(
                              children: _filteredUsers.map((worker) {
                                bool isSelected = customerDetailsProvider
                                        .addTaskModel.taskUser
                                        ?.any((u) =>
                                            u.userDetailsId ==
                                            worker.userDetailsId) ??
                                    false;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: InkWell(
                                    onTap: () {
                                      final userInTask = UserInTaskModel(
                                          userDetailsId: worker.userDetailsId,
                                          userDetailsName: worker.userDetailsName);
                                      if (isSelected) {
                                        customerDetailsProvider
                                            .removeAssignedWorker(userInTask);
                                      } else {
                                        customerDetailsProvider
                                            .addAssignedWorker(userInTask);
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.bluebutton.withOpacity(0.04)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.bluebutton.withOpacity(0.2)
                                              : Colors.grey.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Colors.grey[100],
                                            child: Icon(Icons.person,
                                                color: Colors.grey[400], size: 20),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              worker.userDetailsName ?? '',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E232C),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.bluebutton
                                                    : Colors.grey[300]!,
                                                width: isSelected ? 5 : 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
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
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
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
      ),
    );
  }
}


