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
  String _selectedTaskType = '';

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
    });
    if (isEdit) {
      _formNameController.text = widget.existingForm!.name;
      _departmentController.text = widget.existingForm!.department;
      _taskTypeController.text = widget.existingForm!.taskType;
      _selectedDepartment = widget.existingForm!.department;
      _selectedTaskType = widget.existingForm!.taskType;

      // Deep copy fields so edits don't affect existing state until save
      _selectedFields = widget.existingForm!.fields
          .map((f) => FieldModel(
              id: f.id,
              label: f.label,
              type: f.type,
              options: f.options,
              isMandatory: f.isMandatory))
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
                        final isSelected =
                            tempSelected.any((f) => f.label == field.label);

                        return CheckboxListTile(
                          title: Text(field.label),
                          subtitle: Text(field.type.name),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setDialogState(() {
                              if (value == true) {
                                tempSelected.add(FieldModel(
                                    id: DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString() +
                                        index.toString(),
                                    label: field.label,
                                    type: field.type,
                                    options: field.options,
                                    isMandatory: false));
                              } else {
                                tempSelected
                                    .removeWhere((f) => f.label == field.label);
                              }
                            });
                          },
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
      id: isEdit
          ? widget.existingForm!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _formNameController.text.trim(),
      department: _selectedDepartment,
      taskType: _selectedTaskType,
      fields: _selectedFields,
    );

    if (isEdit) {
      formProvider.updateForm(widget.existingForm!.id, newForm);
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
                      : CommonDropdown<String>(
                          hintText: 'Department*',
                          selectedValue: _selectedDepartment.isNotEmpty
                              ? _selectedDepartment
                              : null,
                          items: provider.departments
                              .map((dept) => DropdownItem<String>(
                                    id: dept,
                                    name: dept,
                                  ))
                              .toList(),
                          controller: _departmentController,
                          onItemSelected: (selectedDept) {
                            setState(() {
                              _selectedDepartment = selectedDept;
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
                      : CommonDropdown<String>(
                          hintText: 'Task Type*',
                          selectedValue: _selectedTaskType.isNotEmpty
                              ? _selectedTaskType
                              : null,
                          items: provider.taskTypes
                              .map((type) => DropdownItem<String>(
                                    id: type,
                                    name: type,
                                  ))
                              .toList(),
                          controller: _taskTypeController,
                          onItemSelected: (selectedType) {
                            setState(() {
                              _selectedTaskType = selectedType;
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
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  field.label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  field.type.name.toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Mandatory',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: field.isMandatory,
                                activeColor: Colors.white,
                                activeTrackColor: AppColors.primaryBlue,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey[300],
                                trackOutlineColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                onChanged: (bool value) {
                                  setState(() {
                                    field.isMandatory = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedFields.removeAt(index);
                              });
                            },
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
