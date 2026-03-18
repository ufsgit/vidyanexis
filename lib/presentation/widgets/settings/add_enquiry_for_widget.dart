import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddEnquiryFor extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String sourceName;
  final String sourceId;
  final String editId;
  final EnquiryForModel? data;

  const AddEnquiryFor({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
    required this.sourceName,
    required this.sourceId,
    this.data,
  });

  @override
  State<AddEnquiryFor> createState() => _AddEnquiryForState();
}

class _AddEnquiryForState extends State<AddEnquiryFor> {
  List<Map<String, dynamic>> selectedFields = [];
  List<Map<String, dynamic>> selectedTaskTypes = [];

  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.sourceCategoryEnquiryController.text.trim().isEmpty) {
      return 'Please enter Source Category';
    }
    if (settingsProvider.enquiryForController.text.trim().isEmpty) {
      return 'Please enter Enquiry For';
    }
    // // Validate order by values in custom fields
    // for (var field in selectedFields) {
    //   if (field['orderBy'] != null && field['orderBy'] is! int) {
    //     return 'Order by must be a valid number for all custom fields';
    //   }
    // }

    // if (settingsProvider.selectedColor == null) {
    //   return 'Please select a category color';
    // }
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
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
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
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

  void _showCustomFieldDialog() {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Select Custom Fields '),
              content: SizedBox(
                width: AppStyles.isWebScreen(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width *
                        0.9, // Better mobile width
                height: MediaQuery.of(context).size.height *
                    0.6, // Fixed height instead of full screen
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: settingsProvider.customFieldModelList.length,
                  itemBuilder: (context, index) {
                    final field = settingsProvider.customFieldModelList[index];
                    bool isSelected = selectedFields.any(
                        (e) => e['custom_field_id'] == field.customFieldId);
                    final f = selectedFields.indexWhere(
                        (e) => e['custom_field_id'] == field.customFieldId);

                    return InkWell(
                      onTap: () {
                        setStateDialog(() {
                          if (isSelected) {
                            selectedFields.removeWhere((e) =>
                                e['custom_field_id'] == field.customFieldId);
                          } else {
                            selectedFields.add({
                              "custom_field_id": field.customFieldId,
                              "custom_field_name": field.customFieldName,
                              "custom_field_type_id": field.customFieldTypeId,
                              "isMandatory": 0,
                              "Order_By": 0,
                              "dropdown_values": field.dropDownValues ?? [],
                              "checkbox_values": field.checkBoxValues ?? []
                            });
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade400
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.shade100,
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main row with selection indicator and field name
                            Row(
                              children: [
                                // Selection indicator
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.blue.shade400
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue.shade400
                                          : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Field name
                                Expanded(
                                  child: Text(
                                    field.customFieldName.toString(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.blue.shade700
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Mandatory option (show below on mobile if selected)
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 32), // Align with text above
                                  Icon(
                                    Icons.star_border,
                                    size: 18,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Mandatory',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8, // Smaller switch for mobile
                                    child: Switch(
                                      value:
                                          selectedFields[f]['isMandatory'] == 1,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          final f = selectedFields.indexWhere(
                                              (e) =>
                                                  e['custom_field_id'] ==
                                                  field.customFieldId);
                                          selectedFields[f]['isMandatory'] =
                                              value ? 1 : 0;
                                        });
                                      },
                                      activeThumbColor: Colors.blue.shade600,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Order by field
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 32), // Align with text above
                                  Icon(
                                    Icons.sort,
                                    size: 18,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Order By',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 80,
                                    height: 32,
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: selectedFields[f]['Order_By']
                                                ?.toString() ??
                                            '',
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade400,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        selectedFields[f]['Order_By'] =
                                            int.tryParse(value) ?? 0;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    print(selectedFields);
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTaskTypeDialog() {
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Select Task Types'),
              content: SizedBox(
                width: AppStyles.isWebScreen(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: settingsProvider.taskType.length,
                  itemBuilder: (context, index) {
                    final task = settingsProvider.taskType[index];
                    bool isSelected = selectedTaskTypes
                        .any((e) => e['task_type_id'] == task.taskTypeId);

                    return InkWell(
                      onTap: () {
                        setStateDialog(() {
                          if (isSelected) {
                            selectedTaskTypes.removeWhere(
                                (e) => e['task_type_id'] == task.taskTypeId);
                          } else {
                            selectedTaskTypes.add({
                              "task_type_id": task.taskTypeId,
                              "task_type_name": task.taskTypeName,
                            });
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? Colors.green.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: isSelected
                                ? Colors.green.shade400
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.green.shade400
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.green.shade400
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                task.taskTypeName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.green.shade700
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appViolet,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.searchTaskType('', context);
      if (widget.isEdit) {
        settingsProvider.enquiryForController.text = widget.status;
        settingsProvider.sourceCategoryEnquiryController.text =
            widget.sourceName;
        settingsProvider.setSourceId(int.parse(widget.sourceId));
        // Load existing custom fields if editing
        if (widget.data?.customFields != null) {
          setState(() {
            selectedFields = widget.data!.customFields!.map((e) {
              // Ensure all required fields are present
              Map<String, dynamic> field = Map<String, dynamic>.from(e);
              if (!field.containsKey('dropdown_values')) {
                field['dropdown_values'] = [];
              }
              if (!field.containsKey('checkbox_values')) {
                field['checkbox_values'] = [];
              }
              if (!field.containsKey('Order_By')) {
                field['Order_By'] = 0;
              }
              return field;
            }).toList();
          });
        }
        // Load existing task types if editing
        if (widget.data?.taskTypes != null) {
          setState(() {
            selectedTaskTypes = widget.data!.taskTypes!
                .map((e) => Map<String, dynamic>.from(e))
                .toList();
          });
        }
      } else {
        settingsProvider.sourceCategoryEnquiryController.clear();
        settingsProvider.setSourceId(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Expanded(
            // Make title responsive
            child: Text(
              widget.isEdit ? 'Edit Enquiry For' : 'Add Enquiry For',
              style: GoogleFonts.plusJakartaSans(
                fontSize: isWeb ? 18 : 16, // Smaller font on mobile
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              settingsProvider.enquiryForController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: isWeb
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width * 0.9,
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.7, // Prevent overflow
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'Source Category',
                      selectedValue: widget.isEdit
                          ? settingsProvider.sourceCategoryId
                          : null,
                      items: settingsProvider.searchSourceCategory
                          .map((source) => DropdownItem<int>(
                                id: source.sourceId,
                                name: source.sourceName ?? '',
                              ))
                          .toList(),
                      controller:
                          settingsProvider.sourceCategoryEnquiryController,
                      onItemSelected: (selectedId) {
                        settingsProvider.setSourceId(selectedId);
                        final selectedItem =
                            settingsProvider.searchSourceCategory.firstWhere(
                          (user) => user.sourceId == selectedId,
                        );
                        settingsProvider.sourceCategoryEnquiryController.text =
                            selectedItem.sourceName ?? '';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.enquiryForController,
                      hintText: 'Enquiry For Name*',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showCustomFieldDialog,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(),
                          height: 54,
                          hintText: 'Custom Field',
                          labelText: '',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showTaskTypeDialog,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          readOnly: true,
                          controller: TextEditingController(),
                          height: 54,
                          hintText: 'Task Type',
                          labelText: '',
                          suffixIcon: const Icon(Icons.keyboard_arrow_down),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedTaskTypes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: selectedTaskTypes.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final task = entry.value;
                      return Chip(
                        label: Text(
                          task['task_type_name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: Colors.green.shade600,
                        deleteIcon: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            selectedTaskTypes.removeAt(idx);
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (selectedFields.isNotEmpty) ...[
                const SizedBox(height: 10),
                // Improved selected fields display with better mobile layout
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: selectedFields.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final field = entry.value;
                          return Container(
                            constraints: BoxConstraints(
                              maxWidth: isWeb
                                  ? double.infinity
                                  : MediaQuery.of(context).size.width * 0.7,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.appViolet,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    field['custom_field_name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedFields.removeAt(idx);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        // Responsive button layout
        Flex(
          direction: isWeb ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isWeb) const SizedBox(height: 8),
            Flexible(
              child: CustomElevatedButton(
                buttonText: 'Cancel',
                onPressed: () {
                  settingsProvider.enquiryForController.clear();
                  Navigator.pop(context);
                },
                backgroundColor: AppColors.whiteColor,
                borderColor: AppColors.appViolet,
                textColor: AppColors.appViolet,
              ),
            ),
            if (isWeb) const SizedBox(width: 8) else const SizedBox(height: 8),
            Flexible(
              child: CustomElevatedButton(
                buttonText: 'Save',
                onPressed: () async {
                  final validationError =
                      validateInputs(context, settingsProvider);
                  if (validationError != null) {
                    showErrorDialog(context, validationError);
                    return;
                  }

                  await settingsProvider.addEnquiryForName(
                    context: context,
                    forId: widget.editId,
                    forName: settingsProvider.enquiryForController.text,
                    customFields: selectedFields,
                    taskTypes: selectedTaskTypes,
                  );
                  setState(() {
                    selectedFields.clear();
                    selectedTaskTypes.clear();
                  });
                },
                backgroundColor: AppColors.appViolet,
                borderColor: AppColors.appViolet,
                textColor: AppColors.whiteColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
