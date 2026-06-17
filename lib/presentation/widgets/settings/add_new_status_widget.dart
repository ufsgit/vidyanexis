import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
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
    if (settingsProvider.progressValueController.text.trim().isNotEmpty) {
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
            borderRadius: BorderRadius.circular(4),
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
                                activeThumbColor: Colors.blue.shade600,
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

  void _showFormChoosingDialog() {
    FormProvider formProvider =
        Provider.of<FormProvider>(context, listen: false);
    SettingsProvider settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    String formSearchQuery = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredList = formProvider.forms
                .where((f) => f.name
                    .toLowerCase()
                    .contains(formSearchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text('Select Form'),
              content: SizedBox(
                width: AppStyles.isWebScreen(context)
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search Form...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          formSearchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('No forms found.'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final formItem = filteredList[index];
                                bool isSelected =
                                    settingsProvider.selectedFormId ==
                                        formItem.id;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      settingsProvider.setSelectedForm(
                                        formItem.id,
                                        formItem.name,
                                      );
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(12),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
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
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            formItem.name,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? Colors.blue.shade700
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(Icons.check_circle,
                                              color: Colors.blue.shade600),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.grey.shade600)),
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      await settingsProvider.fetchSubStatuses();
      final formProvider = Provider.of<FormProvider>(context, listen: false);
      await formProvider.fetchForms(context);
      dropDownProvider.getUserDetails(context);
      settingsProvider.searchDepartment('', context);
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
          DropdownItem<dynamic>(id: 1, name: 'Yes'),
          DropdownItem<dynamic>(id: 0, name: 'No'),
          DropdownItem<dynamic>(id: 2, name: 'Lost'),
          DropdownItem<dynamic>(id: 3, name: 'Sales Closed'),
        ];

        settingsProvider.folloupController.text = followUpOptions
            .firstWhere((e) => e.id.toString() == widget.followUp.toString(),
                orElse: () => followUpOptions[1])
            .name;
        settingsProvider.setSelectedFollowUp(followUpOptions
            .firstWhere((e) => e.id.toString() == widget.followUp.toString(),
                orElse: () => followUpOptions[1])
            .id);

        settingsProvider.isRegisterController.text = registrationOptions
            .firstWhere((e) => e.id.toString() == widget.isRegister.toString(),
                orElse: () => registrationOptions[1])
            .name;
        settingsProvider.setIsRegistered(registrationOptions
            .firstWhere((e) => e.id.toString() == widget.isRegister.toString(),
                orElse: () => registrationOptions[1])
            .id);

        // String regVal = widget.isRegister.toString().toLowerCase();
        // String preselectedId = 'no';
        // if (regVal == '1' || regVal == 'yes') {
        //   preselectedId = 'yes';
        // } else if (regVal == '0' || regVal == 'no') {
        //   preselectedId = 'no';
        // } else if (regVal == '2' || regVal == 'lost') {
        //   preselectedId = 'lost';
        // } else if (regVal == 'sales_closed' || regVal == 'sales closed') {
        //   preselectedId = 'sales_closed';
        // }

        // final selectedRegItem = registrationOptions.firstWhere(
        //     (e) => e.id == widget.isRegister,
        //     orElse: () => registrationOptions[1]); // Default to 'no'

        // settingsProvider.isRegisterController.text = selectedRegItem.name;
        // settingsProvider.setIsRegistered(selectedRegItem.id);
        settingsProvider.setSelectedColor(widget.colorCode);
        settingsProvider.setViewInId(widget.data!.viewInId ?? 0);
        settingsProvider.setStageId(widget.data!.stageId ?? 0);
        settingsProvider.stageStatusController.text =
            widget.data!.statusName ?? "";
        settingsProvider.progressValueController.text =
            widget.data!.progressValue.toString();
        settingsProvider.whatsappTemplateIdController.text =
            widget.data!.whatsappTemplateId ?? "";

        settingsProvider.viewInController.text = widget.data!.viewInName ?? "";
        settingsProvider
            .setSelectedSubStatuses(widget.data!.subStatuses?.toList() ?? []);
        settingsProvider.setSelectedTransferStatuses(
            widget.data!.transferStatuses?.toList() ?? []);
        settingsProvider.isTransfer = widget.data!.isTransfer == 1;
        settingsProvider.isTime = widget.data!.isTime == 1;
        settingsProvider.isTransferStatus = widget.data!.isTransferStatus == 1;
        settingsProvider.isSendUser = widget.data!.isSendUser == 1;
        settingsProvider.templateIdController.text =
            widget.data!.templateId ?? "";
        settingsProvider.isLinkForm = widget.data!.isLinkForm == 1;
        settingsProvider.isAmount = widget.data!.isAmount == 1;
        settingsProvider.setSelectedForm(
            widget.data!.formId?.toString() ?? "", widget.data!.formName ?? "");

        settingsProvider.selectedDepartmentId =
            widget.data!.departmentId ?? 0;
        leadProvider.departmentController.text =
            widget.data!.departmentName ?? "";
        leadProvider.searchUserController.text =
            widget.data!.userName ?? "";
        dropDownProvider.setSelectedUserId(widget.data!.userId ?? 0);
      } else {
        // INITIALIZE FOR ADD NEW STATUS
        settingsProvider.isTransfer = false;
        settingsProvider.isTime = false;
        settingsProvider.isTransferStatus = false;
        settingsProvider.isSendUser = false;
        settingsProvider.templateIdController.clear();
        settingsProvider.isLinkForm = false;
        settingsProvider.isAmount = false;
        settingsProvider.setSelectedForm("", "");
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
        settingsProvider.whatsappTemplateIdController.clear();
        dropDownProvider.setSelectedUserId(0);
        leadProvider.departmentController.clear();
        leadProvider.searchUserController.clear();
        settingsProvider.selectedDepartmentId = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);

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
              settingsProvider.whatsappTemplateIdController.clear();
              settingsProvider.templateIdController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height / 1.5,
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
                      hintText: 'Percentage (Max 100%)',
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
              const SizedBox(
                height: 10,
              ),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: settingsProvider.whatsappTemplateIdController,
                hintText: 'Whatsapp Template Id',
                labelText: '',
              ),
              const SizedBox(
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
              const SizedBox(height: 10),
              // Top checkboxes
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Transfer',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isTransfer,
                      onChanged: (value) =>
                          settingsProvider.isTransfer = value ?? false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Time',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isTime,
                      onChanged: (value) =>
                          settingsProvider.isTime = value ?? false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Secondary Status',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isTransferStatus,
                      onChanged: (value) =>
                          settingsProvider.isTransferStatus = value ?? false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Sent User',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isSendUser,
                      onChanged: (value) =>
                          settingsProvider.isSendUser = value ?? false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Link Form',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isLinkForm,
                      onChanged: (value) =>
                          settingsProvider.isLinkForm = value ?? false,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Amount',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      value: settingsProvider.isAmount,
                      onChanged: (value) =>
                          settingsProvider.isAmount = value ?? false,
                    ),
                  ),
                ],
              ),
              if (settingsProvider.isSendUser) ...[
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.templateIdController,
                  hintText: 'Template id',
                  labelText: '',
                ),
              ],
              if (settingsProvider.isLinkForm) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showFormChoosingDialog,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: settingsProvider.selectedFormName.isNotEmpty
                            ? settingsProvider.selectedFormName
                            : '',
                      ),
                      height: 54,
                      hintText: 'Choose Form',
                      labelText: '',
                      suffixIcon: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              if (settingsProvider.isTransfer) ...[
                CommonDropdown<int>(
                  hintText: 'Department',
                  selectedValue: settingsProvider.selectedDepartmentId,
                  items: settingsProvider.departmentModel
                      .map((source) => DropdownItem<int>(
                            id: source.departmentId,
                            name: source.departmentName,
                          ))
                      .toList(),
                  controller: leadProvider.departmentController,
                  onItemSelected: (selectedId) {
                    setState(() {
                      settingsProvider.selectedDepartmentId = selectedId;
                      final selectedDepartment =
                          settingsProvider.departmentModel.firstWhere(
                              (dept) => dept.departmentId == selectedId);
                      leadProvider.departmentController.text =
                          selectedDepartment.departmentName;

                      dropDownProvider.setSelectedUserId(0);
                      leadProvider.searchUserController.clear();
                    });
                  },
                ),
                const SizedBox(height: 10),
                CommonDropdown<int>(
                  hintText: 'Users',
                  items: dropDownProvider.searchUserDetails
                      .where((staff) =>
                          int.tryParse(staff.departmentId ?? "0") ==
                          settingsProvider.selectedDepartmentId)
                      .map((staff) => DropdownItem<int>(
                            id: staff.userDetailsId,
                            name: staff.userDetailsName,
                          ))
                      .toList(),
                  controller: leadProvider.searchUserController,
                  onItemSelected: (selectedId) {
                    setState(() {
                      dropDownProvider.setSelectedUserId(selectedId);
                      final selectedStaff = dropDownProvider.searchUserDetails
                          .firstWhere(
                              (staff) => staff.userDetailsId == selectedId);
                      leadProvider.searchUserController.text =
                          selectedStaff.userDetailsName;
                    });
                  },
                  selectedValue: dropDownProvider.selectedUserId ?? 0,
                ),
              ],

              // Sub Status
              Text('Sub Status',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: settingsProvider.uniqueSubStatuses.map((status) {
                  final isChecked = settingsProvider.selectedSubStatusIds
                      .contains(status.subStatusId);
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width /
                            (AppStyles.isWebScreen(context) ? 6 : 3)) -
                        20,
                    child: CheckboxListTile(
                      dense: true,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      contentPadding: EdgeInsets.zero,
                      title: Text(status.subStatusName ?? '',
                          style: const TextStyle(fontSize: 10)),
                      value: isChecked,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (_) =>
                          settingsProvider.toggleSubStatus(status),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 10),

              // Transfer Status - Now properly conditional
              if (settingsProvider.isTransferStatus) ...[
                Text('Secondary Status',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children:
                      settingsProvider.uniqueTransferStatuses.map((status) {
                    final isChecked = settingsProvider.selectedTransferStatusIds
                        .contains(status.subStatusId);
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width /
                              (AppStyles.isWebScreen(context) ? 6 : 3)) -
                          20,
                      child: CheckboxListTile(
                        dense: true,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        contentPadding: EdgeInsets.zero,
                        title: Text(status.subStatusName ?? '',
                            style: const TextStyle(fontSize: 10)),
                        value: isChecked,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (_) =>
                            settingsProvider.toggleTransferStatus(status),
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
            settingsProvider.whatsappTemplateIdController.clear();
            settingsProvider.templateIdController.clear();
            Navigator.pop(context);
          },
          radius: 4,
          backgroundColor: AppColors.whiteColor,
          borderColor: const Color(0xFFE2E8F0),
          textColor: const Color(0xFF64748B),
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
                colorCode: settingsProvider.selectedColor.toString(),
                whatsappTemplateId:
                    settingsProvider.whatsappTemplateIdController.text);
          },
          radius: 4,
          backgroundColor: AppColors.secondaryBlue,
          borderColor: AppColors.secondaryBlue,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
