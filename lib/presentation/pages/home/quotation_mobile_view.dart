import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/file_downloader.dart';
import 'package:vidyanexis/utils/pdf_action_helper.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/controller/models/tab_state.dart';

class QuotationMobileView extends StatefulWidget {
  const QuotationMobileView({super.key, required this.customerId});
  final String customerId;

  @override
  State<QuotationMobileView> createState() => _QuotationMobileViewState();
}

class _QuotationMobileViewState extends State<QuotationMobileView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .fetchQuotationListIfNeeded(widget.customerId, context, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quotations',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => QuotationCreationWidget(
                        customerId: widget.customerId,
                        quotationId: '0',
                        isEdit: false,
                      ),
                    ),
                  ),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CustomerDetailsProvider>(
              builder: (context, customerDetailsProvider, child) {
                final state = customerDetailsProvider.quotationListState;

                if (state.status == TabStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TabStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.errorMessage ?? 'An error occurred', style: GoogleFonts.plusJakartaSans(color: Colors.red)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => customerDetailsProvider.fetchQuotationListIfNeeded(widget.customerId, context, forceRefresh: true),
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  );
                }

                if (state.status == TabStatus.empty || state.data == null || state.data!.isEmpty) {
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

                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<CustomerDetailsProvider>(context, listen: false)
                        .fetchQuotationListIfNeeded(widget.customerId, context, forceRefresh: true);
                  },
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: state.data!.length,
                    itemBuilder: (context, index) {
                    final item = customerDetailsProvider.quotationList[index];
                    final settingsProvider =
                        Provider.of<SettingsProvider>(context, listen: false);
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
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
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: StatusUtils.getStatusColor(
                                          item.quotationStatusId),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.productName,
                                      style: AppStyles.getBoldTextStyle(
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 7),
                                    decoration: BoxDecoration(
                                      color: StatusUtils.getStatusColor(
                                          item.quotationStatusId),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.quotationStatusName,
                                      style: AppStyles.getBoldTextStyle(
                                        fontSize: 11,
                                        fontColor:
                                            StatusUtils.getStatusTextColor(
                                                item.quotationStatusId),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                    GestureDetector(
                                      onTap: () async {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (c) =>
                                                QuotationCreationWidget(
                                              isEdit: true,
                                              quotationId: item
                                                  .quotationMasterId
                                                  .toString(),
                                              customerId:
                                                  widget.customerId.toString(),
                                              isDuplicate: true,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Tooltip(
                                          message: 'Duplicate Quotation',
                                          child: Icon(Icons.copy,
                                              size: 20,
                                              color: Color.fromARGB(
                                                  255, 184, 175, 0)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  // Share 1 — API-generated PDF (menuIsViewMap[32])
                                  if (settingsProvider.menuIsViewMap[32] ==
                                      1) ...[
                                    if (!kIsWeb) ...[
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
                                                      .getQuotationMasterPdfBytes(
                                                          item.quotationMasterId
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
                                                size: 20,
                                                color: AppColors.primaryBlue),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    GestureDetector(
                                      onTap: () async {
                                        await Loader.showLoader(context);
                                        try {
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getQuotationMasterPdfBytes(
                                                      item.quotationMasterId
                                                          .toString());
                                          if (bytes != null &&
                                              bytes.isNotEmpty) {
                                            final fileName =
                                                'Quotation_${item.quotationMasterId}.pdf';
                                            if (kIsWeb) {
                                              await FileDownloader.saveFile(
                                                  bytes, fileName);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Downloaded successfully'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } else if (Platform.isAndroid) {
                                              try {
                                                await FileDownloader.saveFile(
                                                    bytes, fileName);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Downloaded to Downloads folder'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              } catch (e) {
                                                debugPrint(
                                                    'Download failed, falling back to share: $e');
                                                await Printing.sharePdf(
                                                    bytes: bytes,
                                                    filename: fileName);
                                              }
                                            } else {
                                              await Printing.sharePdf(
                                                  bytes: bytes,
                                                  filename: fileName);
                                            }
                                          }
                                        } catch (e) {
                                          debugPrint(
                                              'Error downloading PDF: $e');
                                        } finally {
                                          Loader.stopLoader(context);
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Tooltip(
                                          message: 'Download Quotation',
                                          child: Icon(Icons.download,
                                              size: 20,
                                              color: Color(0xFF10B981)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        await Loader.showLoader(context);
                                        try {
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getQuotationMasterPdfBytes(
                                                      item.quotationMasterId
                                                          .toString());
                                          if (bytes != null &&
                                              bytes.isNotEmpty) {
                                            await Printing.layoutPdf(
                                              onLayout: (format) async => bytes,
                                              name:
                                                  'Quotation_${item.quotationMasterId}',
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
                                              size: 20,
                                              color: AppColors.primaryBlue),
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Share 2 — Local Commercial/Residential PDF (menuIsViewMap[55])
                                  if (settingsProvider.menuIsViewMap[55] ==
                                      1) ...[
                                    if (!kIsWeb) ...[
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
                                                item.quotationMasterId
                                                    .toString(),
                                                context,
                                              );
                                              await customerDetailsProvider
                                                  .fetchLeadDetails(
                                                      widget.customerId,
                                                      context);
                                              await settingsProvider
                                                  .getCompanyDetails();

                                              if (settingsProvider
                                                      .companyDetails
                                                      .isNotEmpty &&
                                                  (customerDetailsProvider
                                                          .leadDetails
                                                          ?.isNotEmpty ??
                                                      false) &&
                                                  customerDetailsProvider
                                                      .quotationListByMaster
                                                      .isNotEmpty) {
                                                if (item.quotationTypeId == 2) {
                                                  return await generateCommercialPDFBytes(
                                                        context: context,
                                                        companyDetails:
                                                            settingsProvider
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
                                                        companyDetails:
                                                            settingsProvider
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
                                                size: 20,
                                                color: AppColors.primaryBlue),
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        await Loader.showLoader(context);
                                        try {
                                          await customerDetailsProvider
                                              .getQuatationListByMasterId(
                                            item.quotationMasterId.toString(),
                                            context,
                                          );
                                          await customerDetailsProvider
                                              .fetchLeadDetails(
                                                  widget.customerId, context);
                                          await settingsProvider
                                              .getCompanyDetails();

                                          if (settingsProvider
                                                  .companyDetails.isNotEmpty &&
                                              (customerDetailsProvider
                                                      .leadDetails
                                                      ?.isNotEmpty ??
                                                  false) &&
                                              customerDetailsProvider
                                                  .quotationListByMaster
                                                  .isNotEmpty) {
                                            Uint8List? bytes;
                                            if (item.quotationTypeId == 2) {
                                              bytes =
                                                  await generateCommercialPDFBytes(
                                                context: context,
                                                companyDetails: settingsProvider
                                                    .companyDetails[0],
                                                customerDetails:
                                                    customerDetailsProvider
                                                        .leadDetails![0],
                                                quotationData:
                                                    customerDetailsProvider
                                                        .quotationListByMaster[0],
                                              );
                                            } else {
                                              bytes =
                                                  await generateResidentialPDFBytes(
                                                context: context,
                                                companyDetails: settingsProvider
                                                    .companyDetails[0],
                                                customerDetails:
                                                    customerDetailsProvider
                                                        .leadDetails![0],
                                                quotationData:
                                                    customerDetailsProvider
                                                        .quotationListByMaster[0],
                                              );
                                            }

                                            if (bytes != null &&
                                                bytes.isNotEmpty) {
                                              final fileName = item
                                                          .quotationTypeId ==
                                                      2
                                                  ? 'Commercial_${item.quotationMasterId}.pdf'
                                                  : 'Residential_${item.quotationMasterId}.pdf';

                                              if (kIsWeb) {
                                                await FileDownloader.saveFile(
                                                    bytes, fileName);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Downloaded successfully'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              } else if (Platform.isAndroid) {
                                                try {
                                                  await FileDownloader.saveFile(
                                                      bytes, fileName);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Downloaded to Downloads folder'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } catch (e) {
                                                  await Printing.sharePdf(
                                                      bytes: bytes,
                                                      filename: fileName);
                                                }
                                              } else {
                                                await Printing.sharePdf(
                                                    bytes: bytes,
                                                    filename: fileName);
                                              }
                                            }
                                          }
                                        } catch (e) {
                                          debugPrint(
                                              'Error downloading PDF: $e');
                                        } finally {
                                          Loader.stopLoader(context);
                                        }
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Tooltip(
                                          message: 'Download Quotation',
                                          child: Icon(Icons.download,
                                              size: 20,
                                              color: Color(0xFF10B981)),
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
                                        await settingsProvider
                                            .getCompanyDetails();

                                        if (settingsProvider
                                                .companyDetails.isNotEmpty &&
                                            (customerDetailsProvider
                                                    .leadDetails?.isNotEmpty ??
                                                false) &&
                                            customerDetailsProvider
                                                .quotationListByMaster
                                                .isNotEmpty) {
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
                                              size: 20,
                                              color: AppColors.primaryBlue),
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Delete button — only shown when user has delete permission
                                  if (settingsProvider.menuIsDeleteMap[16] ==
                                      1) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        showConfirmationDialog(
                                          context: context,
                                          title: 'Delete Quotation',
                                          content:
                                              'Are you sure you want to delete this quotation?',
                                          isLoading: customerDetailsProvider
                                              .isDeleteLoading,
                                          onCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onConfirm: () async {
                                            await customerDetailsProvider
                                                .deleteQuotation(
                                              item.quotationMasterId.toString(),
                                              widget.customerId.toString(),
                                              context,
                                            );
                                            if (context.mounted)
                                              Navigator.pop(context);
                                          },
                                          confirmButtonText: 'Delete',
                                          confirmButtonColor: Colors.red,
                                        );
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Tooltip(
                                          message: 'Delete Quotation',
                                          child: Icon(Icons.delete_outline,
                                              size: 20, color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (item.description.trim().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(
                                  height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    NumberFormat.currency(locale: 'en_IN', symbol: '₹ ', decimalDigits: 2).format(double.tryParse(item.netTotal) ?? 0.0),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('•',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF94A3B8))),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundImage: const AssetImage(
                                        'assets/images/user-circle1.png'),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.createdByName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.entryDate.toString().toTimeAgo(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
