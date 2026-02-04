import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vidyanexis/helpers/media_stream_helper_stub.dart'
    if (dart.library.html) 'package:vidyanexis/helpers/media_stream_helper_web.dart';

class AudioFileProvider extends ChangeNotifier {
  List<AudioFile> _audios = [];
  List<AudioFile> get audios => _audios;

// Audio player instance
  AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentPlayingIndex;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isRecordingPaused = false;
  String? _currentRecordingPath;
  Duration _recordingDuration = Duration.zero;
  late DateTime _recordingStartTime;
  Timer? _recordingTimer;

  // Web-specific recording variables
  html.MediaRecorder? _nativeMediaRecorder;
  html.MediaStream? _mediaStream;
  List<html.Blob> _recordedChunks = [];
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _positionChangedSubscription;
  StreamSubscription? _durationChangedSubscription;
  // Getters
  bool get isRecording => _isRecording;
  bool get isRecordingPaused => _isRecordingPaused;
  Duration get recordingDuration => _recordingDuration;
  html.MediaRecorder? get nativeMediaRecorder =>
      _nativeMediaRecorder; // Added this getter

  // Format duration for display
  String get formattedRecordingDuration {
    final minutes = _recordingDuration.inMinutes.toString().padLeft(2, '0');
    final seconds =
        (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Permission handling (same as before)
  // Future<bool> _requestMicrophonePermission() async {
  //   if (kIsWeb) {
  //     try {
  //       print('Requesting web microphone permission...');

  //       final isHttps = html.window.location.protocol == 'https:';
  //       final isLocalhost = html.window.location.hostname == 'localhost' ||
  //           html.window.location.hostname == '127.0.0.1';

  //       print('Protocol: ${html.window.location.protocol}');
  //       print('Hostname: ${html.window.location.hostname}');

  //       if (!isHttps && !isLocalhost) {
  //         print('ERROR: Microphone access requires HTTPS or localhost');
  //         return false;
  //       }

  //       final mediaDevices = html.window.navigator.mediaDevices;
  //       if (mediaDevices == null) {
  //         print('ERROR: MediaDevices not available');
  //         return false;
  //       }

  //       final stream = await mediaDevices.getUserMedia({'audio': true});

  //       if (stream != null) {
  //         print('✓ Microphone permission granted');
  //         stream.getTracks().forEach((track) => track.stop());
  //         return true;
  //       } else {
  //         print('ERROR: getUserMedia returned null');
  //         return false;
  //       }
  //     } catch (e) {
  //       print('ERROR: Web microphone permission check failed: $e');
  //       return false;
  //     }
  //   } else {
  //     final status = await Permission.microphone.request();
  //     return status == PermissionStatus.granted;
  //   }
  // }
  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) {
      try {
        print('Requesting web microphone permission...');

        final isHttps = html.window.location.protocol == 'https:';
        final isLocalhost = html.window.location.hostname == 'localhost' ||
            html.window.location.hostname == '127.0.0.1';

        print('Protocol: ${html.window.location.protocol}');
        print('Hostname: ${html.window.location.hostname}');

        if (!isHttps && !isLocalhost) {
          print('ERROR: Microphone access requires HTTPS or localhost');
          return false;
        }

        final mediaDevices = html.window.navigator.mediaDevices;
        if (mediaDevices == null) {
          print('ERROR: MediaDevices not available');
          return false;
        }

        final stream = await mediaDevices.getUserMedia({'audio': true});

        if (stream != null) {
          print('✓ Microphone permission granted');
          // FIXED: Use helper function instead of direct call
          stopMediaStreamHelper(stream);
          return true;
        } else {
          print('ERROR: getUserMedia returned null');
          return false;
        }
      } catch (e) {
        print('ERROR: Web microphone permission check failed: $e');
        return false;
      }
    } else {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    }
  }

