import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/lead_details_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/models/search_leads_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:techtify/presentation/widgets/customer/task_list_page_mobile.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/utils/extensions.dart';

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
        body: leadDetailsProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : leadDetailsProvider.followUpHistory!.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Text(
                          'No activity',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Start by creating a new follow-up.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 2,
                              color: AppColors.grey,
                            );
                          },
                          itemCount:
                              leadDetailsProvider.followUpHistory!.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final lead =
                                leadDetailsProvider.followUpHistory![index];

                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration:
                                  BoxDecoration(color: AppColors.whiteColor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: AppColors.grey)),
                                            height: 32,
                                            width: 32,
                                            child: Center(
                                              child: Image.asset(
                                                'assets/images/lead_icon_4.png',
                                                height: 16,
                                                width: 16,
                                                color: AppColors.parseColor(
                                                    lead.colorCode),
                                              ),
                                            )),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              lead.statusName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textBlack),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textGrey3,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: 'by ',
                                                  ),
                                                  TextSpan(
                                                    text: lead.byUserName,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.textGrey3,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: ' to ',
                                                  ),
                                                  TextSpan(
                                                    text: lead.toUserName,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.textGrey3,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ' • ${lead.entryDate.toDate()}',
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            if (lead.remark.isNotEmpty)
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width -
                                                        100,
                                                child: Text(
                                                  lead.remark,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                  maxLines: 4,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ),
                                              ),
                                            if (lead.remark.isNotEmpty)
                                              const SizedBox(
                                                height: 8,
                                              ),
                                            RichText(
                                              text: TextSpan(
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textGrey3,
                                                ),
                                                children: [
                                                  const TextSpan(
                                                    text: 'Next Follow-up, ',
                                                  ),
                                                  TextSpan(
                                                    text: lead.nextFollowUpDate
                                                        .toWeekdayDate(),
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.textGrey3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (lead.audios.isNotEmpty) ...[
                                      const Text("Audio",
                                          style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              final url =
                                                  lead.audios.first.filePath ??
                                                      '';
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
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Icon((_playingState !=
                                                          null &&
                                                      _playingState!
                                                              .audioParentIndex ==
                                                          index &&
                                                      _playingState!.isPlaying)
                                                  ? Icons.pause
                                                  : Icons.play_arrow),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: SliderTheme(
                                              data: const SliderThemeData(
                                                  trackHeight: 2),
                                              child: Slider(
                                                min: 0,
                                                max: (_playingState != null &&
                                                        _playingState!
                                                                .audioParentIndex ==
                                                            index
                                                    ? _playingState!
                                                        .duration.inMilliseconds
                                                        .toDouble()
                                                        .clamp(0.0,
                                                            double.infinity)
                                                    : 1.0),
                                                value: (_playingState != null &&
                                                        _playingState!
                                                                .audioParentIndex ==
                                                            index
                                                    ? _playingState!
                                                        .position.inMilliseconds
                                                        .clamp(
                                                            0,
                                                            _playingState!
                                                                .duration
                                                                .inMilliseconds)
                                                        .toDouble()
                                                    : 0.0),
                                                onChanged: (_playingState !=
                                                            null &&
                                                        _playingState!
                                                                .audioParentIndex ==
                                                            index)
                                                    ? (v) async {
                                                        final pos = Duration(
                                                            milliseconds:
                                                                v.toInt());
                                                        await _playingState!
                                                            .player
                                                            ?.seek(pos);
                                                      }
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                              (_playingState != null &&
                                                      _playingState!
                                                              .audioParentIndex ==
                                                          index)
                                                  ? '${_format(_playingState!.position)} / ${_format(_playingState!.duration)}'
                                                  : '${_format(Duration.zero)} / ${_format(Duration.zero)}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Add Follow-up',
          onPressed: () {
            final settingsProvider =
                Provider.of<SettingsProvider>(context, listen: false);

            final leadsProvider =
                Provider.of<LeadsProvider>(context, listen: false);
            leadsProvider.statusController.clear();
            leadsProvider.assignToFollowUpController.clear();
            leadsProvider.messageController.clear();
            leadsProvider.nextFollowUpDateController.clear();
            final dropDownProvider =
                Provider.of<DropDownProvider>(context, listen: false);
            dropDownProvider.selectedStatusId = null;
            dropDownProvider.selectedUserId = null;
            leadsProvider.setCutomerId(int.parse(widget.customerId.toString()));

            dropDownProvider.selectedStatusId =
                int.parse(widget.lead?.statusId.toString() ?? "0");
            dropDownProvider.selectedUserId =
                int.parse(widget.lead?.toUserId.toString() ?? "0");
            leadsProvider.setCutomerId(widget.customerId);
            leadsProvider.statusController.text = widget.lead?.statusName ?? "";
            leadsProvider.branchController.text = widget.lead?.branchName ?? "";
            settingsProvider.selectedBranchId = widget.lead?.branchId ?? 0;
            leadsProvider.assignToFollowUpController.text =
                widget.lead?.toUserName ?? "";
            leadsProvider.departmentController.text =
                widget.lead?.departmentName ?? "";
            settingsProvider.selectedDepartmentId =
                int.parse(widget.lead?.departmentId ?? "0");
            leadsProvider.nextFollowUpDateController.text =
                (widget.lead?.nextFollowUpDate ?? '').isNotEmpty
                    ? DateFormat('dd MMM yyyy').format(
                        DateTime.tryParse(widget.lead!.nextFollowUpDate!) ??
                            DateTime(2000, 1, 1))
                    : '';
            // leadsProvider.messageController.text =
            //     lead.remark;
            leadsProvider.messageController.clear();
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddFollowupDialog(
                  customerName: widget.lead?.customerName ?? '',
                );
              },
            ));
            // showDialog(
            //   barrierDismissible: true,
            //   context: context,
            //   builder: (BuildContext context) => AddFollowupDialog(
            //     customerName: '- ${widget.lead?.customerName ?? ''}',
            //   ),
            // );
            // final leadProvider =
            //     Provider.of<LeadsProvider>(context, listen: false);
            // leadProvider.statusController.clear();
            // leadProvider.assignToFollowUpController.clear();
            // leadProvider.messageController.clear();
            // leadProvider.nextFollowUpDateController.clear();
            // final dropDownProvider =
            //     Provider.of<DropDownProvider>(context, listen: false);
            // dropDownProvider.selectedStatusId = null;
            // dropDownProvider.selectedUserId = null;
            // leadProvider.setCutomerId(int.parse(widget.customerId));
            // showDialog(
            //   barrierDismissible: false,
            //   context: context,
            //   builder: (BuildContext context) => const AddFollowupDialog(
            //     customerName: '',
            //   ),
            // );
          },
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
