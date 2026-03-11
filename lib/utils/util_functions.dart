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

void showFriendlySnackBar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isError ? Colors.redAccent : Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.only(
        bottom: 20,
        right: AppStyles.isWebScreen(context) ? MediaQuery.of(context).size.width / 3 : 20,
        left: AppStyles.isWebScreen(context) ? MediaQuery.of(context).size.width / 3 : 20,
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

String formatIndianPhoneNumber(String input) {
  String number = input.replaceAll(RegExp(r'[^\d+]'), '');

  if (number.startsWith('+91')) {
    number = number.substring(3);
  } else if (number.startsWith('91') && number.length > 10) {
    number = number.substring(2);
  }

  if (number.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(number)) {
    return '91$number';
  } else {
    return '';
  }
}
