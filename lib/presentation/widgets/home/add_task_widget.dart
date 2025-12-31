import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_page_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddTaskWidget extends StatefulWidget {
  const AddTaskWidget({
    super.key,
    required this.taskId,
  });

  final int taskId;

  @override
  State<AddTaskWidget> createState() => _AddTaskWidgetState();
}

class _AddTaskWidgetState extends State<AddTaskWidget> {
  final _taskController = TextEditingController();
  final _detailController = TextEditingController();
  final _userController = TextEditingController();
  final _durationController = TextEditingController();
  final _dateController = TextEditingController();
  final _endDateController = TextEditingController();
  TaskPageProvider reportsProvider = TaskPageProvider();
  int taskId = 0;
  int? _selectedUserId;
  String? _selectedDuration;
  DateTime? _selectedDate;
  DateTime? _selectedEndDate;
  bool _isRepeating = false;

  @override
  void dispose() {
    _taskController.dispose();
    _detailController.dispose();
    _userController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isEndDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isEndDate) {
          _selectedEndDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _selectedDate = picked;
          _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Task',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF152D70),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _taskController,
                      hintText: 'Task Name',
                      labelText: 'Task',
                      height: 54,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _detailController,
                      hintText: 'Task Detail',
                      labelText: 'Detail',
                      height: 54,
                    ),
                    const SizedBox(height: 16),
                    Consumer<DropDownProvider>(
                      builder: (context, provider, child) {
                        return CommonDropdown<int>(
                          hintText: 'User',
                          items: provider.searchUserDetails
                              .map((user) => DropdownItem<int>(
                                    id: user.userDetailsId!,
                                    name: user.userDetailsName ?? '',
                                  ))
                              .toList(),
                          controller: _userController,
                          onItemSelected: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedUserId = newValue;
                              });
                            }
                          },
                          selectedValue: _selectedUserId,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _isRepeating,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (value) {
                            setState(() {
                              _isRepeating = value ?? false;
                            });
                          },
                        ),
                        Text(
                          'Is Repeating Task?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (_isRepeating) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CommonDropdown<String>(
                              hintText: 'Duration',
                              items: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                                  .map((d) =>
                                      DropdownItem<String>(id: d, name: d))
                                  .toList(),
                              controller: _durationController,
                              onItemSelected: (val) {
                                setState(() {
                                  _selectedDuration = val;
                                });
                              },
                              selectedValue: _selectedDuration,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, true),
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: _endDateController,
                                  hintText: 'Select End Date',
                                  labelText: 'End Date',
                                  height: 54,
                                  suffixIcon: const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context, false),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: _dateController,
                            hintText: 'Select Date',
                            labelText: 'Date',
                            height: 54,
                            suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (kDebugMode) {
                      print('--- AddTaskWidget: Debugging Save Data ---');
                    }
                    if (kDebugMode) {
                      print('Task Name: ${_taskController.text}');
                    }
                    if (kDebugMode) {
                      print('Task Detail: ${_detailController.text}');
                    }
                    if (kDebugMode) {
                      print('Selected User ID: $_selectedUserId');
                    }
                    if (kDebugMode) {
                      print('Is Repeating: $_isRepeating');
                    }
                    if (kDebugMode) {
                      print('Duration: ${_durationController.text}');
                    }
                    if (kDebugMode) {
                      print('End Date: ${_endDateController.text}');
                    }
                    if (kDebugMode) {
                      print('Task ID (from widget): ${widget.taskId}');
                    }
                    if (kDebugMode) {
                      print('-----------------------------------------');
                    }

                    if (_selectedUserId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a user')),
                      );
                      return;
                    }

                    // Passing _selectedUserId as userId and widget.taskId as taskId
                    bool isSuccess = await reportsProvider.saveTaskData(
                        context,
                        _selectedUserId!,
                        widget.taskId,
                        _taskController.text,
                        _isRepeating,
                        _durationController,
                        _endDateController);
                    if (isSuccess) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
