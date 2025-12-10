import 'dart:developer';
import 'dart:io';
// import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/http/aws_upload.dart';
import 'package:techtify/http/http_requests.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/http/loader.dart';

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
            _fileInfoList.add(
                {'name': platformFile.name, 'type': 'pdf', 'data': fileData});
            print('PDF file added: ${platformFile.name}');
          } else if (fileType.startsWith('image/')) {
            _images.add(fileData);
            // Add file info to the list
            _fileInfoList.add(
                {'name': platformFile.name, 'type': 'image', 'data': fileData});
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

  // Common method to upload files to AWS
  Future<void> _uploadFilesToAws(List<Uint8List> files, String fileType,
      String taskId, BuildContext context) async {
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
          return;
        }
      }
      saveImagesApi(context);
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
          await AwsUpload.uploadToAws(fileData, fileType, taskId, context);
      return uploadedFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      print('Error uploading to AWS: $e');
      return null;
    }
  }

  void saveImagesApi(BuildContext context) async {
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

        Navigator.pop(context);
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

  void updateDocumentType(int newValue, String taskTypeName) {
    _selectedDocumentType = newValue;
    print(_selectedDocumentType);
    notifyListeners();
  }
}
