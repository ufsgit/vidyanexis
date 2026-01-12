import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class TaskLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool isTag;
  final bool isAssignee;
  final Color? color;
  final Color? colorUser;
  final double labelFontSize;
  final FontWeight labelFontWeight;
  final double valueFontSize;
  final FontWeight valueFontWeight;

  const TaskLabelValue({
    super.key,
    required this.label,
    required this.value,
    this.isTag = false,
    this.color,
    this.isAssignee = false,
    this.colorUser,
    this.labelFontSize = 12,
    this.labelFontWeight = FontWeight.w400,
    this.valueFontSize = 12,
    this.valueFontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textGrey4,
              fontSize: labelFontSize,
              fontWeight: labelFontWeight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        isTag
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildValueText(),
              )
            : isAssignee
                ? _buildValueTexts()
                : Expanded(child: _buildValueText()),
      ],
    );
  }

  Widget _buildValueText() {
    return Text(
      value,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textBlack,
        fontSize: valueFontSize,
        fontWeight: valueFontWeight,
      ),
    );
  }

  Widget _buildValueTexts() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorUser,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        value,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textBlack,
          fontSize: valueFontSize,
          fontWeight: valueFontWeight,
        ),
      ),
    );
  }
}
