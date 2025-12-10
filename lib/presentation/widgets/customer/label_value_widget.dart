import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LabelValueWidget extends StatelessWidget {
  final String label;
  final String value;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final Color? labelColor;
  final Color? valueColor;

  const LabelValueWidget({
    super.key,
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Label on the left
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor ?? AppColors.textGrey3,
              ),
            ),
          ),
          const SizedBox(
            width: 100,
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textBlack,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
              textAlign: TextAlign.right,
            ),
          )
        ],
      ),
    );
  }
}
