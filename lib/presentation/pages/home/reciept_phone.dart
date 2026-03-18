import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_receipt_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:provider/provider.dart';

class RecieptPhone extends StatefulWidget {
  String customerId;

  RecieptPhone(this.customerId, {super.key});

  @override
  State<RecieptPhone> createState() => _RecieptPhoneState();
}

class _RecieptPhoneState extends State<RecieptPhone> {
  CustomerDetailsProvider customerDetailsProvider =
      Provider.of<CustomerDetailsProvider>(navigatorKey.currentState!.context);
  SettingsProvider settingsProvider =
      Provider.of<SettingsProvider>(navigatorKey.currentState!.context);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cdProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      cdProvider.getRecieptListApi(widget.customerId.toString(), context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPaymentsContent(context),
          ],
        ),
      ),
      floatingActionButton: settingsProvider.menuIsSaveMap[18] == 1
          ? CustomElevatedButton(
              prefixIcon: Icons.add,
              radius: 32,
              buttonText: 'Add Receipt',
              onPressed: () {
                customerDetailsProvider.customerId = widget.customerId;
                customerDetailsProvider.clearRecieptDetails();
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return AddReceiptPagePhone(
                        recieptId: '0',
                        isEdit: false,
                        customerId: widget.customerId);
                  },
                ));

                // showDialog(
                //   context: context,
                //   barrierDismissible: false,
                //   builder: (BuildContext context) {
                //     return RecieptCreationWidget(
                //         recieptId: '0',
                //         isEdit: false,
                //         customerId: widget.customerId);
                //   },
                // );
              },
              backgroundColor: AppColors.bluebutton,
              borderColor: AppColors.bluebutton,
              textColor: AppColors.whiteColor,
            )
          : SizedBox(),
    );
  }

  Widget _buildPaymentsContent(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: customerDetailsProvider.receiptList.length,
          separatorBuilder: (context, index) =>
              Divider(thickness: 0.8, color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            var receipt = customerDetailsProvider.receiptList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content - payment details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              Image.asset('assets/images/payment_rupees.png')),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              receipt.description,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textBlack,
                              fontSize: 14,
                              maxLine: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            CustomText(
                              "By ${receipt.byUserName} on ${receipt.entryDate.toDayMonthYearFormat()}",
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGrey4,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      CustomText(
                        "+₹${receipt.amount}",
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF48A365),
                        fontSize: 12,
                      ),
                    ],
                  ),
                  // Bottom row with edit and delete buttons
                  Container(
                    alignment: Alignment.bottomRight,
                    child: Wrap(
                      spacing: 4,
                      children: [
                        if (settingsProvider.menuIsEditMap[18] == 1)
                          IconButton(
                            constraints:
                                BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onPressed: () {
                              // customerDetailsProvider.recieptAmountController
                              //     .text = receipt.amount.toString();
                              // customerDetailsProvider
                              //     .recieptDescriptionController
                              //     .text = receipt.description.toString();
                              // showDialog(
                              //   context: context,
                              //   barrierDismissible: false,
                              //   builder: (BuildContext context) {
                              //     return AddReceiptPagePhone(
                              //       recieptId: receipt.receiptId.toString(),
                              //       isEdit: true,
                              //       customerId: widget.customerId,
                              //     );
                              //   },
                              // );
                              customerDetailsProvider.recieptAmountController
                                  .text = receipt.amount.toString();
                              customerDetailsProvider
                                  .recieptDescriptionController
                                  .text = receipt.description.toString();
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return AddReceiptPagePhone(
                                      recieptId: receipt.receiptId.toString(),
                                      isEdit: true,
                                      customerId:
                                          receipt.customerId.toString());
                                },
                              ));
                            },
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        if (settingsProvider.menuIsDeleteMap[18] == 1)
                          IconButton(
                            constraints:
                                BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onPressed: () {
                              showConfirmationDialog(
                                isLoading:
                                    customerDetailsProvider.isDeleteLoading,
                                context: context,
                                title: 'Confirm Deletion',
                                content:
                                    'Are you sure you want to delete this Receipt?',
                                onCancel: () {
                                  Navigator.of(context).pop();
                                },
                                onConfirm: () {
                                  customerDetailsProvider.deleteReciept(
                                    receipt.receiptId.toString(),
                                    widget.customerId,
                                    context,
                                  );
                                  Navigator.of(context).pop();
                                },
                                confirmButtonText: 'Delete',
                                confirmButtonColor: Colors.red,
                              );
                            },
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.textRed,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
