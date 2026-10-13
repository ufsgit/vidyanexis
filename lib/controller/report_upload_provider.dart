import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_urls.dart';

class ReportUploadProvider extends ChangeNotifier {
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  String? _selectedFileExtension;
  bool _isUploading = false;

  Uint8List? get selectedFileBytes => _selectedFileBytes;
  String? get selectedFileName => _selectedFileName;
  String? get selectedFileExtension => _selectedFileExtension;
  bool get isUploading => _isUploading;

  void clearFile() {
    _selectedFileBytes = null;
    _selectedFileName = null;
    _selectedFileExtension = null;
    notifyListeners();
  }

  Future<void> pickDocument(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'csv'
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        Uint8List? fileData;

        if (kIsWeb) {
          fileData = platformFile.bytes;
        } else {
          if (platformFile.bytes != null) {
            fileData = platformFile.bytes;
          } else if (platformFile.path != null) {
            fileData = await File(platformFile.path!).readAsBytes();
          }
        }

        if (fileData != null) {
          _selectedFileBytes = fileData;
          _selectedFileName = platformFile.name;
          _selectedFileExtension = platformFile.extension;
          notifyListeners();
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting file: $e')),
        );
      }
    }
  }

  Future<String?> uploadFileOnly(
      String customerId, BuildContext context) async {
    if (_selectedFileBytes == null) return null;
    try {
      final String ext = (_selectedFileExtension ?? '').toLowerCase();
      String mimeType = 'application/octet-stream';
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
        mimeType = ext == 'jpg' ? 'image/jpeg' : 'image/$ext';
      } else if (ext.isNotEmpty) {
        mimeType = ext;
      }

      if (!context.mounted) return null;
      final String? uploadedKey = await CloudflareUpload.uploadToCloudflare(
        _selectedFileBytes!,
        mimeType,
        customerId,
        context,
      );

      return uploadedKey != null ? HttpUrls.imgBaseUrl + uploadedKey : null;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<void> uploadReport({
    required String receiptId,
    required String customerId,
    required String amount,
    required String description,
    required BuildContext context,
    required CustomerDetailsProvider customerDetailsProvider,
  }) async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a document first')),
      );
      return;
    }

    _isUploading = true;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      final String userId = preferences.getString('userId') ?? "0";
      final String userName = preferences.getString('userName') ?? "";
      final String token = preferences.getString('token') ?? "";

      // Determine mime type and upload to Cloudflare
      final String ext = (_selectedFileExtension ?? '').toLowerCase();
      String mimeType = 'application/octet-stream';
      if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
        mimeType = ext == 'jpg' ? 'image/jpeg' : 'image/$ext';
      } else if (ext.isNotEmpty) {
        mimeType = ext;
      }

      if (!context.mounted) return;
      final String? uploadedKey = await CloudflareUpload.uploadToCloudflare(
        _selectedFileBytes!,
        mimeType,
        customerId,
        context,
      );

      final String uploadedUrl =
          uploadedKey != null ? HttpUrls.imgBaseUrl + uploadedKey : '';

      final String dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (!kIsWeb) {
        try {
          (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
            final client = HttpClient();
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
        } catch (_) {}
      }

      final bodyData = {
        "Receipt_Id": receiptId,
        "Entry_Date": dateTime,
        "Description": description,
        "Amount": amount.isNotEmpty ? amount : "0",
        "Customer_Id": customerId,
        "By_User_Id": int.tryParse(userId) ?? 0,
        "By_User_Name": userName,
        "Report_Path": uploadedUrl,
        "File_Name": _selectedFileName ?? "",
      };

      const targetUrl =
          'https://futuresolarapi.ufstech.net.in/service/Save_Receipt';

      print('post request ====> $targetUrl $bodyData');

      final response = await dio.post(
        targetUrl,
        options: Options(
          headers: {
            'ngrok-skip-browser-warning': 'true',
            "Content-Type": "application/json",
            if (token.isNotEmpty) "Authorization": "Bearer $token",
          },
        ),
        data: bodyData,
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report uploaded successfully')),
          );
          clearFile();
          customerDetailsProvider.clearRecieptDetails();
          Navigator.pop(context);
          customerDetailsProvider.getRecieptListApi(customerId, context);
          customerDetailsProvider.getInvoiceRecieptTotal(customerId, context);
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to upload report (Status ${response.statusCode})')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading report: $e')),
        );
      }
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
