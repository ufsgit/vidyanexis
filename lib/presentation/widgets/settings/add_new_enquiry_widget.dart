import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddEnquirySource extends StatefulWidget {
  final bool isEdit;
  final String status;
  // final String sourceName;
  // final String sourceId;

  final String editId;

  const AddEnquirySource({
    super.key,
    required this.isEdit,
    required this.status,
    // required this.sourceName,
    // required this.sourceId,
    required this.editId,
  });

  @override
  State<AddEnquirySource> createState() => _AddEnquirySourceState();
}

class _AddEnquirySourceState extends State<AddEnquirySource> {
  List<Map<String, dynamic>> selectedFields = [];

  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    // if (settingsProvider.sourceCategoryEnquiryController.text.trim().isEmpty) {
    //   return 'Please enter Source Category';
    // }
    if (settingsProvider.enquirySourceController.text.trim().isEmpty) {
      return 'Please enter Enquiry Source';
    }

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

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        settingsProvider.enquirySourceController.text = widget.status;
        // settingsProvider.sourceCategoryEnquiryController.text =
        //     widget.sourceName;
        // settingsProvider.setSourceId(int.parse(widget.sourceId));
      });
    } else {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.enquirySourceController.clear();
      settingsProvider.sourceCategoryEnquiryController.clear();
      settingsProvider.setSourceId(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Enquiry Source' : 'Add Enquiry Source',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.enquirySourceController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width / 2,
        height: MediaQuery.sizeOf(context).height / 4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: CommonDropdown<int>(
              //         hintText: 'Source Category',
              //         selectedValue: widget.isEdit
              //             ? settingsProvider.sourceCategoryId
              //             : null,
              //         items: settingsProvider.searchSourceCategory
              //             .map((source) => DropdownItem<int>(
              //                   id: source.sourceId,
              //                   name: source.sourceName ?? '',
              //                 ))
              //             .toList(),
              //         controller:
              //             settingsProvider.sourceCategoryEnquiryController,
              //         onItemSelected: (selectedId) {
              //           settingsProvider.setSourceId(selectedId);
              //           final selectedItem =
              //               settingsProvider.searchSourceCategory.firstWhere(
              //             (user) => user.sourceId == selectedId,
              //           );
              //           settingsProvider.sourceCategoryEnquiryController.text =
              //               selectedItem.sourceName ?? '';
              //         },
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.enquirySourceController,
                      hintText: 'Enquiry Name*',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // GestureDetector(
              //   onTap: _showCustomFieldDialog,
              //   child: AbsorbPointer(
              //     child: CustomTextField(
              //       readOnly: true,
              //       controller: TextEditingController(),
              //       height: 54,
              //       hintText: 'Custom Field',
              //       labelText: '',
              //       suffixIcon: const Icon(Icons.keyboard_arrow_down),
              //     ),
              //   ),
              // ),
              // if (selectedFields.isNotEmpty) ...[
              //   const SizedBox(height: 10),
              //   Wrap(
              //     spacing: 8,
              //     runSpacing: 8,
              //     children: selectedFields.asMap().entries.map((entry) {
              //       final idx = entry.key;
              //       final field = entry.value;
              //       return Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 12, vertical: 6),
              //         decoration: BoxDecoration(
              //           color: AppColors.appViolet,
              //           borderRadius: BorderRadius.circular(20),
              //         ),
              //         child: Row(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text(
              //               field['custom_field_name'],
              //               style: const TextStyle(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //             const SizedBox(width: 6),
              //             GestureDetector(
              //               onTap: () {
              //                 setState(() {
              //                   selectedFields.removeAt(idx);
              //                 });
              //               },
              //               child: const Icon(
              //                 Icons.close,
              //                 size: 18,
              //                 color: Colors.white,
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ],
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.enquirySourceController.clear();
            settingsProvider.sourceCategoryEnquiryController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, settingsProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }

            settingsProvider.addEnquiryName(
              context: context,
              statusId: widget.editId,
              statusName: settingsProvider.enquirySourceController.text,
            );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
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
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: settingsProvider.customFieldModelList.length,
                  itemBuilder: (context, index) {
                    final field = settingsProvider.customFieldModelList[index];
                    bool isSelected = selectedFields.any(
                        (e) => e['custom_field_id'] == field.customFieldId);
                    final f = selectedFields.indexWhere(
                        (e) => e['custom_field_id'] == field.customFieldId);

                    // bool isMandatory = field['mandatory'];

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
                              "dropdown_values": field.dropDownValues ?? [],
                              "checkbox_values": field.checkBoxValues ?? []
                            });
                          }
                          // tempFields[index]['selected'] = !isSelected;
                          // // If deselecting, also uncheck mandatory
                          // if (!tempFields[index]['selected']) {
                          //   tempFields[index]['mandatory'] = false;
                          // }
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
                            // Main card content
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

                            // Mandatory option (only show if selected)
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_border,
                                      size: 18,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Mark as mandatory',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                    Switch(
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
                                      activeColor: Colors.blue.shade600,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
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
}
