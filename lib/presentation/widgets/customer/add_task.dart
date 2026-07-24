import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/controller/models/task_details_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class TaskCreationWidget extends StatefulWidget {
  bool isEdit;
  String taskId;
  TaskCustomerModel? task;
  TaskDetails? taskDetails;
  TaskReportModel? taskReportModel;
  bool showDocument;

  TaskCreationWidget({
    super.key,
    required this.isEdit,
    required this.taskId,
    this.task,
    this.taskDetails,
    this.taskReportModel,
    this.showDocument = false,
  });

  @override
  State<TaskCreationWidget> createState() => _TaskCreationWidgetState();
}

class _TaskCreationWidgetState extends State<TaskCreationWidget> {
  String _selectedTaskTypeId = '';
  List<SearchUserDetails> _filteredUsers = [];
  bool isSingleSelect = true;
  bool _showMore = false;

  // --- Document upload state (not customer-based) ---
  final List<Map<String, dynamic>> _taskFileInfoList = [];
  int? _selectedDocTypeId;
  String? _selectedDocTypeName;

  void _updateFilteredUsers() {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType != null) {
      try {
        final selectedTaskTypeModel = dropDownProvider.taskType.firstWhere(
          (task) => task.taskTypeId == customerDetailsProvider.selectedTaskType,
        );

        setState(() {
          _filteredUsers = dropDownProvider.searchUserDetails
              .where((user) =>
                  user.workingStatus == "1" &&
                  user.departmentId.toString() ==
                      selectedTaskTypeModel.departmentIds.toString())
              .toList();

          if (_filteredUsers.length == 1) {
            final worker = _filteredUsers.first;
            final userInTask = UserInTaskModel(
                userDetailsId: worker.userDetailsId,
                userDetailsName: worker.userDetailsName);
            customerDetailsProvider.addTaskModel.taskUser?.clear();
            customerDetailsProvider.addAssignedWorker(userInTask);
          }
        });
      } catch (e) {
        setState(() {
          _filteredUsers = [];
        });
      }
    } else {
      setState(() {
        _filteredUsers = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      provider.getTaskType(context, fetchUserSpecific: true);
      // Fetch document types for document upload section
      provider.getDocumentType(context);

      if (!widget.isEdit) {
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      }

      if (customerDetailsProvider.selectedTaskType != null) {
        final taskTypeId = customerDetailsProvider.selectedTaskType.toString();
        setState(() {
          _selectedTaskTypeId = taskTypeId;
        });
        _updateFilteredUsers();
      }

      if (widget.isEdit) {
        customerDetailsProvider.commissionController.text =
            widget.taskDetails?.commissionNumber.toString() ??
                widget.task?.commissionNumber.toString() ??
                '';
        customerDetailsProvider.taskDescriptionController.text =
            widget.taskDetails?.description ??
                widget.task?.description ??
                widget.taskReportModel?.description ??
                '';

        String? dateStr = widget.taskDetails?.taskDate ??
            widget.task?.taskDate.toString() ??
            widget.taskReportModel?.taskDate;
        if (dateStr != null && dateStr.isNotEmpty) {
          try {
            DateTime date = DateTime.parse(dateStr);
            customerDetailsProvider.taskChoosedateController.text =
                DateFormat('dd MMM yyyy').format(date);
          } catch (e) {
            // Handle parsing error
          }
        }
      }
    });
  }

  // ─── Document helpers ────────────────────────────────────────────────────

