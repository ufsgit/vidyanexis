import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomActionButton extends StatelessWidget {
  final dynamic icon;
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color?
      imageColor; // Keeping variable name for compatibility or renaming to iconColor
  final Color? textColor;
  final double? height;
  final double? iconSize; // Renamed from imageSize

  const CustomActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.imageColor,
    this.textColor,
    this.height = 34,
    this.iconSize = 16,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.grey300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),

            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon is IconData
                    ? Icon(
                        icon,
                        size: iconSize,
                        color: imageColor ?? AppColors.textGrey3,
                      )
                    : FaIcon(
                        icon,
                        size: iconSize,
                        color: imageColor ?? AppColors.textGrey3,
                      ),

                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