  // Get recording path
  Future<String> _getRecordingPath() async {
    if (kIsWeb) {
      return 'recording_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      final directory = await getTemporaryDirectory();
      return '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }
  }

  // Pause recording
  Future<void> pauseRecording() async {
    try {
      if (_isRecording && !_isRecordingPaused) {
        await _audioRecorder.pause();
        _isRecordingPaused = true;
        _recordingTimer?.cancel();
        notifyListeners();
        print('Recording paused');
      }
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }

  // Resume recording
  Future<void> resumeRecording() async {
    try {
      if (_isRecording && _isRecordingPaused) {
        await _audioRecorder.resume();
        _isRecordingPaused = false;
        _startRecordingTimer();
        notifyListeners();
        print('Recording resumed');
      }
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }

  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        if (_nativeMediaRecorder != null) {
          _stopMediaStream();
          _nativeMediaRecorder = null;
        } else {
          await _audioRecorder.cancel();
        }

        _isRecording = false;
        _isRecordingPaused = false;
        _recordingDuration = Duration.zero;
        _recordingTimer?.cancel();

        if (_currentRecordingPath != null && !kIsWeb) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        notifyListeners();
        print('Recording cancelled');
      }
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  // Start recording timer
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && !_isRecordingPaused) {
        _recordingDuration = DateTime.now().difference(_recordingStartTime);
        notifyListeners();
      }
    });
  }

  // Check if recording is supported
  Future<bool> isRecordingSupported() async {
    if (kIsWeb) {
      return html.window.navigator.mediaDevices != null;
    } else {
      return await _audioRecorder.hasPermission();
    }
  }

  Future<void> addAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Change to false to only allow single selection
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'],
    );

    if (result != null && result.files.isNotEmpty) {
      // Clear existing audio files first
      clearAudios();

      // Only process the first file (since allowMultiple is false, there should only be one)
      var platformFile = result.files.first;
      Uint8List? fileData = platformFile.bytes;

      if (fileData != null) {
        // Determine the file type
        String fileType = determineFileType(fileData);

        if (fileType.startsWith('audio/')) {
          // Create AudioFile object with metadata
          String extension = platformFile.extension ?? 'unknown';
          AudioFile audioFile = AudioFile(
            data: fileData,
            name: platformFile.name,
            extension: extension,
          );

          _audios.add(audioFile);
          print('Audio file added: ${platformFile.name}');
        } else {
          print('Invalid audio file type: ${platformFile.name}');
          // Show error to user if needed
        }
      } else {
        print('Unable to read audio file data for ${platformFile.name}');
        // Show error to user if needed
      }

      notifyListeners();
    } else {
      print('No audio file selected.');
    }
  }

  // Start recording using record package
  Future<void> startRecording() async {
    try {
      print('Starting recording process...');

      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        print('ERROR: Microphone permission denied');
        return;
      }

      // Don't clear existing audios - let user decide
      // clearAudios();

      _currentRecordingPath = await _getRecordingPath();
      print('Recording path: $_currentRecordingPath');

      RecordConfig config;
      if (kIsWeb) {
        config = const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        );
      } else {
        config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );
      }

      await _audioRecorder.start(config, path: _currentRecordingPath ?? '');
      print('✓ AudioRecorder.start() completed');

      _isRecording = true;
      _isRecordingPaused = false;
      _recordingStartTime = DateTime.now();
      _startRecordingTimer();

      notifyListeners();
      print('✓ Recording started successfully');
    } catch (e) {
      print('ERROR: Failed to start recording: $e');
      _isRecording = false;
      _isRecordingPaused = false;
      notifyListeners();
    }
  }

  // // Stop recording
  // Future<void> stopRecording() async {
  //   try {
  //     if (_isRecording) {
  //       print('Stopping recording...');
  //       final path = await _audioRecorder.stop();
  //       print('Recording stopped, path: $path');

  //       _isRecording = false;
  //       _isRecordingPaused = false;
  //       _recordingDuration = Duration.zero;
  //       _recordingTimer?.cancel();

  //       if (path != null && path.isNotEmpty) {
  //         await _saveRecordedAudio(path);
  //       }

  //       notifyListeners();
  //       print('✓ Recording stopped and UI updated');
  //     }
  //   } catch (e) {
  //     print('ERROR: Failed to stop recording: $e');
  //     _isRecording = false;
  //     _isRecordingPaused = false;
  //     _recordingTimer?.cancel();
  //     notifyListeners();
  //   }
  // }

  // Future<void> playAudio(int index) async {
  //   if (index >= 0 && index < _audios.length) {
  //     try {
  //       // Stop current playing audio
  //       await _audioPlayer.stop();

  //       // Reset all playing states
  //       for (var audio in _audios) {
  //         audio.isPlaying = false;
  //       }

  //       AudioFile audioFile = _audios[index];

  //       // For existing files, use the direct URL
  //       if (audioFile.existingPath != null) {
  //         await _audioPlayer.play(UrlSource(audioFile.existingPath!));
  //       }
  //       // For newly added files, use blob URL
  //       else if (audioFile.blobUrl == null) {
  //         String mimeType = _getMimeType(audioFile.extension);
  //         audioFile.blobUrl = _createBlobUrl(audioFile.data, mimeType);
  //         await _audioPlayer.play(UrlSource(audioFile.blobUrl!));
  //       }
  //       // For files with existing blob URLs
  //       else {
  //         await _audioPlayer.play(UrlSource(audioFile.blobUrl!));
  //       }

  //       // Update playing state
  //       _audios[index].isPlaying = true;
  //       _currentPlayingIndex = index;

  //       // Rest of your existing play logic...
  //       _audioPlayer.onPlayerComplete.listen((event) {
  //         if (_currentPlayingIndex != null &&
  //             _currentPlayingIndex! < _audios.length) {
  //           _audios[_currentPlayingIndex!].isPlaying = false;
  //           _currentPlayingIndex = null;
  //           notifyListeners();
  //         }
  //       });

  //       _audioPlayer.onPositionChanged.listen((position) {
  //         if (_currentPlayingIndex != null &&
  //             _currentPlayingIndex! < _audios.length) {
  //           _audios[_currentPlayingIndex!].currentPosition = position;
  //           notifyListeners();
  //         }
  //       });

  //       _audioPlayer.onDurationChanged.listen((duration) {
  //         if (_currentPlayingIndex != null &&
  //             _currentPlayingIndex! < _audios.length) {
  //           _audios[_currentPlayingIndex!].duration = duration;
  //           notifyListeners();
  //         }
  //       });

  //       notifyListeners();
  //     } catch (e) {
  //       print('Error playing audio: $e');
  //       // Consider showing error to user
  //     }
  //   }
  // }

  // Save recorded audio from record package
  Future<void> _saveRecordedAudio(String path) async {
    try {
      print('Saving recorded audio from path: $path');

      Uint8List audioData;

      if (kIsWeb) {
        try {
          final file = File(path);
          if (await file.exists()) {
            audioData = await file.readAsBytes();
            print('✓ Read ${audioData.length} bytes from web file');
          } else {
            print('Web file not found - creating placeholder');
            audioData = Uint8List(0);
          }
        } catch (e) {
          print('Error reading web audio file: $e');
          audioData = Uint8List(0);
        }
      } else {
        final file = File(path);
        if (await file.exists()) {
          audioData = await file.readAsBytes();
          print('✓ Read ${audioData.length} bytes from mobile file');
          await file.delete();
        } else {
          print('Mobile recording file not found');
          audioData = Uint8List(0);
        }
      }

      // Create AudioFile object and add to list
      final fileName =
          'Voice Recording ${DateTime.now().toString().substring(0, 19)}';
      final audioFile = AudioFile(
        data: audioData,
        name: fileName,
        extension: kIsWeb ? 'webm' : 'm4a',
        isRecording: true,
        isPlaying: false, // Make sure this is set
      );

      _audios.add(audioFile);
      print('✓ Audio file added to list. Total files: ${_audios.length}');

      // Force UI update
      notifyListeners();
      print('✓ UI notified of changes');
    } catch (e) {
      print('ERROR: Failed to save recorded audio: $e');
    }
  }

