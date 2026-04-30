import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class AddCommercialItemDialog extends StatefulWidget {
  final int index;
  final bool isEdit;

  const AddCommercialItemDialog({
    super.key,
    required this.index,
    this.isEdit = true,
  });

  @override
  State<AddCommercialItemDialog> createState() =>
      _AddCommercialItemDialogState();
}

class _AddCommercialItemDialogState extends State<AddCommercialItemDialog> {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEdit
                        ? 'Edit Commercial Item'
                        : 'Add Commercial Item',
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
                controller: provider.commercialDescriptionController,
                labelText: 'Description',
                hintText: 'Description',
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
                      controller: provider.commercialDCCapacityController,
                      labelText: 'Solar Plant DC Capacity',
                      hintText: 'Solar Plant DC Capacity',
                      height: 54,
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: provider.commercialACCapacityController,
                      labelText: 'Solar Plant AC Capacity',
                      hintText: 'Solar Plant AC Capacity',
                      height: 54,
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: provider.commercialUnitPriceController,
                      labelText: 'Unit Price',
                      hintText: 'Unit Price',
                      height: 54,
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: provider.commercialTotalController,
                      labelText: 'Total',
                      hintText: 'Total',
                      height: 54,
                      borderRadius: 12,
                      borderColor: const Color(0xFFD0D5DD),
                      focusedBorderColor: AppColors.bluebutton,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.isEdit) ...[
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Delete',
                        onPressed: () {
                          provider.deleteCommercialItem(widget.index);
                          Navigator.pop(context);
                        },
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
                        provider.addOrEditCommercialItem(context);
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
}