  Future<void> _showPickOptions(BuildContext ctx) async {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.appViolet),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _addPhotoMobile(allowCamera: true);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.appViolet),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _addPhotoMobile(allowCamera: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: AppColors.appViolet),
              title: const Text('Upload Document (PDF/Image)'),
              onTap: () {
                Navigator.pop(context);
                _addFileMobile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhotoMobile({bool allowCamera = false}) async {
    if (kIsWeb) return;

    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    }

    final ImagePicker picker = ImagePicker();

    if (allowCamera) {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _taskFileInfoList.add({
            'name': photo.name,
            'type': 'image',
            'data': bytes,
            'docTypeId': _selectedDocTypeId,
            'docTypeName': _selectedDocTypeName,
          });
        });
      }
    } else {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 85);
      for (final xfile in images) {
        final bytes = await xfile.readAsBytes();
        setState(() {
          _taskFileInfoList.add({
            'name': xfile.name,
            'type': 'image',
            'data': bytes,
            'docTypeId': _selectedDocTypeId,
            'docTypeName': _selectedDocTypeName,
          });
        });
      }
    }
  }

  Future<void> _addFileMobile() async {
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

        if (platformFile.bytes != null) {
          fileData = platformFile.bytes;
        } else if (platformFile.path != null) {
          fileData = await File(platformFile.path!).readAsBytes();
        }

        if (fileData != null) {
          String fileType = '';
          if (platformFile.bytes != null) {
            fileType = _determineFileType(fileData);
          } else if (platformFile.path != null) {
            fileType =
                lookupMimeType(platformFile.path!, headerBytes: fileData) ?? '';
          }

          final isImage = fileType.startsWith('image/');
          final isPdf = fileType == 'application/pdf';

          if (isImage || isPdf) {
            setState(() {
              _taskFileInfoList.add({
                'name': platformFile.name,
                'type': isPdf ? 'pdf' : 'image',
                'data': fileData,
                'docTypeId': _selectedDocTypeId,
                'docTypeName': _selectedDocTypeName,
              });
            });
          }
        }
      }
    }
  }

  String _determineFileType(Uint8List data) {
    if (data.length >= 4) {
      if (data[0] == 0x25 &&
          data[1] == 0x50 &&
          data[2] == 0x44 &&
          data[3] == 0x46) {
        return 'application/pdf';
      } else if (data[0] == 0xFF &&
          data[1] == 0xD8 &&
          data[data.length - 2] == 0xFF &&
          data[data.length - 1] == 0xD9) {
        return 'image/jpeg';
      } else if (data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return 'image/png';
      }
    }
    return 'unknown';
  }

  void _showFilePreview(BuildContext context, Map<String, dynamic> fileInfo) {
    final Uint8List fileData = fileInfo['data'];
    final String fileName = fileInfo['name'] ?? 'File';
    final String fileType = fileInfo['type'] ?? 'image';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomText(
                      fileName,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      color: AppColors.textBlack,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child:
                        Icon(Icons.close, color: AppColors.textGrey4, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: fileType == 'pdf'
                  ? PdfPreview(
                      build: (format) => fileData,
                      initialPageFormat: PdfPageFormat.a4,
                      useActions: true,
                      canChangePageFormat: false,
                      canChangeOrientation: false,
                      allowPrinting: false,
                      allowSharing: false,
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.memory(fileData, fit: BoxFit.contain),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Upload files and return TaskFile list ───────────────────────────────

  Future<List<TaskFile>> _uploadTaskFiles(BuildContext context) async {
    final List<TaskFile> result = [];
    if (_taskFileInfoList.isEmpty) return result;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('userId') ?? '0';

    for (final file in _taskFileInfoList) {
      final Uint8List fileData = file['data'];
      final String mimeType =
          file['type'] == 'pdf' ? 'application/pdf' : 'image/jpeg';

      final String? uploadedPath = await CloudflareUpload.uploadToCloudflare(
          fileData, mimeType, userId, context);

      if (uploadedPath != null) {
        result.add(TaskFile(
          filePath: HttpUrls.imgBaseUrl + uploadedPath,
          fileName: file['name'] ?? '',
          fileType: file['type'] ?? '',
          documentTypeId: file['docTypeId'],
          documentTypeName: file['docTypeName'],
        ));
      }
    }
    return result;
  }

  // ─── Save handler ────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    if (customerDetailsProvider.selectedTaskType != null &&
        customerDetailsProvider.addTaskModel.taskUser != null &&
        customerDetailsProvider.addTaskModel.taskUser!.isNotEmpty) {
      if (customerDetailsProvider.taskChoosedateController.text.isEmpty) {
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      }

      if (customerDetailsProvider.selectedAMCStatus == 0) {
        customerDetailsProvider.updateAMCStatus(1, 'Not Started');
      }

      // Upload task documents if any and attach to model
      List<Map<String, String>> files = [];
      if (_taskFileInfoList.isNotEmpty) {
        if (context.mounted) Loader.showLoader(context);
        final uploadedFiles = await _uploadTaskFiles(context);
        if (context.mounted) Loader.stopLoader(context);

        customerDetailsProvider.addTaskModel.taskFiles = uploadedFiles;
      }

      await customerDetailsProvider.saveTask(
        widget.taskReportModel?.taskId.toString() ??
            widget.task?.taskId.toString() ??
            widget.taskDetails?.taskId.first.toString() ??
            '0',
        widget.taskReportModel?.taskMasterId.toString() ??
            widget.task?.taskMasterId.toString() ??
            widget.taskDetails?.taskMasterId.toString() ??
            '0',
        customerDetailsProvider.selectedTaskType.toString(),
        customerDetailsProvider.taskDescriptionController.text.toString(),
        customerDetailsProvider.taskChoosedateController.text.toString(),
        customerDetailsProvider.taskChoosetimeController.text.toString(),
        customerDetailsProvider.selectedAssignWorker.toString(),
        context,
        widget.isEdit,
        files,
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cannot save',
              style: TextStyle(
                color: AppColors.appViolet,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Please select a Task Type and at least one Assignee.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: AppColors.appViolet,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    final double dialogWidth = AppStyles.isWebScreen(context)
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.width * 0.9;

    return AlertDialog(
      scrollable: true,
      backgroundColor: const Color(0xFFF8F9FB),
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isEdit ? 'Edit Task' : 'Create Task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E232C),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                customerDetailsProvider.clearTaskDetails();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Select Task Type ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT TASK TYPE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: dropDownProvider.taskType
                              .where((taskType) =>
                                  taskType.manualCreation == 1 ||
                                  (widget.isEdit &&
                                      customerDetailsProvider
                                              .selectedTaskType ==
                                          taskType.taskTypeId))
                              .map((taskType) {
                            bool isSelected =
                                customerDetailsProvider.selectedTaskType ==
                                    taskType.taskTypeId;
                            return InkWell(
                              onTap: () {
                                if (customerDetailsProvider
                                        .addTaskModel.taskUser !=
                                    null) {
                                  customerDetailsProvider.addTaskModel.taskUser!
                                      .clear();
                                }
                                customerDetailsProvider.updateTaskType(
                                    taskType.taskTypeId, taskType.taskTypeName);
                                customerDetailsProvider
                                        .taskChoosedateController.text =
                                    DateFormat('dd MMM yyyy').format(
                                        DateTime.now().add(
                                            Duration(days: taskType.duration)));

                                final defaultStatusId =
                                    taskType.defaultStatusId;
                                customerDetailsProvider.updateAMCStatus(
                                    defaultStatusId != 0 ? defaultStatusId : 1,
                                    '');

                                _updateFilteredUsers();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton
                                      : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  taskType.taskTypeName ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── More / Less toggle ──────────────────────────────────────
              InkWell(
                onTap: () {
                  setState(() {
                    _showMore = !_showMore;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showMore ? 'Less' : 'More',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bluebutton,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showMore
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.bluebutton,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Description ─────────────────────────────────────────────
              if (_showMore) ...[
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DESCRIPTION',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller:
                            customerDetailsProvider.taskDescriptionController,
                        maxLines: 3,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E232C),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter task description...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7F8F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                                color: AppColors.bluebutton.withOpacity(0.5)),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Commission / Amount ─────────────────────────────────────
                if (customerDetailsProvider.selectedTaskType != null &&
                    dropDownProvider.taskType.any((element) =>
                        element.taskTypeId ==
                            customerDetailsProvider.selectedTaskType &&
                        element.commissionNumber == 1))
                  const SizedBox(height: 16),
                if (customerDetailsProvider.selectedTaskType != null &&
                    dropDownProvider.taskType.any((element) =>
                        element.taskTypeId ==
                            customerDetailsProvider.selectedTaskType &&
                        element.commissionNumber == 1))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AMOUNT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller:
                              customerDetailsProvider.commissionController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1E232C),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter amount...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF7F8F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Task Date ───────────────────────────────────────────────
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASK DATE',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (picked != null) {
                            customerDetailsProvider
                                    .taskChoosedateController.text =
                                DateFormat('dd MMM yyyy').format(picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                customerDetailsProvider
                                        .taskChoosedateController.text.isEmpty
                                    ? 'Select Date'
                                    : customerDetailsProvider
                                        .taskChoosedateController.text,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1E232C),
                                ),
                              ),
                              Icon(Icons.calendar_today,
                                  color: AppColors.bluebutton, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Document Upload Section ──────────────────────────────────
                if (widget.showDocument) ...[
                  Container(
                    width: double.infinity,
                    height: 300,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView(
                      children: [
                        Text(
                          'DOCUMENT UPLOAD',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Document type rows (like add_document_phone.dart)
                        if (dropDownProvider.documentType.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Loading document types...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dropDownProvider.documentType.length,
                            itemBuilder: (context, index) {
                              final docType =
                                  dropDownProvider.documentType[index];
                              final selectedCount = _taskFileInfoList
                                  .where((e) =>
                                      e['docTypeId'] == docType.documentTypeId)
                                  .length;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: selectedCount > 0
                                        ? AppColors.bluebutton.withOpacity(0.5)
                                        : AppColors.textGrey2.withOpacity(0.2),
                                    width: selectedCount > 0 ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            docType.documentTypeName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: selectedCount > 0
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                          if (selectedCount > 0)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 2),
                                              child: Text(
                                                '$selectedCount file${selectedCount > 1 ? 's' : ''} added',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 10,
                                                  color: AppColors.bluebutton,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDocTypeId =
                                              docType.documentTypeId;
                                          _selectedDocTypeName =
                                              docType.documentTypeName;
                                        });
                                        if (AppStyles.isWebScreen(context)) {
                                          _addFileMobile();
                                        } else {
                                          _showPickOptions(context);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: selectedCount > 0
                                              ? AppColors.bluebutton
                                              : AppColors.bluebutton
                                                  .withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          selectedCount > 0
                                              ? Icons.add
                                              : Icons.upload_sharp,
                                          color: selectedCount > 0
                                              ? Colors.white
                                              : AppColors.bluebutton,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        // Uploaded files list
                        if (_taskFileInfoList.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'SELECTED FILES',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[400],
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...(_taskFileInfoList.map((fileInfo) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        AppColors.textGrey2.withOpacity(0.3)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      fileInfo['type'] == 'pdf'
                                          ? Icons.picture_as_pdf
                                          : Icons.image,
                                      color: fileInfo['type'] == 'pdf'
                                          ? Colors.red[400]
                                          : AppColors.bluebutton,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fileInfo['name'] ?? 'Unknown file',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                          if (fileInfo['docTypeName'] != null)
                                            Text(
                                              'Type: ${fileInfo['docTypeName']}',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10,
                                                color: AppColors.textGrey4,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => _showFilePreview(
                                              context, fileInfo),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Text(
                                              'View',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: AppColors.bluebutton,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _taskFileInfoList
                                                  .remove(fileInfo);
                                            });
                                          },
                                          child:
                                              const Icon(Icons.clear, size: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList()),
                        ] else ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'No documents added yet',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // ── Assign To ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASSIGN TO',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _filteredUsers.map((worker) {
                            bool isSelected = customerDetailsProvider
                                    .addTaskModel.taskUser
                                    ?.any((u) =>
                                        u.userDetailsId ==
                                        worker.userDetailsId) ??
                                false;
                            return InkWell(
                              onTap: () {
                                final userInTask = UserInTaskModel(
                                    userDetailsId: worker.userDetailsId,
                                    userDetailsName: worker.userDetailsName);
                                // to multiselect change to false
                                if (isSingleSelect) {
                                  if (isSelected) {
                                    customerDetailsProvider
                                        .removeAssignedWorker(userInTask);
                                  } else {
                                    customerDetailsProvider
                                        .addTaskModel.taskUser
                                        ?.clear();
                                    customerDetailsProvider
                                        .addAssignedWorker(userInTask);
                                  }
                                } else {
                                  if (isSelected) {
                                    customerDetailsProvider
                                        .removeAssignedWorker(userInTask);
                                  } else {
                                    customerDetailsProvider
                                        .addAssignedWorker(userInTask);
                                  }
                                }
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.bluebutton
                                      : const Color(0xFFF3F5F7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  worker.userDetailsName ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluebutton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.isEdit ? 'Update Task' : 'Create Task',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.add, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
