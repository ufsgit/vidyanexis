import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/constants/app_colors.dart';

class CustomActionButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? imageColor;
  final Color? textColor;
  final double? height;
  final double? imageSize;

  const CustomActionButton({
    Key? key,
    required this.imagePath,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.imageColor,
    this.textColor,
    this.height = 30,
    this.imageSize = 15,
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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  imagePath,
                  height: imageSize,
                  width: imageSize,
                  color: imageColor ?? AppColors.textGrey3,
                ),
                const SizedBox(width: 4),
                Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBlack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
