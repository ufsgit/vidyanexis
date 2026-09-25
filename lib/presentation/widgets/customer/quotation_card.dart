import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/pages/home/edit_quotation_screen.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';

import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/utils/pdf_action_helper.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/utils/file_downloader.dart';

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

  const QuotationCard({
    super.key,
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
    this.quotation,
  });

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    final bool isApproved = quotation?.adminApproval == 1;
    final bool isDeclined = quotation?.adminApproval == 2 ||
        quotation?.isRejected == 1 ||
        (quotation?.rejectionReason != null &&
            quotation!.rejectionReason!.trim().isNotEmpty);
    final bool isPending = !isApproved && !isDeclined;

    // Top bar color: orange if pending, green on approval, red on decline
    final Color topBarColor = isApproved
        ? const Color(0xFF10B981)
        : isDeclined
            ? const Color(0xFFEF4444)
            : const Color(0xFFF59E0B);

    String formattedDate = '';
    if (posted != 'null' && posted.isNotEmpty) {
      try {
        formattedDate =
            DateFormat('MMM dd, yyyy').format(DateTime.parse(posted));
      } catch (_) {
        formattedDate = posted;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF818CF8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.8),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return EditQuotationScreen(
                      quotationId: taskId, customerId: customerId);
                },
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top colored status bar: orange (pending), green (approved), red (declined)
              Container(
                height: 5,
                width: double.infinity,
                color: topBarColor,
              ),

              // Main Card Body
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Quotation No & Title on left, Status Pill & PDF Actions on right
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "QUOTATION NO : ${quotation?.quotationNo ?? ""}"
                                    .toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFCBD5E1),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PDF Actions when approved
                            if (quotation != null &&
                                quotation!.adminApproval == 1) ...[
                              if (settingsprovider.menuIsViewMap[32] == 1) ...[
                                if (!kIsWeb) ...[
                                  IconButton(
                                    tooltip: 'Share Quotation',
                                    icon: Icon(Icons.share,
                                        size: 18,
                                        color: AppColors.primaryBlue),
                                    onPressed: () async {
                                      PdfActionHelper.showShareOptions(
                                        context: context,
                                        title: 'Quotation',
                                        pdfUrl:
                                            '${HttpUrls.getQuotationMasterPdf}?quotation_master_id=${quotation!.quotationMasterId}',
                                        onGenerate: () async {
                                          final bytes =
                                              await customerDetailsProvider
                                                  .getQuotationMasterPdfBytes(
                                                      quotation!
                                                          .quotationMasterId
                                                          .toString());
                                          return bytes ?? Uint8List(0);
                                        },
                                      );
                                    },
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints(),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                IconButton(
                                  tooltip: 'Download PDF',
                                  icon: const Icon(Icons.download,
                                      size: 19,
                                      color: Color(0xFF10B981)),
                                  onPressed: () async {
                                    await Loader.showLoader(context);
                                    try {
                                      final bytes =
                                          await customerDetailsProvider
                                              .getQuotationMasterPdfBytes(
                                                  quotation!
                                                      .quotationMasterId
                                                      .toString());
                                      if (bytes != null &&
                                          bytes.isNotEmpty) {
                                        final fileName =
                                            'Quotation_${quotation!.quotationMasterId}.pdf';
                                        if (kIsWeb) {
                                          await FileDownloader.saveFile(
                                              bytes, fileName);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Downloaded successfully'),
                                                backgroundColor:
                                                    Colors.green,
                                              ),
                                            );
                                          }
                                        } else if (Platform.isAndroid) {
                                          try {
                                            await FileDownloader.saveFile(
                                                bytes, fileName);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Downloaded to Downloads folder'),
                                                  backgroundColor:
                                                      Colors.green,
                                                ),
                                              );
                                            }
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
                                    } catch (e) {
                                      debugPrint(
                                          'Error downloading PDF: $e');
                                    } finally {
                                      if (context.mounted) {
                                        Loader.stopLoader(context);
                                      }
                                    }
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  tooltip: 'Print Quotation',
                                  icon: Icon(Icons.print,
                                      size: 19,
                                      color: AppColors.primaryBlue),
                                  onPressed: () async {
                                    await Loader.showLoader(context);
                                    if (context.mounted) {
                                      await customerDetailsProvider
                                          .getQuotationMasterPdf(
                                              quotation!.quotationMasterId
                                                  .toString(),
                                              context);
                                      Loader.stopLoader(context);
                                    }
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                              if (settingsprovider.menuIsViewMap[55] == 1) ...[
                                IconButton(
                                  tooltip: quotation?.quotationTypeId == 2
                                      ? 'Download Commercial PDF'
                                      : 'Download Residential PDF',
                                  icon: const Icon(Icons.download_outlined,
                                      size: 19,
                                      color: Color(0xFF10B981)),
                                  onPressed: () async {
                                    await Loader.showLoader(context);
                                    try {
                                      await customerDetailsProvider
                                          .getQuatationListByMasterId(
                                              quotation!.quotationMasterId
                                                  .toString(),
                                              context);
                                      if (context.mounted) {
                                        await customerDetailsProvider
                                            .fetchLeadDetails(
                                                customerId, context);
                                        await settingsprovider
                                            .getCompanyDetails();
                                      }

                                      if (settingsprovider
                                              .companyDetails.isNotEmpty &&
                                          (customerDetailsProvider
                                                  .leadDetails?.isNotEmpty ??
                                              false) &&
                                          customerDetailsProvider
                                              .quotationListByMaster
                                              .isNotEmpty) {
                                        Uint8List? bytes;
                                        if (quotation?.quotationTypeId == 2) {
                                          bytes =
                                              await generateCommercialPDFBytes(
                                            context: context,
                                            companyDetails: settingsprovider
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
                                            companyDetails: settingsprovider
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
                                          final fileName = quotation
                                                      ?.quotationTypeId ==
                                                  2
                                              ? 'Commercial_${quotation!.quotationMasterId}.pdf'
                                              : 'Residential_${quotation!.quotationMasterId}.pdf';

                                          if (kIsWeb) {
                                            await FileDownloader.saveFile(
                                                bytes, fileName);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Downloaded successfully'),
                                                  backgroundColor:
                                                      Colors.green,
                                                ),
                                              );
                                            }
                                          } else if (Platform.isAndroid) {
                                            try {
                                              await FileDownloader.saveFile(
                                                  bytes, fileName);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Downloaded to Downloads folder'),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
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
                                      if (context.mounted) {
                                        Loader.stopLoader(context);
                                      }
                                    }
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                                IconButton(
                                  tooltip: quotation?.quotationTypeId == 2
                                      ? 'Print Commercial'
                                      : 'Print Residential',
                                  icon: Icon(Icons.print_outlined,
                                      size: 19,
                                      color: AppColors.primaryBlue),
                                  onPressed: () async {
                                    await Loader.showLoader(context);
                                    if (context.mounted) {
                                      await customerDetailsProvider
                                          .getQuatationListByMasterId(
                                              quotation!.quotationMasterId
                                                  .toString(),
                                              context);
                                      await customerDetailsProvider
                                          .fetchLeadDetails(
                                              customerId, context);
                                      await settingsprovider
                                          .getCompanyDetails();

                                      if (settingsprovider
                                              .companyDetails.isNotEmpty &&
                                          (customerDetailsProvider
                                                  .leadDetails?.isNotEmpty ??
                                              false) &&
                                          customerDetailsProvider
                                              .quotationListByMaster
                                              .isNotEmpty) {
                                        if (quotation?.quotationTypeId == 2) {
                                          printCommercialPDFs(
                                            context: context,
                                            companyDetails: settingsprovider
                                                .companyDetails[0],
                                            customerDetails:
                                                customerDetailsProvider
                                                    .leadDetails![0],
                                            quotationData:
                                                customerDetailsProvider
                                                    .quotationListByMaster[0],
                                          );
                                        } else {
                                          printResidentialPDFs(
                                            context: context,
                                            companyDetails: settingsprovider
                                                .companyDetails[0],
                                            customerDetails:
                                                customerDetailsProvider
                                                    .leadDetails![0],
                                            quotationData:
                                                customerDetailsProvider
                                                    .quotationListByMaster[0],
                                          );
                                        }
                                      }
                                      Loader.stopLoader(context);
                                    }
                                  },
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                              const SizedBox(width: 4),
                            ],

                            // Status Pill
                            _buildStatusPill(
                              isApproved: isApproved,
                              isDeclined: isDeclined,
                              isPending: isPending,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12.0),

                    // Net Cost Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Net Cost',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: '₹ ',
                              decimalDigits: 2,
                            ).format(double.tryParse(
                                    quotation?.netTotal ?? '0') ??
                                0.0),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12.0),

                    // Action Buttons Row: Edit, Duplicate, Convert, Delete
                    Row(
                      children: [
                        if (settingsprovider.menuIsEditMap[16] == 1) ...[
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            color: const Color(0xFF6366F1),
                            onPressed: () => _handleEdit(
                                context, customerDetailsProvider),
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildActionButton(
                          icon: Icons.copy_rounded,
                          label: 'Duplicate',
                          color: const Color(0xFF10B981),
                          onPressed: () => _handleEdit(
                              context, customerDetailsProvider,
                              isDuplicate: true),
                        ),
                        const SizedBox(width: 8),
                        if (settingsprovider.menuIsViewMap[193] == 1) ...[
                          _buildActionButton(
                            icon: Icons.swap_horiz_rounded,
                            label: quotation?.isConverted == 1
                                ? 'Converted'
                                : 'Convert',
                            color: const Color(0xFF0D9488),
                            onPressed: quotation?.isConverted == 1
                                ? null
                                : () => _handleConvert(
                                    context, customerDetailsProvider),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (settingsprovider.menuIsDeleteMap[16] == 1)
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            color: const Color(0xFFEF4444),
                            onPressed: () => _handleDelete(
                                context, customerDetailsProvider),
                          ),
                      ],
                    ),

                    // Approval Status / Actions Section
                    if (quotation != null) ...[
                      const SizedBox(height: 12),
                      if (isApproved)
                        _buildApprovedBanner()
                      else if (isDeclined)
                        _buildDeclinedBanner(context)
                      else
                        _buildApprovalRequiredBox(
                          context: context,
                          customerDetailsProvider: customerDetailsProvider,
                          settingsprovider: settingsprovider,
                        ),
                    ],
                  ],
                ),
              ),

              // Footer: User Initials Avatar, Date & Created By, Chevron
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(color: Color(0xFFF1F5F9)),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        _getInitials(createdBy),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${formattedDate.isNotEmpty ? formattedDate : ''}${formattedDate.isNotEmpty && createdBy.isNotEmpty ? ' • ' : ''}$createdBy',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Status Badge Pill
  Widget _buildStatusPill({
    required bool isApproved,
    required bool isDeclined,
    required bool isPending,
  }) {
    final Color bgColor;
    final Color borderColor;
    final Color dotColor;
    final Color textColor;
    final String label;

    if (isApproved) {
      bgColor = const Color(0xFFDCFCE7);
      borderColor = const Color(0xFF86EFAC);
      dotColor = const Color(0xFF16A34A);
      textColor = const Color(0xFF15803D);
      label = 'Approved';
    } else if (isDeclined) {
      bgColor = const Color(0xFFFEE2E2);
      borderColor = const Color(0xFFFCA5A5);
      dotColor = const Color(0xFFDC2626);
      textColor = const Color(0xFFB91C1C);
      label = 'Declined';
    } else {
      bgColor = const Color(0xFFFEF3C7).withOpacity(0.5);
      borderColor = const Color(0xFFFDE68A);
      dotColor = const Color(0xFFD97706);
      textColor = const Color(0xFFB45309);
      label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Rounded Outlined Action Button (Icon on top, Label on bottom)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    final bool isDisabled = onPressed == null;
    final effectiveColor = isDisabled ? Colors.grey : color;

    return Expanded(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey.withOpacity(0.04)
                : color.withOpacity(0.02),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey.shade300
                  : color.withOpacity(0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: effectiveColor),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Pending Approval Required Box
  Widget _buildApprovalRequiredBox({
    required BuildContext context,
    required CustomerDetailsProvider customerDetailsProvider,
    required SettingsProvider settingsprovider,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFEF3C7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APPROVAL REQUIRED',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF92400E),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Awaiting Manager',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (settingsprovider.menuIsViewMap[189] == 1)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final success = await customerDetailsProvider
                          .updateQuotationApprovalStatus(
                              taskId, 1, context, customerId);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Status updated to Approved')),
                        );
                      }
                    },
                    icon: const Icon(Icons.check,
                        size: 16, color: Colors.white),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              if (settingsprovider.menuIsViewMap[189] == 1 &&
                  settingsprovider.menuIsViewMap[192] == 1)
                const SizedBox(width: 10),
              if (settingsprovider.menuIsViewMap[192] == 1)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRejectionDialog(context, taskId, customerId,
                          customerDetailsProvider);
                    },
                    icon: const Icon(Icons.close,
                        size: 16, color: Color(0xFF991B1B)),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFF991B1B),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Approved Status Banner
  Widget _buildApprovedBanner() {
    String approverName = "Admin";
    if (quotation!.approvedByName?.isNotEmpty == true) {
      approverName = quotation!.approvedByName!;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF16A34A), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Approved by $approverName',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF15803D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Declined Status Banner
  Widget _buildDeclinedBanner(BuildContext context) {
    String rejecterName = "Admin";
    if (quotation!.rejectedByName?.isNotEmpty == true) {
      rejecterName = quotation!.rejectedByName!;
    } else if (quotation!.rejectedBy != null &&
        quotation!.rejectedBy!.trim().isNotEmpty) {
      try {
        final dropDownProvider =
            Provider.of<DropDownProvider>(context, listen: false);
        final staff = dropDownProvider.searchUserDetails.firstWhere(
          (s) =>
              s.userDetailsId.toString() ==
              quotation!.rejectedBy.toString(),
          orElse: () =>
              SearchUserDetails(userDetailsId: 0, userDetailsName: ''),
        );
        if (staff.userDetailsName.isNotEmpty) {
          rejecterName = staff.userDetailsName;
        }
      } catch (_) {}
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cancel_rounded,
                  color: Color(0xFFDC2626), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rejected by $rejecterName',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFB91C1C),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (quotation!.rejectionReason != null &&
              quotation!.rejectionReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${quotation!.rejectionReason}',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF7F1D1D),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Initials generator (e.g. "Sales Engineer" -> "SE", "Admin" -> "AD")
  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  // Edit / Duplicate Handler
  Future<void> _handleEdit(
    BuildContext context,
    CustomerDetailsProvider customerDetailsProvider, {
    bool isDuplicate = false,
  }) async {
    if (isDuplicate && customerDetailsProvider.hasPendingApprovalQuotation()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Approval pending quotations are there , please clear that'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await customerDetailsProvider.getQuatationListByMasterId(taskId, context);
    final quotaion = customerDetailsProvider.quotationListByMaster.first;

    // ---- Population Logic ----
    customerDetailsProvider.customerId = customerId;
    customerDetailsProvider.qproductnameController.text = title;
    customerDetailsProvider.advanceController.text = advancePercentage;
    customerDetailsProvider.deliveryController.text = deliveryPercentage;
    customerDetailsProvider.workCompletionController.text =
        completionPercentage;
    customerDetailsProvider.qsubsidyAmountController.text = subsidy;
    customerDetailsProvider.qwarrentyController.text = warranty;
    customerDetailsProvider.qtermsConditionsController.text = terms;
    customerDetailsProvider.quotationDescriptionController.text =
        quotaion.description;
    customerDetailsProvider.quotationDescription2Controller.text =
        quotaion.description2;
    customerDetailsProvider.quotationDescription3Controller.text =
        quotaion.description3;
    if (!isDuplicate) {
      customerDetailsProvider.rejectionReasonController.text =
          quotaion.rejectionReason;
    }

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
    customerDetailsProvider.additionalStructureController.text =
        quotaion.additionalStructure.toString();

    // ---- TOTALS ----
    customerDetailsProvider.subtotalController.text =
        quotaion.totalAmount.toString();
    customerDetailsProvider.totalController.text =
        quotaion.netTotal.toString();

    // ---- ITEMS ----
    customerDetailsProvider.updateItemsFromQuotationDetailsNew(
      quotaion.quotationDetails,
      quotaion.billOfMaterials,
      quotaion.productionChart,
      quotaion.structureMaterials,
    );

    // ---- GST ----
    final taxable = double.tryParse(quotaion.taxableAmount) ?? 0;
    final gst = double.tryParse(quotaion.gstAmount) ?? 0;
    final gstPer = double.tryParse(quotaion.gstPer) ?? 0;

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
        quotaion.quotationTypeName;
    customerDetailsProvider.selectedQuotationType = quotaion.quotationTypeId;

    // ---- CABLE DETAILS ----
    customerDetailsProvider.cableStructureController.text =
        quotaion.cableStructure;
    customerDetailsProvider.cableTypeController.text = quotaion.cableType;
    customerDetailsProvider.cableShortCircuitTempController.text =
        quotaion.cableShortCircuitTemp;
    customerDetailsProvider.cableStandardController.text =
        quotaion.cableStandard;
    customerDetailsProvider.cableConductorClassController.text =
        quotaion.cableConductorClass;
    customerDetailsProvider.cableMaterialController.text =
        quotaion.cableMaterial;
    customerDetailsProvider.cableProtectionController.text =
        quotaion.cableProtection;
    customerDetailsProvider.cableWarrantyController.text =
        quotaion.cableWarranty;
    customerDetailsProvider.cableTensileStrengthController.text =
        quotaion.cableTensileStrength;

    // ---- OTHER DETAILS ----
    customerDetailsProvider.plantCapacityController.text =
        quotaion.plantCapacity;
    customerDetailsProvider.moduleTechnologiesController.text =
        quotaion.moduleTechnologies;
    customerDetailsProvider.mountingStructureTechnologiesController.text =
        quotaion.mountingStructureTechnologies;
    customerDetailsProvider.projectSchemeController.text =
        quotaion.projectScheme;
    customerDetailsProvider.powerEvacuationController.text =
        quotaion.powerEvacuation;
    customerDetailsProvider.areaApproximateController.text =
        quotaion.areaApproximate;
    customerDetailsProvider.solarPlantOutputConnectionController.text =
        quotaion.solarPlantOutputConnection;
    customerDetailsProvider.schemeController.text = quotaion.scheme;
    customerDetailsProvider.qvalidityController.text = quotaion.validity;
    customerDetailsProvider.qtendorNumberController.text =
        quotaion.tendorNumber;
    customerDetailsProvider.paymentTermsController.text =
        quotaion.paymentTermsName;
    customerDetailsProvider.incoTermsController.text = quotaion.incoTerms;
    customerDetailsProvider.shippingChargesController.text =
        quotaion.shippingCharges;
    customerDetailsProvider.totalAdCESSController.text = quotaion.otherTax;
    customerDetailsProvider.totalCgstAmountController.text =
        quotaion.totalCgstAmount;
    customerDetailsProvider.totalSgstAmountController.text =
        quotaion.totalSgstAmount;

    customerDetailsProvider.selectedBranchId = quotaion.branchId;
    customerDetailsProvider.commercialItems = quotaion.commercialItems;
    customerDetailsProvider.scopeOfWorkItems = quotaion.scopeOfWorkItems;

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) {
            return EditQuotationScreen(
              quotationId: taskId,
              customerId: customerId,
              isDuplicate: isDuplicate,
            );
          },
        ),
      );
    }
  }

  // Delete Handler
  void _handleDelete(
    BuildContext context,
    CustomerDetailsProvider customerDetailsProvider,
  ) {
    showConfirmationDialog(
      context: context,
      title: 'Delete Quotation',
      content: 'Are you sure you want to delete this quotation?',
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
  }

  // Convert Handler
  Future<void> _handleConvert(
    BuildContext context,
    CustomerDetailsProvider customerDetailsProvider,
  ) async {
    await customerDetailsProvider.checkQuotationConvert(
      taskId,
      context,
      customerId,
    );
  }

  void _showRejectionDialog(
    BuildContext context,
    String taskId,
    String customerId,
    CustomerDetailsProvider customerDetailsProvider,
  ) {
    final TextEditingController reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            children: [
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
              const SizedBox(width: 8),
              Text(
                'Reject Quotation',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please enter the reason for rejection:',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter rejection reason...',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Rejection reason is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final reason = reasonController.text.trim();
                  Navigator.pop(dialogContext);
                  final success = await customerDetailsProvider
                      .updateQuotationRejectionStatus(
                          taskId, reason, context, customerId);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quotation rejected successfully'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  Future<void> _generateAndPrintPDF(BuildContext context) async {
    try {
      final ByteData assetData =
          await rootBundle.load('assets/images/cygnus.pdf');
      final Uint8List pdfBytes = assetData.buffer.asUint8List();

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name: 'Customer Report',
        format: PdfPageFormat.a4,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to generate or print PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
