import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/report_upload_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class RecieptCreationWidget extends StatelessWidget {
  final bool isEdit;
  final String customerId;
  final String recieptId;
  const RecieptCreationWidget(
      {super.key,
      required this.recieptId,
      required this.isEdit,
      required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final reportUploadProvider = Provider.of<ReportUploadProvider>(context);

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            isEdit ? 'Edit Reciept' : 'Add Reciept',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                reportUploadProvider.clearFile();
                customerDetailsProvider.clearRecieptDetails();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),
            CustomTextField(
                readOnly: false,
                height: 54,
                controller: customerDetailsProvider.recieptAmountController,
                hintText: 'Amount*',
                labelText: '',
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number),
            const SizedBox(height: 16.0),
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.recieptDescriptionController,
              hintText: 'Description',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Document / Report',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 8.0),
            // Container used to select document
            if (reportUploadProvider.selectedFileName == null)
              InkWell(
                onTap: reportUploadProvider.isUploading
                    ? null
                    : () => reportUploadProvider.pickDocument(context),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 20),
                      onPressed: reportUploadProvider.isUploading
                          ? null
                          : () {
                              reportUploadProvider.clearFile();
                            },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12.0),
            // Button "Upload report" below it
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            reportUploadProvider.clearFile();
            customerDetailsProvider.clearRecieptDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider
                .recieptAmountController.text.isNotEmpty) {
              String? uploadedFilePath;
              if (reportUploadProvider.selectedFileBytes != null) {
                uploadedFilePath = await reportUploadProvider.uploadFileOnly(
                    customerId, context);
              }
              if (!context.mounted) return;
              customerDetailsProvider.saveReciept(
                  recieptId, customerId, context,
                  filePath: uploadedFilePath);
              reportUploadProvider.clearFile();
            } else {
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
                    content: const Text(
                      'Missing Details',
                      style: TextStyle(
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
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
