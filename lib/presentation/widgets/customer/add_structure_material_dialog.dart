import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class AddStructureMaterialDialog extends StatefulWidget {
  final int index;
  final bool isEdit;

  const AddStructureMaterialDialog({
    super.key,
    required this.index,
    this.isEdit = true,
  });

  @override
  State<AddStructureMaterialDialog> createState() =>
      _AddStructureMaterialDialogState();
}

class _AddStructureMaterialDialogState
    extends State<AddStructureMaterialDialog> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                    widget.isEdit
                        ? 'Edit Structure Material'
                        : 'Add Structure Material',
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
              if (provider.isQuotationFieldVisible(50)) ...[
                CustomTextField(
                  controller: provider.structureItemsController,
                  labelText: provider.getQuotationFieldName(50, 'Items'),
                  hintText: provider.getQuotationFieldName(50, 'Items'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.isQuotationFieldVisible(51)) ...[
                CustomTextField(
                  controller: provider.structureQtyController,
                  labelText: provider.getQuotationFieldName(51, 'Quantity'),
                  hintText: provider.getQuotationFieldName(51, 'Quantity'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.isQuotationFieldVisible(52)) ...[
                CustomTextField(
                  controller: provider.structureBrandController,
                  labelText: provider.getQuotationFieldName(52, 'Brand'),
                  hintText: provider.getQuotationFieldName(52, 'Brand'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 16),
              ],
              if (provider.isQuotationFieldVisible(153)) ...[
                CustomTextField(
                  controller: provider.structureSpecificationController,
                  labelText:
                      provider.getQuotationFieldName(153, 'Specification'),
                  hintText: provider.getQuotationFieldName(153, 'Specification'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 24),
              ],
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
                        provider.addOrEditStructureMaterial();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete this structural material?',
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
                provider.deleteStructureMaterial(widget.index);
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
