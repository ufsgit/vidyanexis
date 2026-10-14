import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/reciept_list_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptListModel reciept;
  final String customerId;
  const ReceiptCard({
    super.key,
    required this.reciept,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Row(
              children: [
                Image.asset(
                  'assets/images/task-02.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(reciept.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6.0),
            _buildApprovalSection(
                context, customerDetailsProvider, settingsprovider),
            const SizedBox(height: 8.0),
            AppStyles.isWebScreen(context)
                ? Row(
                    children: [
                      Text('Rs ${reciept.amount}'),
                      const SizedBox(
                        width: 15,
                      ),
                      const Spacer(),
                      if (settingsprovider.menuIsEditMap[18] == 1)
                        IconButton(
                          onPressed: () {
                            customerDetailsProvider.recieptAmountController
                                .text = reciept.amount.toString();
                            customerDetailsProvider.recieptDescriptionController
                                .text = reciept.description.toString();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return RecieptCreationWidget(
                                    recieptId: reciept.receiptId.toString(),
                                    isEdit: true,
                                    customerId: customerId);
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      if (settingsprovider.menuIsDeleteMap[18] == 1)
                        IconButton(
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
                                      reciept.receiptId.toString(),
                                      customerId,
                                      context);
                                  Navigator.of(context).pop();
                                },
                                confirmButtonText: 'Delete',
                                confirmButtonColor: Colors.red,
                              );
                            },
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.textRed,
                            )),
                      Text(
                        reciept.entryDate != 'null' &&
                                reciept.entryDate.isNotEmpty
                            ? 'Posted On : ${DateFormat('MMM dd, yyyy').format(DateTime.parse(reciept.entryDate))}'
                            : 'Posted On : ',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.navigate_next_outlined,
                        color: Colors.grey,
                        size: 30,
                      )
                    ],
                  )
                : Wrap(
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('Rs ${reciept.amount}'),
                      const SizedBox(
                        width: 15,
                      ),
                      if (settingsprovider.menuIsEditMap[18] == 1)
                        IconButton(
                          onPressed: () {
                            customerDetailsProvider.recieptAmountController
                                .text = reciept.amount.toString();
                            customerDetailsProvider.recieptDescriptionController
                                .text = reciept.description.toString();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return RecieptCreationWidget(
                                    recieptId: reciept.receiptId.toString(),
                                    isEdit: true,
                                    customerId: customerId);
                              },
                            );
                          },
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      if (settingsprovider.menuIsDeleteMap[18] == 1)
                        IconButton(
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
                                      reciept.receiptId.toString(),
                                      customerId,
                                      context);
                                  Navigator.of(context).pop();
                                },
                                confirmButtonText: 'Delete',
                                confirmButtonColor: Colors.red,
                              );
                            },
                            icon: Icon(
                              Icons.delete,
                              color: AppColors.textRed,
                            )),
                      Text(
                        reciept.entryDate != 'null' &&
                                reciept.entryDate.isNotEmpty
                            ? 'Posted On : ${DateFormat('MMM dd, yyyy').format(DateTime.parse(reciept.entryDate))}'
                            : 'Posted On : ',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      const Icon(
                        Icons.navigate_next_outlined,
                        color: Colors.grey,
                        size: 30,
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection(
      BuildContext context,
      CustomerDetailsProvider customerDetailsProvider,
      SettingsProvider settingsprovider) {
    if (reciept.adminApproval == 1) {
      final approverName = reciept.approvedByName?.isNotEmpty == true
          ? reciept.approvedByName!
          : 'admin';
      return Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            'Approved by $approverName',
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (reciept.adminApproval == 2 ||
        reciept.isRejected == 1 ||
        (reciept.rejectionReason != null &&
            reciept.rejectionReason!.trim().isNotEmpty)) {
      final rejecterName = reciept.rejectedByName?.isNotEmpty == true
          ? reciept.rejectedByName!
          : 'admin';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                'Rejected by $rejecterName',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (reciept.rejectionReason != null &&
              reciept.rejectionReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              reciept.rejectionReason!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
              ),
            ),
          ],
        ],
      );
    } else {
      // Pending
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.shade700, width: 0.8),
            ),
            child: Text(
              'Pending',
              style: TextStyle(
                color: Colors.amber.shade900,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (settingsprovider.menuIsViewMap[216] == 1) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final success = await customerDetailsProvider
                    .updateReceiptApprovalStatus(
                        reciept.receiptId.toString(), context, customerId);
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status updated to Approved'),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 11)),
            ),
          ],
          if (settingsprovider.menuIsViewMap[217] == 1) ...[
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () {
                _showRejectionDialog(context, customerDetailsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Reject', style: TextStyle(fontSize: 11)),
            ),
          ],
        ],
      );
    }
  }

  void _showRejectionDialog(
    BuildContext context,
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
                          reciept.receiptId.toString(),
                          reason,
                          context,
                          customerId);
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
