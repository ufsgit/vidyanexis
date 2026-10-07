import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/task_customer_model.dart';
import 'package:vidyanexis/controller/models/task_history_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/home/customer_task_overview_tab.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskHistoryPopup extends StatelessWidget {
  final String taskId;
  final String taskName;

  const TaskHistoryPopup({
    super.key,
    required this.taskId,
    required this.taskName,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Container contentBox(context) {
    return Container(
      width: 500,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHeader(context),
          Expanded(
            child: _buildHistoryList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Task History",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  taskName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF64748B), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.taskHistoryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  "No history found",
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: provider.taskHistoryList.length,
          itemBuilder: (context, index) {
            final history = provider.taskHistoryList[index];
            return _buildHistoryItem(
                history, index == provider.taskHistoryList.length - 1);
          },
        );
      },
    );
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

  Widget _buildHistoryItem(TaskHistoryModel history, bool isLast) {
    final audioFiles = (history.taskFiles ?? []).where(_isAudioFile).toList();
    final documentFiles =
        (history.taskFiles ?? []).where((f) => !_isAudioFile(f)).toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(builder: (_) {
                        Color statusColor = const Color(0xFF3B82F6);
                        final lowerStatus = (history.statusName ?? '').toLowerCase();
                        if (lowerStatus.contains('complete') || lowerStatus.contains('done')) {
                          statusColor = const Color(0xFF10B981);
                        } else if (lowerStatus.contains('progress')) {
                          statusColor = const Color(0xFF3B82F6);
                        } else if (lowerStatus.contains('pend') || lowerStatus.contains('hold')) {
                          statusColor = const Color(0xFFF59E0B);
                        } else if (lowerStatus.contains('cancel') || lowerStatus.contains('reject')) {
                          statusColor = const Color(0xFFEF4444);
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            history.statusName ?? 'Updated',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        );
                      }),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(history.entryDate),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (history.description != null &&
                      history.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 13,
                                color: Color(0xFF3B82F6),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Comments',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.description!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF1E293B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (history.remarks != null &&
                      history.remarks!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.rate_review_outlined,
                                size: 13,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Remarks / Feedback',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.remarks!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF1E293B),
                              height: 1.4,
                            ),
                          ),
                        ],
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
                                  constraints: const BoxConstraints(maxWidth: 150),
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
                  const SizedBox(height: 8),
                  if (history.location != null && history.location!.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            history.location!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        history.byUserName ?? 'System',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      // Handle "dd/MM/yyyy h:mm a" or ISO format
      DateTime dateTime;
      if (dateStr.contains('/')) {
        // Try parsing with the specific format if it contains '/'
        try {
          dateTime = DateFormat('dd/MM/yyyy h:mm a').parse(dateStr);
        } catch (e) {
          dateTime = DateFormat('dd/MM/yyyy').parse(dateStr);
        }
      } else {
        dateTime = DateTime.parse(dateStr);
      }
      return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }
}