// Method to pause audio
  Future<void> pauseAudio(int index) async {
    if (index >= 0 && index < _audios.length && _audios[index].isPlaying) {
      await _audioPlayer.pause();
      _audios[index].isPlaying = false;
      notifyListeners();
    }
  }

// Method to resume audio
  Future<void> resumeAudio(int index) async {
    if (index >= 0 && index < _audios.length && !_audios[index].isPlaying) {
      await _audioPlayer.resume();
      _audios[index].isPlaying = true;
      notifyListeners();
    }
  }

// Method to stop audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    if (_currentPlayingIndex != null &&
        _currentPlayingIndex! < _audios.length) {
      _audios[_currentPlayingIndex!].isPlaying = false;
      _audios[_currentPlayingIndex!].currentPosition = Duration.zero;
      _currentPlayingIndex = null;
      notifyListeners();
    }
  }

// Method to seek audio
  Future<void> seekAudio(int index, Duration position) async {
    if (index >= 0 && index < _audios.length && _currentPlayingIndex == index) {
      await _audioPlayer.seek(position);
    }
  }

  // Stop native web recording
  Future<void> stopNativeWebRecording() async {
    if (!kIsWeb || _nativeMediaRecorder == null) return;

    try {
      print('Stopping native web recording...');
      _nativeMediaRecorder!.stop();
      _stopMediaStream();

      _isRecording = false;
      _isRecordingPaused = false;
      _recordingDuration = Duration.zero;
      _recordingTimer?.cancel();

      // Don't call notifyListeners here - it will be called in _saveNativeRecording
      print('✓ Native web recording stop initiated');
    } catch (e) {
      print('ERROR: Failed to stop native web recording: $e');
      notifyListeners();
    }
  }

  // Helper method to stop media stream
  void _stopMediaStream() {
    if (_mediaStream != null) {
      stopMediaStreamHelper(_mediaStream);
      _mediaStream = null;
    }
  }

  String _createBlobUrl(Uint8List data, String mimeType) {
    if (kIsWeb) {
      final blob = html.Blob([data], mimeType);
      return html.Url.createObjectUrl(blob);
    } else {
      throw UnsupportedError('Blob URLs are only supported on web platform');
    }
  }

  // Debug recording state
  void debugRecordingState() {
    print('=== Recording State Debug ===');
    print('isRecording: $_isRecording');
    print('isRecordingPaused: $_isRecordingPaused');
    print('currentRecordingPath: $_currentRecordingPath');
    print('recordingDuration: $_recordingDuration');
    print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
    print('Total audio files: ${_audios.length}');

    if (kIsWeb) {
      print('Browser: ${html.window.navigator.userAgent}');
      print('Protocol: ${html.window.location.protocol}');
      print('Hostname: ${html.window.location.hostname}');
      print('Has MediaDevices: ${html.window.navigator.mediaDevices != null}');
      print('Native MediaRecorder: ${_nativeMediaRecorder != null}');
      print('Media Stream: ${_mediaStream != null}');
      print('Recorded chunks: ${_recordedChunks.length}');
    }

    // Print audio files info
    for (int i = 0; i < _audios.length; i++) {
      final audio = _audios[i];
      print('Audio $i: ${audio.name} (${audio.data.length} bytes)');
    }

    print('============================');
  }

  // Test method to add a dummy audio file
  void addTestAudioFile() {
    final testFile = AudioFile(
      data: Uint8List.fromList([1, 2, 3, 4, 5]), // Dummy data
      name: 'Test Audio File',
      extension: 'mp3',
      isRecording: false,
      isPlaying: false,
    );

    _audios.add(testFile);
    notifyListeners();
    print('Test audio file added');
  }

