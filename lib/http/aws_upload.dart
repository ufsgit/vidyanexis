import 'dart:typed_data';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:aws_s3_upload_lite/enum/acl.dart';
import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/http/loader.dart';

class AwsUpload {
  static Future<String?> uploadToAws(Uint8List result, String fileType,
      String taskId, BuildContext context) async {
    try {
      String uploadFileName = DateTime.now().millisecondsSinceEpoch.toString();
      String uploadFilePath = '${AppStyles.name()}/UploadedImages/$taskId/';
      // String uploadFilePath = 'Dyuthi/UploadedImages/$taskId/';
      // String uploadFilePath = 'ExtraWatts/UploadedImages/$taskId/';
      // String uploadFilePath = 'Crystal/UploadedImages/$taskId/';
      final uploadKey = uploadFilePath + uploadFileName;

      final data = await AwsS3.uploadUint8List(
        acl: ACL.public_read,
        accessKey: "AKIAX37YDYI4ACBOVVMU",
        secretKey: "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",
        file: result,
        bucket: "ufsnabeelphotoalbum",
        region: "us-east-2",
        key: uploadKey,
        metadata: {"test": "test"},
        contentType: fileType,
        destDir: uploadFilePath,
        filename: uploadFileName,
      );

      print('<<<<<<<<<<<<<<aws result>>>>>>>>>>>>>>');
      print(data.toString());

      final publicUrl =
          'https://ufsnabeelphotoalbum.s3.amazonaws.com/$uploadKey';
      print('Public URL: $publicUrl');
      print('Profile URL: $uploadKey');
      return uploadKey;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      print('Error uploading to AWS: $e');
      return null;
    }
  }

  static Future<String?> uploadAudioToAws(Uint8List result, String fileType,
      String taskId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      String uploadFileName = '${DateTime.now().millisecondsSinceEpoch}_audio';
      String uploadFilePath = '${AppStyles.name()}/UploadedAudios/$taskId/';
      final uploadKey = uploadFilePath + uploadFileName;

      final data = await AwsS3.uploadUint8List(
        acl: ACL.public_read,
        accessKey: "AKIAX37YDYI4ACBOVVMU",
        secretKey: "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",
        file: result,
        bucket: "ufsnabeelphotoalbum",
        region: "us-east-2",
        key: uploadKey,
        metadata: {"type": "audio", "task_id": taskId},
        contentType: fileType,
        destDir: uploadFilePath,
        filename: uploadFileName,
      );

      print('Audio uploaded successfully');
      Loader.stopLoader(context);

      print(
          'Audio URL: https://ufsnabeelphotoalbum.s3.amazonaws.com/$uploadKey');

      return uploadKey;
    } catch (e) {
      Loader.stopLoader(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio Upload Failed')),
      );
      print('Error uploading audio to AWS: $e');
      return null;
    }
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
}
