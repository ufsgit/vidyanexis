import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_kre_pdf.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_printer_edit_pdf.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/quotation_details_printer_widget.dart';

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
  final QuatationListModel? quotation;

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
      required this.productionChartModel,
      this.quotation});

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
                  ' ₹ ${quotation?.netTotal ?? '0'}',
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
                if (settingsprovider.menuIsViewMap[32] == 1) ...[
                  // New Print Button
                  CustomOutlinedSvgButton(
                    onPressed: () async {
                      await Loader.showLoader(context);
                      await customerDetailsProvider.getQuotationMasterPdf(
                          taskId, context);
                      Loader.stopLoader(context);
                    },
                    svgPath: 'assets/images/Print.svg',
                    label: 'Print',
                    breakpoint: 860,
                    foregroundColor: AppColors.primaryBlue,
                    backgroundColor: Colors.white,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 8),
                  if (quotation?.quotationTypeId == 2)
                    CustomOutlinedSvgButton(
                      onPressed: () async {
                        await Loader.showLoader(context);
                        await customerDetailsProvider
                            .getQuatationListByMasterId(taskId, context);
                        await customerDetailsProvider.fetchLeadDetails(
                            customerId, context);
                        await settingsprovider.getCompanyDetails();

                        if (settingsprovider.companyDetails.isNotEmpty &&
                            (customerDetailsProvider.leadDetails?.isNotEmpty ??
                                false) &&
                            customerDetailsProvider
                                .quotationListByMaster.isNotEmpty) {
                          printCommercialPDFs(
                              context: context, //     companyDetails:
                              companyDetails:
                                  settingsprovider.companyDetails[0],
                              customerDetails:
                                  customerDetailsProvider.leadDetails![0],
                              quotationData: customerDetailsProvider
                                  .quotationListByMaster[0]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Unable to load details for printing')),
                          );
                        }
                        Loader.stopLoader(context);
                      },
                      svgPath: 'assets/images/Print.svg',
                      label: 'Print Commercial',
                      breakpoint: 860,
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  if (quotation?.quotationTypeId == 1)
                    CustomOutlinedSvgButton(
                      onPressed: () async {
                        await Loader.showLoader(context);
                        await customerDetailsProvider
                            .getQuatationListByMasterId(taskId, context);
                        await customerDetailsProvider.fetchLeadDetails(
                            customerId, context);
                        await settingsprovider.getCompanyDetails();

                        if (settingsprovider.companyDetails.isNotEmpty &&
                            (customerDetailsProvider.leadDetails?.isNotEmpty ??
                                false) &&
                            customerDetailsProvider
                                .quotationListByMaster.isNotEmpty) {
                          printResidentialPDFs(
                              context: context, //     companyDetails:
                              companyDetails:
                                  settingsprovider.companyDetails[0],
                              customerDetails:
                                  customerDetailsProvider.leadDetails![0],
                              quotationData: customerDetailsProvider
                                  .quotationListByMaster[0]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Unable to load details for printing')),
                          );
                        }
                        Loader.stopLoader(context);
                      },
                      svgPath: 'assets/images/Print.svg',
                      label: 'Print Residential',
                      breakpoint: 860,
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                ],
                if (settingsprovider.menuIsEditMap[16] == 1)
                  IconButton(
                    onPressed: () async {
                      await customerDetailsProvider.getQuatationListByMasterId(
                          taskId, context);
                      final quotation =
                          customerDetailsProvider.quotationListByMaster.first;

                      // ---- BASIC DETAILS ----
                      customerDetailsProvider.customerId = customerId;
                      customerDetailsProvider.qproductnameController.text =
                          quotation.productName;
                      customerDetailsProvider.advanceController.text =
                          quotation.advancePercentage;
                      customerDetailsProvider.deliveryController.text =
                          quotation.onDeliveryPercentage;
                      customerDetailsProvider.workCompletionController.text =
                          quotation.workCompletionPercentage;
                      customerDetailsProvider.qsubsidyAmountController.text =
                          quotation.subsidyAmount;
                      customerDetailsProvider.qwarrentyController.text =
                          quotation.warranty;
                      customerDetailsProvider.qtermsConditionsController.text =
                          quotation.termsAndConditions;

                      // ---- STATUS ----
                      customerDetailsProvider.selectedQuotationStatus =
                          quotation.quotationStatusId;
                      customerDetailsProvider.selectedQuotationStatusName =
                          quotation.quotationStatusName;

                      // ---- FEES ----
                      customerDetailsProvider.registrationFeeController.text =
                          quotation.ksebRegistrationFee.toString();
                      customerDetailsProvider.feasibilityFeeController.text =
                          quotation.ksebFeasibilityFee.toString();
                      customerDetailsProvider.systemPriceController.text =
                          quotation.ksebSystemPrice.toString();
                      customerDetailsProvider.additionalStructureController
                          .text = quotation.additionalStructure.toString();

                      // ---- TOTALS ----
                      customerDetailsProvider.subtotalController.text =
                          quotation.totalAmount.toString();
                      customerDetailsProvider.totalController.text =
                          quotation.netTotal.toString();

                      // ---- ITEMS ----
                      customerDetailsProvider
                          .updateItemsFromQuotationDetailsNew(
                        quotation.quotationDetails,
                        quotation.billOfMaterials,
                        quotation.productionChart,
                      );

                      // ---- GST ----
                      final taxable =
                          double.tryParse(quotation.taxableAmount) ?? 0;
                      final gst = double.tryParse(quotation.gstAmount) ?? 0;
                      final gstPer = double.tryParse(quotation.gstPer) ?? 0;

                      customerDetailsProvider.gstTaxableAmountController.text =
                          taxable.toStringAsFixed(2);
                      customerDetailsProvider.cgstTaxableAmountController.text =
                          (taxable / 2).toStringAsFixed(2);
                      customerDetailsProvider.sgstTaxableAmountController.text =
                          (taxable / 2).toStringAsFixed(2);

                      customerDetailsProvider.totalGstAmountController.text =
                          gst.toStringAsFixed(2);
                      customerDetailsProvider.totalCgstAmountController.text =
                          (gst / 2).toStringAsFixed(2);
                      customerDetailsProvider.totalSgstAmountController.text =
                          (gst / 2).toStringAsFixed(2);

                      customerDetailsProvider.totalGstPerController.text =
                          gstPer.toStringAsFixed(2);
                      customerDetailsProvider.totalCgstPerController.text =
                          (gstPer / 2).toStringAsFixed(2);
                      customerDetailsProvider.totalSgstPerController.text =
                          (gstPer / 2).toStringAsFixed(2);

                      // ---- QUOTATION TYPE ----
                      customerDetailsProvider.quotationTypeController.text =
                          quotation.quotationTypeName;
                      customerDetailsProvider.selectedQuotationType =
                          quotation.quotationTypeId;

                      // ---- CABLE DETAILS ----
                      customerDetailsProvider.cableStructureController.text =
                          quotation.cableStructure;
                      customerDetailsProvider.cableTypeController.text =
                          quotation.cableType;
                      customerDetailsProvider.cableShortCircuitTempController
                          .text = quotation.cableShortCircuitTemp;
                      customerDetailsProvider.cableStandardController.text =
                          quotation.cableStandard;
                      customerDetailsProvider.cableConductorClassController
                          .text = quotation.cableConductorClass;
                      customerDetailsProvider.cableMaterialController.text =
                          quotation.cableMaterial;
                      customerDetailsProvider.cableProtectionController.text =
                          quotation.cableProtection;
                      customerDetailsProvider.cableWarrantyController.text =
                          quotation.cableWarranty;
                      customerDetailsProvider.cableTensileStrengthController
                          .text = quotation.cableTensileStrength;

                      // ---- OTHER DETAILS ----
                      customerDetailsProvider.plantCapacityController.text =
                          quotation.plantCapacity;
                      customerDetailsProvider.moduleTechnologiesController
                          .text = quotation.moduleTechnologies;
                      customerDetailsProvider
                          .mountingStructureTechnologiesController
                          .text = quotation.mountingStructureTechnologies;
                      customerDetailsProvider.projectSchemeController.text =
                          quotation.projectScheme;
                      customerDetailsProvider.powerEvacuationController.text =
                          quotation.powerEvacuation;
                      customerDetailsProvider.areaApproximateController.text =
                          quotation.areaApproximate;
                      customerDetailsProvider
                          .solarPlantOutputConnectionController
                          .text = quotation.solarPlantOutputConnection;
                      customerDetailsProvider.schemeController.text =
                          quotation.scheme;
                      customerDetailsProvider.qvalidityController.text =
                          quotation.validity;
                      customerDetailsProvider.qtendorNumberController.text =
                          quotation.tendorNumber;
                      customerDetailsProvider.paymentTermsController.text =
                          quotation.paymentTermsName;
                      customerDetailsProvider.incoTermsController.text =
                          quotation.incoTerms;
                      customerDetailsProvider.shippingChargesController.text =
                          quotation.shippingCharges;
                      customerDetailsProvider.totalAdCESSController.text =
                          quotation.otherTax;
                      customerDetailsProvider.totalCgstAmountController.text =
                          quotation.totalCgstAmount;
                      customerDetailsProvider.totalSgstAmountController.text =
                          quotation.totalSgstAmount;

                      customerDetailsProvider.commercialItems =
                          quotation.commercialItems;

                      customerDetailsProvider.scopeOfWorkItems =
                          quotation.scopeOfWorkItems;

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
