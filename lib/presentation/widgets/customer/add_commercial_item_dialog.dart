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
              if (provider.isQuotationFieldVisible(88)) ...[
                CustomTextField(
                  controller: provider.commercialDescriptionController,
                  labelText: provider.getQuotationFieldName(88, 'Description'),
                  hintText: provider.getQuotationFieldName(88, 'Description'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  if (provider.isQuotationFieldVisible(89)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialDCCapacityController,
                        labelText: provider.getQuotationFieldName(
                            89, 'Solar Plant DC Capacity'),
                        hintText: provider.getQuotationFieldName(
                            89, 'Solar Plant DC Capacity'),
                        height: 54,
                        borderRadius: 12,
                        borderColor: const Color(0xFFD0D5DD),
                        focusedBorderColor: AppColors.bluebutton,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (provider.isQuotationFieldVisible(90)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialACCapacityController,
                        labelText: provider.getQuotationFieldName(
                            90, 'Solar Plant AC Capacity'),
                        hintText: provider.getQuotationFieldName(
                            90, 'Solar Plant AC Capacity'),
                        height: 54,
                        borderRadius: 12,
                        borderColor: const Color(0xFFD0D5DD),
                        focusedBorderColor: AppColors.bluebutton,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (provider.isQuotationFieldVisible(91)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialUnitPriceController,
                        labelText:
                            provider.getQuotationFieldName(91, 'Unit Price'),
                        hintText:
                            provider.getQuotationFieldName(91, 'Unit Price'),
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
                  ],
                  if (provider.isQuotationFieldVisible(92)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialTotalController,
                        labelText: provider.getQuotationFieldName(92, 'Total'),
                        hintText: provider.getQuotationFieldName(92, 'Total'),
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
                ],
              ),
              const SizedBox(height: 16),
              if (provider.isQuotationFieldVisible(93)) ...[
                CustomTextField(
                  controller: provider.commercialQtyController,
                  labelText: provider.getQuotationFieldName(93, 'Quantity'),
                  hintText: provider.getQuotationFieldName(93, 'Quantity'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  onChanged: (value) {
                    provider.calculateCommercialTotal();
                  },
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (provider.isQuotationFieldVisible(95)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialGSTPercController,
                        labelText: provider.getQuotationFieldName(95, 'GST %'),
                        hintText: provider.getQuotationFieldName(95, 'GST %'),
                        height: 54,
                        borderRadius: 12,
                        borderColor: const Color(0xFFD0D5DD),
                        focusedBorderColor: AppColors.bluebutton,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onChanged: (value) {
                          provider.calculateCommercialTotal();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (provider.isQuotationFieldVisible(94)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.commercialGSTController,
                        labelText: provider.getQuotationFieldName(94, 'GST'),
                        hintText: provider.getQuotationFieldName(94, 'GST'),
                        height: 54,
                        borderRadius: 12,
                        borderColor: const Color(0xFFD0D5DD),
                        focusedBorderColor: AppColors.bluebutton,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        readOnly: true,
                      ),
                    ),
                  ],
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
