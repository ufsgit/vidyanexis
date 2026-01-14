import 'package:flutter/material.dart';

class Loader {
  static Future<void> showLoader(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Colors.blue,
        ),
      ),
    );
  }

  static void stopLoader(BuildContext context) {
    try {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close the dialog
      }
    } catch (e) {
      print("Error stopping loader: $e");
    }
  }
}
