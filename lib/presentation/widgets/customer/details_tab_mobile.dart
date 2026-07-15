import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/label_value_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/pages/home/kseb_print_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_agreement_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_feasibility_pdf.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'dart:typed_data';
import 'package:vidyanexis/utils/pdf_action_helper.dart';
import 'package:vidyanexis/http/loader.dart';

class DetailsTabMobile extends StatefulWidget {
  final String customerId;

  const DetailsTabMobile({
    super.key,
    required this.customerId,
  });

  @override
  State<DetailsTabMobile> createState() => _DetailsTabMobileState();
}

class _DetailsTabMobileState extends State<DetailsTabMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(
      context,
    );
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final sideProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: leadDetailsProvider.isFetchLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Documents & Actions Section
                    _buildStyledCard(
                      child: TileWidget(
                        title: 'Documents & Actions',
                        iconAssetPath:
                            'assets/images/icon_bookmark_details.png',
                        initiallyExpanded: false,
                        showDivider: false,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 12.0),
                            child: Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: [
                                if (settingsProvider.menuIsViewMap[61] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'KSEB',
                                    icon: Icons.electric_bolt_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'KSEB PDF',
                                        onGenerate: () async {
                                          return await generateKsebPdfBytes(
                                                customerDetails:
                                                    leadDetailsProvider
                                                        .leadDetails!.first,
                                                context: context,
                                              ) ??
                                              Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[63] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Vendor Agreement',
                                    icon: Icons.handshake_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Vendor Agreement',
                                        onGenerate: () async {
                                          return await generateVendorAgreementPdfBytes(
                                                customerDetails:
                                                    leadDetailsProvider
                                                        .leadDetails!.first,
                                                context: context,
                                              ) ??
                                              Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[62] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Vendor Feasibility',
                                    icon: Icons.fact_check_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Vendor Feasibility',
                                        onGenerate: () async {
                                          return await generateRtsFeasibilityReportPdfBytes(
                                                customerDetails:
                                                    leadDetailsProvider
                                                        .leadDetails!.first,
                                                context: context,
                                              ) ??
                                              Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[101] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Annexure 1',
                                    icon: Icons.description_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Annexure 1',
                                        pdfUrl:
                                            '${HttpUrls.getPdfAnnexure1}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfAnnexure1}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[102] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Annexure 2',
                                    icon: Icons.description_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Annexure 2',
                                        pdfUrl:
                                            '${HttpUrls.getPdfAnnexure2}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfAnnexure2}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[103] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Annexure 3',
                                    icon: Icons.description_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Annexure 3',
                                        pdfUrl:
                                            '${HttpUrls.getPdfAnnexure3}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfAnnexure3}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[105] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Net Meter',
                                    icon: Icons.history_edu_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Net Meter Agreement',
                                        pdfUrl:
                                            '${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[106] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'MNRE Agreement',
                                    icon: Icons.gavel_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'MNRE Agreement',
                                        pdfUrl:
                                            '${HttpUrls.getPdfMnreAgreement}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfMnreAgreement}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[107] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Loan Agreement',
                                    icon: Icons.account_balance_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Loan Agreement',
                                        pdfUrl:
                                            '${HttpUrls.getPdfLoanAgreement}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfLoanAgreement}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[108] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Schedule',
                                    icon: Icons.calendar_month_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Schedule',
                                        pdfUrl:
                                            '${HttpUrls.getPdfSchedule}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfSchedule}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[109] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Completion Report',
                                    icon: Icons.assignment_turned_in_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Completion Report',
                                        pdfUrl:
                                            '${HttpUrls.getPdfCompletionReport}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfCompletionReport}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[110] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'KSEB Net Meter',
                                    icon: Icons.electric_bolt_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'KSEB Net Meter',
                                        pdfUrl:
                                            '${HttpUrls.getPdfKsebNetMeter}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfKsebNetMeter}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[111] == 1)
                                  _buildActionBtn(
                                    context,
                                    text: 'Agreement A3s',
                                    icon: Icons.handshake_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Vendor Agreement A3s',
                                        pdfUrl:
                                            '${HttpUrls.getPdfVendorAgreement}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfVendorAgreement}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if (settingsProvider.menuIsViewMap[112] == 1 &&
                                    sideProvider.name != 'Lead /')
                                  _buildActionBtn(
                                    context,
                                    text: 'Warranty',
                                    icon: Icons.verified_user_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Warranty',
                                        pdfUrl:
                                            '${HttpUrls.getPdfWarranty}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfWarranty}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if ((settingsProvider.menuIsViewMap[163] == 1 || settingsProvider.menuIsViewMapPrint[163] == 1) && sideProvider.name != 'Lead /')
                                  _buildActionBtn(
                                    context,
                                    text: 'Work Completion Report',
                                    icon: Icons.assignment_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Work Completion Report',
                                        pdfUrl:
                                            '${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                                if ((settingsProvider.menuIsViewMap[164] == 1 || settingsProvider.menuIsViewMapPrint[164] == 1) && sideProvider.name != 'Lead /')
                                  _buildActionBtn(
                                    context,
                                    text: 'Checklist',
                                    icon: Icons.checklist_rtl_outlined,
                                    onTap: () async {
                                      PdfActionHelper.showPdfOptions(
                                        context: context,
                                        title: 'Checklist',
                                        pdfUrl:
                                            '${HttpUrls.getPdfChecklist}${widget.customerId}',
                                        onGenerate: () async {
                                          await Loader.showLoader(context);
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getAnnexurePdfBytes(
                                                      '${HttpUrls.getPdfChecklist}${widget.customerId}');
                                          Loader.stopLoader(context);
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStyledCard(
                      child: TileWidget(
                        initiallyExpanded: true,
                        title: 'Basic details',
                        iconAssetPath: 'assets/images/icon_profile_details.png',
                        showDivider: false,
                        children: [
                          LabelValueWidget(
                            label: 'Name',
                            value: leadDetailsProvider
                                .leadDetails![0].customerName,
                          ),
                          const SizedBox(height: 8),
                          LabelValueWidget(
                            label: 'Enquiry source',
                            value: dropDownProvider.getEnquirySourceNameById(
                                leadDetailsProvider
                                    .leadDetails![0].enquirySourceId,
                                leadDetailsProvider
                                    .leadDetails![0].enquirySourceName),
                          ),
                          const SizedBox(height: 8),
                          if (leadDetailsProvider
                              .leadDetails![0].referenceName.isNotEmpty)
                            LabelValueWidget(
                              label: 'Sub Source',
                              value: leadDetailsProvider
                                  .leadDetails![0].referenceName,
                            ),
                          if (leadDetailsProvider
                              .leadDetails![0].referenceName.isNotEmpty)
                            const SizedBox(height: 8),
                          LabelValueWidget(
                            label: 'Mobile no',
                            value: leadDetailsProvider
                                .leadDetails![0].contactNumber
                                .toString(),
                          ),
                          // const SizedBox(height: 8),
                          // LabelValueWidget(
                          //   label: 'Email id',
                          //   value: leadDetailsProvider.leadDetails![0].email,
                          // ),
                          const SizedBox(height: 8),
                          LabelValueWidget(
                            label: 'Enquiry for',
                            value: dropDownProvider.getEnquiryForNameById(
                                leadDetailsProvider
                                    .leadDetails![0].enquiryForId,
                                leadDetailsProvider
                                    .leadDetails![0].enquiryForName),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // Address
                    _buildStyledCard(
                      child: TileWidget(
                        title: 'Address',
                        iconAssetPath:
                            'assets/images/icon_location_details.png',
                        showDivider: false,
                        children: [
                          LabelValueWidget(
                            label: 'Address',
                            value: leadDetailsProvider.leadDetails![0].address,
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () => _openMaps(
                                leadDetailsProvider.leadDetails![0].location),
                            child: LabelValueWidget(
                              label: 'Location',
                              labelColor: AppColors.bluebutton,
                              value:
                                  leadDetailsProvider.leadDetails![0].location,
                            ),
                          ),
                          SizedBox(height: 8),
                          // LabelValueWidget(
                          //   label: 'City',
                          //   value: leadDetailsProvider.leadDetails![0].address2 ??
                          //       "",
                          // ),
                          // SizedBox(height: 8),
                          // LabelValueWidget(
                          //   label: 'District',
                          //   value: leadDetailsProvider.leadDetails![0].address3 ??
                          //       "",
                          // ),
                          // SizedBox(height: 8),
                          // LabelValueWidget(
                          //   label: 'Pin code',
                          //   value: leadDetailsProvider.leadDetails![0].pincode,
                          // ),
                          // SizedBox(height: 8),
                          // LabelValueWidget(
                          //   label: 'State',
                          //   value: leadDetailsProvider.leadDetails![0].address4 ??
                          //       "",
                          // ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // Invertor and panel details
                    // TileWidget(
                    //   title: 'Inverter and panel details',
                    //   iconAssetPath: 'assets/images/icon_settings_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Inverter Brand',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].inverterTypeName,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Inverter Capacity',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].inverterCapacity
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Panel Brand',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].panelTypeName
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),

                    //     LabelValueWidget(
                    //       label: 'Panel Capacity',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].panelCapacity
                    //           .toString(),
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Panel Phase',
                    //       value: leadDetailsProvider.leadDetails![0].phaseName,
                    //     ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel Brand',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelBrand,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel Watts',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelWatts,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Panel SN',
                    //     //   value: leadDetailsProvider.leadDetails![0].panelSn,
                    //     // ),
                    //   ],
                    // ),

                    // Consumer details
                    // TileWidget(
                    //   title: 'Cost details',
                    //   iconAssetPath: 'assets/images/icon_consumer_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Project Cost',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].projectCost,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Additional Cost',
                    //       value: leadDetailsProvider
                    //           .leadDetails![0].additionalCost,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Advance Paid By Customer',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].advanceAmount,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Cost Includes',
                    //       value:
                    //           leadDetailsProvider.leadDetails![0].costIncName,
                    //     ),
                    //     SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Connection load',
                    //     //   value: leadDetailsProvider
                    //     //       .leadDetails![0].connectedLoad
                    //     //       .toString(),
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Proposed KW',
                    //     //   value: leadDetailsProvider.leadDetails![0].proposedKw,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Roof type',
                    //     //   value: leadDetailsProvider.leadDetails![0].roofType,
                    //     // ),
                    //     // SizedBox(height: 8),
                    //     // LabelValueWidget(
                    //     //   label: 'Application number',
                    //     //   value: leadDetailsProvider
                    //     //       .leadDetails![0].applicationNumber,
                    //     // ),
                    //     SizedBox(height: 8),
                    //   ],
                    // ),
                    // TileWidget(
                    //   title: 'Additional Details',
                    //   iconAssetPath: 'assets/images/icon_consumer_details.png',
                    //   children: [
                    //     LabelValueWidget(
                    //       label: 'Consumer Number',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].consumerNumber ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Electrical Section',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].electricalSection ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Connection Load',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].connectedLoad
                    //               .toString() ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'REP',
                    //       value: leadDetailsProvider.leadDetails![0].rep ?? "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Lead By',
                    //       value: leadDetailsProvider.leadDetails![0].leadBy,
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Work type',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].workTypeName ??
                    //           "",
                    //     ),
                    //     SizedBox(height: 8),
                    //     LabelValueWidget(
                    //       label: 'Roof type',
                    //       value: leadDetailsProvider
                    //               .leadDetails![0].roofTypeName ??
                    //           "",
                    //     ),
                    //   ],
                    // ),
                    // Invoice details
                    // if (settingsProvider.menuIsViewMap[21] == 1)
                    //   TileWidget(
                    //     title: 'Invoice details',
                    //     iconAssetPath:
                    //         'assets/images/icon_bookmark_details.png',
                    //     children: [
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Number',
                    //       //   value:
                    //       //       leadDetailsProvider.leadDetails![0].invoiceNo,
                    //       // ),
                    //       // SizedBox(height: 8),
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Amount',
                    //       //   value: leadDetailsProvider
                    //       //       .leadDetails![0].invoiceAmount
                    //       //       .toString(),
                    //       // ),
                    //       // SizedBox(height: 8),
                    //       // LabelValueWidget(
                    //       //   label: 'Invoice Date',
                    //       //   value: leadDetailsProvider
                    //       //       .leadDetails![0].invoiceDate
                    //       //       .toFormattedDate(),
                    //       // ),
                    //       SizedBox(height: 8),
                    //     ],
                    //   ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: child,
      ),
    );
  }

  Future<void> _openMaps(String location) async {
    print('DEBUG: _openMaps called with: "$location"');

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location available')),
      );
      return;
    }

    String cleanLocation = location.trim();

    // Check if location is already a URL
    if (cleanLocation.startsWith('http://') ||
        cleanLocation.startsWith('https://')) {
      print('DEBUG: Location is already a URL');
      try {
        await launchUrl(Uri.parse(cleanLocation),
            mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        print('DEBUG: Error launching existing URL: $e');
        // If the existing URL fails, try to extract coordinates
        RegExp coordRegex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
        Match? match = coordRegex.firstMatch(cleanLocation);
        if (match != null) {
          String coords = '${match.group(1)},${match.group(2)}';
          String newUrl = 'https://www.google.com/maps/search/$coords';
          print('DEBUG: Trying extracted coordinates URL: $newUrl');
          await launchUrl(Uri.parse(newUrl),
              mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    // Check if location contains coordinates
    bool isCoordinates =
        RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$').hasMatch(cleanLocation);
    print('DEBUG: Is coordinates: $isCoordinates');

    String webUrl;

    if (isCoordinates) {
      webUrl = 'https://www.google.com/maps/search/$cleanLocation';
    } else {
      final encodedLocation = Uri.encodeComponent(cleanLocation);
      webUrl = 'https://www.google.com/maps/search/$encodedLocation';
    }

    print('DEBUG: Final URL: $webUrl');

    try {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('DEBUG: Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps: $e')),
      );
    }
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.bluebutton,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
