import 'dart:developer';
import 'dart:io';
// import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/main.dart';

class ImageUploadProvider extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  TextEditingController docTypeController = TextEditingController();

  final List<Uint8List> _images = []; // List to store images
  final List<Uint8List> _pdfs = []; // List to store PDFs
  List<Map<String, String>> uploadedFilePaths = [];

  List<Uint8List> get images => _images;
  List<Uint8List> get pdfs => _pdfs;
  int? _selectedDocumentType;
  int? get selectedDocumentType => _selectedDocumentType;
  String customerId = '0';
  List<Map<String, dynamic>> _fileInfoList = [];
  List<Map<String, dynamic>> get fileInfoList => _fileInfoList;
  String? _selectedDocumentTypeName;
  String? get selectedDocumentTypeName => _selectedDocumentTypeName;

  void setCutomerId(String cid) {
    customerId = cid;
  }

  // Method to add files (supports images and PDFs)
  Future<void> addMultipleFile() async {
    if (!kIsWeb) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      for (var platformFile in result.files) {
        Uint8List? fileData;

        // Handle Web and Mobile/Platform paths
        if (platformFile.bytes != null) {
          // For Web
          fileData = platformFile.bytes;
        } else if (platformFile.path != null) {
          // For Android/iOS
          fileData = await File(platformFile.path!).readAsBytes();
        }

        if (fileData != null) {
          // Determine the file type using its content (byte data)
          String fileType = '';
          if (platformFile.bytes != null) {
            fileType = determineFileType(fileData);
          } else if (platformFile.path != null) {
            fileType =
                lookupMimeType(platformFile.path!, headerBytes: fileData) ?? '';
          }
          print(fileType);

          if (fileType == 'application/pdf') {
            _pdfs.add(fileData);
            print('PDF file added: ${platformFile.name}');
          } else if (fileType.startsWith('image/')) {
            _images.add(fileData);
            print('Image file added: ${platformFile.name}');
          } else {
            print('Unsupported file type: ${platformFile.name}');
          }

          // Notify listeners if applicable
          notifyListeners();
        } else {
          print('Unable to read file data for ${platformFile.name}');
        }
      }
    } else {
      print('No file selected.');
    }
  }

  static Future<Map<String, dynamic>?> addFile() async {
    if (!kIsWeb) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result == null || result.files.isEmpty) {
      print('No file selected.');
      return null;
    }

    var platformFile = result.files.first;

    if (kIsWeb) {
      // Web: Use `bytes` instead of `path`
      if (platformFile.bytes != null) {
        return {
          'data': platformFile.bytes,
          'name': platformFile.name
        }; // Return file data and file name for web
      } else {
        print('Error: File has no bytes data.');
        return null;
      }
    } else {
      // Mobile: Use path to access file
      if (platformFile.path != null) {
        final file = File(platformFile.path!);
        final fileData = await file.readAsBytes();
        return {
          'data': fileData,
          'name': platformFile.name
        }; // Return file data and file name for mobile
      } else {
        print('Error: File has no valid path.');
        return null;
      }
    }
  }

  Future<void> addFileMobile() async {
    if (!kIsWeb) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      for (var platformFile in result.files) {
        Uint8List? fileData;

        // Handle Web and Mobile/Platform paths
        if (platformFile.bytes != null) {
          // For Web
          fileData = platformFile.bytes;
        } else if (platformFile.path != null) {
          // For Android/iOS
          fileData = await File(platformFile.path!).readAsBytes();
        }

        if (fileData != null) {
          // Determine the file type using its content (byte data)
          String fileType = '';
          if (platformFile.bytes != null) {
            fileType = determineFileType(fileData);
          } else if (platformFile.path != null) {
            fileType =
                lookupMimeType(platformFile.path!, headerBytes: fileData) ?? '';
          }
          print(fileType);

          if (fileType == 'application/pdf') {
            _pdfs.add(fileData);
            // Add file info to the list
            _fileInfoList.add({
              'name': platformFile.name,
              'type': 'pdf',
              'data': fileData,
              'docTypeId': _selectedDocumentType,
              'docTypeName': _selectedDocumentTypeName,
            });
            print('PDF file added: ${platformFile.name}');
          } else if (fileType.startsWith('image/')) {
            _images.add(fileData);
            // Add file info to the list
            _fileInfoList.add({
              'name': platformFile.name,
              'type': 'image',
              'data': fileData,
              'docTypeId': _selectedDocumentType,
              'docTypeName': _selectedDocumentTypeName,
            });
            print('Image file added: ${platformFile.name}');
          } else {
            print('Unsupported file type: ${platformFile.name}');
          }

          // Notify listeners if applicable
          notifyListeners();
        } else {
          print('Unable to read file data for ${platformFile.name}');
        }
      }
    } else {
      print('No file selected.');
    }
  }

  Future<void> addPhotoMobile({bool allowCamera = false}) async {
    if (kIsWeb) return;

    if (!await _requestPhotoPermission()) {
      print('Photo permission denied');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final ImageSource source =
        allowCamera ? ImageSource.camera : ImageSource.gallery;

    if (source == ImageSource.camera) {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        _images.add(bytes);
        _fileInfoList.add({
          'name': photo.name,
          'type': 'image',
          'data': bytes,
          'docTypeId': _selectedDocumentType,
          'docTypeName': _selectedDocumentTypeName,
        });
        notifyListeners();
      }
    } else {
      // Gallery - multi select
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);
      for (final xfile in images) {
        final bytes = await xfile.readAsBytes();
        _images.add(bytes);
        _fileInfoList.add({
          'name': xfile.name,
          'type': 'image',
          'data': bytes,
          'docTypeId': _selectedDocumentType,
          'docTypeName': _selectedDocumentTypeName,
        });
      }
      if (images.isNotEmpty) notifyListeners();
    }
  }

