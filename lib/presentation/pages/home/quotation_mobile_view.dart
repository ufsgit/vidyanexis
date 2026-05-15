import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/pages/home/edit_quotation_screen.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/file_downloader.dart';
import 'package:vidyanexis/utils/pdf_action_helper.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class QuotationMobileView extends StatefulWidget {
  const QuotationMobileView({super.key, required this.customerId});
  final String customerId;

  @override
  State<QuotationMobileView> createState() => _QuotationMobileViewState();
}

class _QuotationMobileViewState extends State<QuotationMobileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getQuatationList(widget.customerId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Consumer<CustomerDetailsProvider>(
          builder: (context, customerDetailsProvider, child) {
            if (customerDetailsProvider.isQuotationListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (customerDetailsProvider.quotationList.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Text(
                      'No quotations found.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Start by creating a new quotation.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              separatorBuilder: (_, __) => Divider(
                thickness: 2,
                color: Colors.grey.shade200,
              ),
              // padding: EdgeInsets.all(16),
              itemCount: customerDetailsProvider.quotationList.length,
              itemBuilder: (context, index) {
                final item = customerDetailsProvider.quotationList[index];
                final settingsProvider =
                    Provider.of<SettingsProvider>(context, listen: false);
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => QuotationCreationWidget(
                          isEdit: true,
                          quotationId: item.quotationMasterId.toString(),
                          customerId: widget.customerId.toString(),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 22,
                              color: StatusUtils.getStatusColor(
                                  item.quotationStatusId),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: AppStyles.getBoldTextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 7),
                              decoration: BoxDecoration(
                                color: StatusUtils.getStatusColor(
                                    item.quotationStatusId),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                item.quotationStatusName,
                                style: AppStyles.getBoldTextStyle(
                                  fontSize: 11,
                                  fontColor: StatusUtils.getStatusTextColor(
                                      item.quotationStatusId),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Share 1 — API-generated PDF (menuIsViewMap[32])
                            if (settingsProvider.menuIsViewMap[32] == 1) ...[
                              GestureDetector(
                                onTap: () async {
                                  PdfActionHelper.showShareOptions(
                                    context: context,
                                    title: 'Quotation 1',
                                    pdfUrl:
                                        '${HttpUrls.getQuotationMasterPdf}?quotation_master_id=${item.quotationMasterId}',
                                    onGenerate: () async {
                                      final bytes =
                                          await customerDetailsProvider
                                              .getQuotationMasterPdfBytes(item
                                                  .quotationMasterId
                                                  .toString());
                                      return bytes ?? Uint8List(0);
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Tooltip(
                                    message: 'Share Quotation 1',
                                    child: Icon(Icons.share,
                                        size: 20, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await Loader.showLoader(context);
                                  try {
                                    final bytes = await customerDetailsProvider
                                        .getQuotationMasterPdfBytes(
                                            item.quotationMasterId.toString());
                                    if (bytes != null && bytes.isNotEmpty) {
                                      final fileName =
                                          'Quotation_${item.quotationMasterId}.pdf';
                                      if (Platform.isAndroid) {
                                        try {
                                          await FileDownloader.saveFile(
                                              bytes, fileName);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Downloaded to Downloads folder'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          debugPrint('Download failed, falling back to share: $e');
                                          await Printing.sharePdf(
                                              bytes: bytes, filename: fileName);
                                        }
                                      } else {
                                        await Printing.sharePdf(
                                            bytes: bytes, filename: fileName);
                                      }
                                    }
                                  } catch (e) {
                                    debugPrint('Error downloading PDF: $e');
                                  } finally {
                                    Loader.stopLoader(context);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Tooltip(
                                    message: 'Download Quotation',
                                    child: Icon(Icons.download,
                                        size: 20, color: Color(0xFF10B981)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await Loader.showLoader(context);
                                  try {
                                    final bytes = await customerDetailsProvider
                                        .getQuotationMasterPdfBytes(
                                            item.quotationMasterId.toString());
                                    if (bytes != null && bytes.isNotEmpty) {
                                      await Printing.layoutPdf(
                                        onLayout: (format) async => bytes,
                                        name: 'Quotation_${item.quotationMasterId}',
                                      );
                                    }
                                  } finally {
                                    Loader.stopLoader(context);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Tooltip(
                                    message: 'Print Quotation 1',
                                    child: Icon(Icons.print,
                                        size: 20, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ),
                            ],
                            // Share 2 — Local Commercial/Residential PDF (menuIsViewMap[55])
                            if (settingsProvider.menuIsViewMap[55] == 1) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  PdfActionHelper.showShareOptions(
                                    context: context,
                                    title: item.quotationTypeId == 2
                                        ? 'Commercial PDF'
                                        : 'Residential PDF',
                                    onGenerate: () async {
                                      await customerDetailsProvider
                                          .getQuatationListByMasterId(
                                        item.quotationMasterId.toString(),
                                        context,
                                      );
                                      await customerDetailsProvider
                                          .fetchLeadDetails(
                                              widget.customerId, context);
                                      await settingsProvider.getCompanyDetails();

                                      if (settingsProvider
                                              .companyDetails.isNotEmpty &&
                                          (customerDetailsProvider
                                                  .leadDetails?.isNotEmpty ??
                                              false) &&
                                          customerDetailsProvider
                                              .quotationListByMaster.isNotEmpty) {
                                        if (item.quotationTypeId == 2) {
                                          return await generateCommercialPDFBytes(
                                                context: context,
                                                companyDetails: settingsProvider
                                                    .companyDetails[0],
                                                customerDetails:
                                                    customerDetailsProvider
                                                        .leadDetails![0],
                                                quotationData:
                                                    customerDetailsProvider
                                                        .quotationListByMaster[0],
                                              ) ??
                                              Uint8List(0);
                                        } else {
                                          return await generateResidentialPDFBytes(
                                                context: context,
                                                companyDetails: settingsProvider
                                                    .companyDetails[0],
                                                customerDetails:
                                                    customerDetailsProvider
                                                        .leadDetails![0],
                                                quotationData:
                                                    customerDetailsProvider
                                                        .quotationListByMaster[0],
                                              ) ??
                                              Uint8List(0);
                                        }
                                      }
                                      return Uint8List(0);
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Tooltip(
                                    message: item.quotationTypeId == 2
                                        ? 'Share Commercial'
                                        : 'Share Residential',
                                    child: Icon(Icons.share_outlined,
                                        size: 20, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await Loader.showLoader(context);
                                  await customerDetailsProvider
                                      .getQuatationListByMasterId(
                                    item.quotationMasterId.toString(),
                                    context,
                                  );
                                  await customerDetailsProvider
                                      .fetchLeadDetails(
                                          widget.customerId, context);
                                  await settingsProvider.getCompanyDetails();

                                  if (settingsProvider
                                          .companyDetails.isNotEmpty &&
                                      (customerDetailsProvider
                                              .leadDetails?.isNotEmpty ??
                                          false) &&
                                      customerDetailsProvider
                                          .quotationListByMaster.isNotEmpty) {
                                    if (item.quotationTypeId == 2) {
                                      printCommercialPDFs(
                                          context: context,
                                          companyDetails: settingsProvider
                                              .companyDetails[0],
                                          customerDetails:
                                              customerDetailsProvider
                                                  .leadDetails![0],
                                          quotationData:
                                              customerDetailsProvider
                                                  .quotationListByMaster[0]);
                                    } else {
                                      printResidentialPDFs(
                                          context: context,
                                          companyDetails: settingsProvider
                                              .companyDetails[0],
                                          customerDetails:
                                              customerDetailsProvider
                                                  .leadDetails![0],
                                          quotationData:
                                              customerDetailsProvider
                                                  .quotationListByMaster[0]);
                                    }
                                  }
                                  Loader.stopLoader(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Tooltip(
                                    message: item.quotationTypeId == 2
                                        ? 'Print Commercial'
                                        : 'Print Residential',
                                    child: Icon(Icons.print_outlined,
                                        size: 20, color: AppColors.primaryBlue),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.getRegularTextStyle(
                            fontSize: 14,
                            fontColor: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '₹ ${item.totalAmount}',
                              style: AppStyles.getBodyTextStyle(
                                  fontSize: 14,
                                  fontColor: Colors.grey.shade800),
                            ),
                            const SizedBox(width: 5),
                            const Text('•',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const SizedBox(width: 5),
                            Text(
                              'by',
                              style: AppStyles.getRegularTextStyle(
                                  fontSize: 14,
                                  fontColor: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 5),
                            CircleAvatar(
                              radius: 10,
                              backgroundImage:
                                  AssetImage('assets/images/user-circle1.png'),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.createdByName,
                              style: AppStyles.getBodyTextStyle(
                                  fontSize: 14,
                                  fontColor: const Color(0xFF607085)),
                            ),
                            const Spacer(),
                            Text(
                              item.entryDate.toString().toTimeAgo(),
                              style: AppStyles.getRegularTextStyle(
                                  fontColor: Colors.grey.shade500,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Add Quotation',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => QuotationCreationWidget(
                customerId: widget.customerId,
                quotationId: '0',
                isEdit: false,
              ),
            ),
            // MaterialPageRoute(
            //   builder: (c) => AddQuotationWidgetMobile(
            //     customerId: widget.customerId,
            //     quotationId: '0',
            //   ),
            // ),
          ),
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
