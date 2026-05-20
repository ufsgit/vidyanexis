import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_card.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_payment_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentTabWidget extends StatefulWidget {
  final String customerId;
  const PaymentTabWidget({super.key, required this.customerId});

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
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payments',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      if (Provider.of<SettingsProvider>(context, listen: false)
                              .menuIsSaveMap[81] ==
                          1)
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddPaymentWidget(
                                customerId: widget.customerId,
                              ),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
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
