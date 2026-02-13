import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_payment_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_card.dart';

class PaymentTabWidget extends StatefulWidget {
  final String customerId;
  const PaymentTabWidget({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<PaymentTabWidget> createState() => _PaymentTabWidgetState();
}

class _PaymentTabWidgetState extends State<PaymentTabWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getPaymentListApi(widget.customerId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Filter logic if needed, but for now we show all "receipts" as payments
    // If we wanted to distinguish between "Receipt" and "Payment" strictly, we might need a dedicated flag in the backend or unique description prefix.
    // For this task, we assume all receipts shown here are payments.

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: customerDetailsProvider.isPaymentListLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (settingsProvider.menuIsSaveMap[18] == 1)
                        ElevatedButton.icon(
                          onPressed: () {
                            customerDetailsProvider.clearPaymentDetails();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AddPaymentWidget(
                                    customerId: widget.customerId);
                              },
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Payment"),
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
                ),
                Expanded(
                  child: customerDetailsProvider.paymentList.isEmpty
                      ? const Center(
                          child: Text(
                            "No payments found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: customerDetailsProvider.paymentList.length,
                          itemBuilder: (context, index) {
                            final payment =
                                customerDetailsProvider.paymentList[index];
                            return PaymentCard(
                              payment: payment,
                              customerId: widget.customerId,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
