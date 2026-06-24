import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddEnquiryForMobilePage extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String sourceName;
  final String sourceId;
  final String editId;
  final EnquiryForModel? data;

  const AddEnquiryForMobilePage({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
    required this.sourceName,
    required this.sourceId,
    this.data,
  });

  @override
  State<AddEnquiryForMobilePage> createState() =>
      _AddEnquiryForMobilePageState();
}

class _AddEnquiryForMobilePageState extends State<AddEnquiryForMobilePage> {
  List<Map<String, dynamic>> selectedFields = [];
  List<Map<String, dynamic>> selectedTaskTypes = [];

  String? _validateInputs(SettingsProvider settingsProvider) {
    if (settingsProvider.sourceCategoryEnquiryController.text.trim().isEmpty) {
      return 'Please enter Source Category';
    }
    if (settingsProvider.enquiryForController.text.trim().isEmpty) {
      return 'Please enter Enquiry For';
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        margin: const EdgeInsets.all(12),
      ),
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
              title: Text(
                'Select Custom Fields',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.6,
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
                              "isMandatoryAtRegistration": 0,
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
                          borderRadius: BorderRadius.circular(4),
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
                            Row(
                              children: [
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
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const SizedBox(width: 32),
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
                                    scale: 0.8,
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
                              Row(
                                children: [
                                  const SizedBox(width: 32),
                                  Icon(
                                    Icons.app_registration,
                                    size: 18,
                                    color: Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Mandatory at registration',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: selectedFields[f]
                                              ['isMandatoryAtRegistration'] ==
                                          1,
                                      onChanged: (value) {
                                        setStateDialog(() {
                                          final f = selectedFields.indexWhere(
                                              (e) =>
                                                  e['custom_field_id'] ==
                                                  field.customFieldId);
                                          selectedFields[f][
                                                  'isMandatoryAtRegistration'] =
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
                              Row(
                                children: [
                                  const SizedBox(width: 32),
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
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide: BorderSide(
                                            color: Colors.blue.shade200,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
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
              title: Text(
                'Select Task Types',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
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
                          borderRadius: BorderRadius.circular(4),
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
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
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
        if (widget.data?.customFields != null) {
          setState(() {
            selectedFields = widget.data!.customFields!.map((e) {
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
              if (!field.containsKey('isMandatoryAtRegistration')) {
                field['isMandatoryAtRegistration'] = 0;
              }
              return field;
            }).toList();
          });
        }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            settingsProvider.enquiryForController.clear();
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ),
        title: Text(
          widget.isEdit ? 'Edit Enquiry For' : 'Add Enquiry For',
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('DETAILS'),
                        const SizedBox(height: 16),
                        CommonDropdown<int>(
                          hintText: 'Source Category *',
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
                            final selectedItem = settingsProvider
                                .searchSourceCategory
                                .firstWhere(
                              (user) => user.sourceId == selectedId,
                            );
                            settingsProvider.sourceCategoryEnquiryController
                                .text = selectedItem.sourceName ?? '';
                          },
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: settingsProvider.enquiryForController,
                          hintText: 'Enquiry For Name *',
                          labelText: '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel('ASSOCIATED CUSTOM FIELDS & TASK TYPES'),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _showCustomFieldDialog,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              readOnly: true,
                              controller: TextEditingController(),
                              height: 54,
                              hintText: 'Select Custom Fields',
                              labelText: '',
                              suffixIcon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _showTaskTypeDialog,
                          child: AbsorbPointer(
                            child: CustomTextField(
                              readOnly: true,
                              controller: TextEditingController(),
                              height: 54,
                              hintText: 'Select Task Types',
                              labelText: '',
                              suffixIcon: const Icon(Icons.keyboard_arrow_down),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedTaskTypes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('SELECTED TASK TYPES'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                selectedTaskTypes.asMap().entries.map((entry) {
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
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (selectedFields.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('SELECTED CUSTOM FIELDS'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children:
                                selectedFields.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final field = entry.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.appViolet,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      field['custom_field_name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
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
                  const SizedBox(height: 24),
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    buttonText: 'Cancel',
                    onPressed: () {
                      settingsProvider.enquiryForController.clear();
                      Navigator.pop(context);
                    },
                    radius: 4,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFE2E8F0),
                    textColor: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomElevatedButton(
                    buttonText: 'Save',
                    onPressed: () async {
                      final error = _validateInputs(settingsProvider);
                      if (error != null) {
                        _showErrorSnackBar(error);
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
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    radius: 4,
                    backgroundColor: AppColors.secondaryBlue,
                    borderColor: AppColors.secondaryBlue,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }
}
