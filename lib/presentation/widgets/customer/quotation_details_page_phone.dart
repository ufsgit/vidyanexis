import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_kre_pdf.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/presentation/pages/home/add_quotation_widget_mobile.dart';

import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
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
      required this.productiopnChart});

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
          if (settingsprovider.menuIsViewMap[32] == 1)
            CustomOutlinedSvgButton(
              onPressed: () async {
                await Loader.showLoader(context);
                await customerDetailsProvider.getQuatationListByMasterId(
                    widget.quotationId, context);
                await customerDetailsProvider.fetchLeadDetails(
                    widget.customerId, context);
                await settingsprovider.getCompanyDetails();
                generateAndPrintPDFs(
                    context: context, //     companyDetails:
                    companyDetails: settingsprovider.companyDetails[0],
                    customerDetails: customerDetailsProvider.leadDetails![0],
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
          CustomPopMenuButtonWidget(
            onOptionSelected: (PopupMenuOptions option) async {
              // Add async keyword here
              switch (option) {
                case PopupMenuOptions.edit:
                  customerDetailsProvider.customerId = widget.customerId;
                  customerDetailsProvider.qproductnameController.text =
                      widget.title;
                  customerDetailsProvider.advanceController.text =
                      widget.advance;
                  customerDetailsProvider.deliveryController.text =
                      widget.onDelivery;
                  customerDetailsProvider.workCompletionController.text =
                      widget.completion;
                  customerDetailsProvider.qsubsidyAmountController.text =
                      widget.subsidy;
                  customerDetailsProvider.qwarrentyController.text =
                      widget.warranty;
                  customerDetailsProvider.qtermsConditionsController.text =
                      widget.terms;
                  // customerDetailsProvider.updateItemsFromQuotationDetails(
                  //     widget.quotation_details,
                  //     widget.bill_of_materials,
                  //     widget.productiopnChart);
                  customerDetailsProvider.selectedQuotationStatus =
                      int.parse(widget.statusId);
                  customerDetailsProvider.selectedQuotationStatusName =
                      widget.status;

                  customerDetailsProvider.quotationStatusController.text =
                      widget.status;
                  customerDetailsProvider.updateSubtotal();
                  await customerDetailsProvider.getQuatationListByMasterId(
                      widget.quotationId, context);
                  customerDetailsProvider.subtotalController.text =
                      customerDetailsProvider
                          .quotationListByMaster[0].totalAmount
                          .toString();
                  customerDetailsProvider.totalController.text =
                      customerDetailsProvider.quotationListByMaster[0].netTotal
                          .toString();
                  customerDetailsProvider.updateItemsFromQuotationDetailsNew(
                      customerDetailsProvider
                          .quotationListByMaster[0].quotationDetails,
                      customerDetailsProvider
                          .quotationListByMaster[0].billOfMaterials,
                      customerDetailsProvider
                          .quotationListByMaster[0].productionChart);
                  final taxableAmount = double.tryParse(customerDetailsProvider
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
                      customerDetailsProvider.quotationListByMaster[0].adCess
                          .toString();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => AddQuotationWidgetMobile(
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
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: CustomText(
                                                  customerDetailsProvider
                                                      .quotationListByMaster[0]
                                                      .billOfMaterials[index]
                                                      .invoiceNo,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textGrey3,
                                                ),
                                              ),
                                              CustomText(
                                                customerDetailsProvider
                                                    .quotationListByMaster[0]
                                                    .billOfMaterials[index]
                                                    .itemsAndDescription,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textBlack,
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      'Quantity',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textGrey4,
                                                    ),
                                                  ),
                                                  CustomText(
                                                    customerDetailsProvider
                                                        .quotationListByMaster[
                                                            0]
                                                        .billOfMaterials[index]
                                                        .quantity
                                                        .toString(),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      'Make',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textGrey4,
                                                    ),
                                                  ),
                                                  CustomText(
                                                    customerDetailsProvider
                                                        .quotationListByMaster[
                                                            0]
                                                        .billOfMaterials[index]
                                                        .make,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: CustomText(
                                                      'Distributor',
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textGrey4,
                                                    ),
                                                  ),
                                                  CustomText(
                                                    customerDetailsProvider
                                                        .quotationListByMaster[
                                                            0]
                                                        .billOfMaterials[index]
                                                        .distributor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
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
