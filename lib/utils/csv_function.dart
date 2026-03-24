import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

String? filePath;
List<Map<String, dynamic>> jsonData = [];

// Function to pick and load an Excel file
Future<List<Map<String, dynamic>>> pickAndLoadExcelFile() async {
  // Pick an Excel file
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['xlsx'], // Specify file type (xlsx)
  );

  if (result != null) {
    var file = result.files.single;
    var bytes = file.bytes; // Use `bytes` directly

    if (bytes != null) {
      var excel = Excel.decodeBytes(bytes);

      // If a valid sheet exists
      log("xcl ite : ${excel.sheets.values.first}");

      if (excel.sheets.isNotEmpty) {
        var sheet = excel
            .sheets.values.first; // Get the first sheet (adjust as necessary)

        // Process the rows and headers
        var items = processSheet(sheet);
        log("xcl ite : $items");
        return items;
      }
    }
  }
  return [];
}

// Process the sheet rows
List<Map<String, dynamic>> processSheet(Sheet sheet) {
  List<Map<String, dynamic>> data = [];
  var headerRow = sheet.rows[0]; // First row as headers

  // Define the custom key mapping
  var customKeys = {
    'Name': 'Name',
    'Mobile': 'Mobile',
  };

  // Iterate through rows starting from the second row (skip header row)
  for (var i = 1; i < sheet.rows.length; i++) {
    var row = sheet.rows[i];
    Map<String, dynamic> rowData = {};

    bool isEmptyRow = true;

    // Iterate through the columns in the row
    for (var j = 0; j < headerRow.length; j++) {
      var header = cleanHeader(headerRow[j]?.value?.toString() ?? "");
      var value = row[j]?.value;

      if (header.isNotEmpty) {
        var customKey = customKeys[header] ?? header;
        var convertedValue = _convertCellValueToString(value);
        rowData[customKey] = convertedValue;

        // If any value is not null, mark the row as non-empty
        if (convertedValue != null && convertedValue.isNotEmpty) {
          isEmptyRow = false;
        }
      }
    }

    // Only add non-empty rows
    if (!isEmptyRow) {
      data.add(rowData);
    }
  }

  // Update the state with the processed data
  // setState(() {
  jsonData = data;
  print(jsonEncode(jsonData)); // Print the result in JSON format
  return jsonData;
  // Optionally, print the result or do anything with jsonData
}

// Helper function to clean headers by trimming and removing unwanted characters
String cleanHeader(String header) {
  String cleanedHeader = header.trim().replaceAll(RegExp(r'\u00A0'), '');
  return cleanedHeader;
}

// Helper function to convert cell values to a string (or appropriate type)
dynamic _convertCellValueToString(dynamic value) {
  if (value is String) {
    return value;
  } else if (value is int) {
    return value.toString();
  } else if (value is double) {
    return value.toString();
  } else if (value is DateTime) {
    return value.toIso8601String();
  } else if (value is num) {
    return value.toString();
  } else if (value == null) {
    return "";
  }
  String stringValue = value.toString();
  if (stringValue.endsWith('.0')) {
    return stringValue.substring(0, stringValue.length - 2); // Remove ".0"
  }
  return stringValue;
}

Future<void> exportToExcel({
  required List<String> headers,
  required List<Map<String, dynamic>> data,
  required String fileName,
}) async {
  try {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0))
        ..value = TextCellValue(headers[i])
        ..cellStyle = CellStyle(
          bold: true,
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Add data rows
    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final rowData = data[rowIndex];
      for (int colIndex = 0; colIndex < headers.length; colIndex++) {
        final header = headers[colIndex];
        final cellValue = rowData[header]?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: colIndex, rowIndex: rowIndex + 1))
          .value = TextCellValue(cellValue);
      }
    }

    // Auto-size columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    // Ensure file name has .xlsx extension
    final safeFileName =
        fileName.endsWith('.xlsx') ? fileName : '$fileName.xlsx';

    // Get Excel bytes
    final bytes = excel.encode();
    if (bytes == null) {
      throw 'Failed to encode Excel file';
    }

    // Web platform handling
    if (kIsWeb) {
      // Convert bytes to base64
      final base64 = base64Encode(bytes);

      // Create a data URI
      final dataUri =
          'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64';

      // Create anchor element with download attribute
      final anchor = html.AnchorElement(href: dataUri)
        ..setAttribute('download', safeFileName)
        ..setAttribute('style', 'display: none');

      // Add to the DOM
      html.document.body?.append(anchor);

      // Trigger download
      anchor.click();

      // Clean up
      anchor.remove();

      print('Excel file download initiated in web browser (data URI method)');
      return;
    }

    // Mobile platform handling
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory ??= Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw 'Platform not supported';
    }

    final filePath = '${directory.path}/$safeFileName';

    // Save the Excel file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    print('Excel file exported successfully: $filePath');

    // For mobile platforms, you might want to add sharing functionality here
  } catch (e) {
    print('Error exporting to Excel: $e');
    rethrow;
  }
}
