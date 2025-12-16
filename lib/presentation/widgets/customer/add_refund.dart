import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class RefundCreationWidget extends StatelessWidget {
  bool isEdit;
  String customerId;
  String recieptId;
  RefundCreationWidget(
      {super.key,
      required this.recieptId,
      required this.isEdit,
      required this.customerId});

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
            isEdit ? 'Edit Refund Form' : 'Add Refund Form',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                customerDetailsProvider.clearRecieptDetails();
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
        // height: MediaQuery.sizeOf(context).height / 1.5,
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
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.electricalsectioncontroller,
                hintText: 'Electrical section*',
                labelText: '',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller:
                    customerDetailsProvider.electricalsectionplacecontroller,
                hintText: 'Place*',
                labelText: '',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.consumernumbercontroller,
                hintText: 'Consumer Number*',
                labelText: '',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.kwcapacitycontroller,
                hintText: 'KW Capacity*',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            Text(
              'Account details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.accountnamecontroller,
                hintText: 'Account Holds Name*',
                labelText: '',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.accountnumbercontroller,
                hintText: 'Acoount Number*',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.banknamecontroller,
                hintText: 'Bank Name*',
                labelText: '',
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.ifsccontroller,
                hintText: 'IFSC Code*',
                labelText: '',
                keyboardType: TextInputType.text),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearRecieptDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save11',
          onPressed: () async {
            if (customerDetailsProvider.ifsccontroller.text.isNotEmpty &&
                customerDetailsProvider
                    .electricalsectioncontroller.text.isNotEmpty &&
                customerDetailsProvider
                    .electricalsectionplacecontroller.text.isNotEmpty &&
                customerDetailsProvider
                    .consumernumbercontroller.text.isNotEmpty &&
                customerDetailsProvider.kwcapacitycontroller.text.isNotEmpty &&
                customerDetailsProvider.accountnamecontroller.text.isNotEmpty &&
                customerDetailsProvider
                    .accountnumbercontroller.text.isNotEmpty &&
                customerDetailsProvider.banknamecontroller.text.isNotEmpty) {
              customerDetailsProvider.saveRefund(
                  recieptId, customerId, context);
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
                      'Missing Details',
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
