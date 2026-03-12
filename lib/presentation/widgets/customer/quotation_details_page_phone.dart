import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_kre_pdf.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/presentation/pages/home/add_quotation_widget_mobile.dart';

import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/bom_item_card_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class QuotationDetailsPagePhone extends StatefulWidget {
  static String route = '/quotationDetails/';
  final String quotationId;
  final String category;
  final String title;
  final String statusId;
  final String createdBy;
  final String advance;
  final String completion;
  final String onDelivery;
  final String posted;
  final String status;
  final String servicename;
  final String customerId;
  final String warranty;
  final String terms;
  final String subsidy;
  final List<QuotationDetail> quotation_details;
  final List<BillOfMaterial> bill_of_materials;
  final List<ProductionChartModel> productiopnChart;
  final QuatationListModel quotation;

  const QuotationDetailsPagePhone(
      {super.key,
      required this.quotationId,
      required this.category,
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
      required this.advance,
      required this.completion,
      required this.onDelivery,
      required this.productiopnChart,
      required this.quotation});

  @override
  State<QuotationDetailsPagePhone> createState() =>
      _QuotationDetailsPagePhoneState();
}

class _QuotationDetailsPagePhoneState extends State<QuotationDetailsPagePhone> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getQuatationListByMasterId(
          widget.quotationId.toString(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: Text(
          'Quotation details',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack),
        ),
        actions: [
          if (settingsprovider.menuIsViewMap[55] == 1) ...[
            if (widget.quotation.quotationTypeId == 2)
              CustomOutlinedSvgButton(
                onPressed: () async {
                  await Loader.showLoader(context);
                  await customerDetailsProvider.getQuatationListByMasterId(
                      widget.quotationId, context);
                  await customerDetailsProvider.fetchLeadDetails(
                      widget.customerId, context);
                  await settingsprovider.getCompanyDetails();
                  printCommercialPDFs(
                      context: context, //     companyDetails:
                      companyDetails: settingsprovider.companyDetails[0],
                      customerDetails: customerDetailsProvider.leadDetails![0],
                      quotationData:
                          customerDetailsProvider.quotationListByMaster[0]);
                  Loader.stopLoader(context);
                },
                svgPath: 'assets/images/Print.svg',
                label: 'Print Commercial',
                breakpoint: 860,
                foregroundColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
            if (widget.quotation.quotationTypeId == 1)
              CustomOutlinedSvgButton(
                onPressed: () async {
                  await Loader.showLoader(context);
                  await customerDetailsProvider.getQuatationListByMasterId(
                      widget.quotationId, context);
                  await customerDetailsProvider.fetchLeadDetails(
                      widget.customerId, context);
                  await settingsprovider.getCompanyDetails();
                  printResidentialPDFs(
                      context: context, //     companyDetails:
                      companyDetails: settingsprovider.companyDetails[0],
                      customerDetails: customerDetailsProvider.leadDetails![0],
                      quotationData:
                          customerDetailsProvider.quotationListByMaster[0]);
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
          if (settingsprovider.menuIsViewMap[32] == 1)
            CustomOutlinedSvgButton(
              onPressed: () async {
                await Loader.showLoader(context);
                await customerDetailsProvider.getQuotationMasterPdf(
                    widget.quotationId, context);
                Loader.stopLoader(context);
              },
              svgPath: 'assets/images/Print.svg',
              label: 'Print Quotation 1',
              breakpoint: 860,
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              borderSide: BorderSide(color: AppColors.primaryBlue),
            ),
          CustomPopMenuButtonWidget(
            onOptionSelected: (PopupMenuOptions option) async {
              // Add async keyword here
              switch (option) {
                case PopupMenuOptions.edit:
                  await customerDetailsProvider.getQuatationListByMasterId(
                      widget.quotationId, context);
                  final quotation =
                      customerDetailsProvider.quotationListByMaster.first;

                  // ---- BASIC DETAILS ----
                  customerDetailsProvider.customerId = widget.customerId;
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
                  customerDetailsProvider.quotationDescriptionController.text =
                      quotation.description;
                  customerDetailsProvider.quotationDescription2Controller.text =
                      quotation.description2;
                  customerDetailsProvider.quotationDescription3Controller.text =
                      quotation.description3;

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
                  final taxable = double.tryParse(quotation.taxableAmount) ?? 0;
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
                  customerDetailsProvider.cableShortCircuitTempController.text =
                      quotation.cableShortCircuitTemp;
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
                  customerDetailsProvider.cableTensileStrengthController.text =
                      quotation.cableTensileStrength;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => QuotationCreationWidget(
                        customerId: widget.customerId,
                        quotationId: widget.quotationId,
                        isEdit: true,
                      ),
                    ),
                  );
                  break;
                case PopupMenuOptions.delete:
                  showConfirmationDialog(
                    context: context,
                    isLoading: customerDetailsProvider.isDeleteLoading,
                    title: 'Confirm Deletion',
                    content: 'Are you sure you want to delete this Quotation?',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      await customerDetailsProvider.deleteQuotation(
                          widget.quotationId, widget.customerId, context);
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                    },
                    confirmButtonText: 'Delete',
                    confirmButtonColor: Colors.red,
                  );

                  break;
              }
            },
          ),
        ],
      ),
      body: customerDetailsProvider.quotationListByMaster.isEmpty
          ? const Center(
              child: CustomText('No data'),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: StatusUtils.getStatusColor(2),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    child: Text(
                                      customerDetailsProvider
                                          .quotationListByMaster[0]
                                          .quotationStatusName,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: StatusUtils.getStatusTextColor(
                                              int.parse(widget.quotationId))),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomText(
                          customerDetailsProvider
                              .quotationListByMaster[0].productName,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        CustomText(
                          'Total Amount',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey4,
                        ),
                        CustomText(
                          '₹${customerDetailsProvider.quotationListByMaster[0].totalAmount}',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomText(
                          'Created by ${customerDetailsProvider.quotationListByMaster[0].createdBy}',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey4,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: AppColors.grey300,
                  ),
                  TileWidget(
                    leading: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Items summary',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: '',
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.scaffoldColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ListView.separated(
                                    itemCount: customerDetailsProvider
                                        .quotationListByMaster[0]
                                        .quotationDetails
                                        .length,
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(
                                        height: 10,
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return productRowItem(
                                        productName: customerDetailsProvider
                                            .quotationListByMaster[0]
                                            .quotationDetails[index]
                                            .itemName,
                                        quantity: customerDetailsProvider
                                            .quotationListByMaster[0]
                                            .quotationDetails[index]
                                            .quantity,
                                        price: customerDetailsProvider
                                            .quotationListByMaster[0]
                                            .quotationDetails[index]
                                            .MRP
                                            .toString(),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                            Container(
                              decoration:
                                  BoxDecoration(color: AppColors.whiteColor),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: [
                                    //     Expanded(
                                    //       child: CustomText(
                                    //         'Sub total',
                                    //         fontSize: 12,
                                    //         fontWeight: FontWeight.w500,
                                    //         color: AppColors.textGrey4,
                                    //       ),
                                    //     ),
                                    //     CustomText(
                                    //       '₹4,600',
                                    //       fontSize: 12,
                                    //       fontWeight: FontWeight.w600,
                                    //       color: AppColors.textBlack,
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            'Subsidy',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey4,
                                          ),
                                        ),
                                        CustomText(
                                          '₹${customerDetailsProvider.quotationListByMaster[0].subsidyAmount}',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      'Total',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  CustomText(
                                    '₹${customerDetailsProvider.quotationListByMaster[0].totalAmount}',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  TileWidget(
                    leading: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Terms and conditions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: '',
                    children: [
                      Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                          ),
                          decoration: BoxDecoration(
                              color: AppColors.scaffoldColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  CustomText(
                                    customerDetailsProvider
                                        .quotationListByMaster[0]
                                        .termsAndConditions,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textGrey3,
                                  ),
                                ],
                              ),
                            ),
                          ))
                    ],
                  ),
                  TileWidget(
                    leading: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Warranty',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: '',
                    children: [
                      Container(
                          constraints: const BoxConstraints(
                            maxHeight: 300,
                          ),
                          decoration: BoxDecoration(
                              color: AppColors.scaffoldColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Row(
                                children: [
                                  CustomText(
                                    customerDetailsProvider
                                        .quotationListByMaster[0].warranty,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textGrey3,
                                  ),
                                ],
                              ),
                            ),
                          ))
                    ],
                  ),
                  TileWidget(
                    leading: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Bill of materials',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: '',
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              color: AppColors.scaffoldColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ListView.separated(
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(
                                        height: 8,
                                      );
                                    },
                                    itemCount: customerDetailsProvider
                                        .quotationListByMaster[0]
                                        .billOfMaterials
                                        .length,
                                    shrinkWrap: true,
                                    physics: const ClampingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final item = customerDetailsProvider
                                          .quotationListByMaster[0]
                                          .billOfMaterials[index];
                                      return BomItemCardWidget(
                                        itemName: item.itemsAndDescription,
                                        quantity: item.quantity.toString(),
                                        make: item.make,
                                        distributor: item.distributor,
                                        comments: item.invoiceNo,
                                        uom: item.uom,
                                      );
                                    },
                                  )
                                ],
                              )))
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget productRowItem({
    required String productName,
    required int quantity,
    required String price,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: productName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlack,
                  ),
                ),
                TextSpan(
                  text: '\nx$quantity',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGrey4,
                  ),
                ),
              ],
            ),
          ),
        ),
        CustomText(
          price,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
      ],
    );
  }
}
