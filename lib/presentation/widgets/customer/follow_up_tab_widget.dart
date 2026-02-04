import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

class FollowUpTabWidget extends StatelessWidget {
  const FollowUpTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE9EDF1);

    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isFollowUpHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.followUpHistory.isEmpty) {
          return const Center(child: Text("No follow-up history found"));
        }

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
              // Header
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderCell('#', width: 50),
                    _buildHeaderCell('Date'),
                    _buildHeaderCell('Assigned To', flex: 2),
                    _buildHeaderCell('Assigned By', flex: 2),
                    _buildHeaderCell('Status'),
                    _buildHeaderCell('Next Follow-up'),
                    _buildHeaderCell('Remarks', flex: 2),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  itemCount: provider.followUpHistory.length,
                  itemBuilder: (context, index) {
                    final history = provider.followUpHistory[index];
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDataCell((index + 1).toString(), width: 50),
                          _buildDataCell(_formatDate(history.followUpDate)),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildUserCell(history.assignedToName),
                          ),
                          _buildWidgetCell(
                            flex: 2,
                            child: _buildUserCell(history.assignedByName),
                          ),
                          _buildWidgetCell(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                history.statusName ?? 'Follow up',
                                style: TextStyle(
                                  color: AppColors.statusGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          _buildDataCell(_formatDate(history.nextFollowUpDate)),
                          _buildDataCell(
                            history.remarks ?? "",
                            flex: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF7D8B9B),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildDataCell(String text,
      {int flex = 1, bool isBold = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
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
          // overflow: TextOverflow.ellipsis, // Allow text to wrap if needed, or omit ellipsish
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1}) {
    const borderColor = Color(0xFFE9EDF1);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _buildUserCell(String? userName) {
    if (userName == null || userName.isEmpty || userName == 'null') {
      return const Text("-", style: TextStyle(fontSize: 12));
    }
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: getAvatarColor(userName),
          child: Text(
            userName[0].toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            userName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: AppColors.textBlack),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == 'null') return "-";
    try {
      DateTime? date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        date = DateFormat('dd-MM-yyyy').parse(dateStr);
      }
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
