import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateStringFormatter on String {
  String toFormattedDate() {
    try {
      final DateTime date = DateTime.parse(this);
      return DateFormat('E, MMM d').format(date);
      // 'E' for abbreviated weekday (Mon)
      // 'MMM' for abbreviated month (May)
      // 'd' for day of month (28)
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }

  String toUniversalYyyyMmDd() {
    if (this == null || this!.trim().isEmpty) return '';
    final value = this!.trim();

    // Try parsing with common formats
    final List<DateFormat> formats = [
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd-MM-yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('dd MMM yyyy'),
      DateFormat('MM/dd/yyyy'),
      DateFormat('yyyy/MM/dd'),
    ];

    DateTime? parsedDate;

    // Try all formats
    for (final format in formats) {
      try {
        parsedDate = format.parseStrict(value);
        break;
      } catch (_) {}
    }

    // Try DateTime.parse as fallback
    if (parsedDate == null) {
      try {
        parsedDate = DateTime.parse(value);
      } catch (_) {}
    }

    if (parsedDate == null) return '';

    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  String toDDMMYYYY() {
    try {
      final DateTime date = DateTime.parse(this);
      return DateFormat('dd/MM/yyyy').format(date);
      // 'E' for abbreviated weekday (Mon)
      // 'MMM' for abbreviated month (May)
      // 'd' for day of month (28)
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }

  String to24HourTime() {
    // Return empty string if the input is empty
    if (this.isEmpty) return '';

    try {
      // Check if the string contains AM/PM
      bool isPM = this.toUpperCase().contains('PM');
      bool isAM = this.toUpperCase().contains('AM');

      // Extract the time part (remove AM/PM)
      String timePart = this.replaceAll(RegExp(r'[aApP][mM]'), '').trim();

      // Split into hours and minutes
      List<String> parts = timePart.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);

      // Convert to 24-hour format
      if (isPM && hours < 12) {
        hours += 12;
      } else if (isAM && hours == 12) {
        hours = 0;
      }

      // Format the time as HH:MM:SS
      String formattedHours = hours.toString().padLeft(2, '0');
      String formattedMinutes = minutes.toString().padLeft(2, '0');

      return '$formattedHours:$formattedMinutes:00';
    } catch (e) {
      // Return original string if parsing fails
      return this;
    }
  }

  String toyyyymmdd() {
    if (trim().isEmpty) return '';

    final formats = [
      DateFormat('dd MMM yyyy'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('yyyy-MM-dd'),
    ];

    for (final format in formats) {
      try {
        final parsedDate = format.parse(this);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        // continue to next format
      }
    }

    try {
      final parsedDate = DateTime.parse(this);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return ''; // Return empty if all formats fail
    }
  }

  String toMonthDayYearFormat() {
    if (this.isEmpty) return this;

    try {
      DateTime date;

      // Check if string contains time component (has a space or 'T' separator)
      if (this.contains(' ') || this.contains('T')) {
        // Split the datetime string
        String dateStr;
        if (this.contains(' ')) {
          dateStr = this.split(' ')[0]; // Take only the date part
        } else {
          dateStr = this.split('T')[0]; // Take only the date part
        }

        // Process the date part
        final parts = dateStr.split('-');
        if (parts.length >= 3 && parts[0].length == 4) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          date = DateTime(year, month, day);
        } else {
          // If format is unexpected, try standard parsing
          date = DateTime.parse(this);
        }
      }
      // Handle time in format "11:37:52" (just time, no date)
      else if (this.contains(':') && !this.contains('-')) {
        // If it's just a time, use today's date
        final now = DateTime.now();
        final timeParts = this.split(':');

        if (timeParts.length >= 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);
          final second = timeParts.length >= 3 ? int.parse(timeParts[2]) : 0;

          date = DateTime(now.year, now.month, now.day, hour, minute, second);
        } else {
          return this; // Return original if it doesn't match expected time format
        }
      }
      // Parse date from ISO format (YYYY-MM-DD)
      else if (this.contains('-') && this.split('-').length >= 3) {
        final parts = this.split('-');

        // Handle standard ISO format (YYYY-MM-DD)
        if (parts[0].length == 4) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);

          date = DateTime(year, month, day);
        } else {
          // Try standard parsing
          date = DateTime.parse(this);
        }
      } else {
        // Try standard parsing as fallback
        date = DateTime.parse(this);
      }

      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      print('Error formatting date to Month Day, Year format: $e');
      return this; // Return original string if parsing fails
    }
  }

  String toDayMonthYearFormat() {
    if (this.isEmpty) return this;

    try {
      DateTime date;

      // Check if string contains time component (has a space or 'T' separator)
      if (this.contains(' ') || this.contains('T')) {
        String dateStr =
            this.split(RegExp(r'[ T]'))[0]; // Extract only the date part
        date = DateTime.parse(dateStr);
      }
      // Handle time in format "HH:mm:ss" (just time, no date)
      else if (this.contains(':') && !this.contains('-')) {
        return this; // Return as it is if it's just a time
      }
      // Handle DD-MM-YYYY format
      else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(this)) {
        List<String> parts = this.split('-');
        date = DateTime.parse(
            '${parts[2]}-${parts[1]}-${parts[0]}'); // Convert to YYYY-MM-DD
      }
      // Parse date from ISO format (YYYY-MM-DD)
      else if (this.contains('-')) {
        date = DateTime.parse(this);
      } else {
        return this; // If the format is unknown, return original string
      }

      return DateFormat('dd MMM yyyy').format(date); // Convert to "28 May 2024"
    } catch (e) {
      print('Error formatting date: $e | Input: $this');
      return this; // Return original string if parsing fails
    }
  }

  String toDate() {
    if (this.isEmpty) return this;

    try {
      // First format: DD-MM-YYYY-HH:MM
      if (this.contains('-') && this.split('-').length == 4) {
        final parts = this.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        // Parse time component
        final timeParts = parts[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

        final date = DateTime(year, month, day, hour, minute);
        return DateFormat('d MMM yyyy').format(date);
      }

      // Second format: DD-MM-YYYY
      else if (this.contains('-') && this.split('-').length == 3) {
        final parts = this.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        final date = DateTime(year, month, day);
        return DateFormat('d MMM yyyy').format(date);
      }

      // Try standard parsing as fallback
      final date = DateTime.parse(this);
      return DateFormat('d MMM yyyy').format(date);
    } catch (e) {
      print('Error parsing date: $e');
      return this; // Return original string if parsing fails
    }
  }

  String toWeekdayDate() {
    if (this.isEmpty) return this;

    try {
      DateTime date;

      // Format: DD-MM-YYYY-HH:MM
      if (this.contains('-') && this.split('-').length == 4) {
        final parts = this.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        // Parse time component
        final timeParts = parts[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

        date = DateTime(year, month, day, hour, minute);
      }
      // Format: DD-MM-YYYY
      else if (this.contains('-') && this.split('-').length == 3) {
        final parts = this.split('-');
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        date = DateTime(year, month, day);
      } else {
        // Standard parsing
        date = DateTime.parse(this);
      }

      // Format as "Mon, Feb 25"
      return DateFormat('E, MMM d').format(date);
    } catch (e) {
      print('Error parsing weekday date: $e');
      return this; // Return original string if parsing fails
    }
  }

  String toTimeAgo() {
    try {
      DateTime date = DateTime.parse(this);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      int months = 0;
      DateTime dateTemp = DateTime(date.year, date.month);
      DateTime nowTemp = DateTime(now.year, now.month);
      months =
          (nowTemp.year - dateTemp.year) * 12 + nowTemp.month - dateTemp.month;

      if (months >= 12) {
        int years = (months / 12).floor();
        return years == 1 ? '1 year ago' : '$years years ago';
      } else if (months >= 1) {
        return months == 1 ? '1 month ago' : '$months months ago';
      } else if (difference.inDays >= 7) {
        int weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else if (difference.inDays >= 1) {
        return difference.inDays == 1
            ? '1 day ago'
            : '${difference.inDays} days ago';
      } else if (difference.inHours >= 1) {
        return difference.inHours == 1
            ? '1 hour ago'
            : '${difference.inHours} hours ago';
      } else if (difference.inMinutes >= 1) {
        return difference.inMinutes == 1
            ? '1 minute ago'
            : '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return this; // Return original string if parsing fails
    }
  }
}

extension IntExtensions on int? {
  bool isNullOrZero() {
    return this == null || this == 0;
  }

  bool isGreaterThanZero() {
    return this != null && this! > 0;
  }

  String setIfNullEmpty() {
    return this == null ? "" : toString();
  }

  int getDaysInMonth(int year, int month) {
    List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))) {
      return 29; // February in a leap year
    }
    return daysInMonth[month - 1];
  }

  String toYearAndMonth() {
    int years = 0;
    int months = 0;
    int days = 0;
    if (!isNullOrZero()) {
      // Start from a base date
      DateTime startDate =
          DateTime(1, 1, 1); // Starting from year 1, month 1, day 1

      // Days to be added
      int daysToAdd = this!;

      // Calculate the end date
      DateTime endDate = startDate.add(Duration(days: daysToAdd));

      // Calculate years, months, and days
      years = endDate.year - startDate.year;
      months = endDate.month - startDate.month;
      days = endDate.day - startDate.day;

      if (days < 0) {
        // If days are negative, subtract one month and calculate days again
        months -= 1;
        // Handle month roll-back
        if (months < 0) {
          years -= 1;
          months += 12; // Roll back to December of the previous year
        }
        DateTime daysInPrevMonth =
            startDate.add(Duration(days: daysToAdd - days));
        days = daysInPrevMonth.day;
      }

      // Correct for the case where endDate.day is less than startDate.day
      if (endDate.day < startDate.day) {
        var tempDate = DateTime(
            endDate.year, endDate.month, 0); // Last day of the previous month
        days += tempDate.day;
      }
    }

    print("Years: $years, Months: $months, Days: $days");
    return "$years Y $months M $days D ";
  }
}

extension StringExtensions on String? {
  // String capitalize() {
  //   if (this.isEmpty) return this;
  //   return this[0].toUpperCase() + this.substring(1);
  // }
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    return emailRegex.hasMatch(this!);
  }

  bool isNullOrEmpty() {
    return this == null || this!.isEmpty;
  }

  bool isLocalFile() {
    return this!.startsWith('/') || this!.startsWith('file://');
  }
}

extension HexColor on Color {
  /// Convert a [Color] to a hex string like "Color(0xff405ed9)"
  String toHexString() {
    return 'Color(0x${value.toRadixString(16).padLeft(8, '0')})';
  }

  /// Convert from a hex string like "Color(0xff405ed9)" to a [Color]
  static Color? fromHexString(String colorString) {
    final hex = RegExp(r'0x[0-9a-fA-F]{8}').stringMatch(colorString);
    if (hex != null) {
      return Color(int.parse(hex));
    }
    return null;
  }
}
