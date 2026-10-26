import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_history_model.dart';
import 'package:vidyanexis/presentation/widgets/home/edit_remark_dialog.dart';
import 'package:vidyanexis/utils/status_utils.dart';

class FollowUpTabWidget extends StatelessWidget {
  final String? customerId;
  const FollowUpTabWidget({super.key, this.customerId});

  static const Color borderColor = Color(0xFFE9EDF1);

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isFollowUpHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.followUpHistory.isEmpty) {
          return const Center(
            child: Text(
              "No follow-up history found",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          );
        }

        if (!AppStyles.isWebScreen(context)) {
          return _buildMobileList(context, provider);
        }

        return _buildWebTable(context, provider);
      },
    );
  }

  /// Web Table View matching the Tasks tab design
  Widget _buildWebTable(
      BuildContext context, CustomerDetailsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor),
          left: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        children: [
          // Header Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCell('#', width: 50.0),
                _buildHeaderCell('Follow-up Date', flex: 2),
                _buildHeaderCell('Status', flex: 2),
                _buildHeaderCell('Assigned To', flex: 2),
                _buildHeaderCell('Assigned By', flex: 2),
                _buildHeaderCell('Next Follow-up', flex: 2),
                _buildHeaderCell('Remarks', flex: 3),
                _buildHeaderCell('Options', flex: 1, textAlign: TextAlign.center),
              ],
            ),
          ),
          // Scrollable List of Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: provider.followUpHistory.length,
              itemBuilder: (context, index) {
                final history = provider.followUpHistory[index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _openEditDialog(context, history),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDataCell((index + 1).toString(), width: 50.0),
                          _buildDataCell(
                            _formatDate(history.followUpDate ?? ''),
                            flex: 2,
                            isBold: true,
                            maxLines: 2,
                          ),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildStatusCell(history),
                          ),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildUserCell(history.assignedToName),
                          ),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildUserCell(history.assignedByName),
                          ),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildNextFollowUpCell(
                                history.nextFollowUpDate),
                          ),
                          _buildWidgetCell(
                            flex: 3,
                            child: _buildRemarksCell(history.remarks),
                          ),
                          _buildWidgetCell(
                            flex: 1,
                            child: _buildOptionsCell(context, history),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile List View with clean card layout
  Widget _buildMobileList(
      BuildContext context, CustomerDetailsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.followUpHistory.length,
      itemBuilder: (context, index) {
        final history = provider.followUpHistory[index];
        return _buildMobileCard(context, history, index);
      },
    );
  }

  Widget _buildMobileCard(
      BuildContext context, FollowUpHistoryModel history, int index) {
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
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Date & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history,
                        size: 16, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(history.followUpDate ?? ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              _buildStatusCell(history),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: borderColor, height: 1),
          ),
          // Assignment & Next Follow up
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _buildInfoColumn(
                  'Assigned To', _buildUserCell(history.assignedToName)),
              _buildInfoColumn(
                  'Assigned By', _buildUserCell(history.assignedByName)),
              _buildInfoColumn(
                'Next Follow-up',
                _buildNextFollowUpCell(history.nextFollowUpDate),
              ),
            ],
          ),
          if (history.remarks != null && history.remarks!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor),
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
                            fontWeight: FontWeight.w600),
                      ),
                      InkWell(
                        onTap: () => _openEditDialog(context, history),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 12, color: AppColors.primaryBlue),
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
                    history.remarks!,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCell(
    String text, {
    int flex = 1,
    double? width,
    TextAlign textAlign = TextAlign.start,
  }) {
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: textAlign == TextAlign.center
            ? Alignment.center
            : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF7D8B9B),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildDataCell(
    String text, {
    int flex = 1,
    bool isBold = false,
    double? width,
    int maxLines = 1,
  }) {
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildWidgetCell({
    required Widget child,
    int flex = 1,
    double? width,
  }) {
    Widget container = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: child,
    );

    if (width != null) return SizedBox(width: width, child: container);
    return Expanded(flex: flex, child: container);
  }

  Widget _buildStatusCell(FollowUpHistoryModel history) {
    Color bgColor = AppColors.lightGreen;
    Color textColor = AppColors.statusGreen;

    final sId = int.tryParse(history.statusId ?? '');
    if (sId != null && sId > 0) {
      bgColor = StatusUtils.getStatusColor(sId);
      textColor = StatusUtils.getStatusTextColor(sId);
    } else {
      final s = (history.statusName ?? '').toLowerCase();
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
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          history.statusName ?? 'Follow up',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildUserCell(String? userName) {
    if (userName == null || userName.isEmpty || userName == 'null') {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text("-",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            )),
      );
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
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildNextFollowUpCell(String? nextFollowUpDate) {
    final dateFormatted =
        _formatDate(nextFollowUpDate ?? '', includeTime: false);
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_outlined, size: 15, color: Colors.blueGrey),
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
      ),
    );
  }

  Widget _buildRemarksCell(String? remarks) {
    final text =
        (remarks != null && remarks.trim().isNotEmpty) ? remarks.trim() : '-';
    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: text,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildOptionsCell(
      BuildContext context, FollowUpHistoryModel history) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Edit Remark',
          icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => _openEditDialog(context, history),
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

  void _openEditDialog(BuildContext context, FollowUpHistoryModel history) {
    EditRemarkDialog.show(
      context,
      customerId: customerId ?? '',
      followUpId: history.followUpId ?? '',
      initialRemark: history.remarks ?? '',
      statusId: int.tryParse(history.statusId ?? ''),
      statusName: history.statusName,
      toUserName: history.assignedToName,
      followUpDate: history.nextFollowUpDate,
    );
  }

  String _formatDate(String dateStr, {bool includeTime = true}) {
    if (dateStr.isEmpty || dateStr == 'null') return '-';
    try {
      // Clean input (handles "00:00:00.000" or extra spaces)
      String cleaned = dateStr
          .replaceFirst(RegExp(r'00:00:00\.000\s*'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      final dateTime = DateTime.tryParse(cleaned);
      if (dateTime != null) {
        return includeTime
            ? DateFormat('dd MMM yyyy hh:mm:ss a').format(dateTime)
            : DateFormat('dd MMM yyyy').format(dateTime);
      }

      // If already in dd-MM-yyyy format
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
}

