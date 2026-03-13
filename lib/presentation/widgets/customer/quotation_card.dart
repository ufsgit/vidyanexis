import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/pages/home/edit_quotation_screen.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return QuotationDetailsWidget(
                serviceId: taskId,
                customerId: customerId,
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Status and Print Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3,
                          backgroundColor: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (quotation != null)
                    Row(
                      children: [
                        // Print Quotation 1 - ID 32
                        if (settingsprovider.menuIsViewMap[32] == 1)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Print Quotation 1',
                          icon: const Icon(Icons.print,
                              size: 22, color: Colors.blue),
                          onPressed: () async {
                            await Loader.showLoader(context);
                            await customerDetailsProvider.getQuotationMasterPdf(
                                quotation!.quotationMasterId.toString(),
                                context);
                            Loader.stopLoader(context);
                          },
                        ),
                      const SizedBox(width: 8),
                      // Print Commercial/Residential - ID 55
                      if (settingsprovider.menuIsViewMap[55] == 1)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: quotation?.quotationTypeId == 2
                              ? 'Print Commercial'
                              : 'Print Residential',
                          icon: const Icon(Icons.print_outlined,
                              size: 22, color: Colors.blue),
                            onPressed: () async {
                              await Loader.showLoader(context);
                              await customerDetailsProvider
                                  .getQuatationListByMasterId(
                                      quotation!.quotationMasterId.toString(),
                                      context);
                              await customerDetailsProvider.fetchLeadDetails(
                                  customerId, context);
                              await settingsprovider.getCompanyDetails();

                              if (settingsprovider.companyDetails.isNotEmpty &&
                                  (customerDetailsProvider
                                          .leadDetails?.isNotEmpty ??
                                      false) &&
                                  customerDetailsProvider
                                      .quotationListByMaster.isNotEmpty) {
                                if (quotation?.quotationTypeId == 2) {
                                  printCommercialPDFs(
                                      context: context,
                                      companyDetails:
                                          settingsprovider.companyDetails[0],
                                      customerDetails: customerDetailsProvider
                                          .leadDetails![0],
                                      quotationData: customerDetailsProvider
                                          .quotationListByMaster[0]);
                                } else {
                                  printResidentialPDFs(
                                      context: context,
                                      companyDetails:
                                          settingsprovider.companyDetails[0],
                                      customerDetails: customerDetailsProvider
                                          .leadDetails![0],
                                      quotationData: customerDetailsProvider
                                          .quotationListByMaster[0]);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Unable to load details for printing')),
                                );
                              }
                              Loader.stopLoader(context);
                            },
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              // Title
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              // Amount
              Row(
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹ ${quotation?.netTotal ?? '0'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Action Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (settingsprovider.menuIsEditMap[16] == 1)
                    CustomOutlinedSvgButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      onPressed: () async {
                        await customerDetailsProvider
                            .getQuatationListByMasterId(taskId, context);
                        final quotaion =
                            customerDetailsProvider.quotationListByMaster.first;

                        // ---- Population Logic ----
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
                        customerDetailsProvider
                            .qtermsConditionsController.text = terms;
                        customerDetailsProvider.quotationDescriptionController
                            .text = quotaion.description;
                        customerDetailsProvider.quotationDescription2Controller
                            .text = quotaion.description2;
                        customerDetailsProvider.quotationDescription3Controller
                            .text = quotaion.description3;

                        // ---- STATUS ----
                        customerDetailsProvider.selectedQuotationStatus =
                            quotaion.quotationStatusId;
                        customerDetailsProvider.selectedQuotationStatusName =
                            quotaion.quotationStatusName;

                        // ---- FEES ----
                        customerDetailsProvider.registrationFeeController.text =
                            quotaion.ksebRegistrationFee.toString();
                        customerDetailsProvider.feasibilityFeeController.text =
                            quotaion.ksebFeasibilityFee.toString();
                        customerDetailsProvider.systemPriceController.text =
                            quotaion.ksebSystemPrice.toString();
                        customerDetailsProvider.additionalStructureController
                            .text = quotaion.additionalStructure.toString();

                        // ---- TOTALS ----
                        customerDetailsProvider.subtotalController.text =
                            quotaion.totalAmount.toString();
                        customerDetailsProvider.totalController.text =
                            quotaion.netTotal.toString();

                        // ---- ITEMS ----
                        customerDetailsProvider
                            .updateItemsFromQuotationDetailsNew(
                          quotaion.quotationDetails,
                          quotaion.billOfMaterials,
                          quotaion.productionChart,
                        );

                        // ---- GST ----
                        final taxable =
                            double.tryParse(quotaion.taxableAmount) ?? 0;
                        final gst = double.tryParse(quotaion.gstAmount) ?? 0;
                        final gstPer = double.tryParse(quotaion.gstPer) ?? 0;

                        customerDetailsProvider.gstTaxableAmountController
                            .text = taxable.toStringAsFixed(2);
                        customerDetailsProvider.cgstTaxableAmountController
                            .text = (taxable / 2).toStringAsFixed(2);
                        customerDetailsProvider.sgstTaxableAmountController
                            .text = (taxable / 2).toStringAsFixed(2);

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
                            quotaion.quotationTypeName;
                        customerDetailsProvider.selectedQuotationType =
                            quotaion.quotationTypeId;

                        // ---- CABLE DETAILS ----
                        customerDetailsProvider.cableStructureController.text =
                            quotaion.cableStructure;
                        customerDetailsProvider.cableTypeController.text =
                            quotaion.cableType;
                        customerDetailsProvider.cableShortCircuitTempController
                            .text = quotaion.cableShortCircuitTemp;
                        customerDetailsProvider.cableStandardController.text =
                            quotaion.cableStandard;
                        customerDetailsProvider.cableConductorClassController
                            .text = quotaion.cableConductorClass;
                        customerDetailsProvider.cableMaterialController.text =
                            quotaion.cableMaterial;
                        customerDetailsProvider.cableProtectionController.text =
                            quotaion.cableProtection;
                        customerDetailsProvider.cableWarrantyController.text =
                            quotaion.cableWarranty;
                        customerDetailsProvider.cableTensileStrengthController
                            .text = quotaion.cableTensileStrength;

                        // ---- OTHER DETAILS ----
                        customerDetailsProvider.plantCapacityController.text =
                            quotaion.plantCapacity;
                        customerDetailsProvider.moduleTechnologiesController
                            .text = quotaion.moduleTechnologies;
                        customerDetailsProvider
                            .mountingStructureTechnologiesController
                            .text = quotaion.mountingStructureTechnologies;
                        customerDetailsProvider.projectSchemeController.text =
                            quotaion.projectScheme;
                        customerDetailsProvider.powerEvacuationController.text =
                            quotaion.powerEvacuation;
                        customerDetailsProvider.areaApproximateController.text =
                            quotaion.areaApproximate;
                        customerDetailsProvider
                            .solarPlantOutputConnectionController
                            .text = quotaion.solarPlantOutputConnection;
                        customerDetailsProvider.schemeController.text =
                            quotaion.scheme;
                        customerDetailsProvider.qvalidityController.text =
                            quotaion.validity;
                        customerDetailsProvider.qtendorNumberController.text =
                            quotaion.tendorNumber;
                        customerDetailsProvider.paymentTermsController.text =
                            quotaion.paymentTermsName;
                        customerDetailsProvider.incoTermsController.text =
                            quotaion.incoTerms;
                        customerDetailsProvider.shippingChargesController.text =
                            quotaion.shippingCharges;
                        customerDetailsProvider.totalAdCESSController.text =
                            quotaion.otherTax;
                        customerDetailsProvider.totalCgstAmountController.text =
                            quotaion.totalCgstAmount;
                        customerDetailsProvider.totalSgstAmountController.text =
                            quotaion.totalSgstAmount;

                        customerDetailsProvider.selectedBranchId =
                            quotaion.branchId;

                        customerDetailsProvider.commercialItems =
                            quotaion.commercialItems;

                        customerDetailsProvider.scopeOfWorkItems =
                            quotaion.scopeOfWorkItems;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return EditQuotationScreen(
                                  quotationId: taskId,
                                  customerId: customerId);
                            },
                          ),
                        );

                      },
                      svgPath: 'assets/images/Edit.svg',
                      label: 'Edit',
                      breakpoint: 300,
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  if (settingsprovider.menuIsDeleteMap[16] == 1)
                    CustomOutlinedSvgButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      onPressed: () {
                        showConfirmationDialog(
                          context: context,
                          title: 'Delete Quotation',
                          content:
                              'Are you sure you want to delete this quotation?',
                          isLoading: customerDetailsProvider.isDeleteLoading,
                          onCancel: () {
                            Navigator.pop(context);
                          },
                          onConfirm: () async {
                            await customerDetailsProvider.deleteQuotation(
                                taskId, customerId, context);
                            if (context.mounted) Navigator.pop(context);
                          },
                        );
                      },
                      svgPath: 'assets/images/Delete.svg',
                      label: 'Delete',
                      breakpoint: 300,
                      foregroundColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.05),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                ],
              ),
              const Divider(height: 32),
              // Footer
              Row(
                children: [
                  Text(
                    posted != 'null' && posted.isNotEmpty
                        ? DateFormat('MMM dd, yyyy')
                            .format(DateTime.parse(posted))
                        : '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• By: $createdBy',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.navigate_next_outlined,
                    color: Colors.grey,
                    size: 20,
                  )
                ],
              ),
            ],
          ),
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
