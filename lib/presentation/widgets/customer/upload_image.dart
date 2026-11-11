import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class ImageUploadAlert extends StatefulWidget {
  final String customerId;
  final int? initialDocumentTypeId;
  final String? initialDocumentTypeName;
  final String? taskId;

  const ImageUploadAlert({
    super.key,
    required this.customerId,
    this.initialDocumentTypeId,
    this.initialDocumentTypeName,
    this.taskId,
  });

  @override
  _ImageUploadAlertState createState() => _ImageUploadAlertState();
}

class _ImageUploadAlertState extends State<ImageUploadAlert> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _selectedDocsKey = GlobalKey();
  String _searchQuery = '';
  bool _isUploading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFiles() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedDocsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _selectedDocsKey.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

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

    final filteredDocTypes = dropDownProvider.documentType.where((docType) {
      if (_searchQuery.isEmpty) return true;
      final name = (docType.documentTypeName ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase().trim());
    }).toList();

    return PopScope(
      canPop: !_isUploading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.initialDocumentTypeId == null) ...[
                        Container(
                          height: 40,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search document type...',
                              hintStyle: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade500),
                              prefixIcon: const Icon(Icons.search,
                                  size: 20, color: Colors.grey),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          size: 18, color: Colors.grey),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        if (filteredDocTypes.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: CustomText(
                                'No matching document types',
                                fontSize: 13,
                                color: AppColors.textGrey3,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredDocTypes.length,
                            separatorBuilder: (context, index) => Divider(
                                color: Colors.grey.withOpacity(0.2), height: 1),
                            itemBuilder: (context, index) {
                              final docType = filteredDocTypes[index];
                              final selectedCount = provider.fileInfoList
                                  .where((e) =>
                                      e['docTypeId'] == docType.documentTypeId)
                                  .length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
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
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Row(
                                                    children: [
                                                      CustomText(
                                                        '$selectedCount file${selectedCount > 1 ? 's' : ''} added',
                                                        fontSize: 11,
                                                        color:
                                                            AppColors.appViolet,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      InkWell(
                                                        onTap: _scrollToFiles,
                                                        child: const Text(
                                                          'View',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'PlusJakartaSans',
                                                            fontSize: 11,
                                                            color: Color(
                                                                0xFF1A7AE8),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                                            // _showPickOptions(context, provider);
                                            await provider.addFileMobile();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: selectedCount > 0
                                                  ? AppColors.appViolet
                                                  : AppColors.appViolet
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                  ),

                                  // ---------- Description box (only when files exist) ----------
                                  if (selectedCount > 0) ...[
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: CustomTextField(
                                        height: 54,
                                        controller: TextEditingController(
                                          text: provider.getDescription(
                                              docType.documentTypeId),
                                        )..selection = TextSelection.collapsed(
                                            offset: provider
                                                .getDescription(
                                                    docType.documentTypeId)
                                                .length),
                                        hintText: 'Add description',
                                        labelText: '',
                                        onChanged: (value) {
                                          provider.updateDescription(
                                              docType.documentTypeId, value);
                                        },
                                        keyboardType: TextInputType.multiline,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ],
                              );
                            },
                          ),
                      ] else ...[
                        // Initial document type view
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.appViolet.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(4),
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
                                radius: 4,
                                textSize: 12,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (provider.fileInfoList.isNotEmpty) ...[
                        KeyedSubtree(
                          key: _selectedDocsKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        AppColors.textGrey2.withOpacity(0.3)),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            _showPreview(context, fileInfo),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            'View',
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              color: Color(0xFF1A7AE8),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          provider.removeFileAt(index);
                                        },
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red, size: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                            ],
                          ),
                        ),
                      ] else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 48,
                                    color:
                                        AppColors.textGrey2.withOpacity(0.5)),
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
                    onPressed: _isUploading
                        ? null
                        : () {
                            provider.clearFiles();
                            Navigator.pop(context);
                          },
                    buttonText: 'Cancel',
                    backgroundColor: Colors.white,
                    borderColor: AppColors.textGrey2,
                    textColor: AppColors.textBlack,
                    radius: 4,
                  ),
                  const SizedBox(width: 12),
                  CustomElevatedButton(
                    isLoading: _isUploading,
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (_isUploading) return;
                            provider.setCutomerId(widget.customerId);
                            if (provider.fileInfoList.isNotEmpty) {
                              setState(() {
                                _isUploading = true;
                              });
                              try {
                                await provider.uploadAllDocumentsGrouped(
                                  context,
                                  taskId: widget.taskId,
                                );
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isUploading = false;
                                  });
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Pick at least one document')),
                              );
                            }
                          },
                    buttonText: 'Upload Documents',
                    backgroundColor: AppColors.appViolet,
                    borderColor: AppColors.appViolet,
                    textColor: Colors.white,
                    radius: 4,
                  ),
                ],
              ),
            ],
          ),
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
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1A7AE8)),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await provider.addPhotoMobile(allowCamera: true);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF1A7AE8)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await provider.addPhotoMobile(allowCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF1A7AE8)),
              title: const Text('Upload Document'),
              onTap: () async {
                Navigator.pop(context);
                await provider.addFileMobile();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, Map<String, dynamic> fileInfo) {
    final dynamic rawData = fileInfo['data'];
    Uint8List? fileData;
    if (rawData is Uint8List) {
      fileData = rawData;
    } else if (rawData is List<int>) {
      fileData = Uint8List.fromList(rawData);
    }
    final String fileName = fileInfo['name'] as String? ?? 'File';
    final String mimeType = fileInfo['mimeType'] as String? ?? '';
    final String type = fileInfo['type'] as String? ?? 'image';
    final lowerName = fileName.toLowerCase();
    final isImage = type == 'image' ||
        mimeType.startsWith('image/') ||
        lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.webp');
    final isPdf = type == 'pdf' ||
        mimeType == 'application/pdf' ||
        lowerName.endsWith('.pdf');

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        final screenHeight = MediaQuery.of(ctx).size.height;
        final isWeb = AppStyles.isWebScreen(ctx);

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: isWeb
              ? const EdgeInsets.symmetric(horizontal: 60, vertical: 30)
              : EdgeInsets.zero,
          child: SizedBox(
            width: isWeb ? screenWidth * 0.85 : screenWidth,
            height: isWeb ? screenHeight * 0.9 : screenHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  top: 60,
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: isPdf && fileData != null && fileData.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PdfPreview(
                            build: (format) => fileData!,
                            useActions: false,
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            canDebug: false,
                            dynamicLayout: false,
                            allowPrinting: false,
                            allowSharing: false,
                            initialPageFormat: PdfPageFormat.a4,
                            pdfFileName: fileName,
                            loadingWidget: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            onError: (context, error) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.picture_as_pdf,
                                      size: 64, color: Colors.redAccent),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Unable to preview PDF: $error',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : isImage && fileData != null && fileData.isNotEmpty
                          ? Center(
                              child: InteractiveViewer(
                                minScale: 0.5,
                                maxScale: 4.0,
                                child: Image.memory(
                                  fileData,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 64,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPdf
                                        ? Icons.picture_as_pdf
                                        : Icons.insert_drive_file,
                                    size: 72,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Text(
                                      fileName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  right: 60,
                  child: Row(
                    children: [
                      Icon(
                        isPdf
                            ? Icons.picture_as_pdf
                            : (isImage ? Icons.image : Icons.insert_drive_file),
                        color: isPdf ? Colors.redAccent : Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 12,
                  child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(ctx),
                    tooltip: 'Close',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
