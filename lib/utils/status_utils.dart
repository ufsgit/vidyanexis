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
}
