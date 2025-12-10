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
