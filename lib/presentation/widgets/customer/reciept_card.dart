import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/reciept_list_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_reciept.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';

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
        borderRadius: BorderRadius.circular(10),
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
}
