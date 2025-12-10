import 'package:intl/intl.dart';

String formatDate(String date, String inputFormat, String outputFormat) {
  try {
    // Parse the input date
    DateTime parsedDate = DateFormat(inputFormat).parse(date);
    // Format the date to the desired output
    return DateFormat(outputFormat).format(parsedDate);
  } catch (e) {
    // Handle errors (e.g., invalid date format)
    print("Error formatting date: $e");
    return date; // Return the original date in case of error
  }
}
