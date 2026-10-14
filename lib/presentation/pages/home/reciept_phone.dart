import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_receipt_page_phone.dart';
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
      // cdProvider.getRecieptListApi(widget.customerId.toString(), context);
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
                            const SizedBox(height: 4),
                            if (receipt.adminApproval == 1)
                              Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Approved by ${receipt.approvedByName?.isNotEmpty == true ? receipt.approvedByName! : 'admin'}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else if (receipt.adminApproval == 2 ||
                                receipt.isRejected == 1 ||
                                (receipt.rejectionReason != null &&
                                    receipt.rejectionReason!.trim().isNotEmpty))
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.cancel_outlined,
                                          color: Colors.red, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Rejected by ${receipt.rejectedByName?.isNotEmpty == true ? receipt.rejectedByName! : 'admin'}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (receipt.rejectionReason != null &&
                                      receipt.rejectionReason!.trim().isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      receipt.rejectionReason!,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: Colors.amber.shade700,
                                      width: 0.8),
                                ),
                                child: Text(
                                  'Pending',
                                  style: TextStyle(
                                    color: Colors.amber.shade900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (receipt.adminApproval == 0 &&
                            receipt.isRejected != 1) ...[
                          if (settingsProvider.menuIsViewMap[216] == 1)
                            ElevatedButton(
                              onPressed: () async {
                                final success = await customerDetailsProvider
                                    .updateReceiptApprovalStatus(
                                        receipt.receiptId.toString(),
                                        context,
                                        widget.customerId);
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Status updated to Approved'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Approve',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          if (settingsProvider.menuIsViewMap[217] == 1)
                            ElevatedButton(
                              onPressed: () {
                                _showRejectionDialog(
                                    context,
                                    receipt.receiptId.toString(),
                                    widget.customerId,
                                    customerDetailsProvider);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Reject',
                                  style: TextStyle(fontSize: 11)),
                            ),
                        ],
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

  void _showRejectionDialog(
    BuildContext context,
    String receiptId,
    String customerId,
    CustomerDetailsProvider customerDetailsProvider,
  ) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text(
                'Reject Receipt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please provide a reason for rejecting this receipt:',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter rejection reason...',
                    hintStyle:
                        TextStyle(fontSize: 13, color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rejection reason is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final reason = reasonController.text.trim();
                  Navigator.pop(dialogContext);
                  final success = await customerDetailsProvider
                      .updateReceiptRejectionStatus(
                          receiptId, reason, context, customerId);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt rejected successfully'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
