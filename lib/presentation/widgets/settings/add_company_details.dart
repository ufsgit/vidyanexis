import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class AddCompanyDetails extends StatefulWidget {
  final bool isEdit;
  final String companyId;

  const AddCompanyDetails({
    super.key,
    required this.isEdit,
    required this.companyId,
  });

  @override
  State<AddCompanyDetails> createState() => _AddCompanyDetailsState();
}

class _AddCompanyDetailsState extends State<AddCompanyDetails> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    // if (settingsProvider.enquiryForController.text.trim().isEmpty) {
    //   return 'Please enter Enquiry For';
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

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
      });
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
            widget.isEdit ? 'Edit Company Details' : 'Add Company Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
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
        width: MediaQuery.sizeOf(context).width / 2,
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
                      controller: settingsProvider.cnameController,
                      hintText: 'Name',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.cmobileController,
                      hintText: 'Mobile',
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
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.caddress1Controller,
                      hintText: 'Address',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.caddress2Controller,
                      hintText: 'City',
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
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.caddress3Controller,
                      hintText: 'District',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.caddress4Controller,
                      hintText: 'State',
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
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.cphoneController,
                      hintText: 'Phone',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: settingsProvider.cemailController,
                      hintText: 'Email',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Location Check When End Task:   ${settingsProvider.toggleValue == 1 ? "On" : "Off"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: settingsProvider.toggleValue ==
                        1, // Convert int to bool
                    onChanged: (bool value) {
                      settingsProvider
                          .setToggleValue(value ? 1 : 0); // Convert bool to int
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CustomElevatedButton(
                buttonText: 'Upload Image',
                onPressed: () async {
                  await settingsProvider.addFile();
                },
                backgroundColor: AppColors.whiteColor,
                borderColor: AppColors.appViolet,
                textColor: AppColors.appViolet,
              ),
              const SizedBox(
                height: 10,
              ),
              settingsProvider.images.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      physics: const ClampingScrollPhysics(),
                      itemCount: settingsProvider.images.length,
                      itemBuilder: (context, index) {
                        final image = settingsProvider.images[index];
                        return Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                // Implement full-screen image view here
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  image,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () =>
                                    settingsProvider.removeImage(image),
                                child: const CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.delete,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    )
                  : Container(),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.enquiryForController.clear();
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
            await settingsProvider.uploadImagesToAws('1', context);

            settingsProvider.saveCompanyDetails(
              context: context,
              companyId: widget.companyId,
            );
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
