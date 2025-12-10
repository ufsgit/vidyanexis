import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/customer/reciept_card.dart';
import 'package:provider/provider.dart';

class ReceiptScreen extends StatefulWidget {
  String customerId;
  ReceiptScreen(this.customerId);

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
                  if (settingsProvider.menuIsSaveMap[18] == 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        customerDetailsProvider.customerId = widget.customerId;
                        customerDetailsProvider.clearRecieptDetails();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return RecieptCreationWidget(
                                recieptId: '0',
                                isEdit: false,
                                customerId: widget.customerId);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Receipt'),
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
                  itemCount: customerDetailsProvider.receiptList.length,
                  itemBuilder: (context, index) {
                    var reciept = customerDetailsProvider.receiptList[index];
                    return GestureDetector(
                      onTap: () {
                        // if (onTap != null) {
                        //   onTap(task.serviceId);
                        //   customerDetailsProvider
                        //       .setServiceEditDropDown(
                        //           task.serviceTypeId,
                        //           task.serviceTypeName,
                        //           task.serviceStatusId,
                        //           task.serviceStatusName);
                        //   customerDetailsProvider
                        //           .taskDescriptionController
                        //           .text =
                        //       task.description
                        //           .toString();
                        //   customerDetailsProvider
                        //           .serviceController
                        //           .text =
                        //       task.serviceName
                        //           .toString();
                        //   customerDetailsProvider
                        //           .serviceAmountController
                        //           .text =
                        //       task.amount.toString();
                        // }
                      },
                      child: ReceiptCard(
                          reciept: reciept, customerId: widget.customerId),
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
