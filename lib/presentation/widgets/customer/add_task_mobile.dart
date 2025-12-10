import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:techtify/controller/audio_file_provider.dart';
import 'package:techtify/controller/models/task_customer_model.dart';
import 'package:techtify/controller/models/task_details_model.dart';
import 'package:techtify/controller/models/task_type_status_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/models/amc_status_model.dart';
import 'package:techtify/controller/models/search_user_details_model.dart';
import 'package:techtify/controller/models/task_type_model.dart';
import 'package:techtify/http/http_urls.dart';
import 'package:techtify/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:techtify/presentation/widgets/home/auto_complete_textfield.dart';

import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
import 'package:techtify/presentation/widgets/home/custom_textfield_widget_mobile.dart';

class AddTaskMobile extends StatefulWidget {
  bool isEdit;
  String taskId;
  TaskDetails? task;

  AddTaskMobile(
      {super.key, required this.isEdit, required this.taskId, this.task});

  @override
  State<AddTaskMobile> createState() => _AddTaskMobileState();
}

class _AddTaskMobileState extends State<AddTaskMobile> {
  late FocusNode statusNode;
  late FocusNode amcStatusNode;
  String _selectedTaskTypeId = '';
  Future<List<TaskTypeStatusModel>>? _statusFuture;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final audioProvider =
          Provider.of<AudioFileProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);

      // Clear audio files if not in edit mode
      if (!widget.isEdit) {
        audioProvider.clearAudios();
        customerDetailsProvider.taskChoosedateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      } else if (widget.task != null) {
        // Load existing audio files when editing
        _loadExistingAudioFiles(widget.task!.taskFiles);
      } else if (widget.task != null) {
        _loadExistingAudioFiles(widget.task!.taskFiles);
      }
      settingsProvider.getSearchLeadStatus('', "0", context);

      if (customerDetailsProvider.selectedTaskType != null) {
        final taskTypeId = customerDetailsProvider.selectedTaskType.toString();
        setState(() {
          _selectedTaskTypeId = taskTypeId;
          _statusFuture =
              provider.getStatusByTaskTypeId(context, taskTypeId, '3');
        });
      }
    });
  }

  void _updateStatusDropdown(String taskTypeId) {
    final provider = Provider.of<DropDownProvider>(context, listen: false);

    setState(() {
      _selectedTaskTypeId = taskTypeId;
      _statusFuture = provider.getStatusByTaskTypeId(context, taskTypeId, '3');
    });
  }

