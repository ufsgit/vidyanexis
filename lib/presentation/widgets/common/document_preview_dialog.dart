import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<bool?> showDocumentPreviewDialog({
  required BuildContext context,
  required String fileName,
  required Uint8List? bytes,
  required String? mimeType,
  Future<bool> Function()? onUpload,
}) {
  final lower = fileName.toLowerCase();
  final isImage = (mimeType?.startsWith('image/') ?? false) ||
      lower.endsWith('.jpg') ||
      lower.endsWith('.jpeg') ||
      lower.endsWith('.png') ||
      lower.endsWith('.webp');
  final isPdf = (mimeType == 'application/pdf') || lower.endsWith('.pdf');

  bool isUploading = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return PopScope(
            canPop: !isUploading,
            child: Dialog(
              backgroundColor: Colors.black,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                children: [
                  // Preview content
                  Center(
                    child: isImage && bytes != null
                        ? InteractiveViewer(
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image,
                                      size: 72, color: Colors.white70),
                                  SizedBox(height: 12),
                                  Text(
                                    'Unable to preview image',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : isPdf
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.picture_as_pdf,
                                      size: 80, color: Colors.red.shade400),
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 24),
                                    child: Text(
                                      fileName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.insert_drive_file,
                                      size: 72, color: Colors.white70),
                                  const SizedBox(height: 12),
                                  Text(
                                    fileName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                  ),

                  // Title
                  Positioned(
                    top: 48,
                    left: 16,
                    right: 60,
                    child: Text(
                      fileName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Close
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isUploading ? Colors.white38 : Colors.white,
                        size: 28,
                      ),
                      onPressed: isUploading
                          ? null
                          : () => Navigator.pop(ctx, false),
                    ),
                  ),

                  // Cancel / Upload at bottom
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  isUploading ? Colors.grey : Colors.black,
                              backgroundColor:
                                  isUploading ? const Color(0xFFF1F5F9) : Colors.white,
                              side: BorderSide(
                                color: isUploading
                                    ? Colors.grey.shade400
                                    : Colors.black,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: isUploading
                                ? null
                                : () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A7AE8),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFF1A7AE8),
                              disabledForegroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: isUploading
                                ? null
                                : () async {
                                    if (isUploading) return;
                                    setState(() {
                                      isUploading = true;
                                    });
                                    if (onUpload != null) {
                                      try {
                                        final ok = await onUpload();
                                        if (ctx.mounted) {
                                          if (ok) {
                                            Navigator.pop(ctx, true);
                                          } else {
                                            setState(() {
                                              isUploading = false;
                                            });
                                            ScaffoldMessenger.of(ctx)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to upload document. Please try again.'),
                                              ),
                                            );
                                          }
                                        }
                                      } catch (e) {
                                        if (ctx.mounted) {
                                          setState(() {
                                            isUploading = false;
                                          });
                                          ScaffoldMessenger.of(ctx)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Upload failed: ${e.toString().replaceAll('Exception:', '').trim()}',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      Navigator.pop(ctx, true);
                                    }
                                  },
                            child: isUploading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Upload',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}