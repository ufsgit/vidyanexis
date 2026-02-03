import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/payment_schedule_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddPaymentScheduleWidget extends StatelessWidget {
  final bool isEdit;
  final String customerId;
  final String scheduleId;
  const AddPaymentScheduleWidget(
      {super.key,
      required this.scheduleId,
      required this.isEdit,
      required this.customerId});

  @override
  Widget build(BuildContext context) {
    final paymentScheduleProvider =
        Provider.of<PaymentScheduleProvider>(context);
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            isEdit ? 'Edit Payment Schedule' : 'Add Payment Schedule',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                paymentScheduleProvider.clearControllers();
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
              'Schedule details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: true,
                height: 54,
                controller: paymentScheduleProvider.scheduleDateController,
                hintText: 'Schedule Date*',
                labelText: '',
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    paymentScheduleProvider.scheduleDateController.text =
                        formattedDate;
                  }
                },
                suffixIcon: const Icon(Icons.calendar_today)),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: paymentScheduleProvider.amountController,
                hintText: 'Amount*',
                labelText: '',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 16.0),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: paymentScheduleProvider.descriptionController,
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
            paymentScheduleProvider.clearControllers();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (paymentScheduleProvider.amountController.text.isNotEmpty &&
                paymentScheduleProvider
                    .scheduleDateController.text.isNotEmpty) {
              paymentScheduleProvider.savePaymentSchedule(
                  scheduleId, customerId, context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please fill all required fields')),
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
