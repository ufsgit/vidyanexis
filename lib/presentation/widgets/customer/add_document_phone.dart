import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
          if (provider.fileInfoList.isNotEmpty) {
            await provider.uploadAllDocumentsGrouped(context);
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
            CustomTextfieldWidgetMobile(
              controller: _searchController,
              labelText: 'Search Document Type',
              prefixIcon: Icon(Icons.search, color: AppColors.textGrey2, size: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dropDownProvider.documentType
                  .where((e) => e.documentTypeName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
                  .length,
              itemBuilder: (context, index) {
                final filteredList = dropDownProvider.documentType
                    .where((e) => e.documentTypeName
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();
                final docType = filteredList[index];
                final selectedCount = provider.fileInfoList
                    .where((e) => e['docTypeId'] == docType.documentTypeId)
                    .length;

                return Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedCount > 0
                          ? AppColors.bluebutton.withOpacity(0.5)
                          : AppColors.textGrey2.withOpacity(0.2),
                      width: selectedCount > 0 ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.01),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              docType.documentTypeName ?? '',
                              fontSize: 13,
                              fontWeight: selectedCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: AppColors.textBlack,
                            ),
                            if (selectedCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: CustomText(
                                  '$selectedCount file${selectedCount > 1 ? 's' : ''} added',
                                  fontSize: 10,
                                  color: AppColors.bluebutton,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          provider.updateDocumentType(
                              docType.documentTypeId, docType.documentTypeName);
                          _showPickOptions(context, provider);
                        },
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: selectedCount > 0
                                ? AppColors.bluebutton
                                : AppColors.bluebutton.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            selectedCount > 0 ? Icons.add : Icons.upload_sharp,
                            color: selectedCount > 0
                                ? Colors.white
                                : AppColors.bluebutton,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(
              height: 12,
            ),
            provider.fileInfoList.isEmpty
                ? Center(
                    child: CustomText(
                      'No documents uploaded yet',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.textGrey4,
                    ),
                  )
                : Column(
                    children: provider.fileInfoList.map((fileInfo) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.textGrey2.withOpacity(0.3))),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        fileInfo['name'] ?? 'Unknown file',
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13,
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
                                      child: Icon(
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

  void _showPickOptions(BuildContext context, ImageUploadProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.appViolet),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                provider.addPhotoMobile(allowCamera: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.appViolet),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(context);
                provider.addPhotoMobile(allowCamera: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: AppColors.appViolet),
              title: const Text('Upload Document (PDF/Image)'),
              onTap: () {
                Navigator.pop(context);
                provider.addFileMobile();
              },
            ),
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
