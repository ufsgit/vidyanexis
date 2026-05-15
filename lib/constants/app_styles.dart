import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/http/http_urls.dart';

class AppStyles {
  static String? _cachedName;
  static String? _cachedLogo;

  static void updateCachedBranding(String? name, String? logo) {
    _cachedName = name;
    _cachedLogo = logo;
  }

  static String logo() {
    if (_cachedLogo != null && _cachedLogo!.isNotEmpty) {
      if (_cachedLogo!.startsWith('http')) {
        return _cachedLogo!;
      } else {
        return "${HttpUrls.imgBaseUrl}$_cachedLogo";
      }
    }
    return 'assets/images/Icon-512.png';
  }

  static String name() {
    if (_cachedName != null && _cachedName!.isNotEmpty) {
      return _cachedName!;
    }
    const String fallback = 'TrackboxDevelopment';
    try {
      final String url = HttpUrls.baseUrl;
      final int slashIndex = url.indexOf('//');
      if (slashIndex == -1) return fallback;
      final String afterSlashes = url.substring(slashIndex + 2);
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
    try {
      return MediaQuery.sizeOf(context).width > 1000;
    } catch (_) {
      return false; // Default for mobile or safely handle
    }
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
