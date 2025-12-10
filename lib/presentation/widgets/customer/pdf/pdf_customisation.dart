import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class PDFService {
  Future<Uint8List> loadPdfFromAssets(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  Future<Uint8List> customizePdf(
      String assetPath, Map<String, dynamic> apiData) async {
    // Load the base PDF
    final Uint8List baseData = await loadPdfFromAssets(assetPath);

    // Create a new PDF document
    final pdf = pw.Document();

    // Convert PDF pages to images using the printing package
    final pdfRasterStream = Printing.raster(baseData, pages: null, dpi: 300);

    // Collect all pages as images
    final List<PdfRaster> pages = await pdfRasterStream.toList();

    // Process each page
    for (int i = 0; i < pages.length; i++) {
      final pageRaster = pages[i];

      // Convert raster to PNG
      final pageImage = await pageRaster.toPng();

      // Add a new page with the original page as background
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Base page as background image
                pw.Image(pw.MemoryImage(pageImage)),

                // Add custom data from API based on the page
                // Page 11 (0-based index 10) - "What is included" table
                if (i == 10)
                  pw.Positioned(
                    top: 320,
                    left: 150,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: _buildTableRows(apiData),
                    ),
                  ),

                // Page 12 (0-based index 11) - Commercial Summary
                if (i == 11)
                  pw.Positioned(
                    top: 185,
                    left: 680,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(apiData['systemPrice'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 25),
                        pw.Text(apiData['additionalStructure'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 25),
                        pw.Text(apiData['totalAmount'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 25),
                        pw.Text(apiData['subsidyAmount'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 25),
                        pw.Text(apiData['effectivePrice'] ?? '',
                            style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    // Save and return the customized PDF
    return pdf.save();
  }

  // Helper method to build table rows from API data
  List<pw.Widget> _buildTableRows(Map<String, dynamic> apiData) {
    final List<pw.Widget> rows = [];

    // Assuming apiData contains a list of items
    final items = apiData['items'] as List<dynamic>? ?? [];

    for (int i = 0; i < items.length && i < 12; i++) {
      final item = items[i];
      rows.add(
        pw.Row(
          children: [
            pw.Text(item['description'] ?? '',
                style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(width: 20),
            pw.Text(item['make'] ?? '', style: pw.TextStyle(fontSize: 10)),
          ],
        ),
      );
      rows.add(pw.SizedBox(height: 25)); // Spacing between rows
    }

    return rows;
  }
}
