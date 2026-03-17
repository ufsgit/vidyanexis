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

  void _showWorkerSelectionBottomSheet() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a task type first!')),
      );
      return;
    }

    final selectedTaskType = dropDownProvider.taskType.firstWhere(
        (task) => task.taskTypeId == customerDetailsProvider.selectedTaskType);

    final filteredUsers = dropDownProvider.searchUserDetails
        .where((user) =>
            user.departmentId.toString() ==
            selectedTaskType.departmentIds.toString())
        .toList();

    if (filteredUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No workers available in this department!')),
      );
      return;
    }

    Set<int> selectedUserIds = {
      if (customerDetailsProvider.addTaskModel.taskUser != null)
        ...customerDetailsProvider.addTaskModel.taskUser!
            .map((u) => u.userDetailsId!)
    };

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Worker',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final worker = filteredUsers[index];
                        bool isSelected =
                            selectedUserIds.contains(worker.userDetailsId);

                        return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Icon(Icons.person, color: Colors.grey[600]),
                            ),
                            title: Text(
                              worker.userDetailsName ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              worker.departmentName ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            trailing: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.bluebutton : Colors.grey[400]!,
                                  width: isSelected ? 6 : 1.5,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                final userInTask = UserInTaskModel(
                                    userDetailsId: worker.userDetailsId,
                                    userDetailsName: worker.userDetailsName);
                                if (isSelected) {
                                  selectedUserIds.remove(worker.userDetailsId!);
                                  customerDetailsProvider
                                      .removeAssignedWorker(userInTask);
                                } else {
                                  selectedUserIds.add(worker.userDetailsId!);
                                  customerDetailsProvider
                                      .addAssignedWorker(userInTask);
                                }
                              });
                            });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.bluebutton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Selection',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        Wrap(
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
                                    horizontal: 18, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton
                                      : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  taskType.taskTypeName ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        ..._filteredUsers.take(4).map((worker) {
                          bool isSelected = customerDetailsProvider
                                  .addTaskModel.taskUser
                                  ?.any((u) =>
                                      u.userDetailsId ==
                                      worker.userDetailsId) ??
                              false;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
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
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton.withOpacity(0.04)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.bluebutton.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.15),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[100],
                                      child: Icon(Icons.person, color: Colors.grey[400], size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        worker.userDetailsName ?? '',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E232C),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? AppColors.bluebutton : Colors.grey[300]!,
                                          width: isSelected ? 6 : 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        
                        const SizedBox(height: 8),
                        
                        InkWell(
                          onTap: _showWorkerSelectionBottomSheet,
                          child: CustomPaint(
                            painter: DottedBorderPainter(
                              color: Colors.grey[400]!,
                              strokeWidth: 1,
                              gap: 4,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.add, color: Colors.grey[400], size: 20),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Add new assignee',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[400],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
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
            padding: const EdgeInsets.all(24),
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
              height: 56,
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

class DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DottedBorderPainter({
    required this.color,
    this.strokeWidth = 1,
    this.gap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(14),
      ));

    for (PathMetric pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(
          pathMetric.extractPath(distance, distance + gap),
          paint,
        );
        distance += gap * 2;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
