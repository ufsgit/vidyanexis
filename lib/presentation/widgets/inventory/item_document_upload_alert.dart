import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/item_document_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class ItemDocumentUploadAlert extends StatefulWidget {
  final int itemId;
  final String itemName;

  const ItemDocumentUploadAlert({
    super.key,
    required this.itemId,
    required this.itemName,
  });

  @override
  _ItemDocumentUploadAlertState createState() =>
      _ItemDocumentUploadAlertState();
}

class _ItemDocumentUploadAlertState extends State<ItemDocumentUploadAlert> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);

      dropDownProvider.getDocumentType(context);
      expenseProvider.clearPendingItemFiles();
      expenseProvider.getItemDocuments(widget.itemId, context);
    });
  }

  // ---------- Fullscreen (same as document page) ----------
  void _showFullScreenImage(
    BuildContext context,
    int initialIndex,
    List<dynamic> items,
    bool baseImgUrl,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final PageController pageController =
            PageController(initialPage: initialIndex);

        return Dialog(
          backgroundColor: Colors.black,
          child: FocusScope(
            autofocus: true,
            child: KeyboardListener(
              autofocus: true,
              focusNode: FocusNode(),
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if (pageController.page! > 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    if (pageController.page! < items.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: items.length,
                    controller: pageController,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final String imagePath = item is ItemDocumentModel
                          ? item.filePath
                          : (item['filePath'] as String? ?? '');

                      final isPdf = imagePath.toLowerCase().endsWith('.pdf') ||
                          imagePath.toLowerCase().contains('.pdf');

                      if (isPdf) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  size: 80, color: Colors.red),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () async {
                                  final url = Uri.parse(imagePath);
                                  try {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    debugPrint('Could not open PDF: $e');
                                  }
                                },
                                icon: const Icon(Icons.open_in_new,
                                    color: Colors.white),
                                label: const Text('Open PDF',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      }

                      return Center(
                        child: Image.network(
                          baseImgUrl
                              ? imagePath
                              : HttpUrls.imgBaseUrl + imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.hide_image_outlined,
                                  size: 50, color: Colors.white),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 0,
                    left: 20,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        if (pageController.page! > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 20,
                    bottom: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        if (pageController.page! < items.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Thumbnail widget
  Widget _buildThumbnail({
    required String filePath,
    required String? fileName,
    required bool isPdf,
    required VoidCallback onTap,
    required Widget actionButton, // delete or X
  }) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade100,
                    child: isPdf
                        ? const Center(
                            child: Icon(Icons.picture_as_pdf,
                                size: 40, color: Colors.red),
                          )
                        : Image.network(
                            filePath,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.insert_drive_file,
                                  size: 36, color: Colors.grey),
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: actionButton,
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (fileName != null)
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    final filteredDocTypes = dropDownProvider.documentType.where((docType) {
      if (_searchQuery.isEmpty) return true;
      final name = (docType.documentTypeName ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase().trim());
    }).toList();

    // Group saved (API) documents by documentTypeId
    final Map<int, List<ItemDocumentModel>> savedByType = {};
    for (final doc in provider.itemDocuments) {
      savedByType.putIfAbsent(doc.documentTypeId, () => []).add(doc);
    }

    // Group pending (Cloudflare only) by docTypeId
    final Map<int, List<Map<String, dynamic>>> pendingByType = {};
    for (final file in provider.pendingItemFiles) {
      final typeId = file['docTypeId'] as int? ?? 0;
      pendingByType.putIfAbsent(typeId, () => []).add(file);
    }

    return Dialog(
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
            // Header
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
                    provider.clearPendingItemFiles();
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
                    // Search
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
                          setState(() => _searchQuery = value);
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
                        separatorBuilder: (_, __) => Divider(
                            color: Colors.grey.withOpacity(0.2), height: 1),
                        itemBuilder: (context, index) {
                          final docType = filteredDocTypes[index];
                          final typeId = docType.documentTypeId;

                          final savedList = savedByType[typeId] ?? [];
                          final pendingList = pendingByType[typeId] ?? [];
                          final totalCount =
                              savedList.length + pendingList.length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Document type row + upload button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
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
                                            fontWeight: totalCount > 0
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: AppColors.textBlack,
                                          ),
                                          if (totalCount > 0)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: CustomText(
                                                '$totalCount file${totalCount > 1 ? 's' : ''}',
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
                                        await provider.pickAndUploadItemFiles(
                                          docTypeId: typeId,
                                          docTypeName:
                                              docType.documentTypeName ?? '',
                                          context: context,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: totalCount > 0
                                              ? AppColors.appViolet
                                              : AppColors.appViolet
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          totalCount > 0
                                              ? Icons.add
                                              : Icons.upload_sharp,
                                          color: totalCount > 0
                                              ? Colors.white
                                              : AppColors.appViolet,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Thumbnails under this document type
                              if (savedList.isNotEmpty ||
                                  pendingList.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      // ----- Saved (API) → DELETE button -----
                                      ...savedList.asMap().entries.map((entry) {
                                        final i = entry.key;
                                        final doc = entry.value;
                                        final isPdf = doc.filePath
                                                .toLowerCase()
                                                .endsWith('.pdf') ||
                                            doc.filePath
                                                .toLowerCase()
                                                .contains('.pdf');

                                        return _buildThumbnail(
                                          filePath: doc.filePath,
                                          fileName:
                                              doc.filePath.split('/').last,
                                          isPdf: isPdf,
                                          onTap: () {
                                            _showFullScreenImage(
                                              context,
                                              i,
                                              savedList,
                                              true,
                                            );
                                          },
                                          actionButton: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                      'Delete Document'),
                                                  content: const Text(
                                                      'Are you sure you want to delete this document?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        provider
                                                            .deleteItemDocument(
                                                          documentId: doc
                                                              .itemDocumentId,
                                                          itemId: widget.itemId,
                                                          context: context,
                                                        );
                                                      },
                                                      child: const Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: const CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.delete,
                                                  size: 16, color: Colors.red),
                                            ),
                                          ),
                                        );
                                      }),

                                      // ----- Pending (Cloudflare only) → X button -----
                                      ...pendingList
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key;
                                        final file = entry.value;
                                        final path =
                                            file['filePath'] as String? ?? '';
                                        final isPdf = file['type'] == 'pdf' ||
                                            path.toLowerCase().endsWith('.pdf');

                                        // global index in pendingItemFiles for remove
                                        final globalIndex = provider
                                            .pendingItemFiles
                                            .indexOf(file);

                                        return _buildThumbnail(
                                          filePath: path,
                                          fileName: file['name'] as String?,
                                          isPdf: isPdf,
                                          onTap: () {
                                            _showFullScreenImage(
                                              context,
                                              i,
                                              pendingList,
                                              true,
                                            );
                                          },
                                          actionButton: GestureDetector(
                                            onTap: () {
                                              if (globalIndex >= 0) {
                                                provider.removePendingItemFile(
                                                    globalIndex);
                                              }
                                            },
                                            child: const CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.white,
                                              child: Icon(Icons.close,
                                                  size: 16, color: Colors.red),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomElevatedButton(
                  onPressed: () {
                    provider.clearPendingItemFiles();
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
                  onPressed: () async {
                    await provider.saveItemDocuments(
                      itemId: widget.itemId,
                      context: context,
                    );
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
    );
  }
}
