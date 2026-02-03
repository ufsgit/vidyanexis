import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/payment_schedule_provider.dart';
import 'package:vidyanexis/controller/models/payment_schedule_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_payment_schedule.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class PaymentScheduleCard extends StatelessWidget {
  final PaymentScheduleModel schedule;
  final String customerId;
  const PaymentScheduleCard({
    super.key,
    required this.schedule,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final paymentScheduleProvider =
        Provider.of<PaymentScheduleProvider>(context);
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
                const Icon(Icons.description_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(
                  width: 5,
                ),
                Text(schedule.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text('Rs ${schedule.amount}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                if (settingsprovider.menuIsEditMap[18] ==
                    1) // Using mapping for Receipt as a proxy or if we have separate mapping
                  IconButton(
                    onPressed: () {
                      paymentScheduleProvider.setControllers(schedule);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AddPaymentScheduleWidget(
                              scheduleId: schedule.paymentScheduleId.toString(),
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
                          isLoading: paymentScheduleProvider.isLoading,
                          context: context,
                          title: 'Confirm Deletion',
                          content:
                              'Are you sure you want to delete this Payment Schedule?',
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                          onConfirm: () {
                            paymentScheduleProvider.deletePaymentSchedule(
                                schedule.paymentScheduleId.toString(),
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
                  schedule.scheduleDate != 'null' &&
                          schedule.scheduleDate.isNotEmpty
                      ? 'Schedule Date : ${DateFormat('MMM dd, yyyy').format(DateTime.parse(schedule.scheduleDate))}'
                      : 'Schedule Date : ',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
