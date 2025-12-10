import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomOutlinedSvgButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String svgPath;
  final String label;
  final double breakpoint;
  final Color foregroundColor;
  final Color backgroundColor;
  final BorderSide borderSide;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final double iconSize;
  final OutlinedBorder? shape;
  final bool showIcon;

  const CustomOutlinedSvgButton(
      {super.key,
      required this.onPressed,
      required this.svgPath,
      required this.label,
      this.breakpoint = 860,
      this.foregroundColor = Colors.blue,
      this.backgroundColor = Colors.white,
      this.borderSide = const BorderSide(color: Colors.blue),
      this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      this.borderRadius = 16.0,
      this.textStyle,
      this.iconSize = 24.0,
      this.shape,
      this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        shape: shape ??
            ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
        side: borderSide,
        padding: padding,
      ),
      child: showIcon
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                    foregroundColor,
                    BlendMode.srcIn,
                  ),
                ),
                if (MediaQuery.of(context).size.width > breakpoint) ...[
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: textStyle ??
                        GoogleFonts.plusJakartaSans(
                          color: foregroundColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            )
          : Center(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: textStyle ??
                    GoogleFonts.plusJakartaSans(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
    );
  }
}
