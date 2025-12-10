import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';

Widget textFieldWidget(
    {required TextEditingController? controller,
    required String? labelText,
    required BuildContext context,
    required double? height,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    FocusNode? focusNode}) {
  return SizedBox(
    height: height,
    child: TextField(
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      obscureText: obscureText,
      controller: controller,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textGrey4,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        hintText: labelText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textGrey3,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        fillColor: AppStyles.isWebScreen(context)
            ? AppColors.scaffoldColor
            : AppColors.surfaceGrey,
        filled: true,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textGrey2, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: AppStyles.isWebScreen(context)
                    ? AppColors.textGrey2
                    : AppColors.surfaceGrey,
                width: 1.5)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textGrey2)),
      ),
    ),
  );
}

Widget buttonWidget(
    {required BuildContext context,
    required String text,
    required Color? backgroundColor,
    required Color? txtColor,
    required double height,
    required double fontSize,
    required void Function()? onPressed}) {
  return SizedBox(
    height: height,
    width: MediaQuery.sizeOf(context).width,
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: txtColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        )),
  );
}
