import 'package:flutter/material.dart';

class StatusUtils {
  static Color getTaskColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static Color getTaskTextColor(int statusId) {
    switch (statusId) {
      case 1:
        return Colors.blue.shade900;
      case 2:
        return Colors.green.shade900;
      case 3:
        return Colors.orange.shade900;
      case 4:
        return Colors.red.shade900;
      default:
        return Colors.black;
    }
  }

  static String getDisplayStatus(String status) {
    if (status.toLowerCase() == "converted") {
      return "Confirm";
    }
    return status;
  }

  static Color getStatusColor(int status) {
    switch (status) {
      case 3:
        return const Color(0xFFE5ECFA);
      case 2:
        return const Color(0xFFE8EFE6);
      case 1:
        return const Color(0xFFFCF1E3);
      case 4:
        return const Color(0xFFE7E9F0);
      case 5:
        return const Color(0xFFF2E3E0);
      default:
        return const Color(0xFFE5ECFA);
    }
  }

  static Color getStatusTextColor(int status) {
    switch (status) {
      case 3:
        return const Color(0xFF2349BF);
      case 2:
        return const Color(0xFF407537);
      case 1:
        return const Color(0xFFA4622B);
      case 4:
        return const Color(0xFF293681);
      case 5:
        return const Color(0xFFAE392D);
      default:
        return Colors.grey[700]!;
    }
  }
}
