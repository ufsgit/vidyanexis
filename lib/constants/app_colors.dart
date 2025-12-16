import 'package:flutter/material.dart';

class AppColors {
  static Color scaffoldColor = const Color(0xFFF6F7F9);
  static Color whiteColor = const Color(0xFFFFFFFF);

  static Color statusColor = const Color.fromARGB(255, 241, 212, 205);

  static Color lightBlueColor = const Color(0xFFE5F0FF);
  static Color lightBlueColor2 = const Color(0xFFE8F4FF);
  static Color darkGrey = const Color(0xFF8E97A3);
  static Color textBlue800 = const Color(0xFF152D70);
  static Color textBlack = const Color(0xFF172230);
  static Color primaryViolet = const Color(0xFF152D70);
  static Color primaryBlue = const Color(0xFFEFB60A);

  static Color violet = const Color(0xFF6A0DAD);
  static Color buttonBackgroundColor = const Color(0xFFA2C6EB);

  static Color secondaryBlue = const Color(0xFF5499D9);
  static Color appViolet = const Color(0xFFEFB60A);
  static Color lightGreen = const Color(0xFFD9FAD9);
  static Color surfaceGrey = const Color(0xFFF4F7FA);
  static Color techityfyGrey = Color.fromARGB(255, 0, 90, 69);
  static Color darkGreen = const Color(0xFF27A127);
  static Color textGrey1 = const Color(0xFFE9EDF1);
  static Color textGrey2 = const Color(0xFFC2C9D0);
  static Color textGrey3 = const Color(0xFF607085);
  static Color textGrey4 = const Color(0xFF7D8B9B);
  static Color grey300 = const Color(0xFFEFF2F5);

  static Color grey = const Color(0xFFE9EDF1);
  static Color textRed = const Color(0xFFFF3B30);
  static Color btnRed = Color(0xFFAE392D);
  static Color darkBlue = const Color(0xFF5497E3);
  static Color textYellow = const Color(0xFFFF9500);
  static Color textGreen = const Color(0xFF34C759);
  static Color statusGreen = const Color(0xFF407537);
  static const Color bluebutton = Color(0xFF1A7AE8);

  static Color green = const Color(0xFFACD5A5);

  //common colors
  static Color commonBackgroundColor = const Color(0xFFE9EDF1);
  static Color commonTextColor = const Color(0xFF000000);
  static Color commonTextBoxColor = const Color(0xFFFFFFFF);
  static Color commonBorderColor = const Color(0xFFFFFFFF);

  static Color parseColor(String colorCode) {
    try {
      // Handle format: Color(0xFFFFFFFF)
      if (colorCode.contains("0x")) {
        final hexString =
            colorCode.replaceAll("Color(", "").replaceAll(")", "").trim();
        return Color(int.parse(hexString));
      }

      // Handle format: Color(alpha: 1.0000, red: 0.2510, green: 0.3686, blue: 0.8510, colorSpace: ColorSpace.sRGB)
      if (colorCode.contains("alpha:") &&
          colorCode.contains("red:") &&
          colorCode.contains("green:") &&
          colorCode.contains("blue:")) {
        final regex = RegExp(
            r'alpha:\s*([0-9.]+),\s*red:\s*([0-9.]+),\s*green:\s*([0-9.]+),\s*blue:\s*([0-9.]+)');
        final match = regex.firstMatch(colorCode);

        if (match != null) {
          double alpha = double.parse(match.group(1)!);
          double red = double.parse(match.group(2)!);
          double green = double.parse(match.group(3)!);
          double blue = double.parse(match.group(4)!);

          return Color.fromARGB(
            (alpha * 255).round().clamp(0, 255),
            (red * 255).round().clamp(0, 255),
            (green * 255).round().clamp(0, 255),
            (blue * 255).round().clamp(0, 255),
          );
        }
      }

      // If it doesn't match any known pattern, fallback color
      return const Color(0xff34c759);
    } catch (e) {
      return const Color(0xff34c759); // Fallback color in case of error
    }
  }
}

Color getAvatarColor(String name) {
  final colors = [
    Colors.blue.withOpacity(.75),
    Colors.purple.withOpacity(.75),
    Colors.orange.withOpacity(.75),
    Colors.teal.withOpacity(.75),
    Colors.pink.withOpacity(.75),
    Colors.indigo.withOpacity(.75),
    Colors.green.withOpacity(.75),
    Colors.deepOrange.withOpacity(.75),
    Colors.cyan.withOpacity(.75),
    Colors.brown.withOpacity(.75),
  ];
  final nameHash = name.hashCode.abs();
  return colors[nameHash % colors.length];
}

class StatusUtils {
  // Method to get background color based on status
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

  // Method to get text color based on status
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

  static Color getTaskColor(int status) {
    switch (status) {
      case 3:
        return const Color(0xFFE8EFE6);
      case 2:
        return const Color(0xFFFCF1E3);
      case 1:
        return const Color(0xFFF2E3E0);
      default:
        return const Color(0xFFE5ECFA);
    }
  }

  // Method to get text color based on status
  static Color getTaskTextColor(int status) {
    switch (status) {
      case 3:
        return const Color(0xFF407537);
      case 2:
        return const Color(0xFFA4622B);
      case 1:
        return const Color(0xFFAE392D);
      default:
        return Colors.grey[700]!;
    }
  }

  static Color getStatusMobileColor(String statusName) {
    switch (statusName) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}
