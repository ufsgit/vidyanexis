import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/models/custom_field_dropdown.dart';
import 'package:techtify/controller/models/custom_field_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

import '../../../constants/app_styles.dart';

class AddCustomField extends StatefulWidget {
  final bool isEdit;
  final String status;
  final String editId;
  final CustomFieldModel? customFieldTypeModel;
  const AddCustomField({
    super.key,
    required this.isEdit,
    required this.status,
    required this.editId,
    this.customFieldTypeModel,
  });

  @override
  State<AddCustomField> createState() => _AddCustomFieldState();
}

class _AddCustomFieldState extends State<AddCustomField> {
  // String? validateInputs(
  //     BuildContext context, SettingsProvider settingsProvider) {
  //   if (settingsProvider.fieldNameController.text.trim().isEmpty) {
  //     return 'Please enter field Name';
  //   }
  //   if (settingsProvider.fieldTypeController.text.trim().isEmpty) {
  //     return 'Please enter Field Type';
  //   }
  //
  //
  //   return null;
  // }
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.fieldNameController.text.trim().isEmpty) {
      return 'Please enter field name';
    }
    if (settingsProvider.fieldTypeController.text.trim().isEmpty) {
      return 'Please select field type';
    }

    final bool requiresFieldList =
        settingsProvider.fieldNameid == 3 || settingsProvider.fieldNameid == 5;
    if (requiresFieldList && settingsProvider.fieldListItems.isEmpty) {
      return 'Please add at least one item in the Field List';
    }

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.getCustomFieldDropDown(context);
      if (widget.isEdit) {
        settingsProvider.fieldNameController.text =
            widget.customFieldTypeModel?.customFieldName ?? "";
        settingsProvider.setFieldId(
          settingsProvider.customFieldTypeModelList.firstWhere(
              orElse: () => CustomFieldTypeModel(customFieldId: 0),
              (e) =>
                  e.customFieldTypeId ==
                  widget.customFieldTypeModel?.customFieldTypeId),
        );

        if (widget.customFieldTypeModel?.customFieldTypeId == 3) {
          settingsProvider.fieldListItems =
              widget.customFieldTypeModel?.dropDownValues ?? [];
        }

        if (widget.customFieldTypeModel?.customFieldTypeId == 5) {
          settingsProvider.fieldListItems =
              widget.customFieldTypeModel?.checkBoxValues ?? [];
        }
      } else {
        settingsProvider.fieldNameController.clear();
        settingsProvider.fieldTypeController.clear();
        settingsProvider.fieldListItems.clear();
        // settingsProvider.setFieldId(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Custom Field' : 'Add Custom Field',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.fieldNameController.clear();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      content: Container(
        color: Colors.white,
        width: MediaQuery.sizeOf(context).width / 2,
        // height: MediaQuery.sizeOf(context).height /4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.fieldNameController,
                      hintText: 'Field Name*',
                      labelText: '',
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
                    child: CommonDropdown<CustomFieldTypeModel>(
                      hintText: 'Field type*',
                      selectedValue: widget.isEdit
                          ? settingsProvider.selectedCustomFieldType
                          : null,
                      items: settingsProvider.customFieldTypeModelList
                          .map(
                            (e) => DropdownItem<CustomFieldTypeModel>(
                                id: e, name: e.customFieldTypeName ?? ""),
                          )
                          .toList(),
                      controller: settingsProvider.fieldTypeController,
                      onItemSelected: (selectedId) {
                        settingsProvider.setFieldId(selectedId);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              if ((settingsProvider.fieldNameid == 3 ||
                      settingsProvider.fieldNameid == 5) &&
                  settingsProvider.fieldTypeController.text.isNotEmpty)
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Field List ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textGrey1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '*',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                readOnly: false,
                                height: 54,
                                controller:
                                    settingsProvider.fieldListController,
                                hintText: '',
                                labelText: '',
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  final text = settingsProvider
                                      .fieldListController.text
                                      .trim();
                                  if (text.isEmpty) return;

                                  if (settingsProvider.editingIndex != null) {
                                    settingsProvider.saveEditedItem(text);
                                  } else {
                                    settingsProvider.addFieldItem(text);
                                  }
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add '),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors
                                      .primaryBlue, // Change foreground color
                                  backgroundColor:
                                      Colors.white, // Change background color
                                  side: BorderSide(
                                      color: AppColors
                                          .primaryBlue), // Change border color
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Add border radius
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      const SizedBox(height: 16),
                      AppStyles.isWebScreen(context)
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: settingsProvider.fieldListItems.length,
                              itemBuilder: (context, index) {
                                final item =
                                    settingsProvider.fieldListItems[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      TextButton(
                                        onPressed: () {
                                          settingsProvider
                                              .startEditingItem(index);
                                        },
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.blue[400],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          settingsProvider
                                              .removeFieldItem(index);
                                        },
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red[400],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: settingsProvider.fieldListItems.length,
                              itemBuilder: (context, index) {
                                final item =
                                    settingsProvider.fieldListItems[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              settingsProvider
                                                  .startEditingItem(index);
                                            },
                                            icon: Icon(Icons.edit,
                                                size: 18,
                                                color: Colors.blue[400]),
                                            label: Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.blue[400],
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              settingsProvider
                                                  .removeFieldItem(index);
                                            },
                                            icon: Icon(Icons.delete,
                                                size: 18,
                                                color: Colors.red[400]),
                                            label: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red[400],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ]),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.fieldNameController.clear();
            settingsProvider.fieldTypeController.clear();
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final error = validateInputs(context, settingsProvider);
            if (error != null) {
              showErrorDialog(context, error);
              return;
            }

            CustomFieldModel customFieldTypeModel = CustomFieldModel();
            customFieldTypeModel.customFieldId =
                widget.isEdit ? widget.customFieldTypeModel!.customFieldId : 0;
            customFieldTypeModel.customFieldName =
                settingsProvider.fieldNameController.text;
            customFieldTypeModel.customFieldTypeId =
                settingsProvider.fieldNameid;

            // customFieldTypeModel.dropDownValues =
            //     settingsProvider.fieldListItems.map((e) => e).join(',');

            settingsProvider.saveCustomField(context, customFieldTypeModel);
            Navigator.pop(context);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
