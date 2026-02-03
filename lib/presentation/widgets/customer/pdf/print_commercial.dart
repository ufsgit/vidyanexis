import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

GetQuotationbyMasterIdmodel? quotation;
LeadDetails? customer;

Future<void> printCommercialPDFs({
  required BuildContext context,
  required GetQuotationbyMasterIdmodel quotationData,
  required Company companyDetails,
  required LeadDetails customerDetails,
}) async {
  try {
    quotation = quotationData;
    customer = customerDetails;

    final pw.Document pdf = pw.Document();
    await _addFirstPage(pdf, 1);
    await _addPlaceholderPage(pdf, 2);
    await _addThirdPage(pdf, 3);
    await _addFourthPage(pdf);
    await _addFifthPage(pdf);
    await _addSixthPage(pdf, 6);
    await _addPlaceholderPage(pdf, 7);
    await _addEightPage(pdf);
    await _addNinthPage(pdf, 9);

    final Uint8List pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: 'Commercial.pdf',
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

Future<void> _addFirstPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/commercial_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  try {
    final ByteData contentImageData = await rootBundle.load(contentImagePath);
    contentImageBytes = contentImageData.buffer.asUint8List();
    contentImage = pw.MemoryImage(contentImageBytes);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Full-page background image
              pw.Positioned.fill(
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),

              // 2. Customer Name (To:)
              pw.Positioned(
                left: 70, // Adjust these values to match your blank space
                top: 175, // Fine-tune until text sits perfectly in the blank
                right: 70,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      customer?.customerName ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.Text(
                      customer?.address ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Subject Line
              pw.Positioned(
                left: 95,
                top: 222,
                right: 95,
                child: pw.SizedBox(
                  width: PdfPageFormat.a4.width, // Prevent overflow
                  child: pw.Text(
                    quotation?.productName ?? '',
                    style: pw.TextStyle(
                      fontSize: 12,
                    ),
                    maxLines: 3,
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  } catch (e) {
    print('Content image not found: $contentImagePath');
    _addFallbackPage(pdf, pageNumber);
    return;
  }
}

Future<void> _addThirdPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/commercial_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  try {
    final ByteData contentImageData = await rootBundle.load(contentImagePath);
    contentImageBytes = contentImageData.buffer.asUint8List();
    contentImage = pw.MemoryImage(contentImageBytes);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Full-page background image
              pw.Positioned.fill(
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),

              // 2. Customer Name (To:)
              pw.Positioned(
                left: 260, // Adjust these values to match your blank space
                top: 400, // Fine-tune until text sits perfectly in the blank
                right: 20,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      quotation?.plantCapacity ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.moduleTechnologies ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.mountingStructureTechnologies ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.projectScheme ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.powerEvacuation ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.areaApproximate ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.solarPlantOutputConnection ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    pw.SizedBox(
                      height: 12,
                    ),
                    pw.Text(
                      quotation?.scheme ?? '',
                      style: const pw.TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  } catch (e) {
    print('Content image not found: $contentImagePath');
    _addFallbackPage(pdf, pageNumber);
    return;
  }
}

Future<void> _addFourthPage(pw.Document pdf) async {
  // Load fonts
  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

  String headerImagePath = 'assets/images/commercial_header.jpg';
  Uint8List? headerImageBytes;
  pw.MemoryImage? headerImage;

  String footerImagePath = 'assets/images/commercial_footer.jpg';
  Uint8List? footerImageBytes;
  pw.MemoryImage? footerImage;
  try {
    final ByteData headerImageData = await rootBundle.load(headerImagePath);
    headerImageBytes = headerImageData.buffer.asUint8List();
    headerImage = pw.MemoryImage(headerImageBytes);

    final ByteData footerImageData = await rootBundle.load(footerImagePath);
    footerImageBytes = footerImageData.buffer.asUint8List();
    footerImage = pw.MemoryImage(footerImageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => _buildHeader(headerImage),
        footer: (context) => _buildFooter(footerImage),
        build: (context) => [
          // Site Observation - Dynamic
          pw.Text('Site Observation',
              style: pw.TextStyle(font: boldFont, fontSize: 11)),
          pw.SizedBox(height: 10),
          pw.Text('- Considered Open RCC Roof Area.',
              style: pw.TextStyle(font: font, fontSize: 11)),
          pw.SizedBox(height: 10),
          pw.Text(
              '- Design data is sourced from Google, might vary from actual.',
              style: pw.TextStyle(font: font, fontSize: 11)),
          pw.SizedBox(height: 30),

          // Title - Now Dynamic
          pw.Center(
            child: pw.Text(
              'Technical Proposal',
              style: pw.TextStyle(font: boldFont, fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
              'List of Major Proposed Material and Make for ${quotation?.productName ?? ''}',
              style: pw.TextStyle(font: boldFont, fontSize: 11)),
          pw.SizedBox(height: 20),

          // Dynamic Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: const {
              0: pw.FixedColumnWidth(60),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(),
              3: pw.FlexColumnWidth(),
            },
            children: [
              // Header
              pw.TableRow(
                children: [
                  _tableHeader('Sl No'),
                  _tableHeader('Description & Specifications'),
                  _tableHeader('Quantity'),
                  _tableHeader('Make / Reference'),
                ],
              ),

              // Dynamic Rows from List
              ...(quotation?.billOfMaterials ?? [])
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    _tableCell((index + 1).toString(),
                        align: pw.Alignment.center),
                    _tableCell(item.itemsAndDescription ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.quantity.toString(),
                        align: pw.Alignment.center),
                    _tableCell(item.make ?? '', align: pw.Alignment.center),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 30),
        ],
      ),
    );
  } catch (e) {
    _addFallbackPage(pdf, 4);
    return;
  }
}

Future<void> _addFifthPage(pw.Document pdf) async {
  // Load fonts
  final boldFont = await PdfGoogleFonts.openSansBold();

  String headerImagePath = 'assets/images/commercial_header.jpg';
  Uint8List? headerImageBytes;
  pw.MemoryImage? headerImage;

  String footerImagePath = 'assets/images/commercial_footer.jpg';
  Uint8List? footerImageBytes;
  pw.MemoryImage? footerImage;
  try {
    final ByteData headerImageData = await rootBundle.load(headerImagePath);
    headerImageBytes = headerImageData.buffer.asUint8List();
    headerImage = pw.MemoryImage(headerImageBytes);

    final ByteData footerImageData = await rootBundle.load(footerImagePath);
    footerImageBytes = footerImageData.buffer.asUint8List();
    footerImage = pw.MemoryImage(footerImageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        header: (context) => _buildHeader(headerImage),
        footer: (context) => _buildFooter(footerImage),
        build: (context) => [
          // Title - Now Dynamic
          pw.Center(
            child: pw.Text(
              'Scope of Work',
              style: pw.TextStyle(font: boldFont, fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 20),

          // Dynamic Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: const {
              0: pw.FixedColumnWidth(60),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(),
              3: pw.FlexColumnWidth(),
            },
            children: [
              // Header
              pw.TableRow(
                children: [
                  _tableHeader('Sl No'),
                  _tableHeader('Design and Engineering'),
                  _tableHeader('A3S Scope'),
                  _tableHeader('Client Scope'),
                ],
              ),

              // Dynamic Rows from List
              ...(quotation?.scopeOfWorkItems ?? [])
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    _tableCell((index + 1).toString(),
                        align: pw.Alignment.center),
                    _tableCell(item.designAndEngineering ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.a3SScope ?? '', align: pw.Alignment.center),
                    _tableCell(item.clientScope ?? '',
                        align: pw.Alignment.center),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 30),
        ],
      ),
    );
  } catch (e) {
    _addFallbackPage(pdf, 5);
    return;
  }
}

Future<void> _addSixthPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/commercial_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  try {
    final ByteData contentImageData = await rootBundle.load(contentImagePath);
    contentImageBytes = contentImageData.buffer.asUint8List();
    contentImage = pw.MemoryImage(contentImageBytes);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Full-page background image
              pw.Positioned.fill(
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),

              // 2. Cable
              pw.Positioned(
                top: 200,
                left: 60,
                right: 60,
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        _tableHeader('Structure'),
                        _tableHeader('Material'),
                      ],
                    ),
                    _cableSpecRow('Type', quotation?.cableType ?? ''),
                    _cableSpecRow('Short circuit temperature range',
                        quotation?.cableShortCircuitTemp ?? ''),
                    _cableSpecRow('Standard', quotation?.cableStandard ?? ''),
                    _cableSpecRow('Conductor Class',
                        quotation?.cableConductorClass ?? ''),
                    _cableSpecRow('Material', quotation?.cableMaterial ?? ''),
                    _cableSpecRow(
                        'Protection', quotation?.cableProtection ?? ''),
                    _cableSpecRow('Warranty', quotation?.cableWarranty ?? ''),
                    _cableSpecRow('Tensile strength',
                        quotation?.cableTensileStrength ?? ''),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  } catch (e) {
    print('Content image not found: $contentImagePath');
    _addFallbackPage(pdf, pageNumber);
    return;
  }
}

Future<void> _addEightPage(pw.Document pdf) async {
  // Load fonts

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

  String headerImagePath = 'assets/images/commercial_header.jpg';
  Uint8List? headerImageBytes;
  pw.MemoryImage? headerImage;

  String footerImagePath = 'assets/images/commercial_footer.jpg';
  Uint8List? footerImageBytes;
  pw.MemoryImage? footerImage;
  double totalAmount = double.tryParse(quotation?.netTotal ?? '0') ?? 0.0;
  String amountInWords = convertNumberToWords(totalAmount);
  try {
    final ByteData headerImageData = await rootBundle.load(headerImagePath);
    headerImageBytes = headerImageData.buffer.asUint8List();
    headerImage = pw.MemoryImage(headerImageBytes);

    final ByteData footerImageData = await rootBundle.load(footerImagePath);
    footerImageBytes = footerImageData.buffer.asUint8List();
    footerImage = pw.MemoryImage(footerImageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(headerImage),
        footer: (context) => _buildFooter(footerImage),
        build: (context) => [
          /// ---------------- TOP DISCLAIMER ----------------
          pw.Text(
            'Damage caused by external events unconnected with flaws or defects in the product.\n'
            'Unauthorized attempts to repair / maintenance by non-authorized / certified personnel.\n'
            'Force Majeure, including but not limited to earthquake, lightning, acts of vandalism.',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),

          pw.SizedBox(height: 25),

          /// ---------------- COMMERCIAL PROPOSAL TITLE ----------------
          pw.Text(
            'Commercial Proposal .',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 10),
          // Dynamic Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: const {
              0: pw.FixedColumnWidth(60),
              1: pw.FlexColumnWidth(),
              2: pw.FlexColumnWidth(),
              3: pw.FlexColumnWidth(),
              4: pw.FlexColumnWidth(),
              5: pw.FlexColumnWidth(),
            },
            children: [
              // Header
              pw.TableRow(
                children: [
                  _tableHeader('Sl No'),
                  _tableHeader('Description'),
                  _tableHeader('Solar plant DC capacity'),
                  _tableHeader('Solar plant AC capacity'),
                  _tableHeader('Unit price (INR wp)'),
                  _tableHeader('Total Price Exc. Tax'),
                ],
              ),

              // Dynamic Rows from List
              ...(quotation?.commercialItems ?? [])
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    _tableCell((index + 1).toString(),
                        align: pw.Alignment.center),
                    _tableCell(item.description ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.dcCapacity ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.acCapacity ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.unitPrice ?? '',
                        align: pw.Alignment.center),
                    _tableCell(item.total ?? '', align: pw.Alignment.center),
                  ],
                );
              }),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: const {
              0: pw.FixedColumnWidth(60),
              1: pw.FlexColumnWidth(4),
              2: pw.FlexColumnWidth(),
            },
            children: [
              // Header
              pw.TableRow(
                children: [
                  _tableCell(''),
                  _tableCell('Total System Cost Exc. Tax',
                      align: pw.Alignment.centerRight),
                  _tableCell(quotation?.netTotal ?? '0'),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 25),

          /// ---------------- AMOUNT IN WORDS ----------------
          pw.Text(
            'Amount in words: $amountInWords',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),

          pw.SizedBox(height: 25),

          /// ---------------- PAYMENT TERMS TITLE ----------------
          pw.Text(
            'Payment Terms',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 10),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(3),
            },
            children: [
              _cableSpecRow('Payment', 'Stage', isBold: true),
              _cableSpecRow('${quotation?.advancePercentage ?? ""}%',
                  "Advance Against Purchase Order ",
                  align: pw.Alignment.centerLeft, isBold: true),
              _cableSpecRow('${quotation?.onDeliveryPercentage ?? ""}%',
                  "On readiness of major material at our warehouse before dispatch along with 100% taxes and against proforma invoice ",
                  align: pw.Alignment.centerLeft, isBold: true),
              _cableSpecRow('${quotation?.workCompletionPercentage ?? ""}%',
                  "After project completion ",
                  align: pw.Alignment.centerLeft, isBold: true),
            ],
          ),
          pw.SizedBox(height: 10),

          /// ---------------- PROJECT COMPLETION ----------------
          pw.Text(
            'Project Completion: 15 to 30 days from the date of drawing approval, '
            'providing access to roof and receipt of advance and whichever is later.',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),

          pw.SizedBox(height: 10),

          /// ---------------- DELAY DISCLAIMER ----------------
          pw.Text(
            'A3S shall not be responsible for delays not attributable to A3S like delay '
            'due to regulatory issues like KSEB policies etc., in such a case timeline '
            'will get automatically extended for the period of any such delay not solely '
            'attributable to A3S.',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ],
      ),
    );
  } catch (e) {
    _addFallbackPage(pdf, 5);
    return;
  }
}

Future<void> _addNinthPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/commercial_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  try {
    final ByteData contentImageData = await rootBundle.load(contentImagePath);
    contentImageBytes = contentImageData.buffer.asUint8List();
    contentImage = pw.MemoryImage(contentImageBytes);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // 1. Full-page background image
              pw.Positioned.fill(
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),

              // 4. Subject Line
              pw.Positioned(
                left: 140,
                top: 130,
                right: 140,
                child: pw.SizedBox(
                  width: PdfPageFormat.a4.width, // Prevent overflow
                  child: pw.Text(
                    quotation?.entryDate.toDDMMYYYY() ?? '',
                    style: pw.TextStyle(
                      fontSize: 11,
                    ),
                    maxLines: 3,
                    overflow: pw.TextOverflow.clip,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  } catch (e) {
    print('Content image not found: $contentImagePath');
    _addFallbackPage(pdf, pageNumber);
    return;
  }
}

pw.TableRow _cableSpecRow(String parameter, String value,
    {pw.Alignment align = pw.Alignment.center, bool isBold = false}) {
  return pw.TableRow(
    children: [
      _tableCell(parameter, align: pw.Alignment.center, isBold: isBold),
      _tableCell(value, align: align, isBold: isBold),
    ],
  );
}

// Reusable table cell widgets
pw.Widget _tableHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10),
      textAlign: pw.TextAlign.center,
    ),
  );
}

