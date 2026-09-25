import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/task_history_popup.dart';

class CustomerTaskOverviewTab extends StatefulWidget {
  final String customerId;
  const CustomerTaskOverviewTab({super.key, required this.customerId});

  @override
  State<CustomerTaskOverviewTab> createState() =>
      _CustomerTaskOverviewTabState();
}

class _CustomerTaskOverviewTabState extends State<CustomerTaskOverviewTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getCustomerTaskOverview(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isTaskOverviewLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = provider.customerTaskOverviewTasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No summary data available',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        final isWeb = AppStyles.isWebScreen(context);

        if (isWeb) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: tasks.map((task) {
                return _buildSummaryCard(task, isWeb: isWeb);
              }).toList(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return _buildSummaryCard(task, isWeb: isWeb);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(TaskCustomerModel task, {bool isWeb = false}) {
    return TaskSummaryCardWidget(task: task, isWeb: isWeb);
  }
}

class TaskSummaryCardWidget extends StatefulWidget {
  final TaskCustomerModel task;
  final bool isWeb;

  const TaskSummaryCardWidget(
      {super.key, required this.task, this.isWeb = false});

  @override
  State<TaskSummaryCardWidget> createState() => _TaskSummaryCardWidgetState();
}

class _TaskSummaryCardWidgetState extends State<TaskSummaryCardWidget> {
  bool _isLoadingStatus = true;
  bool _isFollowUp = false;

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final statuses = await dropDownProvider.getStatusByTaskTypeId(
        context, widget.task.taskTypeId.toString(), '3');

    bool isFollowUp = false;
    for (var status in statuses) {
      if (status.statusId == widget.task.taskStatusId) {
        if (status.followup == 1) {
          isFollowUp = true;
        }
        break;
      }
    }
    if (mounted) {
      setState(() {
        _isFollowUp = isFollowUp;
        _isLoadingStatus = false;
      });
    }
  }

  Color _getStatusColor(String statusName) {
    final status = statusName.toLowerCase();
    if (status.contains('complete') ||
        status.contains('finish') ||
        status.contains('done')) {
      return const Color(0xFF10B981);
    } else if (status.contains('pending') || status.contains('wait')) {
      return const Color(0xFFF59E0B);
    } else if (status.contains('hold') || status.contains('cancel')) {
      return const Color(0xFFEF4444);
    } else if (status.contains('progress')) {
      return const Color(0xFF8B5CF6);
    }
    return const Color(0xFF3B82F6);
  }

  String _formatDate(String dateStr) {
    try {
      String cleaned = dateStr
          .replaceFirst(RegExp(r'00:00:00\.000\s*'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      final dateTime = DateTime.parse(cleaned);
      return DateFormat('dd/MM/yyyy hh:mm:ss a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDays(int days) {
    if (days == 0) return '0 Days';
    if (days == 1) return '1 Day';
    return '$days Days';
  }

  bool _isAudioFile(TaskFile file) {
    final type = (file.fileType ?? '').toLowerCase().trim();
    final path = (file.filePath ?? '').toLowerCase().trim();
    final name = (file.fileName ?? '').toLowerCase().trim();

    return type == 'audio' ||
        type.contains('audio') ||
        path.endsWith('.mpeg') ||
        path.endsWith('.mp3') ||
        path.endsWith('.wav') ||
        path.endsWith('.m4a') ||
        path.endsWith('.ogg') ||
        path.endsWith('.webm') ||
        path.contains('uploadedaudios') ||
        name.endsWith('.mpeg') ||
        name.endsWith('.mp3') ||
        name.endsWith('.wav') ||
        name.endsWith('.m4a') ||
        name.endsWith('.webm');
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isWeb = widget.isWeb;

    // Calculate durations
    String taskTypeDurationStr = '';
    String actualDurationStr = '';

    if (!_isLoadingStatus) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate =
          DateTime(task.taskDate.year, task.taskDate.month, task.taskDate.day);

      final taskTypeDuration = taskDate.difference(today).inDays;
      taskTypeDurationStr = _formatDays(taskTypeDuration);

      if (task.entryDate != null) {
        final entryDate = DateTime(
            task.entryDate!.year, task.entryDate!.month, task.entryDate!.day);
        if (_isFollowUp) {
          final actualDuration = today.difference(entryDate).inDays;
          actualDurationStr = _formatDays(actualDuration);
        } else {
          final actualDuration = taskDate.difference(entryDate).inDays;
          actualDurationStr = _formatDays(actualDuration);
        }
      }
    }

    // Separate audio files and other documents
    final audioFiles = task.taskFiles.where(_isAudioFile).toList();
    final documentFiles =
        task.taskFiles.where((f) => !_isAudioFile(f)).toList();

    return InkWell(
      onTap: () {
        final provider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        provider.fetchTaskHistory(task.taskId.toString());
        showDialog(
          context: context,
          builder: (context) => TaskHistoryPopup(
            taskId: task.taskId.toString(),
            taskName: task.taskTypeName,
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 230,
        margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.taskTypeName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              task.taskStatusName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(task.taskStatusName),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Created on \n ${_formatDate(task.entryDate?.toString() ?? '')}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
            if (task.completionDate.toString().trim().isNotEmpty &&
                task.completionDate.toString().trim() != 'null') ...[
              const SizedBox(height: 6),
              Text(
                'Completed on \n ${_formatDate(task.completionDate.toString())}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
            if (task.toUsername.toString().trim().isNotEmpty &&
                task.toUsername.toString().trim() != 'null') ...[
              const SizedBox(height: 6),
              Text(
                'By ${task.toUsername}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!_isLoadingStatus) ...[
              const SizedBox(height: 6),
              Text(
                'Task Type Duration: $taskTypeDurationStr',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Actual Duration: $actualDurationStr',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
            // Voice recordings section
            if (audioFiles.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...audioFiles.map((audioFile) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TaskSummaryAudioPlayer(
                    url: audioFile.filePath ?? '',
                    fileName: audioFile.fileName?.isNotEmpty == true
                        ? audioFile.fileName!
                        : 'Voice Recording',
                  ),
                );
              }),
            ],
            // Other document attachments section
            if (documentFiles.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: documentFiles.map((doc) {
                  final rawUrl = (doc.filePath ?? '').trim();
                  return InkWell(
                    onTap: () async {
                      if (rawUrl.isNotEmpty) {
                        String fullUrl = rawUrl.replaceAll('\\', '/');
                        if (!fullUrl.startsWith('http://') &&
                            !fullUrl.startsWith('https://')) {
                          if (fullUrl.startsWith('/')) {
                            fullUrl = fullUrl.substring(1);
                          }
                          final base = HttpUrls.imgBaseUrl.endsWith('/')
                              ? HttpUrls.imgBaseUrl
                              : '${HttpUrls.imgBaseUrl}/';
                          fullUrl = '$base$fullUrl';
                        }
                        final uri = Uri.tryParse(fullUrl);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2F6),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file,
                              size: 11, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              doc.fileName?.isNotEmpty == true
                                  ? doc.fileName!
                                  : (doc.documentTypeName ?? 'Attachment'),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TaskSummaryAudioPlayer extends StatefulWidget {
  final String url;
  final String fileName;

  const TaskSummaryAudioPlayer({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  State<TaskSummaryAudioPlayer> createState() => _TaskSummaryAudioPlayerState();
}

class _TaskSummaryAudioPlayerState extends State<TaskSummaryAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
    _player.onPositionChanged.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur;
        });
      }
    });
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (mounted && _isPlaying) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  String _resolveAudioUrl(String raw) {
    String url = raw.trim().replaceAll('\\', '/');
    if (url.isEmpty) return '';
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      if (url.startsWith('/')) {
        url = url.substring(1);
      }
      final base = HttpUrls.imgBaseUrl.endsWith('/')
          ? HttpUrls.imgBaseUrl
          : '${HttpUrls.imgBaseUrl}/';
      url = '$base$url';
    }
    return Uri.encodeFull(url);
  }

  Future<void> _togglePlay() async {
    final resolvedUrl = _resolveAudioUrl(widget.url);
    if (resolvedUrl.isEmpty) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      } else {
        if (_position > Duration.zero) {
          await _player.resume();
        } else {
          await _player.stop();
          debugPrint('Playing audio from URL: $resolvedUrl');
          await _player.play(UrlSource(resolvedUrl));
        }
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _hasError = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Audio playback error for $resolvedUrl: $e');
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    if (_duration.inMilliseconds > 0) {
      progress =
          (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _hasError
                        ? Colors.red.shade400
                        : const Color(0xFF1A7AE8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic_rounded,
                            size: 12, color: Color(0xFF1A7AE8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.fileName.isNotEmpty
                                ? widget.fileName
                                : 'Voice Note',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isPlaying || _position > Duration.zero
                          ? '${_formatDuration(_position)} / ${_formatDuration(_duration)}'
                          : 'Voice Recording',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isPlaying || progress > 0) ...[
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF1A7AE8)),
                minHeight: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
