import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/utils/extensions.dart';

LeadDetails? customer;
GetQuotationbyMasterIdmodel? quotation;
pw.Font malayalamFont = pw.Font();
loadMalayalamFont() async {
  final ByteData fontData = await rootBundle
      .load('assets/fonts/NotoSansMalayalam-VariableFont_wdth,wght.ttf');
  final Uint8List fontBytes = fontData.buffer.asUint8List();
  malayalamFont = pw.Font.ttf(fontBytes.buffer.asByteData());
}

pw.Text getMalayalamText(String text, pw.TextStyle style,
    {pw.TextAlign? textAlign}) {
  return pw.Text(text,
      textAlign: textAlign,
      style: style?.copyWith(font: malayalamFont, fontSize: 10));
}

Future<void> RefundFormPDFs({
  required BuildContext context,
}) async {
  try {
    final pw.Document pdf = pw.Document();

    // Add first page
    await _addFirstRefundPage(pdf);

    final Uint8List pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: "Kerala's Renewable Energy Report",
      format: PdfPageFormat.a4,
      usePrinterSettings: true,
    );
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to generate or print PDF: $e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    print('PDF error: $e');
  }
}

Future<void> _addFirstRefundPage(
  pw.Document pdf,
) async {
  try {
    await loadMalayalamFont();
    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('To'),
                pw.Text('  Sub Engineer / Assistant Engineer'),
                pw.Text('  Electrical Section :-'),
                pw.Text('  Place :-'),
                pw.SizedBox(height: 20),
                pw.Text(
                    'Sub   : Application for Refund of Solar Plant Registration Fee'),
                pw.SizedBox(height: 20),
                getMalayalamText(
                    'അനുബന്ധം - 1',
                    textAlign: pw.TextAlign.right,
                    pw.TextStyle(
                        decoration: pw.TextDecoration.underline,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                getMalayalamText(
                    '        എന്റെ പേരിലുള്ള കണക്ടുമര്‍ നമ്പര്‍                           '
                    'കണക്കില്‍      KW ശേഷിയുള്ള സൗരോര് പ്ലാന്റ് രജിസ്റ്റര് ചെയ്തു '
                    'സബ്സിഡിയായി പൂര്‍ത്തീകരിക്കുകയും പ്രവൃത്തി ആപേക്ഷിക്കുകയും '
                    'ചെയ്തിരിക്കുന്നു. അതിനാല്‍ പ്ലാന്റ് രജിസ്‌ട്രേഷന്‍ ഇന്‍ററില്‍ KSEBL '
                    'യിലേക്ക് പേയ്മെന്റ് ആയി നല്‍കിയ തുക തിരികെ കൊടുക്കണമെന്നു '
                    'എന്റെ ബാങ്ക് അക്കൗണ്ടിലേക്ക് തിരികെ നല്‍കുവാന്‍ അഭ്യര്‍ത്ഥിക്കുന്നു.',
                    textAlign: pw.TextAlign.right,
                    pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Account Holder Name   : '),
                pw.Text('Account Number         :'),
                pw.Text('Bank Name              : '),
                pw.Text('IFSC Code              :'),
                pw.SizedBox(height: 20),
                getMalayalamText(
                    'വിശ്വസ്തതയോടെ',
                    textAlign: pw.TextAlign.right,
                    pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 30),
                getMalayalamText(
                    'പേര്',
                    textAlign: pw.TextAlign.right,
                    pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                getMalayalamText(
                    'ഒപ്പ്',
                    textAlign: pw.TextAlign.right,
                    pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            );
          }),
    );
  } catch (e) {}
}
