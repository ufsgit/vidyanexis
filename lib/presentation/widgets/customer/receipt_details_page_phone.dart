import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/reciept_list_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_receipt_page_phone.dart';
import 'package:techtify/presentation/widgets/customer/expanded_text_widget.dart';
import 'package:techtify/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';
import 'package:techtify/utils/extensions.dart';

class ReceiptDetailsPagePhone extends StatefulWidget {
  static String route = '/receiptDetailsPage';
  final ReceiptListModel reciept;
  const ReceiptDetailsPagePhone({super.key, required this.reciept});

  @override
  State<ReceiptDetailsPagePhone> createState() =>
      _ReceiptDetailsPagePhoneState();
}

class _ReceiptDetailsPagePhoneState extends State<ReceiptDetailsPagePhone> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final settingsprovider = Provider.of<SettingsProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textGrey4,
              )),
        ),
        title: Text(
          'Receipt details',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack),
        ),
        actions: [
          if (settingsprovider.menuIsEditMap[18] == 1)
            CustomPopMenuButtonWidget(
              onOptionSelected: (PopupMenuOptions option) async {
                // Add async keyword here
                switch (option) {
                  case PopupMenuOptions.edit:
                    customerDetailsProvider.recieptAmountController.text =
                        widget.reciept.amount.toString();
                    customerDetailsProvider.recieptDescriptionController.text =
                        widget.reciept.description.toString();
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return AddReceiptPagePhone(
                            recieptId: widget.reciept.receiptId.toString(),
                            isEdit: true,
                            customerId: widget.reciept.customerId.toString());
                      },
                    ));
                    // showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true,
                    //   showDragHandle: false,
                    //   isDismissible: false,
                    //   backgroundColor: Colors.transparent,
                    //   builder: (BuildContext context) {
                    //     return Padding(
                    //       padding: EdgeInsets.only(
                    //           bottom: MediaQuery.of(context).viewInsets.bottom),
                    //       child: Wrap(
                    //         children: [
                    //           AddReceiptPagePhone(
                    //               recieptId:
                    //                   widget.reciept.receiptId.toString(),
                    //               isEdit: true,
                    //               customerId:
                    //                   widget.reciept.customerId.toString()),
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // );
                    break;
                  case PopupMenuOptions.delete:
                    showConfirmationDialog(
                      isLoading: customerDetailsProvider.isDeleteLoading,
                      context: context,
                      title: 'Confirm Deletion',
                      content: 'Are you sure you want to delete this Receipt?',
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                      onConfirm: () async {
                        await customerDetailsProvider.deleteReciept(
                            widget.reciept.receiptId.toString(),
                            widget.reciept.customerId.toString(),
                            context);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      confirmButtonText: 'Delete',
                      confirmButtonColor: Colors.red,
                    );
                    break;
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(color: AppColors.whiteColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                            height: 22,
                            width: 3,
                            decoration: BoxDecoration(
                                color: AppColors.appViolet,
                                borderRadius: BorderRadius.circular(16))),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          'Receipt name',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textBlack),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: ExpandableText(
                        text: widget.reciept.description,
                        maxLines: 2,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey3),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    CustomText(
                      "Total Amount",
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.textGrey4,
                    ),
                    CustomText(
                      "₹${widget.reciept.amount}",
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                      fontSize: 16,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3.withOpacity(.7)),
                        children: [
                          // const TextSpan(
                          //   text: "Created by ",
                          // ),
                          // TextSpan(
                          //   text: "${widget.reciept.customerId}",
                          //   style: GoogleFonts.plusJakartaSans(
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppColors.textGrey3),
                          // ),
                          // const TextSpan(
                          //   text: " on ",
                          // ),
                          TextSpan(
                            text:
                                widget.reciept.entryDate.toMonthDayYearFormat(),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey3),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
