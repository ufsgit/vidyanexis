import 'package:flutter/material.dart';

class AppColors {
  static const Color scaffoldColor = Color(0xFFF6F7F9);
  static const Color whiteColor = Color(0xFFFFFFFF);

  static const Color statusColor = Color.fromARGB(255, 241, 212, 205);

  static const Color lightBlueColor = Color(0xFFE5F0FF);
  static const Color lightBlueColor2 = Color(0xFFE8F4FF);
  static const Color darkGrey = Color(0xFF8E97A3);
  static const Color textBlue800 = Color(0xFF152D70);
  static const Color textBlack = Color(0xFF172230);
  static const Color primaryViolet = Color(0xFF152D70);
  static const Color primaryBlue = Color(0xFF5499D9);

  static const Color violet = Color(0xFF6A0DAD);
  static const Color buttonBackgroundColor = Color(0xFFA2C6EB);

  static const Color secondaryBlue = Color(0xFF5499D9);
  static const Color appViolet = Color(0xFF5499D9);
  static const Color lightGreen = Color(0xFFD9FAD9);
  static const Color surfaceGrey = Color(0xFFF4F7FA);
  static const Color techityfyGrey = Color.fromARGB(255, 0, 90, 69);
  static const Color darkGreen = Color(0xFF27A127);
  static const Color textGrey1 = Color.fromARGB(255, 141, 141, 141);
  static const Color textGrey2 = Color(0xFFC2C9D0);
  static const Color textGrey3 = Color(0xFF607085);
  static const Color textGrey4 = Color(0xFF7D8B9B);
  static const Color grey300 = Color(0xFFEFF2F5);

  static const Color grey = Color(0xFFE9EDF1);
  static const Color textRed = Color(0xFFFF3B30);
  static const Color btnRed = Color(0xFFAE392D);
  static const Color darkBlue = Color(0xFF5497E3);
  static const Color textYellow = Color(0xFFFF9500);
  static const Color textGreen = Color(0xFF34C759);
  static const Color statusGreen = Color(0xFF407537);
  static const Color bluebutton = Color(0xFF1A7AE8);

  static const Color green = Color(0xFFACD5A5);

  //common colors
  static const Color commonBackgroundColor = Color(0xFFE9EDF1);
  static const Color commonTextColor = Color(0xFF000000);
  static const Color commonTextBoxColor = Color(0xFFFFFFFF);
  static const Color commonBorderColor = Color(0xFFFFFFFF);

  static Color parseColor(String colorCode) {
    try {
      if (colorCode.isEmpty ||
          colorCode == 'null' ||
          colorCode == 'Color(null)') {
        return const Color(0xFF8E97A3); // Neutral dark grey fallback
      }

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
