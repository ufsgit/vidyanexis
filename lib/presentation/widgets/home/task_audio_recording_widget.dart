import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';

class TaskAudioRecordingWidget extends StatelessWidget {
  const TaskAudioRecordingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioFileProvider>(
      builder: (context, provider, child) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'Voice Note / Audio',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                if (provider.audios.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A7AE8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.audios.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A7AE8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Recording State
                  if (provider.isRecording) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: provider.isRecordingPaused
                                      ? Colors.orange
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                provider.isRecordingPaused
                                    ? 'Recording Paused'
                                    : 'Recording Voice Note...',
                                style: TextStyle(
                                  color: provider.isRecordingPaused
                                      ? Colors.orange.shade800
                                      : Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  provider.formattedRecordingDuration,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              // Pause / Resume (Mobile / non-native web)
                              if (provider.nativeMediaRecorder == null)
                                OutlinedButton.icon(
                                  onPressed: provider.isRecordingPaused
                                      ? provider.resumeRecording
                                      : provider.pauseRecording,
                                  icon: Icon(
                                    provider.isRecordingPaused
                                        ? Icons.play_arrow_rounded
                                        : Icons.pause_rounded,
                                    size: 16,
                                  ),
                                  label: Text(provider.isRecordingPaused
                                      ? 'Resume'
                                      : 'Pause'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.orange.shade800,
                                    side: BorderSide(
                                        color: Colors.orange.shade300),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              // Stop and Save
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (kIsWeb &&
                                      provider.nativeMediaRecorder != null) {
                                    await provider.stopNativeWebRecording();
                                  } else {
                                    await provider.stopRecording();
                                  }
                                },
                                icon: const Icon(Icons.stop_rounded, size: 16),
                                label: const Text('Stop & Attach'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              // Cancel
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await provider.cancelRecording();
                                },
                                icon: const Icon(Icons.delete_outline,
                                    size: 16),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(
                                      color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Not recording - Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await provider.startRecording();
                            },
                            icon: const Icon(Icons.mic_rounded,
                                size: 18, color: Colors.red),
                            label: Text(
                              isSmallScreen
                                  ? 'Record'
                                  : 'Record Voice Note',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await provider.addAudioFile();
                            },
                            icon: const Icon(Icons.upload_file_rounded,
                                size: 18, color: Color(0xFF1A7AE8)),
                            label: Text(
                              isSmallScreen ? 'Upload' : 'Upload Audio',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xFFE2E8F0)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (kIsWeb) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 13, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Allow microphone access when prompted to record directly in browser',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  // Audio Files List
                  if (provider.audios.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),
                    ...provider.audios.asMap().entries.map((entry) {
                      int index = entry.key;
                      AudioFile audioFile = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: const Color(0xFFE2E8F0), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: audioFile.isRecording
                                    ? Colors.red.shade50
                                    : const Color(0xFFEEF2F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                audioFile.isRecording
                                    ? Icons.mic_rounded
                                    : Icons.audiotrack_rounded,
                                color: audioFile.isRecording
                                    ? Colors.red.shade600
                                    : const Color(0xFF1A7AE8),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    audioFile.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (audioFile.isRecording) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                          child: Text(
                                            'VOICE NOTE',
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Text(
                                        '${(audioFile.data.length / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Play / Pause Button
                            InkWell(
                              onTap: () {
                                if (audioFile.isPlaying) {
                                  provider.pauseAudio(index);
                                } else {
                                  provider.playAudio(index);
                                }
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A7AE8),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  audioFile.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                            if (audioFile.isPlaying) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => provider.stopAudio(),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.stop_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 6),
                            // Delete Button
                            InkWell(
                              onTap: () {
                                provider.removeAudio(index);
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.red.shade700,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
