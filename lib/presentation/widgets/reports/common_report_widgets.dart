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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasDates ? AppColors.primaryBlue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              !hasDates
                  ? '$label: All'
                  : '$label : $formattedFromDate - $formattedToDate',
              style: const TextStyle(fontSize: 14),
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
          ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textRed,
            elevation: 0,
            side: const BorderSide(color: AppColors.textRed),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
