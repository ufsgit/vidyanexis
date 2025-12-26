import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility to share a file (via URL) to WhatsApp.
///
/// This opens WhatsApp (native app) when available, otherwise falls back
/// to WhatsApp Web using `https://wa.me/?text=`. It sends the `fileUrl` plus
/// an optional `caption` as the message body.
class FileShare {
  /// Opens WhatsApp (or WhatsApp web) with the given [fileUrl].
  ///
  /// Returns `true` when a launcher was triggered, `false` otherwise.
  static Future<bool> shareToWhatsApp(String fileUrl, {String? caption}) async {
    final message =
        (caption == null || caption.isEmpty) ? fileUrl : '$caption\n$fileUrl';
    final encoded = Uri.encodeComponent(message);

    // Web: use wa.me web share
    if (kIsWeb) {
      final webUrl = 'https://wa.me/?text=$encoded';
      return await _launchUrl(webUrl);
    }

    // Mobile/Desktop: prefer native whatsapp scheme, fallback to web
    final nativeUrl = 'whatsapp://send?text=$encoded';
    final webUrl = 'https://wa.me/?text=$encoded';

    try {
      final nativeUri = Uri.parse(nativeUrl);
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // ignore and fallback to web
    }

    return await _launchUrl(webUrl);
  }

  static Future<bool> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
    return false;
  }

  /// Opens the user's mail client with a composed message containing [fileUrl].
  ///
  /// [to], [cc], and [bcc] are optional recipient lists. [subject] and [body]
  /// can be provided; if [body] is omitted the [fileUrl] will be used.
  /// Returns `true` when a launcher was triggered, `false` otherwise.
  static Future<bool> shareViaEmail(
    String fileUrl, {
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
  }) async {
    final finalBody =
        (body == null || body.isEmpty) ? fileUrl : '$body\n$fileUrl';

    final params = <String, String>{};
    if (subject != null && subject.isNotEmpty) {
      params['subject'] = subject;
    }
    params['body'] = finalBody;
    if (cc != null && cc.isNotEmpty) params['cc'] = cc.join(',');
    if (bcc != null && bcc.isNotEmpty) params['bcc'] = bcc.join(',');

    String toPart = '';
    if (to != null && to.isNotEmpty) {
      toPart = to.join(',');
    }

    final query = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final mailto = 'mailto:$toPart${query.isNotEmpty ? '?$query' : ''}';

    // Try native mail client first (only on mobile/desktop, not web)
    if (!kIsWeb) {
      try {
        final mailtoUri = Uri.parse(mailto);
        if (await canLaunchUrl(mailtoUri)) {
          return await launchUrl(mailtoUri,
              mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        // ignore and fallback to web
      }
    }

    // Prepare encoded params for web composers
    final encode = (String? s) => s == null ? '' : Uri.encodeComponent(s);
    final toParam = toPart.isNotEmpty ? Uri.encodeComponent(toPart) : '';
    final ccParam =
        cc != null && cc.isNotEmpty ? Uri.encodeComponent(cc.join(',')) : '';
    final bccParam =
        bcc != null && bcc.isNotEmpty ? Uri.encodeComponent(bcc.join(',')) : '';
    final subjectEnc = encode(subject ?? '');
    final bodyEnc = encode(finalBody);

    // Gmail compose URL - proper parameter encoding
    final gmailParams = <String, String>{};
    gmailParams['view'] = 'cm';
    gmailParams['fs'] = '1';
    if (toParam.isNotEmpty) gmailParams['to'] = toParam;
    if (subjectEnc.isNotEmpty) gmailParams['su'] = subjectEnc;
    if (bodyEnc.isNotEmpty) gmailParams['body'] = bodyEnc;
    if (ccParam.isNotEmpty) gmailParams['cc'] = ccParam;
    if (bccParam.isNotEmpty) gmailParams['bcc'] = bccParam;

    final gmailQuery = gmailParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${e.value}')
        .join('&');
    final gmailUrl = 'https://mail.google.com/mail/?$gmailQuery';

    if (await _launchUrl(gmailUrl)) return true;

    // Outlook web compose
    final outlookParams = <String, String>{};
    outlookParams['path'] = '/mail/action/compose';
    if (toParam.isNotEmpty) outlookParams['to'] = toParam;
    if (subjectEnc.isNotEmpty) outlookParams['subject'] = subjectEnc;
    if (bodyEnc.isNotEmpty) outlookParams['body'] = bodyEnc;
    if (ccParam.isNotEmpty) outlookParams['cc'] = ccParam;

    final outlookQuery = outlookParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${e.value}')
        .join('&');
    final outlookUrl = 'https://outlook.office.com/?$outlookQuery';

    if (await _launchUrl(outlookUrl)) return true;

    // Final fallback: open Gmail home (will prompt login if necessary)
    return await _launchUrl('https://mail.google.com');
  }
}
