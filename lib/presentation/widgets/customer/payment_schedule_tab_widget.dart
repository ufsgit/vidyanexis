import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/payment_schedule_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_payment_schedule.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_schedule_card.dart';
import 'package:provider/provider.dart';

class PaymentScheduleTabWidget extends StatefulWidget {
  final String customerId;
  const PaymentScheduleTabWidget({super.key, required this.customerId});

  @override
  State<PaymentScheduleTabWidget> createState() =>
      _PaymentScheduleTabWidgetState();
}

class _PaymentScheduleTabWidgetState extends State<PaymentScheduleTabWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<PaymentScheduleProvider>(context, listen: false);
      provider.getPaymentScheduleList(widget.customerId, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final paymentScheduleProvider =
        Provider.of<PaymentScheduleProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  if (settingsProvider.menuIsSaveMap[18] ==
                      1) // Using 18 as proxy for now
                    ElevatedButton.icon(
                      onPressed: () {
                        paymentScheduleProvider.clearControllers();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AddPaymentScheduleWidget(
                                scheduleId: '0',
                                isEdit: false,
                                customerId: widget.customerId);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Schedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: AppStyles.isWebScreen(context)
                            ? const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12)
                            : const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 0),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: paymentScheduleProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : paymentScheduleProvider.paymentScheduleList.isEmpty
                        ? const Center(
                            child: Text('No Payment Schedules found'))
                        : ListView.builder(
                            itemCount: paymentScheduleProvider
                                .paymentScheduleList.length,
                            itemBuilder: (context, index) {
                              var schedule = paymentScheduleProvider
                                  .paymentScheduleList[index];
                              return PaymentScheduleCard(
                                schedule: schedule,
                                customerId: widget.customerId,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
