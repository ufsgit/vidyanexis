import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/controller/models/enquiry_settings_model.dart';

class AddEnquirySource extends StatefulWidget {
  final bool isEdit;
  final String status;
  // final String sourceName;
  // final String sourceId;

  final String editId;
  final EnquirySourceModel? model;

  const AddEnquirySource({
    super.key,
    required this.isEdit,
    required this.status,
    // required this.sourceName,
    // required this.sourceId,
    required this.editId,
    this.model,
  });

  @override
  State<AddEnquirySource> createState() => _AddEnquirySourceState();
}

class _AddEnquirySourceState extends State<AddEnquirySource> {
  List<Map<String, dynamic>> selectedFields = [];
  bool _showMoreDetails = false;
  late final TextEditingController contactPersonController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController websiteController;
  late final TextEditingController phone2Controller;
  late final TextEditingController contact2Controller;
  late final TextEditingController addressController;
  late final TextEditingController descriptionController;

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

  @override
  void initState() {
    super.initState();
    final model = widget.model;
    contactPersonController =
        TextEditingController(text: model?.contactPerson ?? '');
    phoneController = TextEditingController(text: model?.phone ?? '');
    emailController = TextEditingController(text: model?.email ?? '');
    websiteController = TextEditingController(text: model?.website ?? '');
    phone2Controller = TextEditingController(text: model?.phone2 ?? '');
    contact2Controller = TextEditingController(text: model?.contact2 ?? '');
    addressController = TextEditingController(text: model?.address ?? '');
    descriptionController =
        TextEditingController(text: model?.description ?? '');

    _showMoreDetails = model != null && model.isMoreDetails == 1;

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
  void dispose() {
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    phone2Controller.dispose();
    contact2Controller.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.dispose();
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
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _showMoreDetails,
                    activeColor: AppColors.secondaryBlue,
                    onChanged: (bool? value) {
                      setState(() {
                        _showMoreDetails = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showMoreDetails = !_showMoreDetails;
                      });
                    },
                    child: Text(
                      'More Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
              if (_showMoreDetails) ...[
                const SizedBox(height: 12),
                if (AppStyles.isWebScreen(context)) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: contactPersonController,
                          hintText: 'Contact Person',
                          labelText: '',
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: phoneController,
                          hintText: 'Phone',
                          labelText: '',
                          maxLines: 1,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: emailController,
                          hintText: 'Email',
                          labelText: '',
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: websiteController,
                          hintText: 'Website',
                          labelText: '',
                          maxLines: 1,
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: phone2Controller,
                          hintText: 'Phone 2',
                          labelText: '',
                          maxLines: 1,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: contact2Controller,
                          hintText: 'Contact 2',
                          labelText: '',
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 80,
                    controller: addressController,
                    hintText: 'Address',
                    labelText: '',
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 100,
                    controller: descriptionController,
                    hintText: 'Description',
                    labelText: '',
                    minLines: 3,
                    maxLines: 6,
                  ),
                ] else ...[
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: contactPersonController,
                    hintText: 'Contact Person',
                    labelText: '',
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: phoneController,
                    hintText: 'Phone',
                    labelText: '',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: emailController,
                    hintText: 'Email',
                    labelText: '',
                    maxLines: 1,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: websiteController,
                    hintText: 'Website',
                    labelText: '',
                    maxLines: 1,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: phone2Controller,
                    hintText: 'Phone 2',
                    labelText: '',
                    maxLines: 1,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: contact2Controller,
                    hintText: 'Contact 2',
                    labelText: '',
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 80,
                    controller: addressController,
                    hintText: 'Address',
                    labelText: '',
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    readOnly: false,
                    height: 100,
                    controller: descriptionController,
                    hintText: 'Description',
                    labelText: '',
                    minLines: 3,
                    maxLines: 6,
                  ),
                ],
              ],
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

            settingsProvider.addEnquiryName(
              context: context,
              statusId: widget.editId,
              statusName: settingsProvider.enquirySourceController.text,
              isMoreDetails: _showMoreDetails ? 1 : 0,
              contactPerson:
                  _showMoreDetails ? contactPersonController.text : '',
              phone: _showMoreDetails ? phoneController.text : '',
              email: _showMoreDetails ? emailController.text : '',
              website: _showMoreDetails ? websiteController.text : '',
              phone2: _showMoreDetails ? phone2Controller.text : '',
              contact2: _showMoreDetails ? contact2Controller.text : '',
              address: _showMoreDetails ? addressController.text : '',
              description: _showMoreDetails ? descriptionController.text : '',
            );
          },
          radius: 4,
          backgroundColor: AppColors.secondaryBlue,
          borderColor: AppColors.secondaryBlue,
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
                                  borderRadius: BorderRadius.circular(4),
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
                                      activeThumbColor: Colors.blue.shade600,
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
}
