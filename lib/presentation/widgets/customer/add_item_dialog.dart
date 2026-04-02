import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class AddItemDialog extends StatefulWidget {
  final int index;
  final bool isEdit;

  const AddItemDialog({
    super.key,
    required this.index,
    this.isEdit = true,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEdit ? 'Edit Item' : 'Add Item',
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

              // Item Name
              CustomTextField(
                controller: provider.itemNameController,
                labelText: provider.getQuotationFieldName(1, 'Item Name'),
                hintText: provider.getQuotationFieldName(1, 'Item Name'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),

              // As Per Standard Warranty (MRP)
              CustomTextField(
                controller: provider.itemMrpController,
                labelText: provider.getQuotationFieldName(
                    2, 'As Per Standard Warranty'),
                hintText: provider.getQuotationFieldName(
                    2, 'As Per Standard Warranty'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),

              // As Per Standards (Unit Dropdown)
              CustomTextField(
                controller: provider.itemUnitController,
                labelText:
                    provider.getQuotationFieldName(3, 'As Per Standards'),
                hintText: provider.getQuotationFieldName(3, 'As Per Standards'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
              ),
              const SizedBox(height: 16),

              // Price
              CustomTextField(
                controller: provider.itemPriceController,
                labelText: provider.getQuotationFieldName(4, 'Price'),
                hintText: provider.getQuotationFieldName(4, 'Price'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                onChanged: (_) => provider.calculateTotalAmount(),
              ),
              const SizedBox(height: 16),

              // Quantity
              CustomTextField(
                controller: provider.itemQuantityController,
                labelText: provider.getQuotationFieldName(5, 'Quantity'),
                hintText: provider.getQuotationFieldName(5, 'Quantity'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => provider.calculateTotalAmount(),
              ),
              const SizedBox(height: 16),

              // GST %
              CustomTextField(
                controller: provider.itemGstPercentController,
                labelText: provider.getQuotationFieldName(6, 'GST %'),
                hintText: provider.getQuotationFieldName(6, 'GST %'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                onChanged: (_) => provider.calculateTotalAmount(),
              ),
              const SizedBox(height: 16),

              // GST (read-only)
              CustomTextField(
                controller: provider.itemGstController,
                labelText: provider.getQuotationFieldName(7, 'GST'),
                hintText: provider.getQuotationFieldName(7, 'GST'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Other Tax (Ad CESS)
              CustomTextField(
                controller: provider.itemAdCessController,
                labelText: provider.getQuotationFieldName(8, 'Other Tax'),
                hintText: provider.getQuotationFieldName(8, 'Other Tax'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                onChanged: (_) => provider.calculateTotalAmount(),
              ),
              const SizedBox(height: 16),

              // Amount (read-only)
              CustomTextField(
                controller: provider.itemTotalController,
                labelText: provider.getQuotationFieldName(9, 'Amount'),
                hintText: provider.getQuotationFieldName(9, 'Amount'),
                height: 54,
                borderRadius: 12,
                borderColor: const Color(0xFFD0D5DD),
                focusedBorderColor: AppColors.bluebutton,
                readOnly: true,
              ),
              const SizedBox(height: 24),

              // Action Buttons
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
                        // Validate required fields before calling provider
                        if (provider.itemNameController.text.trim().isEmpty ||
                            provider.itemPriceController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item Name and Price are required'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        provider.addOrEditItem(context);
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
            'Are you sure you want to delete this item?',
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
                provider.deleteItem(widget.index);
                Navigator.pop(context); // Close confirm dialog
                Navigator.pop(context); // Close item dialog
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
