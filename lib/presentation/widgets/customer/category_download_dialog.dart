import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/document_category_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class DocumentCategoryDownloadDialog extends StatefulWidget {
  final String customerId;

  const DocumentCategoryDownloadDialog({
    super.key,
    required this.customerId,
  });

  @override
  State<DocumentCategoryDownloadDialog> createState() =>
      _DocumentCategoryDownloadDialogState();
}

class _DocumentCategoryDownloadDialogState
    extends State<DocumentCategoryDownloadDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getItemDocumentCategories(widget.customerId);
    });
  }

  String _getFullUrl(String path) {
    if (path.startsWith('http')) return path;
    return HttpUrls.imgBaseUrl + path;
  }

  // Open PDF in new tab
  Future<void> _openPdfInNewTab(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open PDF: $e')),
        );
      }
    }
  }

  Future<void> _printImage(BuildContext context, String url) async {
    try {
      final isPdf = url.toLowerCase().split('?').first.endsWith('.pdf');

      final iframe = html.IFrameElement()
        ..style.position = 'fixed'
        ..style.right = '0'
        ..style.bottom = '0'
        ..style.width = '1px'
        ..style.height = '1px'
        ..style.opacity = '0'
        ..style.border = '0';

      if (isPdf) {
        final req = await html.HttpRequest.request(url, responseType: 'blob');
        final blobUrl =
            html.Url.createObjectUrlFromBlob(req.response as html.Blob);

        // runs as plain JS inside the page, so no Dart cross-frame wrapper
        iframe.setAttribute(
          'onload',
          'var f=this;setTimeout(function(){'
              'f.contentWindow.focus();f.contentWindow.print();'
              '},500)',
        );
        iframe.src = blobUrl;
      } else {
        iframe.srcdoc = '<html><head><title> </title>'
            '<style>'
            '@page{size:A4;margin:0}'
            'html,body{margin:0;padding:0}'
            'img{display:block;width:100%;height:100vh;object-fit:contain}'
            '</style></head><body>'
            '<img src="$url" onload="window.focus();window.print()">'
            '</body></html>';
      }

      html.document.body!.append(iframe);
      Future.delayed(const Duration(minutes: 1), iframe.remove);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    }
  }

  // ---------- Full screen viewer ----------
  void _showFullScreenViewer(
    BuildContext context,
    int initialIndex,
    List<DocumentItem> items,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final pageController = PageController(initialPage: initialIndex);

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: FocusScope(
            autofocus: true,
            child: KeyboardListener(
              autofocus: true,
              focusNode: FocusNode(),
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    if ((pageController.page ?? 0) > 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    if ((pageController.page ?? 0) < items.length - 1) {
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
                      final fullUrl = _getFullUrl(item.filePath);

                      // ---------- PDF ----------
                      if (item.isPdf) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  color: Colors.redAccent, size: 90),
                              const SizedBox(height: 20),
                              const Text(
                                'PDF Document',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _openPdfInNewTab(fullUrl),
                                icon: const Icon(Icons.open_in_new,
                                    color: Colors.white, size: 22),
                                label: const Text(
                                  'Open PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // ---------- Image ----------
                      return Stack(
                        children: [
                          InteractiveViewer(
                            child: Center(
                              child: Image.network(
                                fullUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.1),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _printImage(context, fullUrl),
                                icon: const Icon(Icons.print,
                                    color: Colors.white, size: 20),
                                label: const Text(
                                  'Print Image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Navigation
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        if ((pageController.page ?? 0) > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white),
                      onPressed: () {
                        if ((pageController.page ?? 0) < items.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
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

  // ---------- Thumbnail ----------
  Widget _buildDocumentCard(
    BuildContext context,
    DocumentItem doc,
    List<DocumentItem> allDocs,
    int index,
  ) {
    final isWeb = AppStyles.isWebScreen(context);
    final size = isWeb ? 120.0 : 100.0;
    final fullUrl = _getFullUrl(doc.filePath);

    return SizedBox(
      width: size,
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (doc.isPdf) {
                    _openPdfInNewTab(fullUrl); // PDF → new tab
                  } else {
                    _showFullScreenViewer(context, index, allDocs);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: size,
                    height: size,
                    color: Colors.grey[200],
                    child: doc.isImage
                        ? Image.network(
                            fullUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 40),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                doc.isPdf
                                    ? Icons.picture_as_pdf
                                    : Icons.insert_drive_file,
                                color: doc.isPdf ? Colors.red : Colors.grey,
                                size: 42,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                doc.isPdf ? 'PDF' : 'File',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              // if (doc.isImage)
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: () => _printImage(context, fullUrl),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.print,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            doc.documentTypeName,
            style: const TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = AppStyles.isWebScreen(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 60 : 16,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWeb ? 780 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Consumer<CustomerDetailsProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Document Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Body
                Flexible(
                  child: provider.isDocumentCategoriesLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : provider.documentCategoriesError != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  provider.documentCategoriesError!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : provider.documentCategories.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No categories found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  itemCount: provider.documentCategories.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 20),
                                  itemBuilder: (context, index) {
                                    final category =
                                        provider.documentCategories[index];
                                    final docs = category.documents;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                category.documentCategoryName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            // if (docs.isNotEmpty)
                                            //   SizedBox(
                                            //     height: 34,
                                            //     child: CustomElevatedButton(
                                            //       radius: 6,
                                            //       backgroundColor:
                                            //           AppColors.whiteColor,
                                            //       borderColor:
                                            //           AppColors.darkGreen,
                                            //       textColor:
                                            //           AppColors.darkGreen,
                                            //       buttonText: 'Download All',
                                            //       textSize: 12,
                                            //       horizontalPadding: 12,
                                            //       verticalPadding: 0,
                                            //       onPressed: () async {
                                            //         Loader.showLoader(context);
                                            //         await provider
                                            //             .downloadCategoryDocuments(
                                            //           customerId:
                                            //               widget.customerId,
                                            //           categoryId: category
                                            //               .documentCategoryId,
                                            //           categoryName: category
                                            //               .documentCategoryName,
                                            //         );
                                            //         Loader.stopLoader(context);
                                            //       },
                                            //     ),
                                            //   ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (docs.isEmpty)
                                          const Text(
                                            'No documents',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                            ),
                                          )
                                        else
                                          SizedBox(
                                            height: isWeb ? 155 : 140,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: docs.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(width: 12),
                                              itemBuilder: (context, docIndex) {
                                                return _buildDocumentCard(
                                                  context,
                                                  docs[docIndex],
                                                  docs,
                                                  docIndex,
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                ),

                // Footer
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
