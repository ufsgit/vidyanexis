import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.fontSize,
    this.textAlign,
    this.fontStyle,
    this.color,
    this.fontWeight,
    this.maxLine,
    this.overflow,
    this.textDecoration,
    this.selectable,
    this.softWrap = true, // Added softWrap parameter with default value true
  });

  final String? text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLine;
  final TextOverflow? overflow;
  final TextDecoration? textDecoration;
  final bool? selectable;
  final bool softWrap; // Added softWrap property
  final FontStyle? fontStyle;
  @override
  Widget build(BuildContext context) {
    return (selectable ?? false)
        ? SelectionArea(
            child: Text(
              (text ?? ""),
              textAlign: textAlign,
              maxLines: maxLine,
              overflow: overflow,
              softWrap: softWrap, // Use the softWrap parameter

              style: GoogleFonts.plusJakartaSans(
                  color: color,
                  fontSize: fontSize ?? 12,
                  fontStyle: fontStyle,
                  height: 1.5,
                  fontWeight: fontWeight ?? FontWeight.w400,
                  decoration: textDecoration),
            ),
          )
        : Text(
            (text ?? ""),
            textAlign: textAlign,
            maxLines: maxLine,
            overflow: overflow,
            softWrap: softWrap, // Use the softWrap parameter
            style: GoogleFonts.plusJakartaSans(
                color: color,
                fontSize: fontSize ?? 12,
                fontStyle: fontStyle,
                height: 1.5,
                fontWeight: fontWeight ?? FontWeight.w400,
                decoration: textDecoration),
          );
  }
}
