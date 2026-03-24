import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:convert/convert.dart';

class CloudflareUpload {
  static Future<String?> uploadToCloudflare(
    Uint8List result,
    String fileType,
    String taskId,
    BuildContext context,
  ) async {
    try {
      final accessKey = "65cb84d8b8d8a2880efd1100dababc31";
      final secretKey =
          "28be688805e41781c41cf5c66f3e56add70f7d0699e3d7acdbc71cb23fac30a1";
      final bucketName = "vidyanexis";
      final accountId = "538b13d4d239da205337637dc6b57ff0";

      // Generate unique filename
      String uploadFileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Extract extension from fileType (e.g., "image/jpeg" -> "jpeg")
      String extension =
          fileType.contains('/') ? fileType.split('/').last : fileType;

      // Create file path similar to your AWS structure
      String uploadFilePath = 'UploadedImages/$taskId/';
      String fileName = '$uploadFilePath$uploadFileName.$extension';

      final endpoint = "https://$accountId.r2.cloudflarestorage.com";
      final uploadUrl = "$endpoint/$bucketName/$fileName";

      print('=== Upload Debug ===');
      print('File name: $fileName');
      print('Upload URL: $uploadUrl');
      print('File type: $fileType');
      print('Payload size: ${result.length} bytes');

      final now = DateTime.now().toUtc();
      final dateStamp = DateFormat('yyyyMMdd').format(now);
      final amzDate = DateFormat('yyyyMMdd\'T\'HHmmss\'Z\'').format(now);

      // Use the Uint8List result directly (no file reading needed)
      final payload = result;
      final payloadHash = sha256.convert(payload).toString();

      final canonicalHeaders = "host:$accountId.r2.cloudflarestorage.com\n"
          "x-amz-content-sha256:$payloadHash\n"
          "x-amz-date:$amzDate\n";

      final signedHeaders = "host;x-amz-content-sha256;x-amz-date";

      final canonicalRequest = "PUT\n"
          "/$bucketName/$fileName\n"
          "\n"
          "$canonicalHeaders\n"
          "$signedHeaders\n"
          "$payloadHash";

      final canonicalRequestHash =
          sha256.convert(utf8.encode(canonicalRequest)).toString();

      // Cloudflare R2 uses "auto" region, not "us-east-1"
      final scope = "$dateStamp/auto/s3/aws4_request";
      final stringToSign =
          "AWS4-HMAC-SHA256\n$amzDate\n$scope\n$canonicalRequestHash";

      List<int> hmacSha256(List<int> key, String data) =>
          Hmac(sha256, key).convert(utf8.encode(data)).bytes;

      final kSecret = utf8.encode("AWS4$secretKey");
      final kDate = hmacSha256(kSecret, dateStamp);
      final kRegion = hmacSha256(kDate, "auto"); // Changed to "auto"
      final kService = hmacSha256(kRegion, "s3");
      final kSigning = hmacSha256(kService, "aws4_request");

      final signature = hex.encode(hmacSha256(kSigning, stringToSign));

      final authorization =
          "AWS4-HMAC-SHA256 Credential=$accessKey/$scope, SignedHeaders=$signedHeaders, Signature=$signature";

      // Set proper Content-Type
      String getContentType(String type) {
        if (type.contains('/')) return type; // Already in MIME format

        switch (type.toLowerCase()) {
          case 'jpg':
          case 'jpeg':
            return 'image/jpeg';
          case 'png':
            return 'image/png';
          case 'pdf':
            return 'application/pdf';
          default:
            return 'application/octet-stream';
        }
      }

      final headers = {
        "x-amz-date": amzDate,
        "x-amz-content-sha256": payloadHash,
        "Authorization": authorization,
        "Content-Type": getContentType(fileType),
      };

      print('Uploading to R2...');

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: headers,
        body: payload,
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✓ Upload successful');
        // Return the path (like your AWS S3 version does)
        return fileName;
      } else {
        print('✗ Upload failed');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e, stackTrace) {
      print('✗ Error uploading to R2: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      return null;
    }
  }

  static Future<String?> uploadAudioToCloudflare(
    Uint8List result,
    String fileType,
    String taskId,
    BuildContext context,
  ) async {
    try {
      final accessKey = "4884c170ed667f280f2615c329abaf1c";
      final secretKey =
          "38b75cffcaac51c100560eabac6a743dfe0a2943d36300d53012fcdd97bfab65";
      final bucketName = "vidyanexis";
      final accountId = "e8b03061a99616c9340485f214c19a68";

      // ===== FILE INFO =====
      String uploadFileName = '${DateTime.now().millisecondsSinceEpoch}_audio';

      String extension =
          fileType.contains('/') ? fileType.split('/').last : fileType;

      String uploadFilePath = 'UploadedAudios/$taskId/';
      String fileName = '$uploadFilePath$uploadFileName.$extension';

      final endpoint = "https://$accountId.r2.cloudflarestorage.com";
      final uploadUrl = "$endpoint/$bucketName/$fileName";

      print('=== Audio Upload Debug ===');
      print('File name: $fileName');
      print('Upload URL: $uploadUrl');
      print('File type: $fileType');
      print('Payload size: ${result.length} bytes');

      final now = DateTime.now().toUtc();
      final dateStamp = DateFormat('yyyyMMdd').format(now);
      final amzDate = DateFormat('yyyyMMdd\'T\'HHmmss\'Z\'').format(now);

      final payload = result;
      final payloadHash = sha256.convert(payload).toString();

      final canonicalHeaders = "host:$accountId.r2.cloudflarestorage.com\n"
          "x-amz-content-sha256:$payloadHash\n"
          "x-amz-date:$amzDate\n";

      final signedHeaders = "host;x-amz-content-sha256;x-amz-date";

      final canonicalRequest = "PUT\n"
          "/$bucketName/$fileName\n"
          "\n"
          "$canonicalHeaders\n"
          "$signedHeaders\n"
          "$payloadHash";

      final canonicalRequestHash =
          sha256.convert(utf8.encode(canonicalRequest)).toString();

      final scope = "$dateStamp/auto/s3/aws4_request";
      final stringToSign =
          "AWS4-HMAC-SHA256\n$amzDate\n$scope\n$canonicalRequestHash";

      List<int> hmacSha256(List<int> key, String data) =>
          Hmac(sha256, key).convert(utf8.encode(data)).bytes;

      final kSecret = utf8.encode("AWS4$secretKey");
      final kDate = hmacSha256(kSecret, dateStamp);
      final kRegion = hmacSha256(kDate, "auto");
      final kService = hmacSha256(kRegion, "s3");
      final kSigning = hmacSha256(kService, "aws4_request");

      final signature = hex.encode(hmacSha256(kSigning, stringToSign));

      final authorization =
          "AWS4-HMAC-SHA256 Credential=$accessKey/$scope, SignedHeaders=$signedHeaders, Signature=$signature";

      String getAudioContentType(String type) {
        if (type.contains('/')) return type;

        switch (type.toLowerCase()) {
          case 'mp3':
            return 'audio/mpeg';
          case 'wav':
            return 'audio/wav';
          case 'aac':
            return 'audio/aac';
          case 'm4a':
            return 'audio/mp4';
          case 'ogg':
            return 'audio/ogg';
          default:
            return 'application/octet-stream';
        }
      }

      final headers = {
        "x-amz-date": amzDate,
        "x-amz-content-sha256": payloadHash,
        "Authorization": authorization,
        "Content-Type": getAudioContentType(fileType),
      };

      print('Uploading audio to R2...');

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: headers,
        body: payload,
      );

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✓ Audio upload successful');
        return fileName; // same return behavior as image upload
      } else {
        print('✗ Audio upload failed');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Audio upload failed: ${response.statusCode}')),
        );
        return null;
      }
    } catch (e, stackTrace) {
      print('✗ Error uploading audio to R2: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio Upload Failed')),
      );
      return null;
    }
  }

