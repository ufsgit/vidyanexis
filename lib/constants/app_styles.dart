import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static logo() {
    String logo = 'assets/images/logo.png';
    // String logo = 'assets/images/logo_dyuthi.jpg';
    return logo;
  }

  static name() {
    String name = 'Solaris';
    // String name = 'vidyanexis';
    // String name = 'First Day';
    // String name = 'Neopower';
    // String name = 'Horizon';
    // String name = 'Cygnusenergy';
    // String name = 'Kiaenergies';
    // String name = 'Matrix';
    // String name = 'Crystal';
    // String name = 'Dyuthi';
    // String name = 'Securagreen';
    // String name = 'Oxy solar';

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
