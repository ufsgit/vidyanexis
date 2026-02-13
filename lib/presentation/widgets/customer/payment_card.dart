import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/payment_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class PaymentCard extends StatelessWidget {
  final PaymentModel payment;
  final String customerId;

  const PaymentCard({
    super.key,
    required this.payment,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    // Parse description to extract mode if formatted as "Mode - Description"
    String mode = payment.paymentModeName ?? "Unknown";
    String description = payment.description ?? "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy')
                      .format(DateTime.parse(payment.date.toString())),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Rs ${payment.payingAmount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.appViolet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.payment, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Mode: $mode",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                if (settingsprovider.menuIsDeleteMap[70] ==
                    1) // Assuming same permission as Payment Schedule for now
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showConfirmationDialog(
                        isLoading: customerDetailsProvider.isDeleteLoading,
                        context: context,
                        title: 'Confirm Deletion',
                        content:
                            'Are you sure you want to delete this Payment?',
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                        onConfirm: () {
                          customerDetailsProvider.deletePaymentApi(
                              payment.paymentId.toString(),
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
                      size: 20,
                      color: AppColors.textRed,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
