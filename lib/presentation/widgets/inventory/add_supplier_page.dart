import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/supplier_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddSupplier extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final SupplierModel? data;

  const AddSupplier({
    super.key,
    required this.isEdit,
    required this.editId,
    this.data,
  });

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
    if (settingsProvider.supplierNameController.text.trim().isEmpty) {
      return 'Please enter Supplier Name';
    }
    if (settingsProvider.supplierAddressController.text.trim().isEmpty) {
      return 'Please enter Supplier Address';
    }

    // if (settingsProvider.supplierOpeningBalanceController.text.trim().isEmpty) {
    //   return 'Please enter Supplier Opening Balance';
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
        settingsProvider.supplierNameController.text =
            widget.data?.supplierName ?? '';
        settingsProvider.supplierNameController.text =
            widget.data?.supplierName ?? '';
        settingsProvider.supplierAddressController.text =
            widget.data?.address ?? '';
        settingsProvider.supplierAddress1Controller.text =
            widget.data?.address1 ?? '';
        settingsProvider.supplierAddress2Controller.text =
            widget.data?.address2 ?? '';
        settingsProvider.supplierAddress3Controller.text =
            widget.data?.address3 ?? '';
        settingsProvider.supplierPhoneController.text =
            widget.data?.phoneNo ?? '';
        settingsProvider.supplierMobileController.text =
            widget.data?.mobileNo ?? '';
        settingsProvider.supplierEmailController.text =
            widget.data?.email ?? '';
        settingsProvider.supplierGstNoController.text =
            widget.data?.gstNo ?? '';
        settingsProvider.supplierOpeningBalanceController.text =
            widget.data?.openingBalance.toString() ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Supplier' : 'Add Supplier',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              settingsProvider.supplierClear();
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
            // Row with Supplier Name and Address
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierNameController,
                    hintText: 'Supplier Name*',
                    labelText: '',
                  ),
                ),
                // Space between the text fields
              ],
            ),
            const SizedBox(height: 10), // Space below the row

            // Row with Supplier Address1 and Address2
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierAddressController,
                    hintText: 'Address*',
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierAddress1Controller,
                    hintText: 'Address 1',
                    labelText: '',
                  ),
                ),
                // Space between the text fields
              ],
            ),
            const SizedBox(height: 10), // Space below the row

            // Row with Supplier Address3
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierAddress2Controller,
                    hintText: 'Address 2',
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierAddress3Controller,
                    hintText: 'Address 3',
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space below the row

            // Row with Supplier Phone and Mobile
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierPhoneController,
                    hintText: 'Phone',
                    labelText: '',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 10), // Space between the text fields
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierMobileController,
                    hintText: 'Mobile',
                    labelText: '',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space below the row

            // Supplier Email and GST No in a row
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierEmailController,
                    hintText: 'Email',
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 10), // Space between the text fields
                Expanded(
                  child: CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: settingsProvider.supplierGstNoController,
                    hintText: 'GST No',
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Space below the row

            // Supplier Opening Balance as a single field
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: settingsProvider.supplierOpeningBalanceController,
              hintText: 'Opening Balance',
              labelText: '',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        )),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            settingsProvider.supplierClear();
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

            settingsProvider.addSupplier(
              context: context,
              statusId: widget.editId,
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
