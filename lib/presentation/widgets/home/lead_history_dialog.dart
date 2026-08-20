import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_history.dart';
import 'package:vidyanexis/presentation/widgets/home/loading_circle.dart';
import 'package:vidyanexis/presentation/widgets/home/edit_remark_dialog.dart';

class LeadHistoryDialog extends StatefulWidget {
  final String customerId;
  final String customerName;

  const LeadHistoryDialog({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  static void show(BuildContext context,
      {required String customerId, required String customerName}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => LeadHistoryDialog(
        customerId: customerId,
        customerName: customerName,
      ),
    );
  }

  @override
  State<LeadHistoryDialog> createState() => _LeadHistoryDialogState();
}

class _LeadHistoryDialogState extends State<LeadHistoryDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadDetailsProvider>(context, listen: false)
          .fetchFollowUpHistory(widget.customerId);
    });
  }

  String _formatEntryDate(String entryDate) {
    if (entryDate.isEmpty) return '';
    try {
      // Input: "13-05-2026-02:27" or "13-05-2026"
      final parts = entryDate.split('-');
      if (parts.length >= 3) {
        final day = parts[0];
        final monthInt = int.tryParse(parts[1]) ?? 1;
        final year = parts[2];
        final time = parts.length > 3 ? parts[3] : '';

        final monthName = DateFormat('MMM').format(DateTime(2026, monthInt, 1));
        return "$day $monthName $year${time.isNotEmpty ? ' • $time' : ''}";
      }
    } catch (_) {}
    return entryDate;
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    final width = MediaQuery.sizeOf(context).width;
    final dialogWidth = isWeb ? 580.0 : width * 0.95;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40.0 : 16.0,
        vertical: 24.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Premium Header with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Follow-Up History',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.customerName.isNotEmpty
                              ? 'Lead: ${widget.customerName} (ID: ${widget.customerId})'
                              : 'ID: ${widget.customerId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textGrey3,
                    hoverColor: Colors.grey[100],
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // Content Area
            Flexible(
              child: Consumer<LeadDetailsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: LoadingCircle(),
                      ),
                    );
                  }

                  final history = provider.followUpHistory;
                  if (history == null || history.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 60.0, horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_toggle_off_rounded,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No history records found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'There are no follow-ups registered for this lead yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textGrey3,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final isLast = index == history.length - 1;
                      final statusColor = AppColors.parseColor(entry.colorCode);

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Timeline Rail
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Column(
                                children: [
                                  // Timeline Dot
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: statusColor,
                                        width: 3.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: statusColor.withOpacity(0.2),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Connecting line
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Entry Content Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row: Status Badge & Date
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Status Pill Badge
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  statusColor.withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                color: statusColor
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              entry.statusName.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w700,
                                                color: statusColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        // Entry Date
                                        Flexible(
                                          child: Text(
                                            _formatEntryDate(entry.entryDate),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textGrey3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Users By/To info — wraps on narrow screens
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_circle_outlined,
                                          size: 14,
                                          color: AppColors.textGrey3
                                              .withOpacity(0.8),
                                        ),
                                        Text(
                                          entry.byUserName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textBlack,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 12,
                                          color: AppColors.textGrey3
                                              .withOpacity(0.6),
                                        ),
                                        Icon(
                                          Icons.account_circle_rounded,
                                          size: 14,
                                          color: AppColors.textGrey3
                                              .withOpacity(0.8),
                                        ),
                                        Text(
                                          entry.toUserName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textBlack,
                                          ),
                                        ),
                                        if (entry.followUp == 1 &&
                                            entry.nextFollowUpDate
                                                .isNotEmpty) ...[
                                          Container(
                                            width: 3,
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Icon(
                                            Icons.event_outlined,
                                            size: 13,
                                            color: AppColors.textGrey3
                                                .withOpacity(0.8),
                                          ),
                                          Text(
                                            'Next: ${entry.nextFollowUpDate}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textGrey3,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Remark perfect highlight section
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color(0xFFF8FAFC), // Slate 50
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border(
                                          left: BorderSide(
                                            color: statusColor,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.format_quote_rounded,
                                            size: 16,
                                            color: statusColor.withOpacity(0.4),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              entry.remark.isNotEmpty
                                                  ? entry.remark
                                                  : 'No remark added.',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    entry.remark.isNotEmpty
                                                        ? FontStyle.italic
                                                        : FontStyle.normal,
                                                color: entry.remark.isNotEmpty
                                                    ? AppColors.textBlack
                                                    : AppColors.textGrey3,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () {
                                              EditRemarkDialog.show(
                                                context,
                                                customerId: widget.customerId,
                                                followUpId: entry.followUpId,
                                                initialRemark: entry.remark,
                                                statusId: entry.statusId,
                                                statusName: entry.statusName,
                                                toUserName: entry.toUserName,
                                                followUpDate:
                                                    entry.nextFollowUpDate,
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlue
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.edit_outlined,
                                                    size: 12,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Edit',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors
                                                          .primaryBlue,
                                                    ),
                                                  ),
                                                ],
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
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
