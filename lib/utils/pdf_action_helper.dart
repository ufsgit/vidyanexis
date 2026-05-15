import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/utils/file_downloader.dart';
import 'package:vidyanexis/utils/file_share_function.dart';

class PdfActionHelper {
  /// Shows a modal bottom sheet with PDF actions: View/Print, Share to WhatsApp, Share via Email.
  static void showPdfOptions({
    required BuildContext context,
    required String title,
    Future<Uint8List> Function()? onGenerate,
    String? pdfUrl,
    String? fileName,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.print, color: Colors.blue),
                title: const Text('View / Print'),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (onGenerate != null) {
                    await Loader.showLoader(context);
                    try {
                      final bytes = await onGenerate();
                      Loader.stopLoader(context);
                      await Printing.layoutPdf(
                        onLayout: (format) async => bytes,
                        name: fileName ?? 'document.pdf',
                      );
                    } catch (e) {
                      Loader.stopLoader(context);
                      debugPrint('Error printing PDF: $e');
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Share PDF Document'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Loader.showLoader(context);
                  try {
                    Uint8List? bytes;
                    if (onGenerate != null) {
                      bytes = await onGenerate();
                    } else if (pdfUrl != null) {
                      final fullUrl = pdfUrl.startsWith('http')
                          ? pdfUrl
                          : '${HttpUrls.baseUrl}$pdfUrl';
                      final response = await dio.Dio().get<Uint8List>(
                        fullUrl,
                        options: dio.Options(responseType: dio.ResponseType.bytes),
                      );
                      bytes = response.data;
                    }

                    if (bytes != null && bytes.isNotEmpty) {
                      Loader.stopLoader(context);
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: fileName ?? '${title.replaceAll(' ', '_')}.pdf',
                      );
                    }
                  } catch (e) {
                    debugPrint('Error sharing PDF: $e');
                  } finally {
                    Loader.stopLoader(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.blue),
                title: const Text('Download PDF'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Loader.showLoader(context);
                  try {
                    Uint8List? bytes;
                    if (onGenerate != null) {
                      bytes = await onGenerate();
                    } else if (pdfUrl != null) {
                      final fullUrl = pdfUrl.startsWith('http')
                          ? pdfUrl
                          : '${HttpUrls.baseUrl}$pdfUrl';
                      final response = await dio.Dio().get<Uint8List>(
                        fullUrl,
                        options:
                            dio.Options(responseType: dio.ResponseType.bytes),
                      );
                      bytes = response.data;
                    }

                    if (bytes != null && bytes.isNotEmpty) {
                      final fileName =
                          '${title.replaceAll(' ', '_')}.pdf';
                      
                      if (Platform.isAndroid) {
                        try {
                          await FileDownloader.saveFile(bytes, fileName);
                          Loader.stopLoader(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloaded to Downloads folder'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Loader.stopLoader(context);
                          await Printing.sharePdf(bytes: bytes, filename: fileName);
                        }
                      } else {
                        Loader.stopLoader(context);
                        await Printing.sharePdf(bytes: bytes, filename: fileName);
                      }
                    } else {
                      Loader.stopLoader(context);
                    }
                  } catch (e) {
                    Loader.stopLoader(context);
                    debugPrint('Error downloading PDF: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a modal bottom sheet with ONLY share actions: WhatsApp and Email.
  /// Shares the ACTUAL PDF file (not a link).
  static void showShareOptions({
    required BuildContext context,
    required String title,
    Future<Uint8List> Function()? onGenerate,
    String? pdfUrl,
    String? fileName,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Share $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Share PDF Document'),
                subtitle: const Text('Direct PDF File'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Loader.showLoader(context);
                  try {
                    Uint8List? bytes;
                    if (onGenerate != null) {
                      bytes = await onGenerate();
                    } else if (pdfUrl != null) {
                      final fullUrl = pdfUrl.startsWith('http')
                          ? pdfUrl
                          : '${HttpUrls.baseUrl}$pdfUrl';
                      final response = await dio.Dio().get<Uint8List>(
                        fullUrl,
                        options: dio.Options(responseType: dio.ResponseType.bytes),
                      );
                      bytes = response.data;
                    }

                    if (bytes != null && bytes.isNotEmpty) {
                      Loader.stopLoader(context);
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: fileName ?? '${title.replaceAll(' ', '_')}.pdf',
                      );
                    }
                  } catch (e) {
                    debugPrint('Error sharing PDF: $e');
                  } finally {
                    Loader.stopLoader(context);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.blue),
                title: const Text('Download PDF'),
                subtitle: const Text('Save to device'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Loader.showLoader(context);
                  try {
                    Uint8List? bytes;
                    if (onGenerate != null) {
                      bytes = await onGenerate();
                    } else if (pdfUrl != null) {
                      final fullUrl = pdfUrl.startsWith('http')
                          ? pdfUrl
                          : '${HttpUrls.baseUrl}$pdfUrl';
                      final response = await dio.Dio().get<Uint8List>(
                        fullUrl,
                        options:
                            dio.Options(responseType: dio.ResponseType.bytes),
                      );
                      bytes = response.data;
                    }

                    if (bytes != null && bytes.isNotEmpty) {
                      final fileName = '${title.replaceAll(' ', '_')}.pdf';
                      if (Platform.isAndroid) {
                        try {
                          await FileDownloader.saveFile(bytes, fileName);
                          Loader.stopLoader(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Downloaded to Downloads folder'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Loader.stopLoader(context);
                          await Printing.sharePdf(
                              bytes: bytes, filename: fileName);
                        }
                      } else {
                        Loader.stopLoader(context);
                        await Printing.sharePdf(
                            bytes: bytes, filename: fileName);
                      }
                    } else {
                      Loader.stopLoader(context);
                    }
                  } catch (e) {
                    Loader.stopLoader(context);
                    debugPrint('Error downloading PDF: $e');
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

