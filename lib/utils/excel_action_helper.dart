import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/utils/file_downloader.dart';

class ExcelActionHelper {
  static Future<void> downloadExcelDirect({
    required BuildContext context,
    required Future<Uint8List?> Function() onGenerate,
    String fileName = 'Customers.xlsx',
  }) async {
    try {
      final bytes = await onGenerate();

      if (!context.mounted) return;

      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data to export')),
        );
        return;
      }

      // ---------- WEB ----------
      if (kIsWeb) {
        final blob = html.Blob(
          [bytes],
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

        html.document.body!.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Excel downloaded'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }

      // ---------- ANDROID ----------
      if (Platform.isAndroid) {
        try {
          await FileDownloader.saveFile(bytes, fileName);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Downloaded to Downloads folder'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/$fileName');
          await file.writeAsBytes(bytes);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved to: ${file.path}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        return;
      }

      // ---------- iOS & others ----------
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to: ${file.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
