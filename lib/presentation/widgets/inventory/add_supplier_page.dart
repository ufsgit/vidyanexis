import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/supplier_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Supplier' : 'Add Supplier',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlue800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Basic Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierNameController,
                    hintText: 'Supplier Name*',
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Contact Information'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 56,
                          controller: settingsProvider.supplierPhoneController,
                          hintText: 'Phone',
                          labelText: '',
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 56,
                          controller: settingsProvider.supplierMobileController,
                          hintText: 'Mobile',
                          labelText: '',
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierEmailController,
                    hintText: 'Email Address',
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierGstNoController,
                    hintText: 'GST Number',
                    labelText: '',
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Address Details'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierAddressController,
                    hintText: 'Primary Address*',
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierAddress1Controller,
                    hintText: 'Address Line 1',
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierAddress2Controller,
                    hintText: 'Address Line 2',
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierAddress3Controller,
                    hintText: 'Address Line 3',
                    labelText: '',
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Financial Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: settingsProvider.supplierOpeningBalanceController,
                    hintText: 'Opening Balance',
                    labelText: '',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      settingsProvider.supplierClear();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }
}
