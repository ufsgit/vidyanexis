import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddExpenseWidget extends StatefulWidget {
  final bool isEdit;
  final String customerId;
  final String expenseId;

  const AddExpenseWidget({
    super.key,
    required this.expenseId,
    required this.isEdit,
    required this.customerId,
  });

  @override
  State<AddExpenseWidget> createState() => _AddExpenseWidgetState();
}

class _AddExpenseWidgetState extends State<AddExpenseWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getExpenseTypeApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Expense' : 'Add Expense',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                customerDetailsProvider.clearExpenseDetails();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<int>(
              initialValue: customerDetailsProvider.selectedExpenseType,
              items: customerDetailsProvider.expenseTypeList
                  .map((type) => DropdownMenuItem<int>(
                        value: type.expenseTypeId,
                        child: Text(
                          type.expenseTypeName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ))
                  .toList(),
              onChanged: (int? newValue) {
                customerDetailsProvider.selectedExpenseType = newValue;
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
              decoration: InputDecoration(
                label: RichText(
                  text: TextSpan(
                    text: 'Expense Type',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey3,
                    ),
                    children: const <TextSpan>[
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.textGrey2),
                ),
              ),
              isDense: true,
              iconSize: 18,
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.expenseAmountController,
                hintText: 'Amount*',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.expenseDescriptionController,
              hintText: 'Description',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearExpenseDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider
                    .expenseAmountController.text.isNotEmpty &&
                customerDetailsProvider.selectedExpenseType != null) {
              customerDetailsProvider.saveExpenseApi(
                  widget.expenseId, widget.customerId, context);
            } else {
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
                    content: const Text(
                      'Missing Details (Amount or Expense Type)',
                      style: TextStyle(
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
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