// // Method to get MIME type from extension
//   String _getMimeType(String extension) {
//     switch (extension.toLowerCase()) {
//       case 'mp3':
//         return 'audio/mpeg';
//       case 'wav':
//         return 'audio/wav';
//       case 'aac':
//         return 'audio/aac';
//       case 'm4a':
//         return 'audio/mp4';
//       case 'ogg':
//         return 'audio/ogg';
//       case 'flac':
//         return 'audio/flac';
//       default:
//         return 'audio/mpeg';
//     }
//   }

// Updated determineFileType method to include audio detection
  String determineFileType(Uint8List fileData) {
    if (fileData.length < 4) return 'unknown';

    // Check for common file signatures
    if (fileData[0] == 0xFF && fileData[1] == 0xD8) {
      return 'image/jpeg';
    } else if (fileData[0] == 0x89 &&
        fileData[1] == 0x50 &&
        fileData[2] == 0x4E &&
        fileData[3] == 0x47) {
      return 'image/png';
    } else if (fileData[0] == 0x25 &&
        fileData[1] == 0x50 &&
        fileData[2] == 0x44 &&
        fileData[3] == 0x46) {
      return 'application/pdf';
    } else if (fileData.length > 3 &&
        fileData[0] == 0x49 &&
        fileData[1] == 0x44 &&
        fileData[2] == 0x33) {
      return 'audio/mpeg'; // MP3 with ID3 tag
    } else if (fileData.length > 3 &&
        fileData[0] == 0xFF &&
        (fileData[1] & 0xE0) == 0xE0) {
      return 'audio/mpeg'; // MP3 without ID3 tag
    } else if (fileData.length > 11 &&
        fileData[0] == 0x52 &&
        fileData[1] == 0x49 &&
        fileData[2] == 0x46 &&
        fileData[3] == 0x46 &&
        fileData[8] == 0x57 &&
        fileData[9] == 0x41 &&
        fileData[10] == 0x56 &&
        fileData[11] == 0x45) {
      return 'audio/wav';
    } else if (fileData.length > 11 &&
        fileData[0] == 0x52 &&
        fileData[1] == 0x49 &&
        fileData[2] == 0x46 &&
        fileData[3] == 0x46 &&
        fileData[8] == 0x41 &&
        fileData[9] == 0x56 &&
        fileData[10] == 0x49 &&
        fileData[11] == 0x20) {
      return 'audio/x-ms-wma';
    } else if (fileData.length > 8 &&
        fileData[4] == 0x66 &&
        fileData[5] == 0x74 &&
        fileData[6] == 0x79 &&
        fileData[7] == 0x70) {
      return 'audio/mp4'; // M4A files
    } else if (fileData.length > 3 &&
        fileData[0] == 0x4F &&
        fileData[1] == 0x67 &&
        fileData[2] == 0x67 &&
        fileData[3] == 0x53) {
      return 'audio/ogg';
    }

    return 'unknown';
  }

