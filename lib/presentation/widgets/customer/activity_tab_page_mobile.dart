import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_history.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/presentation/widgets/home/edit_remark_dialog.dart';
import 'package:vidyanexis/utils/status_utils.dart';

class ActivityTabPage extends StatefulWidget {
  final SearchLeadModel? lead;
  final int customerId;

  const ActivityTabPage({
    super.key,
    required this.lead,
    required this.customerId,
  });

  @override
  State<ActivityTabPage> createState() => _ActivityTabPageState();
}

class _PlayingAudioState {
  AudioPlayer? player;
  bool isPlaying;
  Duration position;
  Duration duration;
  bool audioError;
  String? url;
  int? audioParentIndex; // index in followUpHistory where this audio belongs

  _PlayingAudioState({
    required this.player,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.audioError,
    this.url,
    this.audioParentIndex,
  });
}

class _ActivityTabPageState extends State<ActivityTabPage> {
  _PlayingAudioState? _playingState;

  void _initAudioPlayer(String url, int audioIndex) {
    // Safely dispose any previous player
    if (_playingState?.player != null) {
      _playingState?.player?.stop();
      _playingState?.player?.dispose();
      _playingState?.player = null;
    }

    final player = AudioPlayer();
    _playingState = _PlayingAudioState(
      player: player,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
      audioError: false,
      url: url,
      audioParentIndex: audioIndex,
    );

    // Listen to audio player events
    // Handle potential null reference exceptions in callbacks by early return
    player.onPlayerComplete.listen((event) {
      if (!mounted) return;
      if (_playingState?.audioParentIndex == audioIndex) {
        setState(() {
          _playingState?.isPlaying = false;
          _playingState?.position = Duration.zero;
        });
      }
    });
    player.onPositionChanged.listen((pos) {
      if (!mounted) return;
      if (_playingState?.audioParentIndex == audioIndex) {
        setState(() {
          _playingState?.position = pos;
        });
      }
    });
    player.onDurationChanged.listen((dur) {
      if (!mounted) return;
      if (_playingState?.audioParentIndex == audioIndex) {
        setState(() {
          _playingState?.duration = dur;
        });
      }
    });
    player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      if (_playingState?.audioParentIndex == audioIndex &&
          state == PlayerState.stopped &&
          _playingState?.isPlaying == true) {
        setState(() {
          _playingState?.isPlaying = false;
        });
      }
    });
  }

  Future<void> _togglePlay(
      {required String url, required int audioIndex}) async {
    // If a different audio is being played, stop and reinit
    if (_playingState == null ||
        _playingState!.audioParentIndex != audioIndex ||
        _playingState!.url != url) {
      _initAudioPlayer(url, audioIndex);
    }

    final player = _playingState!.player;
    if (player == null) return;
    if (_playingState!.isPlaying) {
      await player.pause();
      if (mounted) {
        setState(() {
          _playingState!.isPlaying = false;
        });
      }
    } else {
      try {
        if (_playingState!.position > Duration.zero) {
          await player.resume();
        } else {
          await player.stop();
          await player.play(UrlSource(url));
        }
        if (mounted) {
          setState(() {
            _playingState!.isPlaying = true;
            _playingState!.audioError = false;
          });
        }
      } catch (e) {
        // ignore: avoid_print
        print('Audio play error: $e');
        if (mounted) {
          setState(() {
            _playingState!.isPlaying = false;
            _playingState!.audioError = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to play audio."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);
      leadDetailsProvider.fetchFollowUpHistory(widget.customerId.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    if (_playingState?.player != null) {
      _playingState?.player?.stop();
      _playingState?.player?.dispose();
      _playingState?.player = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: _buildActivityFlow(leadDetailsProvider),
    );
  }

  Widget _buildActivityFlow(LeadDetailsProvider leadDetailsProvider) {
    if (leadDetailsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leadDetailsProvider.followUpHistory!.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Text(
              'No activity',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
            ),
            const SizedBox(height: 4),
            Text(
              'Start by creating a new follow-up.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey3),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: leadDetailsProvider.followUpHistory!.length,
      itemBuilder: (context, index) {
        final lead = leadDetailsProvider.followUpHistory![index];
        return _buildActivityCard(context, lead, index);
      },
    );
  }

  Widget _buildActivityCard(
      BuildContext context, FollowUpHistory lead, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE9EDF1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Date & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.history,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _formatDate(lead.entryDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(lead),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE9EDF1), height: 1),
          ),
          // Assignment & Next Follow up
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildInfoColumn(
                'To',
                _buildUserCell(lead.toUserName),
              ),
              _buildInfoColumn(
                'By',
                _buildUserCell(lead.byUserName),
              ),
              if (lead.nextFollowUpDate.isNotEmpty)
                _buildInfoColumn(
                  'Next Follow-up',
                  _buildNextFollowUpCell(lead.nextFollowUpDate),
                ),
            ],
          ),
          if (lead.remark.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE9EDF1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remarks',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          EditRemarkDialog.show(
                            context,
                            customerId: widget.customerId.toString(),
                            followUpId: lead.followUpId,
                            initialRemark: lead.remark,
                            statusId: lead.statusId,
                            statusName: lead.statusName,
                            toUserName: lead.toUserName,
                            followUpDate: lead.nextFollowUpDate,
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: AppColors.primaryBlue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lead.remark,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (lead.audios.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAudioPlayer(lead, index),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FollowUpHistory lead) {
    Color bgColor = const Color(0xFFD9FAD9);
    Color textColor = const Color(0xFF407537);

    if (lead.statusId > 0) {
      bgColor = StatusUtils.getStatusColor(lead.statusId);
      textColor = StatusUtils.getStatusTextColor(lead.statusId);
    } else {
      final s = lead.statusName.toLowerCase();
      if (s.contains('not') ||
          s.contains('lost') ||
          s.contains('reject') ||
          s.contains('cancel') ||
          s.contains('drop')) {
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
      } else if (s.contains('pending') ||
          s.contains('hold') ||
          s.contains('wait')) {
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
      } else if (lead.colorCode.isNotEmpty) {
        final c = AppColors.parseColor(lead.colorCode);
        bgColor = c.withValues(alpha: 0.15);
        textColor = c;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        lead.statusName.isNotEmpty ? lead.statusName : 'Follow up',
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserCell(String userName) {
    if (userName.isEmpty || userName == 'null') {
      return const Text("-",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: getAvatarColor(userName),
          child: Text(
            userName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            userName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildNextFollowUpCell(String nextFollowUpDate) {
    final dateFormatted = _formatDate(nextFollowUpDate, includeTime: false);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.calendar_today_outlined,
            size: 14, color: AppColors.textGrey3),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            dateFormatted,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  String _formatDate(String dateStr, {bool includeTime = true}) {
    if (dateStr.isEmpty || dateStr == 'null') return '-';
    try {
      String cleaned = dateStr
          .replaceFirst(RegExp(r'00:00:00\.000\s*'), '')
          .replaceFirst(RegExp(r'\.000.*$'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      final dateTime = DateTime.tryParse(cleaned);
      if (dateTime != null) {
        return includeTime
            ? DateFormat('dd MMM yyyy hh:mm:ss a').format(dateTime)
            : DateFormat('dd MMM yyyy').format(dateTime);
      }

      try {
        final parts = cleaned.split('-');
        if (parts.length == 3 &&
            parts[0].length == 2 &&
            parts[2].length == 4) {
          final dt = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          return DateFormat('dd MMM yyyy').format(dt);
        }
      } catch (_) {}

      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildAudioPlayer(FollowUpHistory lead, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Audio", style: TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 6),
        Row(
          children: [
            InkWell(
              onTap: () async {
                final url = lead.audios.first.filePath ?? '';
                if (url.isEmpty) return;
                await _togglePlay(
                  url: url,
                  audioIndex: index,
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon((_playingState != null &&
                        _playingState!.audioParentIndex == index &&
                        _playingState!.isPlaying)
                    ? Icons.pause
                    : Icons.play_arrow),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SliderTheme(
                data: const SliderThemeData(trackHeight: 2),
                child: Slider(
                  min: 0,
                  max: (_playingState != null &&
                          _playingState!.audioParentIndex == index
                      ? _playingState!.duration.inMilliseconds
                          .toDouble()
                          .clamp(0.0, double.infinity)
                      : 1.0),
                  value: (_playingState != null &&
                          _playingState!.audioParentIndex == index
                      ? _playingState!.position.inMilliseconds
                          .clamp(
                              0, _playingState!.duration.inMilliseconds)
                          .toDouble()
                      : 0.0),
                  onChanged: (_playingState != null &&
                          _playingState!.audioParentIndex == index)
                      ? (v) async {
                          final pos = Duration(milliseconds: v.toInt());
                          await _playingState!.player?.seek(pos);
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
                (_playingState != null &&
                        _playingState!.audioParentIndex == index)
                    ? '${_format(_playingState!.position)} / ${_format(_playingState!.duration)}'
                    : '${_format(Duration.zero)} / ${_format(Duration.zero)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