// Helper method for permission handling (cleaner than inline)
  Future<bool> _requestPhotoPermission() async {
    // Modern Android 13+ uses more granular permissions
    final status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    }

    // For older Android or iOS fallback
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }

    return await Permission.photos.isGranted;
  }

  // Helper function to determine file type
  String determineFileType(Uint8List data) {
    if (data.length >= 4) {
      if (data[0] == 0x25 &&
          data[1] == 0x50 &&
          data[2] == 0x44 &&
          data[3] == 0x46) {
        return 'application/pdf'; // PDF
      } else if (data[0] == 0xFF &&
          data[1] == 0xD8 &&
          data[data.length - 2] == 0xFF &&
          data[data.length - 1] == 0xD9) {
        return 'image/jpeg'; // JPEG
      } else if (data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return 'image/png'; // PNG
      }
    }
    return 'unknown';
  }

  void clearFiles() {
    _images.clear();
    _pdfs.clear();
    _selectedDocumentType = null;
    _fileInfoList.clear();
    uploadedFilePaths.clear();
    notifyListeners();
  }

  void removeImage(Uint8List image) {
    _images.remove(image);
    notifyListeners();
  }

  void removePdf(Uint8List pdf) {
    _pdfs.remove(pdf);
    notifyListeners();
  }

  // Upload images to AWS
  Future<void> uploadImagesToAws(String taskId, BuildContext context) async {
    await _uploadFilesToAws(_images, 'image/jpeg', taskId, context);
  }

  // Upload PDFs to AWS
  Future<void> uploadPdfsToAws(String taskId, BuildContext context) async {
    await _uploadFilesToAws(_pdfs, 'application/pdf', taskId, context);
  }

  // Upload all files (images and PDFs)
  Future<void> uploadAllFiles(BuildContext context,
      {bool shouldPop = true}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";

      Loader.showLoader(context);

      // Upload Images
      for (var fileData in _images) {
        String? uploadedFilePath =
            await saveToAws(fileData, 'image/jpeg', userId, context);
        if (uploadedFilePath != null) {
          uploadedFilePaths
              .add({'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath});
        } else {
          Loader.stopLoader(context);
          return;
        }
      }

      // Upload PDFs
      for (var fileData in _pdfs) {
        String? uploadedFilePath =
            await saveToAws(fileData, 'application/pdf', userId, context);
        if (uploadedFilePath != null) {
          uploadedFilePaths
              .add({'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath});
        } else {
          Loader.stopLoader(context);
          return;
        }
      }

      await saveImagesApi(context, shouldPop: shouldPop);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Documents uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading documents')),
      );
      print('Error uploading documents: $e');
    } finally {
      Loader.stopLoader(context);
    }
  }

  // Common method to upload files to AWS
  Future<void> _uploadFilesToAws(List<Uint8List> files, String fileType,
      String taskId, BuildContext context,
      {bool shouldPop = true}) async {
    try {
      Loader.showLoader(context);
      for (var fileData in files) {
        String? uploadedFilePath =
            await saveToAws(fileData, fileType, taskId, context);
        if (uploadedFilePath != null) {
          print('$fileType uploaded: $uploadedFilePath');
          uploadedFilePaths
              .add({'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath});
        } else {
          print('Upload failed for $fileType');
          Loader.stopLoader(context);
          return;
        }
      }
      await saveImagesApi(context, shouldPop: shouldPop);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Documents uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading $fileType')),
      );
      print('Error uploading $fileType: $e');
    } finally {
      Loader.stopLoader(context);
    }
  }

  // Save a single file to AWS
  Future<String?> saveToAws(Uint8List fileData, String fileType, String taskId,
      BuildContext context) async {
    try {
      final String? uploadedFilePath =
          await CloudflareUpload.uploadToCloudflare(
              fileData, fileType, taskId, context);
      return uploadedFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      print('Error uploading to AWS: $e');
      return null;
    }
  }

  Future<void> saveImagesApi(BuildContext context,
      {bool shouldPop = true}) async {
    print(uploadedFilePaths);
    print(_selectedDocumentType);
    print(customerId);
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      String userName = preferences.getString('userName') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveImage,
          bodyData: {
            "Images_Id": 0,
            "Customer_Id": customerId,
            "Document_Type_Id": _selectedDocumentType ?? 0,
            "File_Paths": uploadedFilePaths,
            "User_Details_Id": userId
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');

        if (shouldPop) {
          Navigator.pop(context);
        }
        clearFiles();
        print(data);
        final customerDetailsProvider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        customerDetailsProvider.getDocument(customerId, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void updateDocumentType(int newValue, String? taskTypeName) {
    _selectedDocumentType = newValue;
    _selectedDocumentTypeName = taskTypeName;
    print(_selectedDocumentType);
    notifyListeners();
  }

  Future<void> uploadAllDocumentsGrouped(BuildContext context) async {
    try {
      if (_fileInfoList.isEmpty) return;

      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";

      // Group files by docTypeId
      Map<int?, List<Map<String, dynamic>>> groupedFiles = {};
      for (var file in _fileInfoList) {
        int? typeId = file['docTypeId'];
        groupedFiles.putIfAbsent(typeId, () => []).add(file);
      }

      bool anySuccess = false;

      for (var entry in groupedFiles.entries) {
        int? typeId = entry.key;
        List<Map<String, dynamic>> files = entry.value;

        List<Map<String, String>> currentUploadedPaths = [];

        for (var file in files) {
          Uint8List fileData = file['data'];
          String mimeType =
              file['type'] == 'pdf' ? 'application/pdf' : 'image/jpeg';

          String? uploadedPath =
              await saveToAws(fileData, mimeType, userId, context);
          if (uploadedPath != null) {
            currentUploadedPaths
                .add({'File_Path': HttpUrls.imgBaseUrl + uploadedPath});
          }
        }

        if (currentUploadedPaths.isNotEmpty) {
          // Call the API for this group
          final response = await HttpRequest.httpPostRequest(
              endPoint: HttpUrls.saveImage,
              bodyData: {
                "Images_Id": 0,
                "Customer_Id": customerId,
                "Document_Type_Id": typeId ?? 0,
                "File_Paths": currentUploadedPaths,
                "User_Details_Id": userId
              });

          if (response != null && response.statusCode == 200) {
            anySuccess = true;
          }
        }
      }

      Loader.stopLoader(context);

      if (anySuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents uploaded successfully')),
        );
        Navigator.pop(context);
        clearFiles();
        final customerDetailsProvider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        customerDetailsProvider.getDocument(customerId, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload some documents')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Error in uploadAllDocumentsGrouped: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during upload')),
      );
    }
  }
}