// Method to load existing audio files when editing
  void _loadExistingAudioFiles(List<TaskFile> taskFiles) async {
    final audioProvider =
        Provider.of<AudioFileProvider>(context, listen: false);

    // Clear any existing files first
    audioProvider.clearAudios();

    // Filter and load only audio files
    final audioFiles =
        taskFiles.where((file) => file.fileType == 'audio').toList();

    for (var audioFile in audioFiles) {
      try {
        // Create an AudioFile object with the remote URL
        final newAudioFile = AudioFile(
          data: Uint8List(0), // We'll use blobUrl for remote files
          name: audioFile.fileName ?? 'audio_file',
          extension: audioFile.filePath!.split('.').last.toLowerCase(),
          existingPath: audioFile.filePath, // Store the full URL
        );

        // For remote files, we'll use the URL directly for playback
        newAudioFile.blobUrl = audioFile.filePath;

        // Add to provider
        audioProvider.addExistingAudioFile(newAudioFile);

        print('Added existing audio file: ${audioFile.fileName}');
      } catch (e) {
        print('Error loading existing audio file: $e');
        // You might want to show a snackbar or toast here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: ${audioFile.fileName}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final provider = Provider.of<AudioFileProvider>(context);

    final TextEditingController _workerController = TextEditingController();
    final workerNode = FocusNode();
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: widget.isEdit ? 'Edit task' : 'Add task',
        onLeadingPressed: () {
          customerDetailsProvider.clearTaskDetails();
          Navigator.pop(context);
        },
        onSavePressed: () async {
          if (customerDetailsProvider.selectedTaskType != null &&
              customerDetailsProvider.addTaskModel.taskUser!.isNotEmpty &&
              customerDetailsProvider
                  .taskChoosedateController.text.isNotEmpty &&
              customerDetailsProvider.selectedAMCStatus != 0) {
            List<Map<String, String>> audioFiles = [];
            final provider =
                Provider.of<AudioFileProvider>(context, listen: false);

            if (provider.audios.isNotEmpty) {
              // Handle both edit and new task cases
              for (var audio in provider.audios) {
                if (widget.isEdit) {
                  // For edit mode, check if it's an existing or new file
                  if (audio.existingPath != null) {
                    // Existing file - keep the path
                    audioFiles.add({
                      'File_Path': audio.existingPath!,
                      'File_Name': audio.name,
                      'File_Type': 'audio'
                    });
                  } else {
                    // New file added during edit - upload it
                    String? uploadedFilePath = await provider.saveAudioToAws(
                      audio.data,
                      'audio/mpeg',
                      widget.taskId.toString(),
                      context,
                    );

                    if (uploadedFilePath != null) {
                      audioFiles.add({
                        'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath,
                        'File_Name': audio.name,
                        'File_Type': 'audio'
                      });
                    }
                  }
                } else {
                  // For new task, upload all files
                  String? uploadedFilePath = await provider.saveAudioToAws(
                    audio.data,
                    'audio/mpeg',
                    widget.taskId.toString(),
                    context,
                  );

                  if (uploadedFilePath != null) {
                    audioFiles.add({
                      'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath,
                      'File_Name': audio.name,
                      'File_Type': 'audio'
                    });
                  }
                }
              }
            }

            // Call the saveTask method
            await customerDetailsProvider.saveTask(
              widget.taskId.toString(),
              customerDetailsProvider.selectedTaskType.toString(),
              customerDetailsProvider.taskDescriptionController.text.toString(),
              customerDetailsProvider.taskChoosedateController.text.toString(),
              customerDetailsProvider.taskChoosetimeController.text.toString(),
              customerDetailsProvider.selectedAssignWorker.toString(),
              context,
              widget.isEdit, // Pass the actual edit status
              audioFiles,
            );

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(widget.isEdit
                        ? 'Task edited successfully!'
                        : 'Task added successfully!'),
                  ],
                ),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );

            // Clear the provider after successful save if it's a new task
            if (!widget.isEdit) {
              provider.clearAudios();
            }
          } else {
            // Show error dialog for missing details
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
                    'Missing Details',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Text(
                //       isEdit ? 'Edit task' : 'Add task',
                //       style: GoogleFonts.plusJakartaSans(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w600,
                //         color: AppColors.textBlack,
                //       ),
                //     ),
                //     const Spacer(),
                //     IconButton(
                //         onPressed: () {
                //           customerDetailsProvider.clearTaskDetails();
                //           Navigator.pop(context);
                //         },
                //         icon: const Icon(
                //           Icons.close,
                //           size: 18,
                //         ))
                //   ],
                // ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      value: customerDetailsProvider.selectedTaskType,
                      items: dropDownProvider.taskType
                          .map((status) => DropdownMenuItem<int>(
                                value: status.taskTypeId,
                                child: Text(
                                  status.taskTypeName ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ))
                          .toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          final selectedTaskType = dropDownProvider.taskType
                              .firstWhere(
                                  (task) => task.taskTypeId == newValue);
                          if (customerDetailsProvider.addTaskModel.taskUser !=
                              null) {
                            customerDetailsProvider.addTaskModel.taskUser!
                                .clear();
                          }
                          customerDetailsProvider.updateTaskType(
                              newValue, selectedTaskType.taskTypeName);
                          customerDetailsProvider.updateAMCStatus(0, '');
                          _updateStatusDropdown(newValue.toString());
                          dropDownProvider.getStatusByTaskTypeId(
                              context, newValue.toString(), '3');
                        }
                      },
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        label: RichText(
                          text: TextSpan(
                            text: 'Choose Task',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        floatingLabelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey1,
                        ),
                        labelStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppColors.textGrey2,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 12),
                      ),
                      isDense: true,
                      iconSize: 18,
                    ),
                    const SizedBox(height: 16.0),
                    FutureBuilder<List<TaskTypeStatusModel>>(
                      future: _statusFuture,
                      builder: (context, snapshot) {
                        if (_selectedTaskTypeId.isEmpty) {
                          return DropdownButtonFormField<int>(
                            value: null,
                            items: const [],
                            onChanged: null,
                            decoration: InputDecoration(
                              label: RichText(
                                text: TextSpan(
                                  text: 'Choose Status',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textGrey3,
                                  ),
                                  children: const <TextSpan>[
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              hintText: 'Select a task type first',
                              floatingLabelBehavior: FloatingLabelBehavior.auto,
                              floatingLabelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey1,
                              ),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey3,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.textGrey2,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppColors.textGrey2,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 12),
                            ),
                            isDense: true,
                            iconSize: 18,
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textGrey2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Error loading status data',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  onPressed: () => _updateStatusDropdown(
                                      _selectedTaskTypeId),
                                  color: Colors.red,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.textGrey2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'No status options available',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 20),
                                  onPressed: () => _updateStatusDropdown(
                                      _selectedTaskTypeId),
                                  color: AppColors.textGrey3,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                )
                              ],
                            ),
                          );
                        }
                        final statusList = snapshot.data!;
                        return DropdownButtonFormField<int>(
                          value: statusList.any((status) =>
                                  status.statusId ==
                                  customerDetailsProvider.selectedAMCStatus)
                              ? customerDetailsProvider.selectedAMCStatus
                              : null,
                          items: statusList
                              .map((status) => DropdownMenuItem<int>(
                                    value: status.statusId,
                                    child: Text(
                                      status.statusName ?? "",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              final selectedAmcStatus = statusList.firstWhere(
                                  (status) => status.statusId == newValue);
                              customerDetailsProvider.updateAMCStatus(
                                  newValue, selectedAmcStatus.statusName ?? "");
                            }
                          },
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'Choose Status',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey3,
                                ),
                                children: const <TextSpan>[
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            floatingLabelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey1,
                            ),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.textGrey2,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.textGrey2,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppColors.textGrey2,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                          ),
                          isDense: true,
                          iconSize: 18,
                        );
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      readOnly: false,
                      controller:
                          customerDetailsProvider.taskDescriptionController,
                      labelText: 'Task Description',
                      minLines: 3,
                      maxLines: 5,
                      keyBoardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextfieldWidgetMobile(
                            focusNode: FocusNode(),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                customerDetailsProvider
                                        .taskChoosedateController.text =
                                    DateFormat('dd MMM yyyy').format(picked);
                                // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              }
                            },
                            readOnly: true,
                            controller: customerDetailsProvider
                                .taskChoosedateController,
                            labelText: 'Choose Date*',
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                color: AppColors.textGrey4,
                                size: 24,
                              ),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  customerDetailsProvider
                                          .taskChoosedateController.text =
                                      DateFormat('dd MMM yyyy').format(picked);
                                }
                              },
                            ),
                          ),
                        ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        // Expanded(
                        //   child: CustomTextfieldWidgetMobile(
                        //     focusNode: FocusNode(),
                        //     onTap: () async {
                        //       final TimeOfDay? pickedTime =
                        //           await showTimePicker(
                        //         context: context,
                        //         initialTime: TimeOfDay.now(),
                        //       );

                        //       if (pickedTime != null) {
                        //         final DateTime parsedTime = DateTime(
                        //           0,
                        //           0,
                        //           0,
                        //           pickedTime.hour,
                        //           pickedTime.minute,
                        //         );

                        //         final String formattedTime =
                        //             DateFormat('hh:mm a').format(parsedTime);
                        //         customerDetailsProvider.taskChoosetimeController
                        //             .text = formattedTime;
                        //       }
                        //     },
                        //     readOnly: true,
                        //     controller: customerDetailsProvider
                        //         .taskChoosetimeController,
                        //     labelText: 'Choose Time*',
                        //     suffixIcon: IconButton(
                        //       icon: Icon(
                        //         Icons.access_time_rounded,
                        //         color: AppColors.textGrey4,
                        //       ),
                        //       onPressed: () async {
                        //         final TimeOfDay? pickedTime =
                        //             await showTimePicker(
                        //           context: context,
                        //           initialTime: TimeOfDay.now(),
                        //         );

                        //         if (pickedTime != null) {
                        //           final DateTime parsedTime = DateTime(
                        //             0,
                        //             0,
                        //             0,
                        //             pickedTime.hour,
                        //             pickedTime.minute,
                        //           );

                        //           final String formattedTime =
                        //               DateFormat('hh:mm a').format(parsedTime);
                        //           customerDetailsProvider
                        //               .taskChoosetimeController
                        //               .text = formattedTime;
                        //         }
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: provider.isRecording
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              provider.isRecording ? Colors.red : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Recording Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (provider.isRecording) ...[
                                Icon(
                                  provider.isRecordingPaused
                                      ? Icons.pause
                                      : Icons.fiber_manual_record,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isRecordingPaused
                                      ? 'Recording Paused'
                                      : 'Recording...',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  provider.formattedRecordingDuration,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else
                                ...[],
                            ],
                          ),

                          // Web-specific instructions
                          if (kIsWeb) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.blue, size: 16),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Web Recording: Allow microphone access when prompted',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Recording Control Buttons
                          if (!provider.isRecording) ...[
                            // Recording start buttons
                            if (kIsWeb) ...[
                              // Two options for web recording
                              Column(
                                children: [
                                  // Primary recording button (record package)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        provider.debugRecordingState();
                                        await provider.startRecording();
                                        provider.debugRecordingState();
                                      },
                                      icon: const Icon(Icons.mic, size: 20),
                                      label: const Text('Start Recording'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 8,
                                  ),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        await provider.addAudioFile();
                                      },
                                      icon: const Icon(Icons.audiotrack,
                                          size: 20),
                                      label: const Text('Add Audio file'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Mobile recording button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  provider.debugRecordingState();
                                  await provider.startRecording();
                                  provider.debugRecordingState();
                                },
                                icon: const Icon(Icons.mic, size: 20),
                                label: const Text('Start Recording'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ] else ...[
                            // Recording control buttons (pause, stop, cancel)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Pause/Resume Button (only for record package, not native web)
                                if (provider.nativeMediaRecorder == null) ...[
                                  ElevatedButton.icon(
                                    onPressed: provider.isRecordingPaused
                                        ? provider.resumeRecording
                                        : provider.pauseRecording,
                                    icon: Icon(
                                        provider.isRecordingPaused
                                            ? Icons.play_arrow
                                            : Icons.pause,
                                        size: 20),
                                    label: Text(provider.isRecordingPaused
                                        ? 'Resume'
                                        : 'Pause'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],

                                // Stop Button
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    print('=== STOPPING RECORDING ===');
                                    provider.debugRecordingState();

                                    // Use appropriate stop method based on which recorder is active
                                    if (kIsWeb &&
                                        provider.nativeMediaRecorder != null) {
                                      await provider.stopNativeWebRecording();
                                    } else {
                                      await provider.stopRecording();
                                    }

                                    provider.debugRecordingState();
                                  },
                                  icon: const Icon(Icons.stop, size: 20),
                                  label: const Text('Stop'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                                // Cancel Button
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    print('=== CANCELLING RECORDING ===');
                                    provider.debugRecordingState();
                                    await provider.cancelRecording();
                                    provider.debugRecordingState();
                                  },
                                  icon: const Icon(Icons.cancel, size: 20),
                                  label: const Text('Cancel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await provider.addAudioFile();
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppColors.appViolet,
                    //     foregroundColor: AppColors.whiteColor,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 12, vertical: 12),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: const Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       Icon(Icons.audiotrack, size: 16),
                    //       SizedBox(width: 8),
                    //       CustomText(
                    //         'Add Audio File',
                    //         fontSize: 16,
                    //       ),
                    //     ],
                    //   ),
                    // ),
// Display audio files in UI with playback controls
                    if (provider.audios.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CustomText(
                            //   'Audio Files (${provider.audios.length})',
                            //   fontWeight: FontWeight.bold,
                            //   fontSize: 16,
                            // ),
                            // const SizedBox(height: 8),
                            Column(
                              children:
                                  provider.audios.asMap().entries.map((entry) {
                                int index = entry.key;
                                AudioFile audioFile = entry.value;

                                return // Update your audio display UI to handle remote files

// In your audio display widget:
                                    Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey300,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.lightBlueColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Audio file info and controls
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.audiotrack,
                                            color: AppColors.appViolet,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  audioFile.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (audioFile.isPlaying) {
                                                provider.pauseAudio(index);
                                              } else {
                                                provider.playAudio(index);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.appViolet,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Icon(
                                                audioFile.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Stop button
                                          GestureDetector(
                                            onTap: () => provider.stopAudio(),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Icon(
                                                Icons.stop,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Remove button - different behavior for remote vs local
                                          // Updated remove button with better user feedback
                                          GestureDetector(
                                            onTap: () {
                                              // For local files, remove directly with confirmation
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Remove Audio File'),
                                                    content: Text(
                                                        'Remove "${audioFile.name}" from this task?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          provider.removeAudio(
                                                              index);
                                                          Navigator.pop(
                                                              context);

                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Audio file "${audioFile.name}" removed.'),
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                            ),
                                                          );
                                                        },
                                                        child: const Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red)),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 16,
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Assign Workers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey4,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: ' *', // The asterisk part
                            style: TextStyle(
                                color: Colors.red), // Red color for asterisk
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (null !=
                              customerDetailsProvider
                                  .addTaskModel.taskUser?.isNotEmpty)
                            Wrap(
                              children: customerDetailsProvider
                                  .addTaskModel.taskUser!
                                  .asMap()
                                  .entries
                                  .map((taskUser) {
                                return Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: AppColors.bluebutton),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          taskUser.value.userDetailsName ?? "",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () => customerDetailsProvider
                                                .removeAssignedWorker(
                                                    taskUser.value),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ))
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(
                            height: 6,
                          ),
                          SizedBox(
                            height: 30,
                            child: CustomElevatedButton(
                              prefixIcon: Icons.add,
                              radius: 10,
                              buttonText: 'Assign a Worker',
                              onPressed: customerDetailsProvider
                                          .selectedTaskType !=
                                      null
                                  ? () {
                                      // Get selected task's department ID and filter users
                                      final selectedTaskType = dropDownProvider
                                          .taskType
                                          .firstWhere((task) =>
                                              task.taskTypeId ==
                                              customerDetailsProvider
                                                  .selectedTaskType);

                                      final filteredUsers = dropDownProvider
                                          .searchUserDetails
                                          .where((user) =>
                                              user.departmentId ==
                                              selectedTaskType.departmentIds)
                                          .toList();

                                      if (filteredUsers.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'No workers available in this department to assign!'),
                                          ),
                                        );
                                        return;
                                      }

                                      Set<int> selectedUsers = {
                                        if (customerDetailsProvider
                                                .addTaskModel.taskUser !=
                                            null)
                                          ...customerDetailsProvider
                                              .addTaskModel.taskUser!
                                              .map((taskUser) =>
                                                  taskUser.userDetailsId!)
                                      };

                                      List<String> selectedUserNames =
                                          customerDetailsProvider
                                              .addTaskModel.taskUser!
                                              .where((taskUser) =>
                                                  selectedUsers.contains(
                                                      taskUser.userDetailsId))
                                              .map((taskUser) =>
                                                  taskUser.userDetailsName ??
                                                  '')
                                              .toList();

                                      _workerController.text =
                                          selectedUserNames.join(', ');

                                      // Store users to be removed (marked when unticked)
                                      Set<int> removedUsers = {};
                                      bool isListVisible = false;

                                      showModalBottomSheet(
                                        backgroundColor: AppColors.whiteColor,
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: AppColors.whiteColor,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(14),
                                                    topRight:
                                                        Radius.circular(14),
                                                  ),
                                                ),
                                                constraints: BoxConstraints(
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          0.6,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Center(
                                                      child: Container(
                                                        width: 32,
                                                        height: 4,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(16),
                                                          color: AppColors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Select Worker',
                                                          style: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .textBlack,
                                                          ),
                                                        ),
                                                        InkWell(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Icon(
                                                              Icons.close,
                                                              size: 18,
                                                              color: AppColors
                                                                  .textGrey4,
                                                            ))
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    CustomTextField(
                                                      readOnly: true,
                                                      onTap: () {
                                                        setState(() {
                                                          isListVisible =
                                                              !isListVisible; // Toggle visibility
                                                        });
                                                      },
                                                      controller:
                                                          _workerController,
                                                      hintText:
                                                          "Choose Workers",
                                                      labelText: "",
                                                      height: 54,
                                                    ),
                                                    const SizedBox(height: 8),

                                                    // Show Worker List below the text field (filtered by department)
                                                    if (isListVisible)
                                                      Container(
                                                        height:
                                                            200, // Fixed height for the worker list
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          border: Border.all(
                                                              color: Colors.grey
                                                                  .shade300),
                                                        ),
                                                        child: ListView.builder(
                                                          itemCount:
                                                              filteredUsers
                                                                  .length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            final worker =
                                                                filteredUsers[
                                                                    index];
                                                            bool isSelected =
                                                                selectedUsers
                                                                    .contains(worker
                                                                        .userDetailsId);

                                                            return ListTile(
                                                                title: Text(
                                                                    worker.userDetailsName ??
                                                                        ''),
                                                                subtitle: Text(
                                                                    worker.departmentName ??
                                                                        ''),
                                                                trailing: Icon(
                                                                  isSelected
                                                                      ? Icons
                                                                          .check_circle
                                                                      : Icons
                                                                          .radio_button_unchecked,
                                                                  color: isSelected
                                                                      ? Colors
                                                                          .blue
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                                onTap: () {
                                                                  setState(() {
                                                                    if (selectedUsers
                                                                        .contains(
                                                                            worker.userDetailsId!)) {
                                                                      selectedUsers
                                                                          .remove(
                                                                              worker.userDetailsId!);
                                                                    } else {
                                                                      selectedUsers.add(
                                                                          worker
                                                                              .userDetailsId!);
                                                                    }

                                                                    // Update the text field with selected names (from filtered users)
                                                                    List<String?> selectedUserNames = filteredUsers
                                                                        .where((user) =>
                                                                            selectedUsers.contains(user
                                                                                .userDetailsId))
                                                                        .map((user) =>
                                                                            user.userDetailsName)
                                                                        .toList();

                                                                    _workerController
                                                                            .text =
                                                                        selectedUserNames
                                                                            .join(', ');
                                                                  });
                                                                });
                                                          },
                                                        ),
                                                      ),
                                                    const SizedBox(height: 16),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: SizedBox(
                                                            height: 38,
                                                            child:
                                                                CustomElevatedButton(
                                                              textSize: 14,
                                                              radius: 12,
                                                              buttonText:
                                                                  'Select workers',
                                                              onPressed: () {
                                                                // Remove users only on Confirm
                                                                for (int userId
                                                                    in removedUsers) {
                                                                  customerDetailsProvider
                                                                      .removeAssignedWorker(
                                                                    customerDetailsProvider
                                                                        .addTaskModel
                                                                        .taskUser!
                                                                        .firstWhere((taskUser) =>
                                                                            taskUser.userDetailsId ==
                                                                            userId),
                                                                  );
                                                                }

                                                                for (int userId
                                                                    in selectedUsers) {
                                                                  customerDetailsProvider
                                                                      .updateAssignWorker(
                                                                          userId,
                                                                          dropDownProvider);
                                                                }
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              backgroundColor:
                                                                  AppColors
                                                                      .bluebutton,
                                                              borderColor:
                                                                  AppColors
                                                                      .appViolet,
                                                              textColor: AppColors
                                                                  .whiteColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }
                                  : () {}, // Disable button when no task is selected
                              backgroundColor:
                                  customerDetailsProvider.selectedTaskType !=
                                          null
                                      ? AppColors.whiteColor
                                      : AppColors.grey300,
                              borderColor:
                                  customerDetailsProvider.selectedTaskType !=
                                          null
                                      ? AppColors.appViolet
                                      : AppColors.grey300,
                              textColor:
                                  customerDetailsProvider.selectedTaskType !=
                                          null
                                      ? AppColors.appViolet
                                      : AppColors.grey300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         height: 38,
                //         child: CustomElevatedButton(
                //           textSize: 14,
                //           radius: 12,
                //           buttonText: 'Assign task',
                //           onPressed: () async {
                //             if (customerDetailsProvider.selectedTaskType !=
                //                     null &&
                //                 // customerDetailsProvider.selectedAssignWorker != null &&
                //                 customerDetailsProvider
                //                     .addTaskModel.taskUser!.isNotEmpty &&
                //                 customerDetailsProvider
                //                     .taskChoosedateController.text.isNotEmpty &&
                //                 customerDetailsProvider
                //                     .taskChoosetimeController.text.isNotEmpty) {
                //               customerDetailsProvider.saveTask(
                //                   taskId.toString(),
                //                   customerDetailsProvider.selectedTaskType
                //                       .toString(),
                //                   customerDetailsProvider
                //                       .taskDescriptionController.text
                //                       .toString(),
                //                   customerDetailsProvider
                //                       .taskChoosedateController.text
                //                       .toString(),
                //                   customerDetailsProvider
                //                       .taskChoosetimeController.text
                //                       .toString(),
                //                   customerDetailsProvider.selectedAssignWorker
                //                       .toString(),
                //                   context,
                //                   isEdit);
                //             } else {
                //               showDialog(
                //                 context: context,
                //                 builder: (BuildContext context) {
                //                   return AlertDialog(
                //                     title: Text(
                //                       'Cannot save',
                //                       style: TextStyle(
                //                         color: AppColors.appViolet,
                //                         fontWeight: FontWeight.bold,
                //                       ),
                //                     ),
                //                     content: const Text(
                //                       'Missing Details',
                //                       style: TextStyle(
                //                         color: Colors.black87,
                //                         fontSize: 16,
                //                       ),
                //                     ),
                //                     shape: RoundedRectangleBorder(
                //                       borderRadius: BorderRadius.circular(15),
                //                     ),
                //                     actions: [
                //                       TextButton(
                //                         onPressed: () {
                //                           Navigator.pop(context);
                //                         },
                //                         child: Text(
                //                           'OK',
                //                           style: TextStyle(
                //                             color: AppColors.appViolet,
                //                             fontWeight: FontWeight.bold,
                //                             fontSize: 16,
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   );
                //                 },
                //               );
                //             }
                //           },
                //           backgroundColor: AppColors.bluebutton,
                //           borderColor: AppColors.appViolet,
                //           textColor: AppColors.whiteColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