// static Future<String?> uploadAudioToAws(Uint8List result, String fileType,
//       String taskId, BuildContext context) async {
//     try {
//       Loader.showLoader(context);

//       String uploadFileName = '${DateTime.now().millisecondsSinceEpoch}_audio';
//       String uploadFilePath = '${AppStyles.name()}/UploadedAudios/$taskId/';
//       final uploadKey = uploadFilePath + uploadFileName;

//       final data = await AwsS3.uploadUint8List(
//         acl: ACL.public_read,
//         accessKey: "AKIAX37YDYI4ACBOVVMU",
//         secretKey: "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",
//         file: result,
//         bucket: "ufsnabeelphotoalbum",
//         region: "us-east-2",
//         key: uploadKey,
//         metadata: {"type": "audio", "task_id": taskId},
//         contentType: fileType,
//         destDir: uploadFilePath,
//         filename: uploadFileName,
//       );

//       print('Audio uploaded successfully');
//       Loader.stopLoader(context);

//       print(
//           'Audio URL: https://ufsnabeelphotoalbum.s3.amazonaws.com/$uploadKey');

//       return uploadKey;
//     } catch (e) {
//       Loader.stopLoader(context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Audio Upload Failed')),
//       );
//       print('Error uploading audio to AWS: $e');
//       return null;
//     }
//   }
}

  
  // static Future<File> compressImage(Uint8List bytes) async {
  //   final tempFile = File('${Directory.systemTemp.path}/temp_image.jpg');

  //   // Write the image bytes to the temporary file
  //   await tempFile.writeAsBytes(bytes);

  //   // Compress the image using FlutterImageCompress
  //   var result = await FlutterImageCompress.compressAndGetFile(
  //     tempFile.absolute.path, // The file path to the image
  //     tempFile.absolute.path, // The output path
  //     quality: 70,
  //     minWidth: 1024,
  //     minHeight: 1024,
  //   );

  //   if (result != null) {
  //     return File(result.path); // Convert XFile to File
  //   } else {
  //     throw Exception("Image compression failed.");
  //   }
  // }

  // static String _formatFileSize(int bytes) {
  //   if (bytes <= 0) return "0 B";
  //   const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  //   var i = (log(bytes) / log(1024)).floor();
  //   return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  // }

