import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

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
        color: AppColors.textBlack,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        hintText: labelText,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textGrey3,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        fillColor: const Color(0xFFF0F2F5),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        )),
  );
}


