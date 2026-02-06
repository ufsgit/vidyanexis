import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_expansion_tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_kre_pdf.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_label_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/quotation_details_printer_widget.dart';

class QuotationDetailsWidget extends StatelessWidget {
  final String customerId;
  final String serviceId;
  const QuotationDetailsWidget({
    super.key,
    required this.customerId,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quotation Details',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // if (settingsprovider.menuIsViewMap[32] == 1)
              //   CustomOutlinedSvgButton(
              //     onPressed: () async {
              //       await Loader.showLoader(context);
              //       await customerDetailsProvider.fetchLeadDetails(
              //           customerId, context);
              //       await settingsprovider.getCompanyDetails();

              //       await generateAndPrintPDFs(
              //           context: context,
              //           companyDetails: settingsprovider.companyDetails[0],
              //           customerDetails:
              //               customerDetailsProvider.leadDetails![0],
              //           quotationData:
              //               customerDetailsProvider.quotationListByMaster[0]);
              //       Loader.stopLoader(context);
              //     },
              //     svgPath: 'assets/images/Print.svg',
              //     label: 'Print',
              //     breakpoint: 860,
              //     foregroundColor: AppColors.primaryBlue,
              //     backgroundColor: Colors.white,
              //     borderSide: BorderSide(color: AppColors.primaryBlue),
              //   ),
              const SizedBox(width: 12),
              if (settingsprovider.menuIsEditMap[16] == 1)
                CustomOutlinedSvgButton(
                  onPressed: () async {
                    await customerDetailsProvider.getQuatationListByMasterId(
                        serviceId, context);
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
                    customerDetailsProvider.quotationDescriptionController
                        .text = quotation.description;
                    customerDetailsProvider.quotationDescription2Controller
                        .text = quotation.description2;
                    customerDetailsProvider.quotationDescription3Controller
                        .text = quotation.description3;

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
                    customerDetailsProvider.additionalStructureController.text =
                        quotation.additionalStructure.toString();

                    // ---- TOTALS ----
                    customerDetailsProvider.subtotalController.text =
                        quotation.totalAmount.toString();
                    customerDetailsProvider.totalController.text =
                        quotation.netTotal.toString();

                    // ---- ITEMS ----
                    customerDetailsProvider.updateItemsFromQuotationDetailsNew(
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
                    customerDetailsProvider.cableConductorClassController.text =
                        quotation.cableConductorClass;
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
                    customerDetailsProvider.moduleTechnologiesController.text =
                        quotation.moduleTechnologies;
                    customerDetailsProvider
                        .mountingStructureTechnologiesController
                        .text = quotation.mountingStructureTechnologies;
                    customerDetailsProvider.projectSchemeController.text =
                        quotation.projectScheme;
                    customerDetailsProvider.powerEvacuationController.text =
                        quotation.powerEvacuation;
                    customerDetailsProvider.areaApproximateController.text =
                        quotation.areaApproximate;
                    customerDetailsProvider.solarPlantOutputConnectionController
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
                            quotationId: serviceId,
                            isEdit: true,
                            customerId: customerId);
                      },
                    );
                  },
                  svgPath: 'assets/images/Edit.svg',
                  label: 'Edit',
                  breakpoint: 860,
                  foregroundColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  borderSide: BorderSide(color: AppColors.primaryBlue),
                ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              )
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          customerDetailsProvider.quotationListByMaster.isNotEmpty
              ? Container(
                  color: Colors.white,
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskLabelValue(
                          colorUser: AppColors.statusColor,
                          isAssignee: true,
                          label: 'Status',
                          value: customerDetailsProvider
                              .quotationListByMaster[0].quotationStatusName,
                          labelFontSize: 14,
                          labelFontWeight: FontWeight.w500,
                          valueFontSize: 14,
                          valueFontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(height: 16),

                        CustomExpansionTile(
                          title: 'Basic Details',
                          content: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Product Name:',
                                    style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textGrey3,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                      customerDetailsProvider
                                          .quotationListByMaster[0].productName,
                                      style: GoogleFonts.plusJakartaSans(
                                          color: AppColors.textBlack,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          buildItemRow('Item', 'Amount',
                                              textStyle:
                                                  GoogleFonts.plusJakartaSans(
                                                      color:
                                                          AppColors.textGrey3,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          // Items and Amounts
                                          customerDetailsProvider
                                                  .quotationListByMaster[0]
                                                  .quotationDetails
                                                  .isNotEmpty
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      customerDetailsProvider
                                                          .quotationListByMaster[
                                                              0]
                                                          .quotationDetails
                                                          .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return buildItemRow(
                                                        customerDetailsProvider
                                                            .quotationListByMaster[
                                                                0]
                                                            .quotationDetails[
                                                                index]
                                                            .itemName,
                                                        '₹${customerDetailsProvider.quotationListByMaster[0].quotationDetails[index].amount.toString()}',
                                                        textStyle: GoogleFonts
                                                            .plusJakartaSans(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .textBlack,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400));
                                                  },
                                                )
                                              : const SizedBox(),

                                          const SizedBox(
                                            height: 8,
                                          ),

                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: AppColors.textGrey2
                                                  .withOpacity(.5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: buildItemRow('Total',
                                                  '₹${customerDetailsProvider.quotationListByMaster[0].totalAmount}',
                                                  textStyle: GoogleFonts
                                                      .plusJakartaSans(
                                                          color: AppColors
                                                              .textGrey3,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          buildItemRow('Subsidy',
                                              '₹${customerDetailsProvider.quotationListByMaster[0].subsidyAmount}',
                                              textStyle:
                                                  GoogleFonts.plusJakartaSans(
                                                      color:
                                                          AppColors.textBlack,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12)),
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Container(
                                            height:
                                                AppStyles.isWebScreen(context)
                                                    ? 30
                                                    : null,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: AppColors.textGrey2
                                                  .withOpacity(.5),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: buildItemRow(
                                                  'Customer Amount to Pay',
                                                  '₹${customerDetailsProvider.quotationListByMaster[0].netTotal}',
                                                  textStyle: GoogleFonts
                                                      .plusJakartaSans(
                                                          color: AppColors
                                                              .textBlack,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.textGrey2.withOpacity(.5),
                        ),
                        // CustomExpansionTile: Terms and Conditions
                        CustomExpansionTile(
                          title: 'Terms and Conditions',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    customerDetailsProvider
                                        .quotationListByMaster[0]
                                        .termsAndConditions,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.textGrey2.withOpacity(.5),
                        ),
                        // CustomExpansionTile: Warranty
                        CustomExpansionTile(
                          title: 'Warranty',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    customerDetailsProvider
                                        .quotationListByMaster[0].warranty,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.textGrey2.withOpacity(.5),
                        ),
                        // CustomExpansionTile: Bill of Materials

                        CustomExpansionTile(
                          title: 'Bill of Materials',
                          content: customerDetailsProvider
                                  .quotationListByMaster[0]
                                  .billOfMaterials
                                  .isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.surfaceGrey,
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width -
                                              48,
                                    ),
                                    child: IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Header Row
                                          if (AppStyles.isWebScreen(context))
                                            Row(
                                              children: [
                                                _buildHeaderCell('Sl No', 60),
                                                _buildHeaderCell('Items', 120),
                                                _buildHeaderCell('Make', 250),
                                                _buildHeaderCell(
                                                    'Quantity', 100),
                                                _buildHeaderCell(
                                                    'Invoice No', 150),
                                                _buildFlexibleHeaderCell(
                                                    'Distributor'), // Using flexible header for last column
                                              ],
                                            ),
                                          const SizedBox(height: 16),
                                          if (customerDetailsProvider
                                              .quotationListByMaster[0]
                                              .billOfMaterials
                                              .isNotEmpty)
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: customerDetailsProvider
                                                  .quotationListByMaster[0]
                                                  .billOfMaterials
                                                  .length,
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const SizedBox(height: 10),
                                              itemBuilder: (context, index) {
                                                final item =
                                                    customerDetailsProvider
                                                        .quotationListByMaster[
                                                            0]
                                                        .billOfMaterials[index];
                                                return AppStyles.isWebScreen(
                                                        context)
                                                    ? Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          _buildContentCell(
                                                              '${index + 1}',
                                                              60),
                                                          _buildContentCell(
                                                              item.itemsAndDescription,
                                                              120),
                                                          _buildContentCell(
                                                              item.make, 250),
                                                          _buildContentCell(
                                                              item.quantity
                                                                  .toString(),
                                                              100),
                                                          _buildContentCell(
                                                              item.invoiceNo,
                                                              150),
                                                          _buildFlexibleContentCell(
                                                              item.distributor), // Using flexible content for last column
                                                        ],
                                                      )
                                                    //mobile design
                                                    : Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            buildMobileRow(
                                                                "Item Name",
                                                                item.itemsAndDescription),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: buildMobileRow(
                                                                      "Make",
                                                                      item.make),
                                                                ),
                                                                Expanded(
                                                                  child: buildMobileRow(
                                                                      "Quantity",
                                                                      item.quantity
                                                                          .toString()),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: buildMobileRow(
                                                                      "Invoice No",
                                                                      item.invoiceNo),
                                                                ),
                                                                Expanded(
                                                                  child: buildMobileRow(
                                                                      "Distributor",
                                                                      item.distributor),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  width: AppStyles.isWebScreen(context)
                      ? MediaQuery.of(context).size.width / 2
                      : MediaQuery.of(context).size.width,
                  height: MediaQuery.sizeOf(context).height / 1.5,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
        ],
      ),
    );
  }
}

Widget _buildHeaderCell(String text, double width) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textGrey3,
        ),
      ),
    ),
  );
}

Widget _buildFlexibleHeaderCell(String text) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textGrey3,
        ),
      ),
    ),
  );
}

Widget _buildContentCell(String text, double width) {
  return Padding(
    padding: const EdgeInsets.only(right: 16),
    child: SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    ),
  );
}

Widget _buildFlexibleContentCell(String text) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    ),
  );
}

Widget buildItemRow(String item, String amount, {TextStyle? textStyle}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          item,
          style: textStyle ?? GoogleFonts.plusJakartaSans(),
        ),
      ),
      Text(
        amount,
        style: textStyle ?? GoogleFonts.plusJakartaSans(),
      ),
    ],
  );
}

Widget buildMobileRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$title: ",
            style: TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.textGrey4)),
        Text(value,
            softWrap: true,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textBlack)),
      ],
    ),
  );
}
