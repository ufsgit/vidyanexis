import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
      cdProvider.getRecieptListApi(widget.customerId.toString(), context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                                          ),
                                        if (settingsProvider
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
