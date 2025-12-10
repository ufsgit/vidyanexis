import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class AddReceiptPagePhone extends StatefulWidget {
  bool isEdit;
  String customerId;
  String recieptId;
  AddReceiptPagePhone(
      {super.key,
      required this.recieptId,
      required this.isEdit,
      required this.customerId});

  @override
  State<AddReceiptPagePhone> createState() => _AddReceiptPagePhoneState();
}

class _AddReceiptPagePhoneState extends State<AddReceiptPagePhone> {
  late FocusNode _leadNameFocusNode;
  late FocusNode statusNode;
  late FocusNode complaintNode;

  @override
  void initState() {
    _leadNameFocusNode = FocusNode();
    statusNode = FocusNode();
    complaintNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leadNameFocusNode.requestFocus();
    });
    super.initState();
  }

  // @override
  // void dispose() {
  //   _leadNameFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBarWidget(
        title: widget.isEdit ? 'Edit Payment' : 'Add Payment',
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
        onSavePressed: () async {
          if (customerDetailsProvider.recieptAmountController.text.isNotEmpty) {
            await customerDetailsProvider.saveReciept(
                widget.recieptId, widget.customerId, context);
            if (widget.isEdit) {
              Navigator.pop(context);
            }
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     RichText(
            //       text: TextSpan(
            //         style: GoogleFonts.plusJakartaSans(
            //           color: AppColors.textBlack,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         children: [
            //           TextSpan(
            //             text: widget.isEdit ? 'Edit Reciept' : 'Add Reciept',
            //           ),
            //         ],
            //       ),
            //     ),
            //     InkWell(
            //       onTap: () {
            //         Navigator.of(context).pop();
            //       },
            //       child: Icon(
            //         Icons.close,
            //         color: AppColors.textGrey4,
            //         size: 18,
            //       ),
            //     )
            //   ],
            // ),
            // const SizedBox(height: 16.0),
            CustomTextfieldWidgetMobile(
              focusNode: FocusNode(),
              readOnly: false,
              controller: customerDetailsProvider.recieptDescriptionController,
              labelText: 'Payment Title',
            ),
            const SizedBox(height: 16.0),
            CustomTextfieldWidgetMobile(
              focusNode: FocusNode(),
              keyBoardType: TextInputType.number,
              readOnly: false,
              controller: customerDetailsProvider.recieptAmountController,
              labelText: 'Amount',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            // SizedBox(height: 20),
            // SizedBox(
            //   height: 38,
            //   child: CustomElevatedButton(
            //     textSize: 14,
            //     radius: 12,
            //     isLoading: leadProvider.isSavingFollowup,
            //     buttonText: widget.isEdit ? 'Edit Receipt' : 'Add Receipt',
            //     onPressed: () async {
            //       if (customerDetailsProvider
            //           .recieptAmountController.text.isNotEmpty) {
            //         await customerDetailsProvider.saveReciept(
            //             widget.recieptId, widget.customerId, context);
            //         if (widget.isEdit) {
            //           Navigator.pop(context);
            //         }
            //       } else {
            //         showDialog(
            //           context: context,
            //           builder: (BuildContext context) {
            //             return AlertDialog(
            //               title: Text(
            //                 'Cannot save',
            //                 style: TextStyle(
            //                   color: AppColors.appViolet,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               ),
            //               content: const Text(
            //                 'Missing Details',
            //                 style: TextStyle(
            //                   color: Colors.black87,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //               shape: RoundedRectangleBorder(
            //                 borderRadius: BorderRadius.circular(15),
            //               ),
            //               actions: [
            //                 TextButton(
            //                   onPressed: () {
            //                     Navigator.pop(context);
            //                   },
            //                   child: Text(
            //                     'OK',
            //                     style: TextStyle(
            //                       color: AppColors.appViolet,
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 16,
            //                     ),
            //                   ),
            //                 ),
            //               ],
            //             );
            //           },
            //         );
            //       }
            //     },
            //     backgroundColor: AppColors.appViolet,
            //     borderColor: AppColors.appViolet,
            //     textColor: AppColors.whiteColor,
            //   ),
            // ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
