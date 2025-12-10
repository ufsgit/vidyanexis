import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/models/quotaion_list_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/http/loader.dart';
import 'package:techtify/presentation/widgets/customer/add_quotation.dart';
import 'package:techtify/presentation/widgets/customer/pdf/print_kre_pdf.dart';
import 'package:techtify/presentation/widgets/customer/quotation_printer_edit_pdf.dart';
import 'package:techtify/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:techtify/presentation/widgets/home/quotation_details_printer_widget.dart';

class QuotationCard extends StatelessWidget {
  final String category;
  final String taskId;
  final String title;
  final String advancePercentage;
  final String deliveryPercentage;
  final String completionPercentage;

  final String statusId;
  final String createdBy;
  final String posted;
  final String status;
  final String servicename;
  final String customerId;
  final String warranty;
  final String terms;
  final String subsidy;
  final List<QuotationDetail> quotation_details;
  final List<BillOfMaterial> bill_of_materials;
  final List<ProductionChartModel> productionChartModel;

  const QuotationCard(
      {super.key,
      required this.category,
      required this.taskId,
      required this.title,
      required this.statusId,
      required this.createdBy,
      required this.posted,
      required this.status,
      required this.servicename,
      required this.customerId,
      required this.warranty,
      required this.terms,
      required this.subsidy,
      required this.quotation_details,
      required this.bill_of_materials,
      required this.advancePercentage,
      required this.deliveryPercentage,
      required this.completionPercentage,
      required this.productionChartModel});

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    Color statusColor = statusId == "1"
        ? Colors.orange
        : statusId == "2"
            ? Colors.green
            : Colors.red;

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
            Row(
              children: [
                // Image.asset(
                //   category == "1"
                //       ? 'assets/images/Task type=Site Visit.png'
                //       : category == "2"
                //           ? 'assets/images/Task type=Installation.png'
                //           : category == "3"
                //               ? 'assets/images/Task type=Service.png'
                //               : 'assets/images/Task type=AMC.png',
                //   height: 25,
                // ),
                // SizedBox(
                //   width: 10,
                // ),
                // Text('Service No: $serviceno',
                //     style: const TextStyle(
                //         fontWeight: FontWeight.w500, color: Colors.grey)),
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    )),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            ),
            // const SizedBox(height: 8.0),
            // Row(
            //   children: [
            //     Image.asset(
            //       'assets/images/task-02.png',
            //       width: 16,
            //       height: 16,
            //     ),
            //     SizedBox(
            //       width: 5,
            //     ),
            //     Text(title,
            //         style: const TextStyle(
            //             fontWeight: FontWeight.w500, color: Colors.grey)),
            //   ],
            // ),
            // const SizedBox(height: 8.0),
            Row(
              children: [
                // Image.asset(
                //   'assets/images/HardHat.png',
                //   width: 16,
                //   height: 16,
                // ),
                // SizedBox(
                //   width: 5,
                // ),
                const Text(
                  'Total Amount',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  ' ₹ $servicename',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                // SizedBox(
                //   width: 15,
                // ),
                // Image.asset(
                //   'assets/images/calendar-03.png',
                //   width: 16,
                //   height: 16,
                // ),
                // SizedBox(
                //   width: 5,
                // ),
                // Text(
                //   date != 'null' && date.isNotEmpty
                //       ? DateFormat('MMM dd, yyyy').format(DateTime.parse(date))
                //       : '',
                // ),
                const Spacer(),
                if (settingsprovider.menuIsViewMap[32] == 1)
                  CustomOutlinedSvgButton(
                    onPressed: () async {
                      await Loader.showLoader(context);
                      await customerDetailsProvider.getQuatationListByMasterId(
                          taskId, context);
                      await customerDetailsProvider.fetchLeadDetails(
                          customerId, context);
                      await settingsprovider.getCompanyDetails();
                      generateAndPrintPDFs(
                          context: context, //     companyDetails:
                          companyDetails: settingsprovider.companyDetails[0],
                          customerDetails:
                              customerDetailsProvider.leadDetails![0],
                          quotationData:
                              customerDetailsProvider.quotationListByMaster[0]);
                      // await QuotationPDFPrinter.printQuotationDialog(
                      //     title: 'Quotation',
                      //     companyDetails:
                      //         settingsprovider.companyDetails[0],
                      //     customerDetails:
                      //         customerDetailsProvider.leadDetails![0],
                      //     quotationData: customerDetailsProvider
                      //         .quotationListByMaster[0]);
                      Loader.stopLoader(context);
                    },
                    svgPath: 'assets/images/Print.svg',
                    label: 'Print',
                    breakpoint: 860,
                    foregroundColor: AppColors.primaryBlue,
                    backgroundColor: Colors.white,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                if (settingsprovider.menuIsEditMap[16] == 1)
                  IconButton(
                    onPressed: () async {
                      customerDetailsProvider.customerId = customerId;
                      customerDetailsProvider.qproductnameController.text =
                          title;
                      customerDetailsProvider.advanceController.text =
                          advancePercentage;
                      customerDetailsProvider.deliveryController.text =
                          deliveryPercentage;
                      customerDetailsProvider.workCompletionController.text =
                          completionPercentage;
                      customerDetailsProvider.qsubsidyAmountController.text =
                          subsidy;
                      customerDetailsProvider.qwarrentyController.text =
                          warranty;
                      customerDetailsProvider.qtermsConditionsController.text =
                          terms;
                      // customerDetailsProvider
                      //     .updateItemsFromQuotationDetails(
                      //         quotation_details,
                      //         bill_of_materials,
                      //         productionChartModel);
                      customerDetailsProvider.selectedQuotationStatus =
                          int.parse(statusId);
                      customerDetailsProvider.selectedQuotationStatusName =
                          status;
                      customerDetailsProvider.updateSubtotal();

                      await customerDetailsProvider.getQuatationListByMasterId(
                          taskId, context);
                      customerDetailsProvider.registrationFeeController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].ksebRegistrationFee
                              .toString();
                      customerDetailsProvider.feasibilityFeeController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].ksebFeasibilityFee
                              .toString();
                      customerDetailsProvider.systemPriceController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].ksebSystemPrice
                              .toString();
                      customerDetailsProvider
                              .additionalStructureController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].additionalStructure
                              .toString();
                      customerDetailsProvider.subtotalController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].totalAmount
                              .toString();
                      customerDetailsProvider.totalController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].netTotal
                              .toString();
                      customerDetailsProvider
                          .updateItemsFromQuotationDetailsNew(
                              customerDetailsProvider
                                  .quotationListByMaster[0].quotationDetails,
                              customerDetailsProvider
                                  .quotationListByMaster[0].billOfMaterials,
                              customerDetailsProvider
                                  .quotationListByMaster[0].productionChart);

                      final taxableAmount = double.tryParse(
                              customerDetailsProvider
                                  .quotationListByMaster[0].taxableAmount) ??
                          0.0;
                      final gstAmount = double.tryParse(customerDetailsProvider
                              .quotationListByMaster[0].gstAmount) ??
                          0.0;
                      final gstPer = double.tryParse(customerDetailsProvider
                              .quotationListByMaster[0].gstPer) ??
                          0.0;

                      customerDetailsProvider.gstTaxableAmountController.text =
                          taxableAmount.toStringAsFixed(2);
                      customerDetailsProvider.cgstTaxableAmountController.text =
                          (taxableAmount / 2).toStringAsFixed(2);
                      customerDetailsProvider.sgstTaxableAmountController.text =
                          (taxableAmount / 2).toStringAsFixed(2);

                      customerDetailsProvider.totalGstAmountController.text =
                          gstAmount.toStringAsFixed(2);
                      customerDetailsProvider.totalCgstAmountController.text =
                          (gstAmount / 2).toStringAsFixed(2);
                      customerDetailsProvider.totalSgstAmountController.text =
                          (gstAmount / 2).toStringAsFixed(2);

                      customerDetailsProvider.totalGstPerController.text =
                          gstPer.toStringAsFixed(2);
                      customerDetailsProvider.totalSgstPerController.text =
                          (gstPer / 2).toStringAsFixed(2);
                      customerDetailsProvider.totalCgstPerController.text =
                          (gstPer / 2).toStringAsFixed(2);

                      customerDetailsProvider.totalAdCESSController.text =
                          customerDetailsProvider
                              .quotationListByMaster[0].adCess
                              .toString();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return QuotationCreationWidget(
                              quotationId: taskId,
                              isEdit: true,
                              customerId: customerId);
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (settingsprovider.menuIsDeleteMap[16] == 1)
                  IconButton(
                      onPressed: () {
                        showConfirmationDialog(
                          isLoading: customerDetailsProvider.isDeleteLoading,
                          context: context,
                          title: 'Confirm Deletion',
                          content:
                              'Are you sure you want to delete this Quotation?',
                          onCancel: () {
                            Navigator.of(context).pop();
                          },
                          onConfirm: () {
                            customerDetailsProvider.deleteQuotation(
                                taskId, customerId, context);
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
                  posted != 'null' && posted.isNotEmpty
                      ? DateFormat('MMM dd, yyyy')
                          .format(DateTime.parse(posted))
                      : '',
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(
                  width: 5,
                ),
                Text(' . Created by : $createdBy'),
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
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndPrintPDF(BuildContext context) async {
    try {
      // Option 1: Load a static PDF from assets
      final ByteData assetData =
          await rootBundle.load('assets/images/cygnus.pdf');
      final Uint8List pdfBytes = assetData.buffer.asUint8List();

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Customer Report',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to generate or print PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