pw.Widget _tableCell(String text, {pw.Alignment? align, bool isBold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
      textAlign: align == pw.Alignment.center
          ? pw.TextAlign.center
          : align == pw.Alignment.centerRight
              ? pw.TextAlign.right
              : pw.TextAlign.left,
    ),
  );
}

Future<void> _addPlaceholderPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/commercial_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  try {
    final ByteData contentImageData = await rootBundle.load(contentImagePath);
    contentImageBytes = contentImageData.buffer.asUint8List();
    contentImage = pw.MemoryImage(contentImageBytes);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            width: PdfPageFormat.a4.width,
            height: PdfPageFormat.a4.height,
            child: pw.Image(
              contentImage!,
              fit: pw.BoxFit.fill,
            ),
          );
        },
      ),
    );
  } catch (e) {
    print('Content image not found: $contentImagePath');
    _addFallbackPage(pdf, pageNumber);
    return;
  }
}

void _addFallbackPage(pw.Document pdf, int pageNumber) {
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            width: 300,
            height: 200,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
            ),
            child: pw.Center(
              child: pw.Text(
                'Image Not Found for Page $pageNumber\n'
                'Please ensure assets/images/$pageNumber.jpg exists',
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        );
      },
    ),
  );
}

String formatIndianNumber(String amountString) {
  try {
    final double amount = double.parse(amountString);
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'en_IN',
      decimalDigits: 2,
      symbol: '',
    );
    return formatter.format(amount);
  } catch (e) {
    // Handle cases where amountString is not a valid number
    return amountString;
  }
}

