import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:techtify/constants/app_styles.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double radius;
  final double elevation;
  final double textSize;
  final IconData? prefixIcon; // Optional icon
  final double? iconSize; // Optional icon size
  final double? iconSpacing; // Optional spacing between icon and text

  const CustomElevatedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.radius = 16,
    this.isLoading = false,
    this.elevation = 1,
    this.textSize = 16,
    this.prefixIcon, // Default is null (no icon)
    this.iconSize = 18, // Default icon size
    this.iconSpacing = 8, // Default spacing between icon and text
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                padding: AppStyles.isWebScreen(context)
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                elevation: elevation),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Make row wrap its content
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row content
              children: [
                // Only show icon if provided
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    size: iconSize,
                    color: textColor,
                  ),
                  SizedBox(width: iconSpacing),
                ],
                Text(
                  buttonText,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: textSize,
                      fontWeight: FontWeight.w600,
                      color: textColor),
                ),
              ],
            ),
          );
  }
}
