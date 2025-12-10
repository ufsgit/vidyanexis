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
    Directory? dir = await getDownloadsDirectory();
    dir ??= await getApplicationDocumentsDirectory();
    final String fileName = suggestedName ??
        (uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'download_${DateTime.now().millisecondsSinceEpoch}');
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
