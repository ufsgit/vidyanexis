import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/controller/models/task_details_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TaskCreationWidget extends StatefulWidget {
  bool isEdit;
  String taskId;
  TaskCustomerModel? task;
  TaskDetails? taskDetails;

  TaskCreationWidget(
      {super.key,
      required this.isEdit,
      required this.taskId,
      this.task,
      this.taskDetails});

  @override
  State<TaskCreationWidget> createState() => _TaskCreationWidgetState();
}

class _TaskCreationWidgetState extends State<TaskCreationWidget> {
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
      } else if (widget.taskDetails != null) {
        _loadExistingAudioFiles(widget.taskDetails!.taskFiles);
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

  // Function to fetch status data based on task type
  void _updateStatusDropdown(String taskTypeId) {
    final provider = Provider.of<DropDownProvider>(context, listen: false);

    setState(() {
      _selectedTaskTypeId = taskTypeId;
      _statusFuture = provider.getStatusByTaskTypeId(context, taskTypeId, '3');
    });
  }

  void validateAndUpdateTime(
      BuildContext context, dynamic provider, String timeString, DateTime now) {
    // Parse the time string to get hours and minutes
    try {
      final DateTime parsedTime = DateFormat('hh:mm a').parse(timeString);
      final TimeOfDay timeOfDay =
          TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);

      // Use the validate method to check
      if (!validateTime(context, timeOfDay, now)) {
        // Clear the time if it's invalid
        provider.taskChoosetimeController.text = '';
      }
    } catch (e) {
      // If time parsing fails, just clear the field
      provider.taskChoosetimeController.text = '';
    }
  }

  bool validateTime(BuildContext context, TimeOfDay pickedTime, DateTime now) {
    // Create DateTime object for comparison
    final DateTime selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (selectedTime.isBefore(now)) {
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
              'Please select a future time',
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

      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final provider = Provider.of<AudioFileProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit task' : 'Create task',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                customerDetailsProvider.clearTaskDetails();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      content: Container(
        color: Colors.white,
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.of(context).size.width / 2
            : MediaQuery.of(context).size.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey1,
              ),
            ),
            const SizedBox(height: 16.0),
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
                      .firstWhere((task) => task.taskTypeId == newValue);
                  if (customerDetailsProvider.addTaskModel.taskUser != null) {
                    customerDetailsProvider.addTaskModel.taskUser!.clear();
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                          onPressed: () =>
                              _updateStatusDropdown(_selectedTaskTypeId),
                          color: Colors.red,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                          onPressed: () =>
                              _updateStatusDropdown(_selectedTaskTypeId),
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
                      final selectedAmcStatus = statusList
                          .firstWhere((status) => status.statusId == newValue);
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
            CustomTextField(
              readOnly: false,
              height: 54,
              controller: customerDetailsProvider.taskDescriptionController,
              hintText: 'Task Description',
              labelText: '',
              minLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16.0),
            // Updated UI with debugging and test capabilities

            if (settingsProvider.menuIsViewMap[67].toString() == '1')
              Column(
                children: [
                  // Recording Controls
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: provider.isRecording
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: provider.isRecording ? Colors.red : Colors.grey,
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
                                        borderRadius: BorderRadius.circular(8),
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
                                    icon:
                                        const Icon(Icons.audiotrack, size: 20),
                                    label: const Text('Add Audio file'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
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

                  // const SizedBox(height: 16),

                  // Row(
                  //   children: [
                  //     ElevatedButton(
                  //       onPressed: () async {
                  //         await provider.addAudioFile();
                  //       },
                  //       style: ElevatedButton.styleFrom(
                  //         backgroundColor: AppColors.appViolet,
                  //         foregroundColor: AppColors.whiteColor,
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 12, vertical: 12),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //         ),
                  //       ),
                  //       child: const Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Icon(Icons.audiotrack, size: 16),
                  //           SizedBox(width: 8),
                  //           Text('Add Audio File',
                  //               style: TextStyle(fontSize: 16)),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 16),

                  // Audio Files Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.audio_file,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Audio Files (${provider.audios.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Display message if no audio files
                        if (provider.audios.isEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.audiotrack,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No audio files yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Record audio or upload files to get started',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Display audio files
                          Column(
                            children:
                                provider.audios.asMap().entries.map((entry) {
                              int index = entry.key;
                              AudioFile audioFile = entry.value;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.blue.withOpacity(0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Audio icon with recording indicator
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: audioFile.isRecording
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        audioFile.isRecording
                                            ? Icons.mic
                                            : Icons.audiotrack,
                                        color: audioFile.isRecording
                                            ? Colors.red
                                            : Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Audio file info
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              if (audioFile.isRecording) ...[
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Text(
                                                    'RECORDED',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Text(
                                                '${(audioFile.data.length / 1024).toStringAsFixed(1)} KB',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '.${audioFile.extension}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Action buttons
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Play/Pause Button
                                        GestureDetector(
                                          onTap: () {
                                            if (audioFile.isPlaying) {
                                              provider.pauseAudio(index);
                                            } else {
                                              provider.playAudio(index);
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(16),
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

                                        // Stop Button
                                        GestureDetector(
                                          onTap: () => provider.stopAudio(),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.stop,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Remove Button
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
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
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        provider
                                                            .removeAudio(index);
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                'Audio file "${audioFile.name}" removed.'),
                                                            duration:
                                                                const Duration(
                                                                    seconds: 2),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Remove',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                              size: 16,
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
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    onTap: () async {
                      final DateTime now = DateTime.now();
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now, // Ensures only current or future dates
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        // Update the date controller
                        customerDetailsProvider.taskChoosedateController.text =
                            DateFormat('dd MMM yyyy').format(picked);

                        // If date changed to a future date, clear time to prevent confusion
                        if (picked.day != now.day ||
                            picked.month != now.month ||
                            picked.year != now.year) {
                          customerDetailsProvider
                              .taskChoosetimeController.text = '';
                        }
                        // If date changed to today and there's already a time selected, validate that time
                        else if (customerDetailsProvider
                            .taskChoosetimeController.text.isNotEmpty) {
                          validateAndUpdateTime(
                              context,
                              customerDetailsProvider,
                              customerDetailsProvider
                                  .taskChoosetimeController.text,
                              now);
                        }
                      }
                    },
                    readOnly: true,
                    height: 54,
                    controller:
                        customerDetailsProvider.taskChoosedateController,
                    hintText: 'Choose Date*',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        // Same date picker logic as above
                        final DateTime now = DateTime.now();
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          customerDetailsProvider.taskChoosedateController
                              .text = DateFormat('dd MMM yyyy').format(picked);

                          // Same validation as above when date changes
                          if (picked.day != now.day ||
                              picked.month != now.month ||
                              picked.year != now.year) {
                            customerDetailsProvider
                                .taskChoosetimeController.text = '';
                          } else if (customerDetailsProvider
                              .taskChoosetimeController.text.isNotEmpty) {
                            validateAndUpdateTime(
                                context,
                                customerDetailsProvider,
                                customerDetailsProvider
                                    .taskChoosetimeController.text,
                                now);
                          }
                        }
                      },
                    ),
                    labelText: '',
                  ),
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                // Expanded(
                //   child: CustomTextField(
                //     onTap: () async {
                //       final DateTime now = DateTime.now();
                //       // Check if selected date is today
                //       final bool isToday = customerDetailsProvider
                //               .taskChoosedateController.text ==
                //           DateFormat('dd MMM yyyy').format(now);

                //       final TimeOfDay initialTime = TimeOfDay.now();
                //       // Show time picker
                //       final TimeOfDay? pickedTime = await showTimePicker(
                //         context: context,
                //         initialTime: initialTime,
                //       );

                //       if (pickedTime != null) {
                //         // If today is selected, validate time is not in the past
                //         if (isToday) {
                //           final bool isValid =
                //               validateTime(context, pickedTime, now);
                //           if (!isValid) return; // Don't update if invalid
                //         }

                //         // Format and update time
                //         final DateTime parsedTime = DateTime(
                //           0,
                //           0,
                //           0,
                //           pickedTime.hour,
                //           pickedTime.minute,
                //         );
                //         final String formattedTime =
                //             DateFormat('hh:mm a').format(parsedTime);
                //         customerDetailsProvider.taskChoosetimeController.text =
                //             formattedTime;
                //       }
                //     },
                //     readOnly: true,
                //     height: 54,
                //     controller:
                //         customerDetailsProvider.taskChoosetimeController,
                //     hintText: 'Choose Time*',
                //     suffixIcon: IconButton(
                //       icon: const Icon(Icons.access_time_rounded),
                //       onPressed: () async {
                //         // Same time picker logic as above
                //         final DateTime now = DateTime.now();
                //         final bool isToday = customerDetailsProvider
                //                 .taskChoosedateController.text ==
                //             DateFormat('dd MMM yyyy').format(now);

                //         final TimeOfDay? pickedTime = await showTimePicker(
                //           context: context,
                //           initialTime: TimeOfDay.now(),
                //         );

                //         if (pickedTime != null) {
                //           if (isToday) {
                //             final bool isValid =
                //                 validateTime(context, pickedTime, now);
                //             if (!isValid) return; // Don't update if invalid
                //           }

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
                //               .taskChoosetimeController.text = formattedTime;
                //         }
                //       },
                //     ),
                //     labelText: '',
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Assign Workers',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1,
                ),
                children: const <TextSpan>[
                  TextSpan(
                    text: ' *', // The asterisk part
                    style:
                        TextStyle(color: Colors.red), // Red color for asterisk
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
                      customerDetailsProvider.addTaskModel.taskUser?.isNotEmpty)
                    Wrap(
                      children: customerDetailsProvider.addTaskModel.taskUser!
                          .asMap()
                          .entries
                          .map((taskUser) {
                        return Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.primaryBlue),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      .removeAssignedWorker(taskUser.value),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Assign Workers'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          customerDetailsProvider.selectedTaskType != null
                              ? AppColors.appViolet
                              : AppColors.textGrey2,
                      backgroundColor: AppColors.whiteColor,
                      side: BorderSide(
                        color: customerDetailsProvider.selectedTaskType != null
                            ? AppColors.appViolet
                            : AppColors.textGrey2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: customerDetailsProvider.selectedTaskType != null
                        ? () {
                            final selectedTaskType = dropDownProvider.taskType
                                .firstWhere((task) =>
                                    task.taskTypeId ==
                                    customerDetailsProvider.selectedTaskType);
                            final filteredUsers = dropDownProvider
                                .searchUserDetails
                                .where((user) =>
                                    user.departmentId ==
                                    selectedTaskType.departmentIds)
                                .toList();

                            if (filteredUsers.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No workers available in this department to assign!')),
                              );
                              return;
                            }

                            Set<int> selectedUsers = {
                              if (customerDetailsProvider
                                      .addTaskModel.taskUser !=
                                  null)
                                ...customerDetailsProvider
                                    .addTaskModel.taskUser!
                                    .map((taskUser) => taskUser.userDetailsId!)
                                    .where((id) => id != null)
                                    .cast<int>()
                            };

                            Set<int> removedUsers = {};

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      title: const Text('Select Worker'),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        child: ListView(
                                          children: filteredUsers
                                              .where((user) =>
                                                  user.workingStatus == '1')
                                              .map((user) {
                                            bool isSelected = selectedUsers
                                                .contains(user.userDetailsId!);
                                            bool isMarkedForRemoval =
                                                removedUsers.contains(
                                                    user.userDetailsId!);

                                            return ListTile(
                                              title: Text(
                                                  user.userDetailsName ?? ''),
                                              subtitle: Text(
                                                  user.departmentName ?? ''),
                                              trailing: isSelected &&
                                                      !isMarkedForRemoval
                                                  ? const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.blue)
                                                  : const Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      color: Colors.grey),
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    removedUsers.add(
                                                        user.userDetailsId!);
                                                    selectedUsers.remove(
                                                        user.userDetailsId!);
                                                  } else {
                                                    removedUsers.remove(
                                                        user.userDetailsId!);
                                                    selectedUsers.add(
                                                        user.userDetailsId!);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        CustomElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          buttonText: 'Cancel',
                                          backgroundColor: AppColors.whiteColor,
                                          borderColor: AppColors.appViolet,
                                          textColor: AppColors.appViolet,
                                        ),
                                        CustomElevatedButton(
                                          onPressed: () {
                                            try {
                                              for (int userId in removedUsers) {
                                                if (customerDetailsProvider
                                                            .addTaskModel
                                                            .taskUser !=
                                                        null &&
                                                    customerDetailsProvider
                                                        .addTaskModel
                                                        .taskUser!
                                                        .isNotEmpty) {
                                                  var taskUserToRemove =
                                                      customerDetailsProvider
                                                          .addTaskModel
                                                          .taskUser!
                                                          .where((taskUser) =>
                                                              taskUser
                                                                  .userDetailsId ==
                                                              userId)
                                                          .firstOrNull;

                                                  if (taskUserToRemove !=
                                                      null) {
                                                    customerDetailsProvider
                                                        .removeAssignedWorker(
                                                            taskUserToRemove);
                                                  } else {
                                                    print(
                                                        'Warning: User with ID $userId not found in taskUser list');
                                                  }
                                                }
                                              }

                                              for (int userId
                                                  in selectedUsers) {
                                                bool isAlreadyAssigned =
                                                    customerDetailsProvider
                                                            .addTaskModel
                                                            .taskUser
                                                            ?.any((taskUser) =>
                                                                taskUser
                                                                    .userDetailsId ==
                                                                userId) ??
                                                        false;

                                                if (!isAlreadyAssigned) {
                                                  customerDetailsProvider
                                                      .updateAssignWorker(
                                                          userId,
                                                          dropDownProvider);
                                                }
                                              }

                                              Navigator.pop(context);
                                            } catch (e) {
                                              print(
                                                  'Error in worker assignment: $e');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Error updating workers: ${e.toString()}')),
                                              );
                                              Navigator.pop(context);
                                            }
                                          },
                                          buttonText: "Confirm",
                                          backgroundColor: AppColors.appViolet,
                                          borderColor: AppColors.appViolet,
                                          textColor: AppColors.whiteColor,
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          }
                        : null,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearTaskDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider.selectedTaskType != null &&
                customerDetailsProvider.addTaskModel.taskUser!.isNotEmpty &&
                customerDetailsProvider
                    .taskChoosedateController.text.isNotEmpty &&
                // customerDetailsProvider
                //     .taskChoosetimeController.text.isNotEmpty &&
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
                customerDetailsProvider.taskDescriptionController.text
                    .toString(),
                customerDetailsProvider.taskChoosedateController.text
                    .toString(),
                customerDetailsProvider.taskChoosetimeController.text
                    .toString(),
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
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
