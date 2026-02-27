import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';

void showToastInDialog(String message, BuildContext context) {
  OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: AppStyles.isWebScreen(context) ? 95.0 : 50,
      left: 0.0,
      right: 0.0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: AppStyles.isWebScreen(context)
                ? MediaQuery.of(context).size.width / 3
                : MediaQuery.of(context).size.width,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 39, 39, 39),
              // borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}

String sanitizeForWhatsApp(String phone) {
  if (phone.isEmpty) return phone;

  // 1. Keep leading + if present, extract all digits
  bool startsWithPlus = phone.trimLeft().startsWith('+');
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  String cleaned = startsWithPlus ? '+$digits' : digits;

  // 4. Helper to validate Indian number format
  String? validateIndianNumber(String num) {
    if (num.length == 10) {
      if (num.startsWith('6') ||
          num.startsWith('7') ||
          num.startsWith('8') ||
          num.startsWith('9')) {
        return '91$num';
      }
    }
    return null; // Invalid Indian number
  }

  // 2. If number starts with +91:
  if (cleaned.startsWith('+91')) {
    // - Remove +91
    String remaining = cleaned.substring(3);
    // - Ensure remaining number is exactly 10 digits
    if (remaining.length > 10) {
      remaining = remaining.substring(remaining.length - 10);
    }
    return validateIndianNumber(remaining) ?? '';
  }

  // 3. If number starts with 91 and length > 10:
  if (cleaned.startsWith('91') && cleaned.length > 10) {
    // - Remove leading 91
    String remaining = cleaned.substring(2);
    // - Ensure remaining number is exactly 10 digits
    if (remaining.length > 10) {
      remaining = remaining.substring(remaining.length - 10);
    }
    return validateIndianNumber(remaining) ?? '';
  }

  // If it's strictly a 10 digit number
  if (cleaned.length == 10 && !startsWithPlus) {
    return validateIndianNumber(cleaned) ?? '';
  }

  // If it starts with a different country code using +
  if (startsWithPlus) {
    // We assume non-Indian international numbers are fully valid right from the user input.
    // If you need international validation, we would use a package.
    return cleaned.replaceFirst('+', '');
  }

  // Fallback: take last 10 digits and prepend 91
  if (cleaned.length > 10) {
    String remaining = cleaned.substring(cleaned.length - 10);
    return validateIndianNumber(remaining) ?? '';
  }

  // If all else fails
  return '';
}
