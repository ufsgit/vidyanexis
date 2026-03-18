import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddFormSettingsWidget extends StatefulWidget {
  final FormModel? existingForm;

  const AddFormSettingsWidget({super.key, this.existingForm});

  @override
  State<AddFormSettingsWidget> createState() => _AddFormSettingsWidgetState();
}

class _AddFormSettingsWidgetState extends State<AddFormSettingsWidget> {
  final TextEditingController _formNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _taskTypeController = TextEditingController();

  String _selectedDepartment = '';
  int? _selectedDepartmentId;
  String _selectedTaskType = '';
  int? _selectedTaskTypeId;
  String _selectedCustomerName = '';
  int? _selectedCustomerId;

  List<FieldModel> _selectedFields = [];

  bool _isSaving = false;

  bool get isEdit => widget.existingForm != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FormProvider>(context, listen: false);
      provider.fetchAvailableFields(context);
      provider.fetchDepartments(context);
      provider.fetchTaskTypes(context);
      provider.fetchCustomers(context);
    });
    if (isEdit) {
      _formNameController.text = widget.existingForm!.name;
      _departmentController.text = widget.existingForm!.department;
      _taskTypeController.text = widget.existingForm!.taskType;
      _selectedDepartment = widget.existingForm!.department;
      _selectedDepartmentId = widget.existingForm!.departmentId;
      _selectedTaskType = widget.existingForm!.taskType;
      _selectedTaskTypeId = widget.existingForm!.taskTypeId;
      _selectedCustomerId = widget.existingForm!.customerId;

      // Deep copy fields so edits don't affect existing state until save
      _selectedFields = widget.existingForm!.fields
          .map((f) => FieldModel(
              id: f.id,
              label: f.label,
              type: f.type,
              options: f.options,
              isMandatory: f.isMandatory,
              orderBy: f.orderBy))
          .toList();
    }
  }

  @override
  void dispose() {
    _formNameController.dispose();
    _departmentController.dispose();
    _taskTypeController.dispose();
    super.dispose();
  }

  String? _validateInputs() {
    if (_formNameController.text.trim().isEmpty) {
      return 'Please enter Form Name';
    }
    if (_selectedDepartment.isEmpty) {
      return 'Please select a Department';
    }
    if (_selectedTaskType.isEmpty) {
      return 'Please select a Task Type';
    }
    if (_selectedFields.isEmpty) {
      return 'Please select at least 1 Custom Field';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Validation Error',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSelectFieldsDialog(FormProvider formProvider) {
    // Keep local selection state until dialog is saved
    List<FieldModel> tempSelected = List.from(_selectedFields);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Custom Fields'),
              content: SizedBox(
                width: 400,
                child: Consumer<FormProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoadingFields) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (provider.availableFields.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child:
                            Center(child: Text("No custom fields available")),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: provider.availableFields.length,
                      itemBuilder: (context, index) {
                        final field = provider.availableFields[index];
                        final selectedIndex = tempSelected
                            .indexWhere((f) => f.id == field.id);
                        final isSelected = selectedIndex != -1;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? AppColors.primaryBlue.withOpacity(0.05)
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryBlue.withOpacity(0.3)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              CheckboxListTile(
                                title: Text(
                                  field.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  field.type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                value: isSelected,
                                activeColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      tempSelected.add(FieldModel(
                                          id: field.id,
                                          label: field.label,
                                          type: field.type,
                                          options: field.options,
                                          isMandatory: false,
                                          orderBy: 0));
                                    } else {
                                      tempSelected.removeAt(selectedIndex);
                                    }
                                  });
                                },
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: Row(
                                    children: [
                                      // Mandatory Toggle
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Mandatory',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Transform.scale(
                                            scale: 0.75,
                                            child: Switch(
                                              value: tempSelected[selectedIndex]
                                                  .isMandatory,
                                              activeThumbColor: Colors.white,
                                              activeTrackColor:
                                                  AppColors.primaryBlue,
                                              onChanged: (bool val) {
                                                setDialogState(() {
                                                  tempSelected[selectedIndex]
                                                      .isMandatory = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      // Order By input
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Order By',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 60,
                                            height: 32,
                                            child: TextField(
                                              controller: TextEditingController(
                                                  text: tempSelected[selectedIndex]
                                                      .orderBy
                                                      .toString()),
                                              keyboardType: TextInputType.number,
                                              style: const TextStyle(fontSize: 13),
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                hintText: '0',
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 6),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              onChanged: (val) {
                                                tempSelected[selectedIndex]
                                                        .orderBy =
                                                    int.tryParse(val) ?? 0;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFields = List.from(tempSelected);
                    });
                    Navigator.pop(context);
                  },
                  child: Text('Save',
                      style: TextStyle(color: AppColors.primaryBlue)),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveForm(FormProvider formProvider) async {
    final validationError = _validateInputs();
    if (validationError != null) {
      _showErrorDialog(validationError);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newForm = FormModel(
      id: isEdit ? widget.existingForm!.id : '0',
      name: _formNameController.text.trim(),
      department: _selectedDepartment,
      departmentId: _selectedDepartmentId,
      taskType: _selectedTaskType,
      taskTypeId: _selectedTaskTypeId,
      customerId: _selectedCustomerId,
      fields: _selectedFields,
    );

    if (isEdit) {
      await formProvider.updateForm(context, widget.existingForm!.id, newForm);
    } else {
      await formProvider.addForm(context, newForm);
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context, listen: false);

    final isWeb = AppStyles.isWebScreen(context);
    final dialogWidth = isWeb
        ? MediaQuery.of(context).size.width * 0.5
        : MediaQuery.of(context).size.width * 0.95;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Form' : 'Add New Form',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBlack,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Name
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: _formNameController,
                hintText: 'Form Name*',
                labelText: '',
              ),
              const SizedBox(height: 16),

              // Department Dropdown
              Consumer<FormProvider>(
                builder: (context, provider, child) {
                  return provider.isLoadingDepartments
                      ? const Center(child: CircularProgressIndicator())
                        : CommonDropdown<int>(
                            hintText: 'Department*',
                            selectedValue: _selectedDepartmentId,
                            items: provider.departments
                                .map((dept) => DropdownItem<int>(
                                      id: dept['id'],
                                      name: dept['name'],
                                    ))
                                .toList(),
                            controller: _departmentController,
                            onItemSelected: (selectedId) {
                              setState(() {
                                _selectedDepartmentId = selectedId;
                                _selectedDepartment = provider.departments
                                    .firstWhere(
                                        (d) => d['id'] == selectedId)['name'];
                              });
                            },
                          );
                },
              ),
              const SizedBox(height: 16),

              // Task Type Dropdown
              Consumer<FormProvider>(
                builder: (context, provider, child) {
                  return provider.isLoadingTaskTypes
                      ? const Center(child: CircularProgressIndicator())
                        : CommonDropdown<int>(
                            hintText: 'Task Type*',
                            selectedValue: _selectedTaskTypeId,
                            items: provider.taskTypes
                                .map((type) => DropdownItem<int>(
                                      id: type['id'],
                                      name: type['name'],
                                    ))
                                .toList(),
                            controller: _taskTypeController,
                            onItemSelected: (selectedId) {
                              setState(() {
                                _selectedTaskTypeId = selectedId;
                                _selectedTaskType = provider.taskTypes
                                    .firstWhere(
                                        (t) => t['id'] == selectedId)['name'];
                              });
                            },
                          );
                },
              ),
              const SizedBox(height: 16),

              // Customer Dropdown
              Consumer<FormProvider>(
                builder: (context, provider, child) {
                  return provider.isLoadingCustomers
                      ? const Center(child: CircularProgressIndicator())
                      : CommonDropdown<int>(
                          hintText: 'Customer (optional)',
                          selectedValue: _selectedCustomerId,
                          items: provider.customers
                              .map((c) => DropdownItem<int>(
                                    id: c['id'],
                                    name: c['name'],
                                  ))
                              .toList(),
                          controller: TextEditingController(
                              text: _selectedCustomerName),
                          onItemSelected: (selectedId) {
                            setState(() {
                              _selectedCustomerId = selectedId;
                              _selectedCustomerName = provider.customers
                                  .firstWhere(
                                      (c) => c['id'] == selectedId)['name'];
                            });
                          },
                        );
                },
              ),
              const SizedBox(height: 24),

              // Custom Fields Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Fields',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showSelectFieldsDialog(formProvider),
                    icon: const Icon(Icons.add),
                    label: const Text('Select Fields'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Selected Fields List
              if (_selectedFields.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                        'No fields selected. Please select at least 1 field.'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedFields.length,
                  itemBuilder: (context, index) {
                    final field = _selectedFields[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      field.label,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: AppColors.textBlack,
                                      ),
                                    ),
                                    Text(
                                      field.type.name.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _selectedFields.removeAt(index);
                                  });
                                },
                                tooltip: 'Remove field',
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, thickness: 0.5),
                          ),
                          // Options Row (Responsive)
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              // Mandatory toggle
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Mandatory',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: field.isMandatory,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: AppColors.primaryBlue,
                                      onChanged: (bool value) {
                                        setState(() {
                                          field.isMandatory = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              // Order By input
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Order By',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 70,
                                    height: 38,
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: field.orderBy.toString()),
                                      keyboardType: TextInputType.number,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: AppColors.primaryBlue),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        field.orderBy =
                                            int.tryParse(value) ?? 0;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),

              // Bottom Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: CustomElevatedButton(
                      onPressed: () => _saveForm(formProvider),
                      buttonText: 'Save',
                      backgroundColor: AppColors.primaryBlue,
                      textColor: Colors.white,
                      borderColor: AppColors.primaryBlue,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
