import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/utils/extensions.dart';

class AddNewStatusWidget extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String followUp;
  final String editId;
  final String isRegister;
  String colorCode;
  SearchLeadStatusModel? data;
  AddNewStatusWidget(
      {super.key,
      required this.isEdit,
      required this.status,
      required this.followUp,
      required this.editId,
      required this.isRegister,
      required this.colorCode,
      this.data});

  @override
  State<AddNewStatusWidget> createState() => _AddNewStatusWidgetState();
}

class _AddNewStatusWidgetState extends State<AddNewStatusWidget> {
  List<Map<String, dynamic>> selectedFields = [];
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.statusController.text.trim().isEmpty) {
      return 'Please enter a status';
    }
    if (settingsProvider.folloupController.text.trim().isEmpty) {
      return 'Please select follow up option';
    }
    if (settingsProvider.isRegisterController.text.trim().isEmpty) {
      return 'Please select Registerd Option';
    }
    if (settingsProvider.viewInController.text.trim().isEmpty) {
      return 'Please select View in option';
    }

    // Add percentage validation
    if (settingsProvider.progressValueController.text.trim().isEmpty) {
      return 'Please enter percentage value';
    }

    final double? percentage =
        double.tryParse(settingsProvider.progressValueController.text.trim());
    if (percentage == null) {
      return 'Please enter a valid percentage value';
    }

    if (percentage < 0) {
      return 'Percentage cannot be negative';
    }

    if (percentage > 100) {
      return 'Percentage cannot exceed 100%';
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
                        child: Row(
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
                            // Mandatory option (only show if selected)
                            if (isSelected) ...[
                              const SizedBox(height: 12),
                              Icon(
                                Icons.star_border,
                                size: 18,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Mandatory',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              Switch(
                                value: selectedFields[f]['isMandatory'] == 1,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    final f = selectedFields.indexWhere((e) =>
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      if (widget.isEdit) {
        selectedFields =
            widget.data!.customFields?.map((e) => e.toJson()).toList() ?? [];
        settingsProvider.statusController.text = widget.status;
        final List<DropdownItem<dynamic>> followUpOptions = [
          DropdownItem<dynamic>(id: 1, name: 'Yes'),
          DropdownItem<dynamic>(id: 0, name: 'No'),
          DropdownItem<dynamic>(id: 2, name: 'Lost'),
        ];
        final List<DropdownItem<dynamic>> registrationOptions = [
          DropdownItem<dynamic>(id: 'yes', name: 'Yes'),
          DropdownItem<dynamic>(id: 'no', name: 'No'),
          DropdownItem<dynamic>(id: 'lost', name: 'Lost'),
          DropdownItem<dynamic>(id: 'sales_closed', name: 'Sales Closed'),
        ];

        settingsProvider.folloupController.text = followUpOptions
            .firstWhere((e) => e.id.toString() == widget.followUp.toString(),
                orElse: () => DropdownItem(id: 0, name: 'No'))
            .name;
        settingsProvider.setSelectedFollowUp(followUpOptions
            .firstWhere((e) => e.id.toString() == widget.followUp.toString(),
                orElse: () => DropdownItem(id: 0, name: 'No'))
            .id);

        String regVal = widget.isRegister.toString().toLowerCase();
        String preselectedId = 'no';
        if (regVal == '1' || regVal == 'yes') {
          preselectedId = 'yes';
        } else if (regVal == '0' || regVal == 'no') {
          preselectedId = 'no';
        } else if (regVal == '2' || regVal == 'lost') {
          preselectedId = 'lost';
        } else if (regVal == 'sales_closed' || regVal == 'sales closed') {
          preselectedId = 'sales_closed';
        }

        final selectedRegItem = registrationOptions.firstWhere(
            (e) => e.id == preselectedId,
            orElse: () => registrationOptions[1]); // Default to 'no'

        settingsProvider.isRegisterController.text = selectedRegItem.name;
        settingsProvider.setIsRegistered(selectedRegItem.id);
        settingsProvider.setSelectedColor(widget.colorCode);
        settingsProvider.setViewInId(widget.data!.viewInId ?? 0);
        settingsProvider.setStageId(widget.data!.stageId ?? 0);
        settingsProvider.stageStatusController.text =
            widget.data!.statusName ?? "";
        settingsProvider.progressValueController.text =
            widget.data!.progressValue.toString();

        settingsProvider.viewInController.text = widget.data!.viewInName ?? "";
      } else {
        // INITIALIZE FOR ADD NEW STATUS
        settingsProvider.statusController.clear();
        settingsProvider.folloupController.clear();
        settingsProvider.isRegisterController.clear();
        settingsProvider.setSelectedColor(null);
        settingsProvider.setIsRegistered(null); // Show hint by default
        settingsProvider.setSelectedFollowUp(null); // Show hint by default

        settingsProvider.setViewInId(0);
        settingsProvider.setStageId(0);
        settingsProvider.stageStatusController.text = '';
        settingsProvider.viewInController.text = '';
        settingsProvider.progressValueController.text = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final List<Color> colorOptions = [
      const Color(0xffA8A8A8),
      const Color(0xffDCA654),
      const Color(0xff68AA45),
      const Color(0xff405ED9),
      const Color(0xffB24D44),
      const Color(0xff4D4D4D),
    ];

    final List<DropdownItem<dynamic>> followUpOptions = [
      DropdownItem<dynamic>(id: 1, name: 'Yes'),
      DropdownItem<dynamic>(id: 0, name: 'No'),
      DropdownItem<dynamic>(id: 2, name: 'Lost'),
    ];
    final List<DropdownItem<dynamic>> registrationOptions = [
      DropdownItem<dynamic>(id: 1, name: 'Yes'),
      DropdownItem<dynamic>(id: 0, name: 'No'),
      DropdownItem<dynamic>(id: 2, name: 'Lost'),
      DropdownItem<dynamic>(id: 3, name: 'Sales Closed'),
    ];
    final List<DropdownItem<int>> viewInOptions = [
      DropdownItem<int>(id: 1, name: 'Lead'),
      DropdownItem<int>(id: 2, name: 'Customer'),
      DropdownItem<int>(id: 3, name: 'Task'),
    ];
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Status' : 'Add New Status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.statusController.clear();
              settingsProvider.folloupController.clear();
              settingsProvider.isRegisterController.clear();
              settingsProvider.setSelectedColor(null);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width / 2,
        // height: MediaQuery.sizeOf(context).height / 4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.statusController,
                      hintText: 'Status*',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: CommonDropdown<dynamic>(
                        hintText: 'Follow Up*',
                        selectedValue: settingsProvider.selectedFollowUp,
                        items: followUpOptions,
                        controller: settingsProvider.folloupController,
                        onItemSelected: (selectedId) {
                          settingsProvider.setSelectedFollowUp(selectedId);
                        },
                      ),
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
                    child: CommonDropdown<dynamic>(
                      hintText: 'Registered*',
                      selectedValue: settingsProvider.isRegister,
                      items: registrationOptions,
                      controller: settingsProvider.isRegisterController,
                      onItemSelected: (selectedId) {
                        settingsProvider.setIsRegistered(selectedId);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'View In*',
                      selectedValue:
                          widget.isEdit ? settingsProvider.viewInId : null,
                      items: viewInOptions,
                      controller: settingsProvider.viewInController,
                      onItemSelected: (selectedId) {
                        settingsProvider.setViewInId(selectedId);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'Stage',
                      selectedValue:
                          widget.isEdit ? settingsProvider.stageId : null,
                      items: settingsProvider.searchStage
                          .map((source) => DropdownItem<int>(
                                id: source.stageId,
                                name: source.stageName ?? '',
                              ))
                          .toList(),
                      controller: settingsProvider.stageStatusController,
                      onItemSelected: (selectedId) {
                        settingsProvider.setStageId(selectedId);
                        final selectedItem =
                            settingsProvider.searchStage.firstWhere(
                          (user) => user.stageId == selectedId,
                        );
                        settingsProvider.stageStatusController.text =
                            selectedItem.stageName ?? '';
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.progressValueController,
                      hintText: 'Percentage* (Max 100%)',
                      labelText: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          if (newValue.text.isEmpty) {
                            return newValue;
                          }

                          final double? value = double.tryParse(newValue.text);
                          if (value == null) {
                            return oldValue;
                          }

                          if (value > 100) {
                            return oldValue;
                          }

                          return newValue;
                        }),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final double? percentage = double.tryParse(value);
                          if (percentage != null && percentage > 100) {
                            settingsProvider.progressValueController.text =
                                "100";
                            settingsProvider.progressValueController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: settingsProvider
                                        .progressValueController.text.length));
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
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
              if (selectedFields.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedFields.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final field = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.appViolet,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            field['custom_field_name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFields.removeAt(idx);
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24.0),
              Text(
                'Choose Category Color',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey3,
                ),
              ),
              const SizedBox(height: 16.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: colorOptions.map((color) {
                    bool isSelected =
                        settingsProvider.selectedColor == color.toHexString() ||
                            color.toHexString() == widget.colorCode;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          settingsProvider
                              .setSelectedColor(color.toHexString());
                          widget.colorCode = color.toHexString();

                          print(widget.colorCode);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              width: isSelected ? 35 : 25,
                              height: isSelected ? 35 : 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(77),
                                          blurRadius: 8,
                                          spreadRadius: 3,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.statusController.clear();
            settingsProvider.folloupController.clear();
            settingsProvider.isRegisterController.clear();
            settingsProvider.setSelectedColor(null);
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

            settingsProvider.addLeadStatus(
                context: context,
                statusId: widget.editId,
                customFields: selectedFields,
                statusName: settingsProvider.statusController.text,
                statusOrder: '0',
                followUp: settingsProvider.selectedFollowUp.toString(),
                isRegistered: settingsProvider.isRegister.toString(),
                colorCode: settingsProvider.selectedColor.toString());
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
