import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class ImageUploadAlert extends StatefulWidget {
  final String customerId;
  final int? initialDocumentTypeId;
  final String? initialDocumentTypeName;

  const ImageUploadAlert({
    super.key,
    required this.customerId,
    this.initialDocumentTypeId,
    this.initialDocumentTypeName,
  });

  @override
  _ImageUploadAlertState createState() => _ImageUploadAlertState();
}

class _ImageUploadAlertState extends State<ImageUploadAlert> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final imageProvider =
          Provider.of<ImageUploadProvider>(context, listen: false);

      dropDownProvider.getDocumentType(context);
      imageProvider.clearFiles();

      if (widget.initialDocumentTypeId != null) {
        imageProvider.updateDocumentType(widget.initialDocumentTypeId!,
            widget.initialDocumentTypeName ?? "");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageUploadProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2.5
            : MediaQuery.of(context).size.width * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "Add Documents",
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
                IconButton(
                  onPressed: () {
                    provider.clearFiles();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.initialDocumentTypeId == null) ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dropDownProvider.documentType.length,
                        separatorBuilder: (context, index) => Divider(
                            color: Colors.grey.withOpacity(0.2), height: 1),
                        itemBuilder: (context, index) {
                          final docType = dropDownProvider.documentType[index];
                          final selectedCount = provider.fileInfoList
                              .where((e) =>
                                  e['docTypeId'] == docType.documentTypeId)
                              .length;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        docType.documentTypeName ?? '',
                                        fontSize: 14,
                                        fontWeight: selectedCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: AppColors.textBlack,
                                      ),
                                      if (selectedCount > 0)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: CustomText(
                                            '$selectedCount file${selectedCount > 1 ? 's' : ''} added',
                                            fontSize: 11,
                                            color: AppColors.appViolet,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    provider.updateDocumentType(
                                        docType.documentTypeId,
                                        docType.documentTypeName);
                                    await provider.addFileMobile();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: selectedCount > 0
                                          ? AppColors.appViolet
                                          : AppColors.appViolet
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      selectedCount > 0
                                          ? Icons.add
                                          : Icons.upload_sharp,
                                      color: selectedCount > 0
                                          ? Colors.white
                                          : AppColors.appViolet,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      // Initial document type view
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.appViolet.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.appViolet.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                color: AppColors.appViolet),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    "Document Type",
                                    fontSize: 12,
                                    color: AppColors.textGrey3,
                                  ),
                                  CustomText(
                                    widget.initialDocumentTypeName ?? "",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ],
                              ),
                            ),
                            CustomElevatedButton(
                              buttonText: "Pick Files",
                              onPressed: () => provider.addFileMobile(),
                              backgroundColor: AppColors.appViolet,
                              borderColor: AppColors.appViolet,
                              textColor: Colors.white,
                              radius: 8,
                              textSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (provider.fileInfoList.isNotEmpty) ...[
                      CustomText(
                        "Selected Documents",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey3,
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.fileInfoList.length,
                        itemBuilder: (context, index) {
                          final fileInfo = provider.fileInfoList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.textGrey2.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  fileInfo['type'] == 'pdf'
                                      ? "assets/icons/pdf_icon.svg"
                                      : "assets/icons/document_icon.svg",
                                  height: 32,
                                  width: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        fileInfo['name'] ?? 'Unknown file',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (fileInfo['docTypeName'] != null)
                                        CustomText(
                                          'Type: ${fileInfo['docTypeName']}',
                                          fontSize: 11,
                                          color: AppColors.textGrey4,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    provider.fileInfoList.removeAt(index);
                                    provider.notifyListeners();
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: AppColors.textGrey2.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              CustomText(
                                "No documents selected yet",
                                fontSize: 14,
                                color: AppColors.textGrey3,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  onPressed: () {
                    provider.clearFiles();
                    Navigator.pop(context);
                  },
                  buttonText: 'Cancel',
                  backgroundColor: Colors.white,
                  borderColor: AppColors.textGrey2,
                  textColor: AppColors.textBlack,
                  radius: 12,
                ),
                const SizedBox(width: 12),
                CustomElevatedButton(
                  onPressed: () async {
                    provider.setCutomerId(widget.customerId);
                    if (provider.fileInfoList.isNotEmpty) {
                      await provider.uploadAllDocumentsGrouped(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pick at least one document')),
                      );
                    }
                  },
                  buttonText: 'Upload Documents',
                  backgroundColor: AppColors.appViolet,
                  borderColor: AppColors.appViolet,
                  textColor: Colors.white,
                  radius: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