// Method to clear audio files
  void clearAudios() {
    _audioPlayer.stop();

    // Clean up blob URLs
    for (var audio in _audios) {
      audio.dispose();
    }

    _audios.clear();
    _currentPlayingIndex = null;
    notifyListeners();
  }

// Method to remove specific audio file
  void removeAudio(int index) {
    if (index >= 0 && index < _audios.length) {
      // Stop audio if currently playing this file
      if (_currentPlayingIndex == index) {
        _audioPlayer.stop();
        _currentPlayingIndex = null;
      }

      // Clean up blob URL
      _audios[index].dispose();
      _audios.removeAt(index);

      // Adjust current playing index if necessary
      if (_currentPlayingIndex != null && _currentPlayingIndex! > index) {
        _currentPlayingIndex = _currentPlayingIndex! - 1;
      }

      notifyListeners();
    }
  }

  Future<List<Map<String, String>>> uploadAllAudios(
      String taskId, BuildContext context) async {
    try {
      List audioFiles = audios;
      List<Map<String, String>> uploadedFiles = [];

      if (audioFiles.isEmpty) {
        return uploadedFiles;
      }

      for (var audioFile in audioFiles) {
        String? uploadedFilePath = await saveAudioToAws(
          audioFile.data,
          'audio/mpeg',
          taskId,
          context,
        );

        if (uploadedFilePath != null) {
          uploadedFiles.add({
            'File_Path': HttpUrls.imgBaseUrl + uploadedFilePath,
            'File_Name': audioFile.name,
            'File_Type': 'audio'
          });
        }
      }

      return uploadedFiles;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading audio files: $e')),
      );
      print('Error uploading audio files: $e');
      return [];
    }
  }

  void addExistingAudioFile(AudioFile audioFile) {
    audios.add(audioFile);
    notifyListeners();
  }

  // Native web recording
  Future<void> startNativeWebRecording() async {
    if (!kIsWeb) return;

    try {
      print('Starting native web recording...');

      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        print('ERROR: MediaDevices not available');
        return;
      }

      _mediaStream = await mediaDevices.getUserMedia({'audio': true});

      if (_mediaStream != null) {
        print('✓ Media stream obtained');

        _nativeMediaRecorder = html.MediaRecorder(_mediaStream!);
        _recordedChunks.clear();

        _nativeMediaRecorder!.addEventListener('dataavailable',
            (html.Event event) {
          final blobEvent = event as html.BlobEvent;
          if (blobEvent.data != null && blobEvent.data!.size > 0) {
            _recordedChunks.add(blobEvent.data!);
            print('Data chunk received: ${blobEvent.data!.size} bytes');
          }
        });

        _nativeMediaRecorder!.addEventListener('stop', (html.Event event) {
          print('MediaRecorder stopped - saving recording...');
          _saveNativeRecording();
        });

        _nativeMediaRecorder!.addEventListener('error', (html.Event event) {
          print('MediaRecorder error: $event');
        });

        _nativeMediaRecorder!.start();

        _isRecording = true;
        _isRecordingPaused = false;
        _recordingStartTime = DateTime.now();
        _startRecordingTimer();

        notifyListeners();
        print('✓ Native web recording started');
      }
    } catch (e) {
      print('ERROR: Native web recording failed: $e');
      _stopMediaStream();
    }
  }

  // Save native web recording
  Future<void> _saveNativeRecording() async {
    try {
      print('Saving native web recording...');
      print('Recorded chunks: ${_recordedChunks.length}');

      if (_recordedChunks.isEmpty) {
        print('No recording chunks to save');
        return;
      }

      // Create blob from recorded chunks
      final blob = html.Blob(_recordedChunks, 'audio/webm');
      print('✓ Created blob with ${blob.size} bytes');

      // Convert blob to Uint8List
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);

      reader.onLoad.listen((event) async {
        try {
          final arrayBuffer = reader.result as ByteBuffer;
          final audioData = arrayBuffer.asUint8List();
          print('✓ Converted to Uint8List: ${audioData.length} bytes');

          // Create AudioFile object
          final fileName =
              'Voice Recording ${DateTime.now().toString().substring(0, 19)}';
          final audioFile = AudioFile(
            data: audioData,
            name: fileName,
            extension: 'webm',
            isRecording: true,
            isPlaying: false,
          );

          _audios.add(audioFile);
          print(
              '✓ Native web recording added to list. Total files: ${_audios.length}');

          // Clean up
          _nativeMediaRecorder = null;
          _recordedChunks.clear();

          // Force UI update
          notifyListeners();
          print('✓ UI updated with new recording');
        } catch (e) {
          print('ERROR: Failed to process recording data: $e');
        }
      });

      reader.onError.listen((event) {
        print('ERROR: FileReader error: $event');
      });
    } catch (e) {
      print('ERROR: Failed to save native web recording: $e');
    }
  }

