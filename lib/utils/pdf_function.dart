import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_styles.dart';

Future<pw.MemoryImage?> _loadLogoImage() async {
  try {
    final logoPath = AppStyles.logo();
    if (logoPath.startsWith('http')) {
      final response = await http.get(Uri.parse(logoPath));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } else if (logoPath.startsWith('assets/')) {
      final bytes = await rootBundle.load(logoPath);
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } else {
      final bytes = await rootBundle.load('assets/images/Icon-512.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    }
  } catch (e) {
    print('Error loading logo: $e');
    try {
      final bytes = await rootBundle.load('assets/images/Icon-512.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }
  return null;
}

Future<void> exportToPDF({
  required List<String> headers,
  required List<Map<String, dynamic>> data,
  required String fileName,
}) async {
  final logoImage = await _loadLogoImage();
  final preferences = await SharedPreferences.getInstance();
  final companyName = preferences.getString('cached_company_title') ?? '3rd Eye Security Systems';
  final pdf = pw.Document();

  // Adjust font size based on column count
  double fontSize = 8;
  if (headers.length > 12) {
    fontSize = 5;
  } else if (headers.length > 10) {
    fontSize = 6;
  } else if (headers.length > 8) {
    fontSize = 7;
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(10),
      header: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        );
      },
      build: (pw.Context context) {
        return [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null) ...[
                      pw.Image(logoImage, width: 32, height: 32, fit: pw.BoxFit.contain),
                      pw.SizedBox(width: 8),
                    ],
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          companyName,
                          style: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          fileName.replaceAll('_', ' '),
                          style: const pw.TextStyle(
                              fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Text(
                  'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: data
                .map((row) => headers
                    .map((header) => row[header]?.toString() ?? '')
                    .toList())
                .toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: fontSize,
                color: PdfColors.white),
            cellStyle: pw.TextStyle(fontSize: fontSize, color: PdfColors.grey900),
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#152D70')),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F9FAFB')),
            cellHeight: 20,
            cellAlignments: {
              for (var i = 0; i < headers.length; i++)
                i: pw.Alignment.centerLeft,
            },
            columnWidths: {
              // Optionally adjust column widths if needed, but fromTextArray usually does a decent job
            },
          ),
        ];
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
    name: '$fileName.pdf',
    format: PdfPageFormat.a4.landscape,
  );
}
