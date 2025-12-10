import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final Widget content;
  final EdgeInsetsGeometry? tilePadding;
  final TextStyle? titleStyle;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.content,
    this.tilePadding = EdgeInsets.zero,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      tilePadding: tilePadding,
      title: Text(
        title,
        style: titleStyle ??
            GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: content,
        ),
      ],
    );
  }
}
