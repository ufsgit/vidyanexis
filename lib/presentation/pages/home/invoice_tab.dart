import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/invoice_tab_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_invoice_pdf.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_invoice_single_pdf.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_invoice_tab.dart';

class InvoiceTabPage extends StatefulWidget {
  final String customerId;

  const InvoiceTabPage({super.key, required this.customerId});

  @override
  State<InvoiceTabPage> createState() => _StockReturnPageState();
}

class _StockReturnPageState extends State<InvoiceTabPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final invoiceProvider =
          Provider.of<InvoiceTabProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      invoiceProvider.getInvoiceByCustomer(widget.customerId, context);
      customerDetailsProvider.getQuatationList(widget.customerId, context);

      customerDetailsProvider.getRecieptListApi(
          widget.customerId.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceTabProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 10,
            ),
            AppStyles.isWebScreen(context)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Updated print button onPressed method in InvoiceTabPage
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          await Loader.showLoader(context);

                          // Fetch customer details
                          await customerDetailsProvider.fetchLeadDetails(
                              widget.customerId, context);

                          await invoicePDFPrint(
                            context: context,
                            customerDetails:
                                customerDetailsProvider.leadDetails?[0],
                            quotationList: customerDetailsProvider
                                .quotationList, // Pass the invoice list
                            receiptList: customerDetailsProvider
                                .receiptList, // Pass the receipt list
                          );

                          Loader.stopLoader(context);
                        },
                        svgPath: 'assets/images/Print.svg',
                        label: 'Invoice Summary',
                        breakpoint: 860,
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AddInvoiceTab(
                                  editId: '0',
                                  isEdit: false,
                                  customerId: widget.customerId);
                            },
                          );
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'Add Invoice ',
                        breakpoint: 860,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          await Loader.showLoader(context);

                          // Fetch customer details
                          await customerDetailsProvider.fetchLeadDetails(
                              widget.customerId, context);

                          await invoicePDFPrint(
                            context: context,
                            customerDetails:
                                customerDetailsProvider.leadDetails?[0],
                            quotationList: customerDetailsProvider
                                .quotationList, // Pass the invoice list
                            receiptList: customerDetailsProvider
                                .receiptList, // Pass the receipt list
                          );

                          Loader.stopLoader(context);
                        },
                        svgPath: 'assets/images/Print.svg',
                        label: 'Invoice Summary',
                        breakpoint: 150,
                        foregroundColor: AppColors.primaryBlue,
                        backgroundColor: Colors.white,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: invoiceProvider.invoiceList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final invoice = invoiceProvider.invoiceList[index];
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
                          Text(
                            invoice.invoiceNumber,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Rs ${invoice.totalAmount}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              CustomOutlinedSvgButton(
                                onPressed: () async {
                                  await Loader.showLoader(context);

                                  // Fetch customer details
                                  await customerDetailsProvider
                                      .fetchLeadDetails(
                                          widget.customerId, context);

                                  // Get the current invoice from the list
                                  final currentInvoice =
                                      invoiceProvider.invoiceList[index];

                                  print(
                                      'Current invoice items count: ${currentInvoice.invoiceItems.length}');

                                  // If the current invoice doesn't have items, fetch them
                                  if (currentInvoice.invoiceItems.isEmpty) {
                                    await invoiceProvider.getInvoiceDetails(
                                        currentInvoice.invoiceMasterId,
                                        context);
                                    // Update the current invoice with the fetched details
                                    if (invoiceProvider
                                        .invoiceDetails.isNotEmpty) {
                                      final updatedInvoice =
                                          invoiceProvider.invoiceDetails.first;
                                      await invoiceSinglePDFPrint(
                                        context: context,
                                        customerDetails: customerDetailsProvider
                                            .leadDetails?[0],
                                        invoiceDetails: updatedInvoice,
                                      );
                                    }
                                  } else {
                                    // Use the existing invoice data
                                    await invoiceSinglePDFPrint(
                                      context: context,
                                      customerDetails: customerDetailsProvider
                                          .leadDetails?[0],
                                      invoiceDetails: currentInvoice,
                                    );
                                  }

                                  Loader.stopLoader(context);
                                },
                                svgPath: 'assets/images/Print.svg',
                                label: 'Print',
                                breakpoint: 860,
                                foregroundColor: AppColors.primaryBlue,
                                backgroundColor: Colors.white,
                                borderSide:
                                    BorderSide(color: AppColors.primaryBlue),
                              ),
                              // if (settingsprovider.menuIsEditMap[16] == 1)
                              IconButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AddInvoiceTab(
                                          isEdit: true,
                                          editId: invoice.invoiceMasterId,
                                          customerId: widget.customerId);
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              // if (settingsprovider.menuIsDeleteMap[16] == 1)
                              IconButton(
                                  onPressed: () {
                                    showConfirmationDialog(
                                      context: context,
                                      title: 'Confirm Deletion',
                                      content:
                                          'Are you sure you want to delete this Invoice?',
                                      onCancel: () {
                                        Navigator.of(context).pop();
                                      },
                                      onConfirm: () {
                                        invoiceProvider.deleteInvoice(
                                            invoice.invoiceMasterId,
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
                                    color: AppColors.textRed,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AppStyles.isWebScreen(context)
          ? null
          : CustomOutlinedSvgButton(
              onPressed: () async {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AddInvoiceTab(
                        editId: '0',
                        isEdit: false,
                        customerId: widget.customerId);
                  },
                );
              },
              breakpoint: 150,
              svgPath: 'assets/images/Plus.svg',
              label: 'Add Invoice ',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primaryBlue,
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
    );
  }
}
