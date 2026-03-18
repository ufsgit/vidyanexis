import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/follow_up_history.dart';
import 'package:audioplayers/audioplayers.dart';

class FollowUpCard extends StatefulWidget {
  final FollowUpHistory entry;

  const FollowUpCard({super.key, required this.entry});

  @override
  State<FollowUpCard> createState() => _FollowUpCardState();
}

class _FollowUpCardState extends State<FollowUpCard> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _audioError = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((event) {
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
    // Optional: Listen to onPlayerError for deeper handling (if audioplayers supports it)
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && _isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Don't trigger UI updates after dispose.
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      final url = widget.entry.audios.firstOrNull?.filePath ?? '';
      print('URL-----$url');
      if (url.isEmpty) return;

      try {
        if (_position > Duration.zero) {
          await _player.resume();
        } else {
          await _player
              .stop(); // Stop any previous playback before starting again
          await _player.play(
            UrlSource(url),
          );
        }
        if (mounted) {
          setState(() {
            _isPlaying = true;
            _audioError = false;
          });
        }
      } catch (e) {
        print('Audio play error: $e');
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _audioError = true;
          });
          // For web error: consider tailoring the error message for unsupported audio format
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    widget.entry.entryDate.substring(0, 2), // Day (e.g., "07")
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(
                      DateTime.parse(
                        '2024-${widget.entry.entryDate.substring(3, 5)}-01',
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.entry.entryDate
                        .substring(6, 10), // Year (e.g., "2024")
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.entry.entryDate.substring(11), // time
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        AppStyles.isWebScreen(context) ? "Assigned To" : "To",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E97A3)),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 18,
                              color: Color(0xFF8E97A3),
                            ),
                            const SizedBox(width: 6),
                            Text(widget.entry.toUserName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        "by",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8E97A3)),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.account_circle,
                              size: 18,
                              color: Color(0xFF8E97A3),
                            ),
                            const SizedBox(width: 6),
                            Text(widget.entry.byUserName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status",
                              style: TextStyle(
                                  color: Color(0xFF8E97A3),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(
                            height: 8,
                          ),
                          Container(
                            padding: widget.entry.statusName.isNotEmpty
                                ? const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4)
                                : const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                              // color: StatusUtils.getStatusColor(entry.statusId),
                              color: parseColor(widget.entry.colorCode)
                                  .withOpacity(0.1)
                                  .withAlpha(30),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: Colors.black45, width: 0.1),
                            ),
                            child: Text(
                              widget.entry.statusName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                // color: StatusUtils.getStatusTextColor(
                                //     entry.statusId),
                                color: parseColor(widget.entry.colorCode),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text("Actual Follow-Up",
                      //         style: TextStyle(
                      //             color: Color(0xFF8E97A3),
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w500)),
                      //     const SizedBox(
                      //       height: 8,
                      //     ),
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 6, vertical: 4),
                      //       decoration: BoxDecoration(
                      //         color: const Color(0xFFF6F7F9),
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //       child: Row(
                      //         children: [
                      //           const Icon(
                      //             Icons.calendar_today_rounded,
                      //             size: 15,
                      //             color: Color(0xFF607185),
                      //           ),
                      //           const SizedBox(width: 6),
                      //           Text(entry.actualFollowUpDate,
                      //               style: const TextStyle(
                      //                   fontWeight: FontWeight.bold)),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(
                      //   width: 5,
                      // ),
                      if (widget.entry.followUp == 1)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Next Follow-up Date",
                                style: TextStyle(
                                    color: Color(0xFF8E97A3),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(
                              height: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: Color(0xFF607185),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(widget.entry.nextFollowUpDate,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.entry.audios.isNotEmpty) ...[
                    const Text("Audio", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        InkWell(
                          onTap: _togglePlay,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F7F9),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SliderTheme(
                            data: const SliderThemeData(trackHeight: 2),
                            child: Slider(
                              min: 0,
                              max: _duration.inMilliseconds
                                  .toDouble()
                                  .clamp(0.0, double.infinity),
                              value: _position.inMilliseconds
                                  .clamp(0, _duration.inMilliseconds)
                                  .toDouble(),
                              onChanged: (v) async {
                                final pos = Duration(milliseconds: v.toInt());
                                await _player.seek(pos);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${_format(_position)} / ${_format(_duration)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text("Remark", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    widget.entry.remark,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
