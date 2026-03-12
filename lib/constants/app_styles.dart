import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static logo() {
    String logo = 'assets/images/logo_2.png';
    // String logo = 'assets/images/app_logo.png';
    // String logo = 'assets/images/solaris_logo.png';
    return logo;
  }

  static name() {
    String name = 'solaris'; // dont change this

    return name;
  }

  static TextStyle getHeadingTextStyle({
    Color fontColor = Colors.black,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w700,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }

  static TextStyle getBoldTextStyle({
    Color fontColor = Colors.black,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w500,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }

  static bool isWebScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1300;
  }

  static TextStyle getBodyTextStyle({
    Color fontColor = Colors.black,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w600,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }

  static TextStyle getRegularTextStyle({
    Color fontColor = Colors.black,
    required double fontSize,
  }) {
    return TextStyle(
      fontSize: fontSize,
      color: fontColor,
      fontWeight: FontWeight.w400,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    );
  }
}
