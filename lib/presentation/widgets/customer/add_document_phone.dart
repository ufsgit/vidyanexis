import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/follow_up_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/dotted_border_container.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class AddDocumentPhone extends StatefulWidget {
  String customerId;

  AddDocumentPhone({super.key, required this.customerId});

  @override
  State<AddDocumentPhone> createState() => _AddDocumentPhoneState();
}

class _AddDocumentPhoneState extends State<AddDocumentPhone> {
  late FocusNode complaintNode;

  @override
  void initState() {
    complaintNode = FocusNode();
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final provider = Provider.of<ImageUploadProvider>(context, listen: false);
    provider.docTypeController.text = "";
    provider.clearFiles();
    dropDownProvider.getDocumentType(context);
    super.initState();
  }

  // @override
  // void dispose() {
  //   _leadNameFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ImageUploadProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBarWidget(
        title: 'Add Document',
        onLeadingPressed: () {
          provider.clearFiles();
          Navigator.of(context).pop();
        },
        onSavePressed: () async {
          provider.setCutomerId(widget.customerId);
          if (provider.selectedDocumentType != null) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            String userId = preferences.getString('userId') ?? "0";
            if (provider.images.isNotEmpty) {
              await provider.uploadImagesToAws(userId, context);
            } else if (provider.pdfs.isNotEmpty) {
              await provider.uploadPdfsToAws(userId, context);
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
                      'Pick atleast one document',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                    'Choose Document Type',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ListView(
          shrinkWrap: true,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(
            //   height: 16,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     RichText(
            //       text: TextSpan(
            //         style: GoogleFonts.plusJakartaSans(
            //           color: AppColors.textBlack,
            //           fontSize: 14,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         children: [
            //           TextSpan(
            //             text: 'Add document',
            //           ),
            //         ],
            //       ),
            //     ),
            //     InkWell(
            //       onTap: () {
            //         provider.clearFiles();
            //         Navigator.of(context).pop();
            //       },
            //       child: Icon(
            //         Icons.close,
            //         color: AppColors.textGrey4,
            //         size: 18,
            //       ),
            //     )
            //   ],
            // ),
            // const SizedBox(height: 16.0),
            CustomAutocomplete<DocumentTypeModel>(
              focusNode: complaintNode,
              enabled: true,
              showOptionsOnTap: true,
              optionsViewOpenDirection: OptionsViewOpenDirection.down,
              items: dropDownProvider.documentType,
              displayStringFunction: (model) => model.documentTypeName ?? '',
              defaultText: provider.docTypeController.text,
              labelText: 'Document Type',
              controller: provider.docTypeController,
              onSelected: (DocumentTypeModel selectedStatus) {
                setState(() {
                  provider.docTypeController.text =
                      selectedStatus.documentTypeName ?? '';
                  provider.updateDocumentType(selectedStatus.documentTypeId,
                      selectedStatus.documentTypeName);
                });
              },
              onChanged: (value) {},
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => provider.addFileMobile(),
                    child: Container(
                      color: Colors.white,
                      height: 130,
                      width: MediaQuery.sizeOf(context).width,
                      child: Center(
                        child: Stack(
                          children: [
                            DottedBorderContainer(
                              height: 130,
                              width: MediaQuery.sizeOf(context).width,
                              image: 'assets/icons/document_icon.svg',
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  'Upload Document',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.textGrey4,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => provider.addPhotoMobile(),
                    child: Container(
                      color: Colors.white,
                      height: 130,
                      width: MediaQuery.sizeOf(context).width,
                      child: Center(
                        child: Stack(
                          children: [
                            DottedBorderContainer(
                              height: 130,
                              width: MediaQuery.sizeOf(context).width,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomText(
                                  'Upload Photo',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColors.textGrey4,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            provider.images.isEmpty && provider.pdfs.isEmpty
                ? CustomText(
                    'No documents uploaded yet',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.textGrey4,
                  )
                : Column(
                    children: provider.fileInfoList.map((fileInfo) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              SvgPicture.asset(fileInfo['type'] == 'pdf'
                                  ? "assets/icons/pdf_icon.svg"
                                  : "assets/icons/document_icon.svg"),
                              Expanded(
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CustomText(
                                    fileInfo['name'] ??
                                        'Unknown file', // Display actual file name
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long file names
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      _showFileBottomSheet(
                                          context,
                                          fileInfo['data'],
                                          fileInfo['name'] ?? 'File',
                                          fileInfo['type'] ?? 'image');
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: CustomText(
                                        "View",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColors.bluebutton,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        // Remove just this file
                                        provider.fileInfoList.remove(fileInfo);
                                        provider.notifyListeners();
                                      },
                                      child: const Icon(
                                        Icons.clear,
                                        size: 18,
                                      )),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 20),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showFileBottomSheet(BuildContext context, Uint8List fileData,
      String fileName, String fileType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      fileName,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textBlack,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textGrey4,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: fileType == 'pdf'
                  ? _buildPdfViewer(context, fileData)
                  : _buildImageViewer(fileData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer(Uint8List imageData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Image.memory(
          imageData,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildPdfViewer(BuildContext context, Uint8List pdfData) {
    return PdfPreview(
      build: (format) => pdfData,
      initialPageFormat: PdfPageFormat.a4,
      useActions: true,
      canChangePageFormat: false,
      canChangeOrientation: false,
      allowPrinting: false,
      allowSharing: false,
    );
  }
}
