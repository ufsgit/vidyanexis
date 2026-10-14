import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/controller/models/reciept_list_model.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class ReceiptScreen extends StatefulWidget {
  String customerId;
  ReceiptScreen(this.customerId, {super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  CustomerDetailsProvider customerDetailsProvider =
      Provider.of<CustomerDetailsProvider>(navigatorKey.currentState!.context);
  SettingsProvider settingsProvider =
      Provider.of<SettingsProvider>(navigatorKey.currentState!.context);
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cdProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      // cdProvider.getRecieptListApi(widget.customerId.toString(), context); // Fetched by parent tab controller
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context);
    settingsProvider = Provider.of<SettingsProvider>(context);
    const borderColor = Color(0xFFE9EDF1);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor),
                      left: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderCell('#', width: 50),
                            _buildHeaderCell('Description', flex: 3),
                            _buildHeaderCell('Amount', flex: 2),
                            _buildHeaderCell('Posted On', flex: 2),
                            _buildHeaderCell('Approval', flex: 3),
                            _buildHeaderCell('Options', flex: 1),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: customerDetailsProvider.receiptList.length,
                          itemBuilder: (context, index) {
                            var reciept =
                                customerDetailsProvider.receiptList[index];
                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildDataCell((index + 1).toString(),
                                      width: 50),
                                  _buildDataCell(reciept.description,
                                      flex: 3, isBold: true),
                                  _buildDataCell('₹ ${reciept.amount}',
                                      flex: 2),
                                  _buildDataCell(
                                      reciept.entryDate != 'null' &&
                                              reciept.entryDate.isNotEmpty
                                          ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(reciept.entryDate))
                                          : '-',
                                      flex: 2),
                                  _buildWidgetCell(
                                    flex: 3,
                                    child: _buildApprovalStatusWidget(
                                        reciept, context),
                                  ),
                                  _buildWidgetCell(
                                    flex: 1,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (settingsProvider
                                                .menuIsEditMap[18] ==
                                            1)
                                          IconButton(
                                            tooltip: 'Edit',
                                            onPressed: () {
                                              customerDetailsProvider
                                                      .recieptAmountController
                                                      .text =
                                                  reciept.amount.toString();
                                              customerDetailsProvider
                                                      .recieptDescriptionController
                                                      .text =
                                                  reciept.description
                                                      .toString();
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return RecieptCreationWidget(
                                                      recieptId: reciept
                                                          .receiptId
                                                          .toString(),
                                                      isEdit: true,
                                                      customerId:
                                                          widget.customerId);
                                                },
                                              );
                                            },
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.blue),
                                          ),                                         if (settingsProvider
                                                .menuIsDeleteMap[18] ==
                                            1)
                                          IconButton(
                                            tooltip: 'Delete',
                                            onPressed: () {
                                              showConfirmationDialog(
                                                isLoading:
                                                    customerDetailsProvider
                                                        .isDeleteLoading,
                                                context: context,
                                                title: 'Confirm Deletion',
                                                content:
                                                    'Are you sure you want to delete this Receipt?',
                                                onCancel: () {
                                                  Navigator.of(context).pop();
                                                },
                                                onConfirm: () {
                                                  customerDetailsProvider
                                                      .deleteReciept(
                                                          reciept.receiptId
                                                              .toString(),
                                                          widget.customerId,
                                                          context);
                                                  Navigator.of(context).pop();
                                                },
                                                confirmButtonText: 'Delete',
                                                confirmButtonColor: Colors.red,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              size: 20,
                                              color: AppColors.textRed,
                                            ),
                                          ),
                                        if (reciept.reportPath.isNotEmpty)
                                          IconButton(
                                            tooltip: 'View Document',
                                            onPressed: () async {
                                              final String path =
                                                  reciept.reportPath.trim();
                                              final String fullUrl =
                                                  path.startsWith('http')
                                                      ? path
                                                      : HttpUrls.imgBaseUrl +
                                                          path;
                                              final Uri uri =
                                                  Uri.parse(fullUrl);
                                              try {
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri,
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                } else {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Could not open document'),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Error opening document: $e'),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.visibility_outlined,
                                              size: 20,
                                              color: Colors.teal,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalStatusWidget(
      ReceiptListModel reciept, BuildContext context) {
    if (reciept.adminApproval == 1) {
      final approverName = reciept.approvedByName?.isNotEmpty == true
          ? reciept.approvedByName!
          : 'admin';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Approved by $approverName',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Rejected by $rejecterName',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );
    } else {
      // Pending
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          if (settingsProvider.menuIsViewMap[216] == 1) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                final success = await customerDetailsProvider
                    .updateReceiptApprovalStatus(
                        reciept.receiptId.toString(), context, widget.customerId);
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
          if (settingsProvider.menuIsViewMap[217] == 1) ...[
            const SizedBox(width: 6),
            ElevatedButton(
              onPressed: () {
                _showRejectionDialog(
                    context,
                    reciept.receiptId.toString(),
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

  Widget _buildHeaderCell(String text, {int flex = 1, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF7D8B9B),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildDataCell(String text,
      {int flex = 1, bool isBold = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1}) {
    const borderColor = Color(0xFFE9EDF1);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }
}
