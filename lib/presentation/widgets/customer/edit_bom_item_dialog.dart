import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class EditBomItemDialog extends StatefulWidget {
  final int index;
  final bool isEdit;

  const EditBomItemDialog({
    Key? key,
    required this.index,
    this.isEdit = true,
  }) : super(key: key);

  @override
  State<EditBomItemDialog> createState() => _EditBomItemDialogState();
}

class _EditBomItemDialogState extends State<EditBomItemDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Find the selected unit ID based on the text in the controller
    int? selectedUnitId;
    if (provider.billuomController.text.isNotEmpty) {
      try {
        selectedUnitId = settingsProvider.searchUnit
            .firstWhere(
              (u) => u.unitName == provider.billuomController.text,
            )
            .unitId;
      } catch (e) {
        // Unit not found in the list
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEdit ? 'Edit Material' : 'Add Material',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24),
              CustomTextField(
                controller: provider.billdescriptionController,
                labelText: provider.getQuotationFieldName(10, 'Equipment'),
                hintText: provider.getQuotationFieldName(10, 'Equipment'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billmakeController,
                labelText: provider.getQuotationFieldName(11, 'Specification'),
                hintText: provider.getQuotationFieldName(11, 'Specification'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: provider.billquantityController,
                      labelText: provider.getQuotationFieldName(12, 'Quantity'),
                      hintText: provider.getQuotationFieldName(12, 'Quantity'),
                      height: 54,
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CommonDropdown<int>(
                      hintText: 'UOM',
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                      items: settingsProvider.searchUnit
                          .map((unit) => DropdownItem<int>(
                                id: unit.unitId,
                                name: unit.unitName,
                              ))
                          .toList(),
                      onItemSelected: (value) {
                        setState(() {
                          provider.billuomController.text = settingsProvider
                              .searchUnit
                              .firstWhere((u) => u.unitId == value)
                              .unitName;
                        });
                      },
                      selectedValue: selectedUnitId,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billdistributorController,
                labelText: provider.getQuotationFieldName(13, 'Manufacturer'),
                hintText: provider.getQuotationFieldName(13, 'Manufacturer'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billinvoiceController,
                labelText: provider.getQuotationFieldName(14, 'Comments'),
                hintText: provider.getQuotationFieldName(14, 'Comments'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.isEdit) ...[
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Delete',
                        onPressed: () =>
                            _showDeleteConfirmation(context, provider),
                        backgroundColor: Colors.white,
                        borderColor: Colors.red[400]!,
                        textColor: Colors.red[400]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomElevatedButton(
                      buttonText: 'Save',
                      onPressed: () {
                        provider.addOrEditBillOfMaterialsItem();
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.appViolet,
                      borderColor: AppColors.appViolet,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, CustomerDetailsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete this material?',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteBillOfMaterialsItem(widget.index);
                Navigator.pop(context); // Close confirm
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
