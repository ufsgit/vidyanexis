import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class EditBomItemDialog extends StatelessWidget {
  final int index;
  final bool isEdit;

  const EditBomItemDialog({
    Key? key,
    required this.index,
    this.isEdit = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Material' : 'Add Material',
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
                hintText: 'Enter item description',
                height: 54,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billmakeController,
                labelText: provider.getQuotationFieldName(11, 'Specification'),
                hintText: 'Enter specification',
                height: 54,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: provider.billquantityController,
                      labelText: provider.getQuotationFieldName(12, 'Quantity'),
                      hintText: 'Scale/Qty',
                      height: 54,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: provider.billuomController,
                      labelText: 'UOM',
                      hintText: 'Unit of measure',
                      height: 54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billdistributorController,
                labelText: provider.getQuotationFieldName(13, 'Manufacturer'),
                hintText: 'Enter manufacturer info',
                height: 54,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.billinvoiceController,
                labelText: provider.getQuotationFieldName(14, 'Comments'),
                hintText: 'Add comments or invoice info',
                height: 54,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (isEdit) ...[
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
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteBillOfMaterialsItem(index);
                Navigator.pop(context); // Pop confirmation
                Navigator.pop(context); // Pop Edit dialog
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
