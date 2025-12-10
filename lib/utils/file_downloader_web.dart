import 'dart:html' as html;

class FileDownloader {
  static Future<String> download(String url, {String? suggestedName}) async {
    try {
      final response = await html.HttpRequest.request(
        url,
        method: 'GET',
        responseType: 'blob',
      );
      final blob = response.response as html.Blob;
      final objectUrl = html.Url.createObjectUrlFromBlob(blob);

      final inferredName = suggestedName ?? _inferFileName(url);

      final anchor = html.AnchorElement(href: objectUrl)
        ..download = inferredName
        ..rel = 'noopener'
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(objectUrl);
      return inferredName;
    } catch (e) {
      // Fallback: open in new tab (browser handles it)
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..rel = 'noopener'
        ..style.display = 'none';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      return url;
    }
  }

  static String _inferFileName(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.last;
      }
    } catch (_) {}
    return 'download_${DateTime.now().millisecondsSinceEpoch}';
  }
}
