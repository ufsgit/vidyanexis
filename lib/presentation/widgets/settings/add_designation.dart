import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/designation_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddDesignation extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final DesignationModel? designation;

  const AddDesignation({
    super.key,
    required this.isEdit,
    required this.editId,
    this.designation,
  });

  @override
  State<AddDesignation> createState() => _AddDesignationState();
}

class _AddDesignationState extends State<AddDesignation> {
  // taskTypeId -> {daily, monthly}
  final Map<int, Map<String, TextEditingController>> _targetControllers = {};
  final Map<int, bool> _selectedTaskTypes = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sp = Provider.of<SettingsProvider>(context, listen: false);
      sp.designationNameController.clear();
      sp.searchTaskType('', context); // load all task types

      if (widget.isEdit && widget.designation != null) {
        sp.designationNameController.text = widget.designation!.designationName;

        for (var tt in widget.designation!.taskTypes) {
          _selectedTaskTypes[tt.taskTypeId] = true;
          _targetControllers[tt.taskTypeId] = {
            'daily': TextEditingController(text: tt.dailyCount.toString()),
            'monthly': TextEditingController(text: tt.monthlyCount.toString()),
          };
        }
        _updateSelectAll();
      }
    });
  }

  void _toggleSelectAll() {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _selectAll = !_selectAll;
      for (var task in sp.taskType) {
        _selectedTaskTypes[task.taskTypeId] = _selectAll;
        if (_selectAll && !_targetControllers.containsKey(task.taskTypeId)) {
          _targetControllers[task.taskTypeId] = {
            'daily': TextEditingController(text: '0'),
            'monthly': TextEditingController(text: '0'),
          };
        }
      }
    });
  }

  void _updateSelectAll() {
    final sp = Provider.of<SettingsProvider>(context, listen: false);
    if (sp.taskType.isEmpty) {
      _selectAll = false;
      return;
    }
    bool all = true;
    for (var t in sp.taskType) {
      if (!(_selectedTaskTypes[t.taskTypeId] ?? false)) {
        all = false;
        break;
      }
    }
    setState(() => _selectAll = all);
  }

  String? _validate(SettingsProvider sp) {
    if (sp.designationNameController.text.trim().isEmpty) {
      return 'Please enter Designation Name';
    }
    if (_selectedTaskTypes.values.where((v) => v).isEmpty) {
      return 'Please select at least one Task Type';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final sp = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = isWeb
              ? MediaQuery.of(context).size.width * 0.75
              : MediaQuery.of(context).size.width * 0.95;
          final height = MediaQuery.of(context).size.height * 0.85;

          return Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isEdit ? 'Edit Designation' : 'Add Designation',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name
                CustomTextField(
                  controller: sp.designationNameController,
                  hintText: 'Designation Name *',
                  height: 50,
                  readOnly: false,
                ),
                const SizedBox(height: 20),

                // Task Types header
                Row(
                  children: [
                    Text(
                      'Task Types',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _toggleSelectAll,
                      child: Text(
                        _selectAll ? 'Deselect All' : 'Select All',
                        style: TextStyle(color: AppColors.appViolet),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: sp.taskType.isEmpty
                        ? const Center(child: Text('No Task Types found'))
                        : ListView.builder(
                            itemCount: sp.taskType.length,
                            itemBuilder: (context, index) {
                              final task = sp.taskType[index];
                              final id = task.taskTypeId;
                              final isSelected =
                                  _selectedTaskTypes[id] ?? false;

                              // ensure controllers exist when selected
                              if (isSelected &&
                                  !_targetControllers.containsKey(id)) {
                                _targetControllers[id] = {
                                  'daily': TextEditingController(text: '0'),
                                  'monthly': TextEditingController(text: '0'),
                                };
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondaryBlue
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: (v) {
                                            setState(() {
                                              _selectedTaskTypes[id] =
                                                  v ?? false;
                                              if (v == true &&
                                                  !_targetControllers
                                                      .containsKey(id)) {
                                                _targetControllers[id] = {
                                                  'daily':
                                                      TextEditingController(
                                                          text: '0'),
                                                  'monthly':
                                                      TextEditingController(
                                                          text: '0'),
                                                };
                                              }
                                              _updateSelectAll();
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            task.taskTypeName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _targetControllers[
                                                  id]!['daily'],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Daily Target',
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _targetControllers[
                                                  id]!['monthly'],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Monthly Target',
                                                isDense: true,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      buttonText: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFE2E8F0),
                      textColor: const Color(0xFF64748B),
                      radius: 4,
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      buttonText: 'Save',
                      backgroundColor: AppColors.secondaryBlue,
                      borderColor: AppColors.secondaryBlue,
                      textColor: Colors.white,
                      radius: 4,
                      onPressed: () {
                        final error = _validate(sp);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                          return;
                        }

                        final taskTypesPayload = <Map<String, dynamic>>[];
                        _selectedTaskTypes.forEach((id, selected) {
                          if (selected) {
                            final daily = int.tryParse(
                                    _targetControllers[id]?['daily']?.text ??
                                        '0') ??
                                0;
                            final monthly = int.tryParse(
                                    _targetControllers[id]?['monthly']?.text ??
                                        '0') ??
                                0;
                            final name = sp.taskType
                                .firstWhere((t) => t.taskTypeId == id)
                                .taskTypeName;

                            taskTypesPayload.add({
                              'Task_Type_Id': id,
                              'Task_Type_Name': name,
                              'Daily_Count': daily,
                              'Monthly_Count': monthly,
                            });
                          }
                        });

                        final requestData = {
                          'Designation_Id': widget.isEdit
                              ? int.tryParse(widget.editId) ?? 0
                              : 0,
                          'Designation_Name':
                              sp.designationNameController.text.trim(),
                          'Task_Types': taskTypesPayload,
                        };

                        sp.addDesignation(context: context, data: requestData);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var map in _targetControllers.values) {
      map['daily']?.dispose();
      map['monthly']?.dispose();
    }
    super.dispose();
  }
}
