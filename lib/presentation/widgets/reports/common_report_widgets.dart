import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CommonReportDateFilter extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  final String? formattedFromDate;
  final String? formattedToDate;
  final VoidCallback onTap;
  final String label;

  const CommonReportDateFilter({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.formattedFromDate,
    required this.formattedToDate,
    required this.onTap,
    this.label = 'Date',
  });

  @override
  Widget build(BuildContext context) {
    bool hasDates = fromDate != null || toDate != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: hasDates ? AppColors.primaryBlue : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              !hasDates
                  ? '$label: All'
                  : '$label : $formattedFromDate - $formattedToDate',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_drop_down_outlined,
              color: Colors.black45,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class CommonReportResetButton extends StatelessWidget {
  final VoidCallback onReset;
  final String label;
  final ButtonStyle? style;

  const CommonReportResetButton({
    super.key,
    required this.onReset,
    this.label = 'Reset',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onReset,
      style: style ??
          style ??
          ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textRed,
            elevation: 0,
            side: const BorderSide(color: AppColors.textRed),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class CommonReportSummaryBar extends StatelessWidget {
  final String totalLabel;
  final int totalCount;
  final String showingLabel;
  final int showingCount;

  const CommonReportSummaryBar({
    super.key,
    required this.totalLabel,
    required this.totalCount,
    required this.showingLabel,
    required this.showingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$totalLabel: $totalCount',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '$showingLabel: $showingCount',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
