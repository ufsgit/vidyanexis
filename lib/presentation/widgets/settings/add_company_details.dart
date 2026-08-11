import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

import 'package:vidyanexis/constants/app_styles.dart';

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

    Widget buildContent() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              if (!AppStyles.isWebScreen(context)) ...[
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cnameController,
                  hintText: 'Name',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cmobileController,
                  hintText: 'Mobile',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress1Controller,
                  hintText: 'Address',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress2Controller,
                  hintText: 'City',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress3Controller,
                  hintText: 'District',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.caddress4Controller,
                  hintText: 'State',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cphoneController,
                  hintText: 'Phone',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cemailController,
                  hintText: 'Email',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cgstNoController,
                  hintText: 'GST NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.cpanNoController,
                  hintText: 'PAN NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.ccinNoController,
                  hintText: 'CIN NO',
                  labelText: '',
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: false,
                  height: 54,
                  controller: settingsProvider.ccompanyCodeController,
                  hintText: 'Company Code',
                  labelText: '',
                ),
              ] else ...[
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 10),
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 10),
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 10),
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cgstNoController,
                        hintText: 'GST NO',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.cpanNoController,
                        hintText: 'PAN NO',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.ccinNoController,
                        hintText: 'CIN NO',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: settingsProvider.ccompanyCodeController,
                        hintText: 'Company Code',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              if (settingsProvider.companyDetails.isNotEmpty &&
                  settingsProvider.companyDetails[0].permissions.isNotEmpty) ...[
                ...settingsProvider.companyDetails[0].permissions.map((perm) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${perm.caption} :   ${perm.value == 1 ? "On" : "Off"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: perm.value == 1,
                          onChanged: (bool value) {
                            settingsProvider.updateCompanyPermission(
                                perm.companyPermissionId, value ? 1 : 0);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Location", "Location Check When End Task")}:   ${settingsProvider.toggleValue == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.toggleValue == 1,
                      onChanged: (bool value) {
                        settingsProvider.setToggleValue(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Enquiry For", "Enquiry For Mandatory")}:   ${settingsProvider.enquiryForMandatory == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.enquiryForMandatory == 1,
                      onChanged: (bool value) {
                        settingsProvider.setEnquiryForMandatory(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Enquiry Source", "Enquiry Source Mandatory")}:   ${settingsProvider.enquirySourceMandatory == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.enquirySourceMandatory == 1,
                      onChanged: (bool value) {
                        settingsProvider.setEnquirySourceMandatory(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Consumer Name", "Consumer Name")} :   ${settingsProvider.consumerNameMandatory == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.consumerNameMandatory == 1,
                      onChanged: (bool value) {
                        settingsProvider.setConsumerNameMandatory(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Contact No", "Contact No.")} :   ${settingsProvider.consumerContactNoMandatory == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.consumerContactNoMandatory == 1,
                      onChanged: (bool value) {
                        settingsProvider
                            .setConsumerContactNoMandatory(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Sales", "Lead In Sales")} :   ${settingsProvider.leadInSales == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.leadInSales == 1,
                      onChanged: (bool value) {
                        settingsProvider.setLeadInSales(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Quotation", "Quotation Item")} :   ${settingsProvider.quotationItem == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.quotationItem == 1,
                      onChanged: (bool value) {
                        settingsProvider.setQuotationItem(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Expense", "Additional Expense")} :   ${settingsProvider.additionalExpense == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.additionalExpense == 1,
                      onChanged: (bool value) {
                        settingsProvider.setAdditionalExpense(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("Commercial", "Commercial Proposal")} :   ${settingsProvider.commercialProposal == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.commercialProposal == 1,
                      onChanged: (bool value) {
                        settingsProvider.setCommercialProposal(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption("District", "District & City in Basic Details")} :   ${settingsProvider.districtCityMandatory == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.districtCityMandatory == 1,
                      onChanged: (bool value) {
                        settingsProvider.setDistrictCityMandatory(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption(2, "Lead Mobile Already Existed Check")} :   ${settingsProvider.leadMobileExistedCheck == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.leadMobileExistedCheck == 1,
                      onChanged: (bool value) {
                        settingsProvider.setLeadMobileExistedCheck(value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption(40, "Lead Permission ME and ALL")} :   ${settingsProvider.leadPermissionMeAndAll == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.leadPermissionMeAndAll == 1,
                      onChanged: (bool value) {
                        settingsProvider.updateCompanyPermission(40, value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption(41, "Customer Permission ME and ALL")} :   ${settingsProvider.customerPermissionMeAndAll == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.customerPermissionMeAndAll == 1,
                      onChanged: (bool value) {
                        settingsProvider.updateCompanyPermission(41, value ? 1 : 0);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '${settingsProvider.getPermissionCaption(42, "Task Permission ME and ALL")} :   ${settingsProvider.taskPermissionMeAndAll == 1 ? "On" : "Off"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: settingsProvider.taskPermissionMeAndAll == 1,
                      onChanged: (bool value) {
                        settingsProvider.updateCompanyPermission(42, value ? 1 : 0);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              CustomElevatedButton(
                buttonText: 'Upload Image',
                onPressed: () async {
                  await settingsProvider.addFile();
                },
                radius: 4,
                backgroundColor: AppColors.whiteColor,
                borderColor: const Color(0xFFE2E8F0),
                textColor: const Color(0xFF64748B),
              ),
              const SizedBox(height: 10),
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
                              onTap: () {},
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
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
              if (!AppStyles.isWebScreen(context)) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Cancel',
                        onPressed: () {
                          settingsProvider.enquiryForController.clear();
                          Navigator.pop(context);
                        },
                        radius: 4,
                        backgroundColor: AppColors.whiteColor,
                        borderColor: const Color(0xFFE2E8F0),
                        textColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Save',
                        onPressed: () async {
                          final validationError =
                              validateInputs(context, settingsProvider);
                          if (validationError != null) {
                            showErrorDialog(context, validationError);
                            return;
                          }
                          await settingsProvider.uploadImagesToAws(
                              '1', context);
                          await settingsProvider.saveCompanyDetails(
                            context: context,
                            companyId: widget.companyId,
                          );
                        },
                        radius: 4,
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      );
    }

    if (!AppStyles.isWebScreen(context)) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.isEdit ? 'Edit Company Details' : 'Add Company Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () {
              settingsProvider.enquiryForController.clear();
              Navigator.pop(context);
            },
          ),
        ),
        body: buildContent(),
      );
    }

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
      content: buildContent(),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.enquiryForController.clear();
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
            await settingsProvider.uploadImagesToAws('1', context);
            await settingsProvider.saveCompanyDetails(
              context: context,
              companyId: widget.companyId,
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
}
