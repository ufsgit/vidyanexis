import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportToPDF({
  required List<String> headers,
  required List<Map<String, dynamic>> data,
  required String fileName,
}) async {
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
              children: [
                pw.Text(
                  fileName.replaceAll('_', ' '),
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(fontSize: 10),
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
                fontWeight: pw.FontWeight.bold, fontSize: fontSize),
            cellStyle: pw.TextStyle(fontSize: fontSize),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
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
