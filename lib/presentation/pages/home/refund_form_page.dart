import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_refund.dart';
import 'package:vidyanexis/presentation/widgets/customer/refund_card.dart';

class RefundFormPage extends StatefulWidget {
  String customerId;

  RefundFormPage(this.customerId, {super.key});

  @override
  State<RefundFormPage> createState() => _RefundFormPageState();
}

class _RefundFormPageState extends State<RefundFormPage> {
  CustomerDetailsProvider customerDetailsProvider =
      Provider.of<CustomerDetailsProvider>(navigatorKey.currentState!.context);
  SettingsProvider settingsProvider =
      Provider.of<SettingsProvider>(navigatorKey.currentState!.context);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cdProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      cdProvider.getRefundDetails(widget.customerId.toString(), context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Spacer(),
                  if (settingsProvider.menuIsSaveMap[71] == 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        customerDetailsProvider.customerId = widget.customerId;
                        customerDetailsProvider.clearRecieptDetails();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return RefundCreationWidget(
                                recieptId: '0',
                                isEdit: false,
                                customerId: widget.customerId);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Refund Form'),
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
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: customerDetailsProvider.refundList.length,
                  itemBuilder: (context, index) {
                    final refundData =
                        customerDetailsProvider.refundList[index];
                    return GestureDetector(
                      onTap: () {},
                      child: RefundCard(
                          refundData: refundData,
                          customerId: widget.customerId),
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
