import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class CountWidget extends StatelessWidget {
  const CountWidget({
    super.key,
    required this.color,
    required this.title,
    required this.count,
  });
  final Color color;
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          RichText(
              text: TextSpan(
                  text: count.toString(),
                  style: AppStyles.getHeadingTextStyle(fontSize: 12),
                  children: [
                TextSpan(
                    text: "   $title",
                    style: AppStyles.getHeadingTextStyle(
                        fontSize: 12, fontColor: AppColors.textGrey4))
              ])),
        ],
      ),
    );
  }
}

class CountWidget2 extends StatelessWidget {
  const CountWidget2({
    super.key,
    required this.label,
    required this.title,
    required this.progress,
    required this.count,
    required this.indicatorColor,
  });
  final String label;
  final String title;
  final String progress;
  final String count;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 11,
          width: 11,
          decoration:
              BoxDecoration(color: indicatorColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
              text: title,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.textGrey3),
              children: [
                TextSpan(
                  text: "  $progress",
                  style: AppStyles.getHeadingTextStyle(fontSize: 14),
                )
              ]),
        ),
        const Spacer(),
        RichText(
          text: TextSpan(
              text: count,
              style: AppStyles.getHeadingTextStyle(fontSize: 16),
              children: [
                TextSpan(
                    text: "  $label",
                    style: AppStyles.getHeadingTextStyle(
                        fontSize: 16, fontColor: AppColors.textGrey4))
              ]),
        ),
      ],
    );
  }
}