// Method to save individual audio file to AWS
  Future<String?> saveAudioToAws(Uint8List fileData, String fileType,
      String taskId, BuildContext context) async {
    try {
      final String? uploadedFilePath =
          await CloudflareUpload.uploadAudioToCloudflare(
              fileData, fileType, taskId, context);
      return uploadedFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio Upload Failed')),
      );
      print('Error uploading audio to AWS: $e');
      return null;
    }
  }

  Future<void> stopRecording() async {
    try {
      if (_isRecording) {
        print('Stopping recording...');
        final path = await _audioRecorder.stop();
        print('Recording stopped, path: $path');
        clearAudios();

        _isRecording = false;
        _isRecordingPaused = false;
        _recordingDuration = Duration.zero;
        _recordingTimer?.cancel();

        if (path != null && path.isNotEmpty) {
          if (kIsWeb) {
            await _saveWebRecordedAudioSimple(path);
          } else {
            await _saveRecordedAudio(path);
          }
        }

        notifyListeners();
        print('✓ Recording stopped and UI updated');
      }
    } catch (e) {
      print('ERROR: Failed to stop recording: $e');
      _isRecording = false;
      _isRecordingPaused = false;
      _recordingTimer?.cancel();
      notifyListeners();
    }
  }

// Simplified web recording save method
  Future<void> _saveWebRecordedAudioSimple(String path) async {
    try {
      print('Saving web recorded audio from path: $path');

      final fileName =
          'Voice Recording ${DateTime.now().toString().substring(0, 19)}';

      // For web, we'll store the path directly and use it for playback
      // The record package should provide a usable blob URL or data URL
      final audioFile = AudioFile(
        data: Uint8List(0), // Empty data since we'll use the path/URL directly
        name: fileName,
        extension: 'webm',
        isRecording: true,
        isPlaying: false,
        existingPath: path, // Store the path for direct playback
      );

      _audios.add(audioFile);
      print('✓ Web audio file added with path. Total files: ${_audios.length}');
    } catch (e) {
      print('ERROR: Failed to save web recorded audio: $e');
    }
  }

