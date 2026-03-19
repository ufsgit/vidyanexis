import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/http/http_urls.dart';

class AppStyles {
  static String logo() {
    String logo = 'assets/images/logo_2.png';
    // String logo = 'assets/images/app_logo.png';
    // String logo = 'assets/images/solaris_logo.png';
    return logo;
  }

  static String name() {
    const String fallback = 'Solaris';
    try {
      final String url = HttpUrls.baseUrl;
      // Find the part after 'https://' (or 'http://')
      final int slashIndex = url.indexOf('//');
      if (slashIndex == -1) return fallback;
      final String afterSlashes = url.substring(slashIndex + 2);
      // afterSlashes e.g. 'suryaprabhaapi.trackbox.net.in/'
      final int apiIndex = afterSlashes.toLowerCase().indexOf('api');
      if (apiIndex <= 0) return fallback;
      final String extracted = afterSlashes.substring(0, apiIndex);
      if (extracted.isEmpty) return fallback;
      return extracted;
    } catch (_) {
      return fallback;
    }
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
