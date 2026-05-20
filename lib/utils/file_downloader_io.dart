import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloader {
  static Future<String> download(String url, {String? suggestedName}) async {
    final uri = Uri.parse(url);
    final client = HttpClient();
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    final String fileName = suggestedName ??
        (uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'download_${DateTime.now().millisecondsSinceEpoch}');
    return await saveFile(bytes, fileName);
  }

  static Future<String> saveFile(Uint8List bytes, String fileName) async {
    Directory? dir;
    if (Platform.isAndroid) {
      // Try to find the public Download folder
      try {
        final List<String> commonPaths = [
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Downloads',
        ];
        for (var p in commonPaths) {
          final d = Directory(p);
          if (await d.exists()) {
            dir = d;
            break;
          }
        }

        if (dir == null) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final String rootPath = externalDir.path.split('Android')[0];
            final downloadDir = Directory('${rootPath}Download');
            if (await downloadDir.exists()) {
              dir = downloadDir;
            } else {
              // Try to create it if it doesn't exist (might fail due to permissions)
              await downloadDir.create(recursive: true);
              dir = downloadDir;
            }
          }
        }
      } catch (e) {
        debugPrint("Error finding Download folder: $e");
      }
    }

    dir ??= await getDownloadsDirectory(); // Works on Desktop
    dir ??= await getApplicationDocumentsDirectory(); // iOS / Fallback

    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    debugPrint("File saved to: ${file.path}");
    return file.path;
  }
}