String formatAddress(String address) {
  return address.replaceAll(RegExp(r'\s{2,}'), '\n');
}

//
String convertNumberToWords(double number) {
  if (number == 0) return "Zero Rupees Only";

  String words = _convertNumberToWordsRecursive(number.toInt());

  words = "${words.trim()} Rupees Only";

  // Handle decimal part
  int decimalPart = ((number - number.toInt()) * 100).toInt();
  if (decimalPart > 0) {
    words = words.replaceAll("Only", "");
    words += " and $decimalPart Paise";
  }

  return words;
}

String _convertNumberToWordsRecursive(int number) {
  const List<String> units = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  const List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  if (number == 0) return "";

  String words = "";

  if (number >= 10000000) {
    words += "${_convertNumberToWordsRecursive(number ~/ 10000000)} Crore ";
    number %= 10000000;
  }

  if (number >= 100000) {
    words += "${_convertNumberToWordsRecursive(number ~/ 100000)} Lakh ";
    number %= 100000;
  }

  if (number >= 1000) {
    words += "${_convertNumberToWordsRecursive(number ~/ 1000)} Thousand ";
    number %= 1000;
  }

  if (number >= 100) {
    words += "${units[number ~/ 100]} Hundred ";
    number %= 100;
  }

  if (number > 0) {
    if (words.isNotEmpty) words += "and ";

    if (number < 20) {
      words += units[number];
    } else {
      words += tens[number ~/ 10];
      if (number % 10 > 0) {
        words += " ${units[number % 10]}";
      }
    }
  }

  return words;
}

// _convertSmallNumber is no longer needed but kept for compatibility if used elsewhere (it was private though)
String _convertSmallNumber(int number) {
  return _convertNumberToWordsRecursive(number);
}

// Common Header Widget
pw.Widget _buildHeader(pw.MemoryImage? headerImage) {
  if (headerImage == null) return pw.SizedBox(height: 20);

  return pw.Container(
    alignment: pw.Alignment.centerRight, // or center/left as needed
    margin: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Image(
      headerImage,
      height: 100, // Adjust height as needed
      width: 600,
      fit: pw.BoxFit.contain,
    ),
  );
}

// Common Footer Widget
pw.Widget _buildFooter(pw.MemoryImage? footerImage) {
  return pw.Column(
    children: [
      if (footerImage != null)
        pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20, bottom: 10),
          child: pw.Image(
            footerImage,
            height: 100,
            width: 600,
            fit: pw.BoxFit.contain,
          ),
        ),
    ],
  );
}
