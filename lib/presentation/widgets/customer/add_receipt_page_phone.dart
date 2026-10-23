import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/report_upload_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class AddReceiptPagePhone extends StatefulWidget {
  bool isEdit;
  String customerId;
  String recieptId;
  AddReceiptPagePhone(
      {super.key,
      required this.recieptId,
      required this.isEdit,
      required this.customerId});

  @override
  State<AddReceiptPagePhone> createState() => _AddReceiptPagePhoneState();
}

class _AddReceiptPagePhoneState extends State<AddReceiptPagePhone> {
  late FocusNode _leadNameFocusNode;
  late FocusNode statusNode;
  late FocusNode complaintNode;
  bool _isSaving = false;

  @override
  void initState() {
    _leadNameFocusNode = FocusNode();
    statusNode = FocusNode();
    complaintNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _leadNameFocusNode.requestFocus();
    });
    super.initState();
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave(
    CustomerDetailsProvider customerDetailsProvider,
    ReportUploadProvider reportUploadProvider,
    SettingsProvider settingsProvider,
  ) async {
    if (_isSaving || customerDetailsProvider.isSavingReciept) return;

    if (customerDetailsProvider.recieptAmountController.text.trim().isEmpty) {
      _showAlertDialog('Missing Details');
      return;
    }

    // Permission 227: document is mandatory when menuIsViewMap[227] == 1
    final bool isDocumentMandatory =
        (settingsProvider.menuIsViewMap[227] ?? 0) == 1;
    if (isDocumentMandatory && reportUploadProvider.selectedFileBytes == null) {
      _showAlertDialog('Please attach a document before saving.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? uploadedFilePath;
      if (reportUploadProvider.selectedFileBytes != null) {
        uploadedFilePath = await reportUploadProvider.uploadFileOnly(
            widget.customerId, context);
      }
      if (!mounted) return;
      await customerDetailsProvider.saveReciept(
        widget.recieptId,
        widget.customerId,
        context,
        filePath: uploadedFilePath,
      );
      reportUploadProvider.clearFile();
    } catch (e) {
      debugPrint('Error saving receipt: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final reportUploadProvider = Provider.of<ReportUploadProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool isSavingNow =
        _isSaving || customerDetailsProvider.isSavingReciept;
    final bool isDocumentMandatory =
        (settingsProvider.menuIsViewMap[227] ?? 0) == 1;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBarWidget(
        title: widget.isEdit ? 'Edit Payment' : 'Add Payment',
        onLeadingPressed: () {
          Navigator.of(context).pop();
        },
        onSavePressed: isSavingNow
            ? () {}
            : () => _handleSave(
                customerDetailsProvider, reportUploadProvider, settingsProvider),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          shrinkWrap: true,
          children: [
            CustomTextfieldWidgetMobile(
              focusNode: _leadNameFocusNode,
              readOnly: false,
              controller: customerDetailsProvider.recieptDescriptionController,
              labelText: 'Payment Title',
            ),
            const SizedBox(height: 16.0),
            CustomTextfieldWidgetMobile(
              focusNode: FocusNode(),
              keyBoardType: TextInputType.number,
              readOnly: false,
              controller: customerDetailsProvider.recieptAmountController,
              labelText: 'Amount',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 20.0),
            // Document / Report section
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1,
                ),
                children: [
                  const TextSpan(text: 'Document / Report'),
                  if (isDocumentMandatory)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            if (reportUploadProvider.selectedFileName == null)
              InkWell(
                onTap: (reportUploadProvider.isUploading || isSavingNow)
                    ? null
                    : () => reportUploadProvider.pickDocument(context),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.appViolet.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.appViolet.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 36,
                        color: AppColors.appViolet,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select Document',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.appViolet,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supported: PDF, JPG, PNG, DOC, XLS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.appViolet.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.appViolet.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.appViolet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        reportUploadProvider.selectedFileExtension
                                    ?.toLowerCase() ==
                                'pdf'
                            ? Icons.picture_as_pdf
                            : (['jpg', 'jpeg', 'png'].contains(
                                    reportUploadProvider.selectedFileExtension
                                        ?.toLowerCase())
                                ? Icons.image
                                : Icons.description),
                        color: AppColors.appViolet,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reportUploadProvider.selectedFileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          if (reportUploadProvider.selectedFileBytes != null)
                            Text(
                              '${(reportUploadProvider.selectedFileBytes!.length / 1024).toStringAsFixed(1)} KB',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textGrey2,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.close,
                          color: Colors.red, size: 20),
                      onPressed:
                          (reportUploadProvider.isUploading || isSavingNow)
                              ? null
                              : () {
                                  reportUploadProvider.clearFile();
                                },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
