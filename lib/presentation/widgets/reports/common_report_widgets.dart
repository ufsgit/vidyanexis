import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_drop_down_outlined,
              color: Colors.black45,
              size: 18,
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
    return SizedBox(
      height: 40,
      child: ElevatedButton(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
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


class CommonReportFilterRow extends StatelessWidget {
  final List<Widget> children;

  const CommonReportFilterRow({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1 && children[i].runtimeType != Spacer) {
        // Don\'t add spacing after Spacer
        if (i + 1 < children.length && children[i + 1].runtimeType != Spacer) {
            spacedChildren.add(const SizedBox(width: 16));
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
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
      child: Row(
        children: spacedChildren,
      ),
    );
  }
}

class CommonReportDropdownFilter<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isActive;
  final double maxWidth;

  const CommonReportDropdownFilter({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isActive,
    this.maxWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? AppColors.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          DropdownButton<T>(
            value: value,
            hint: const Text('All'),
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item.value,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: item.child,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            underline: Container(),
            isDense: true,
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}



class CommonReportExportButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const CommonReportExportButton({
    super.key,
    required this.onPressed,
    this.label = 'Export',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.file_download_outlined, size: 18),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