// Updated playAudio method (simplified)
  Future<void> playAudio(int index) async {
    if (index >= 0 && index < _audios.length) {
      try {
        // Stop current playing audio
        await _audioPlayer.stop();

        // Reset all playing states
        for (var audio in _audios) {
          audio.isPlaying = false;
        }

        AudioFile audioFile = _audios[index];
        String? playbackUrl;

        // Determine playback source
        if (audioFile.existingPath != null &&
            audioFile.existingPath!.isNotEmpty) {
          // Use existing path (for recorded files on web or uploaded files)
          playbackUrl = audioFile.existingPath!;
          print('Using existing path for playback: ${audioFile.existingPath}');
        } else if (audioFile.blobUrl != null && audioFile.blobUrl!.isNotEmpty) {
          // Use existing blob URL
          playbackUrl = audioFile.blobUrl!;
          print('Using existing blob URL for playback');
        } else if (audioFile.data.isNotEmpty) {
          // Create blob URL from data (for uploaded files)
          String mimeType = _getMimeType(audioFile.extension);
          if (audioFile.blobUrl == null) {
            audioFile.blobUrl = _createBlobUrl(audioFile.data, mimeType);
          }
          playbackUrl = audioFile.blobUrl!;
          print('Created new blob URL from data for playback');
        } else {
          print('ERROR: No playback source available for audio file');
          return;
        }

        // Play the audio
        await _audioPlayer.play(UrlSource(playbackUrl));
        print('✓ Playing audio from: $playbackUrl');

        // Update playing state
        _audios[index].isPlaying = true;
        _currentPlayingIndex = index;

        // Set up event listeners (only set up once to avoid multiple listeners)
        _setupAudioPlayerListeners();

        notifyListeners();
      } catch (e) {
        print('Error playing audio: $e');
        // Reset playing state on error
        if (_currentPlayingIndex != null &&
            _currentPlayingIndex! < _audios.length) {
          _audios[_currentPlayingIndex!].isPlaying = false;
          _currentPlayingIndex = null;
          notifyListeners();
        }
      }
    }
  }

// Helper method to set up audio player listeners (to avoid duplicate listeners)
  void _setupAudioPlayerListeners() {
    // Cancel existing subscriptions if any
    _playerCompleteSubscription?.cancel();
    _positionChangedSubscription?.cancel();
    _durationChangedSubscription?.cancel();

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (_currentPlayingIndex != null &&
          _currentPlayingIndex! < _audios.length) {
        _audios[_currentPlayingIndex!].isPlaying = false;
        _currentPlayingIndex = null;
        notifyListeners();
      }
    });

    _positionChangedSubscription =
        _audioPlayer.onPositionChanged.listen((position) {
      if (_currentPlayingIndex != null &&
          _currentPlayingIndex! < _audios.length) {
        _audios[_currentPlayingIndex!].currentPosition = position;
        notifyListeners();
      }
    });

    _durationChangedSubscription =
        _audioPlayer.onDurationChanged.listen((duration) {
      if (_currentPlayingIndex != null &&
          _currentPlayingIndex! < _audios.length) {
        _audios[_currentPlayingIndex!].duration = duration;
        notifyListeners();
      }
    });
  }

// Add these subscription variables to your provider class:
// StreamSubscription? _playerCompleteSubscription;
// StreamSubscription? _positionChangedSubscription;
// StreamSubscription? _durationChangedSubscription;

// Don't forget to dispose of subscriptions in your dispose method:
/*
@override
void dispose() {
  _playerCompleteSubscription?.cancel();
  _positionChangedSubscription?.cancel();
  _durationChangedSubscription?.cancel();
  _audioPlayer.dispose();
  _audioRecorder.dispose();
  _recordingTimer?.cancel();
  super.dispose();
}
*/

// Helper method to get MIME type
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'webm':
        return 'audio/webm';
      case 'm4a':
        return 'audio/mp4';
      case 'aac':
        return 'audio/aac';
      case 'ogg':
        return 'audio/ogg';
      case 'flac':
        return 'audio/flac';
      default:
        return 'audio/webm';
    }
  }
}

class AudioFile {
  final Uint8List data;
  final String name;
  final String extension;
  bool isPlaying;
  Duration duration;
  Duration currentPosition;
  String? blobUrl;
  String? existingPath; // Stores the full AWS URL for existing files
  final bool isRecording; // Add this

  AudioFile({
    required this.data,
    required this.name,
    required this.extension,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.currentPosition = Duration.zero,
    this.blobUrl,
    this.existingPath,
    this.isRecording = false,
  });

  void dispose() {
    // Only revoke object URLs we created, not the AWS URLs
    if (blobUrl != null && !blobUrl!.startsWith('http')) {
      html.Url.revokeObjectUrl(blobUrl!);
    }
  }
}
