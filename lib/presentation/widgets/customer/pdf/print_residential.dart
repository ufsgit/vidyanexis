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

Future<void> printResidentialPDFs({
  required BuildContext context,
  required GetQuotationbyMasterIdmodel quotationData,
  required Company companyDetails,
  required LeadDetails customerDetails,
}) async {
  try {
    quotation = quotationData;
    customer = customerDetails;

    final pw.Document pdf = pw.Document();
    await _addPlaceholderPage(pdf, 1);
    await _addSecondPage(pdf, 2);
    await _addThirdPage(pdf, 3);
    await _addItemPage(pdf);
    await _addBillOfMaterialsPage(pdf);
    await _addWarrantyPage(pdf, 9);
    await _addPlaceholderPage(pdf, 10);
    await _addPaymentTermsPage(pdf, 11);
    await _addTwelthPage(pdf, 12);
    // await _addPlaceholderPage(pdf, 13);

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

Future<void> _addItemPage(pw.Document pdf) async {
  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

  String headerImagePath = 'assets/images/residential_header.jpg';
  Uint8List? headerImageBytes;
  pw.MemoryImage? headerImage;

  String footerImagePath = 'assets/images/residential_footer.jpg';
  Uint8List? footerImageBytes;
  pw.MemoryImage? footerImage;

  try {
    final ByteData headerImageData = await rootBundle.load(headerImagePath);
    headerImageBytes = headerImageData.buffer.asUint8List();
    headerImage = pw.MemoryImage(headerImageBytes);

    // Optional footer
    final ByteData footerImageData = await rootBundle.load(footerImagePath);
    footerImageBytes = footerImageData.buffer.asUint8List();
    footerImage = pw.MemoryImage(footerImageBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        header: (context) => _buildHeader(headerImage),
        footer: (context) => _buildFooter(footerImage, context),
        build: (context) => [
          // Main content starts after header
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Quotation Title and Details Row
                pw.Text(
                  'Quotation',
                  style: pw.TextStyle(
                      font: boldFont,
                      fontSize: 18,
                      color: PdfColors.black,
                      decoration: pw.TextDecoration.underline),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Prop. No: ${quotation?.quotationNo ?? ''}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Buyer Details : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${customer?.customerName ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('${customer?.address ?? ''}',
                            style: pw.TextStyle(font: font, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Mob : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${customer?.phoneNumber ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('GST : 32AAXA0127A1Z8',
                            style: pw.TextStyle(font: boldFont, fontSize: 11)),
                        pw.SizedBox(height: 4),
                        pw.Text(
                            'Scope of Work: ${quotation?.productName ?? ''}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('Date: ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text(
                                '${quotation?.entryDate.toDDMMYYYY() ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('Payment Terms : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${quotation?.paymentTermsName ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('Inco Terms : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${quotation?.incoTerms ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('Quote Validity : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${quotation?.validity ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('MNRE Empanelment Number : ',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 11)),
                            pw.Text('${quotation?.tendorNumber ?? ''}',
                                style: pw.TextStyle(font: font, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 15),

                // Item Table Title
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                        color: PdfColor.fromHex('#679900'), width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Bill of Material with Price',
                      style: pw.TextStyle(
                          font: boldFont,
                          color: PdfColor.fromHex('#679900'),
                          fontSize: 11),
                    ),
                  ),
                ),

                // Table
                pw.Table(
                  border: pw.TableBorder.symmetric(
                      outside: pw.BorderSide(
                          color: PdfColor.fromHex('#679900'), width: 1)),
                  columnWidths: {
                    0: pw.FixedColumnWidth(35), // S.N.
                    1: pw.FlexColumnWidth(2), // Product Name
                    2: pw.FlexColumnWidth(1), // HSN
                    3: pw.FlexColumnWidth(1), // Qty
                    4: pw.FlexColumnWidth(1), // Unit
                    5: pw.FlexColumnWidth(1), // Unit Price
                    6: pw.FlexColumnWidth(1), // GST%
                    7: pw.FlexColumnWidth(1), // SGT%
                    8: pw.FlexColumnWidth(1), // IGST%
                    9: pw.FlexColumnWidth(1), // Other Tax%
                    10: pw.FlexColumnWidth(1.5), // Total Amount
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration:
                          pw.BoxDecoration(color: PdfColor.fromHex('#679900')),
                      children: [
                        _tableHeader('S.N.', color: PdfColors.white),
                        _tableHeader('Product Name',
                            color: PdfColors.white,
                            align: pw.Alignment.centerLeft),
                        _tableHeader('HSN no',
                            color: PdfColors.white, align: pw.Alignment.center),
                        _tableHeader('Qty',
                            color: PdfColors.white, align: pw.Alignment.center),
                        _tableHeader('Unit',
                            color: PdfColors.white, align: pw.Alignment.center),
                        _tableHeader('Unit Price',
                            color: PdfColors.white, align: pw.Alignment.center),
                        // _tableHeader('CGST%',
                        //     color: PdfColors.white, align: pw.Alignment.center),
                        // _tableHeader('SGST%',
                        //     color: PdfColors.white, align: pw.Alignment.center),
                        // _tableHeader('IGST%',
                        //     color: PdfColors.white, align: pw.Alignment.center),
                        _tableHeader('Other Tax',
                            color: PdfColors.white, align: pw.Alignment.center),
                        _tableHeader('Total Amount',
                            color: PdfColors.white, align: pw.Alignment.center),
                      ],
                    ),

                    // Data Row (example - make it dynamic as needed)
                    ...(quotation?.quotationDetails ?? [])
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return pw.TableRow(
                        children: [
                          _tableCell((index + 1).toString(),
                              align: pw.Alignment.center, isBold: true),
                          _tableCell(item.itemName ?? '',
                              align: pw.Alignment.centerLeft, isBold: true),
                          _tableCell(item.MRP ?? '',
                              align: pw.Alignment.center,
                              isBold: true), // mpr is hsn code
                          _tableCell(item.quantity.toString(),
                              align: pw.Alignment.center, isBold: true),
                          _tableCell(item.Unit ?? '',
                              align: pw.Alignment.center, isBold: true),
                          _tableCell(item.unitPrice?.toString() ?? '',
                              align: pw.Alignment.center, isBold: true),
                          // _tableCell(((item.GSTPercent) / 2)?.toString() ?? '',
                          //     align: pw.Alignment.center, isBold: true),
                          // _tableCell(((item.GSTPercent) / 2)?.toString() ?? '',
                          //     align: pw.Alignment.center, isBold: true),
                          // _tableCell("0",
                          //     align: pw.Alignment.center, isBold: true),
                          _tableCell(item.AdCESS?.toString() ?? '',
                              align: pw.Alignment.center,
                              isBold: true), // adcess is other tax
                          _tableCell(item.amount?.toString() ?? '',
                              align: pw.Alignment.center, isBold: true),
                        ],
                      );
                    }),
                  ],
                ),

                // Summary Section
                pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColor.fromHex('#679900'), width: 1),
                  columnWidths: const {
                    0: pw.FlexColumnWidth(2),
                    1: pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                              "Description:-\n${quotation?.description3 ?? ''}",
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _summaryRow('Discount',
                                  quotation?.subsidyAmount.toString() ?? '0'),
                              // _summaryRow('CGST',
                              //     quotation?.totalCgstAmount.toString() ?? '0'),
                              _summaryRow('SGST',
                                  quotation?.totalSgstAmount.toString() ?? '0'),
                              _summaryRow('IGST',
                                  quotation?.totalIgstAmount.toString() ?? '0'),
                              _summaryRow('Other Tax',
                                  quotation?.otherTax.toString() ?? '0'),
                              _summaryRow('Shipping Charge',
                                  quotation?.shippingCharges.toString() ?? '0'),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(8.0),
                                color: PdfColor.fromHex('#679900'),
                                child: pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.end,
                                  children: [
                                    pw.Text('Subtotal :',
                                        style: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 11,
                                            fontWeight: pw.FontWeight.bold)),
                                    pw.Text(
                                        quotation?.netTotal.toString() ?? '0',
                                        style: pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 11,
                                            fontWeight: pw.FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // pw.SizedBox(height: 30),

                // // Bank Details
                // pw.Text('BANK ACCOUNT DETAILS',
                //     style: pw.TextStyle(font: boldFont, fontSize: 12)),
                // pw.SizedBox(height: 8),
                // pw.Text('Account Number: 0915102000006552',
                //     style: pw.TextStyle(font: font, fontSize: 11)),
                // pw.Text('IFSC Code: IBKL0000339',
                //     style: pw.TextStyle(font: font, fontSize: 11)),
                // pw.Text('Account Name : A3S ECOSAVE PRIVATE LIMITED',
                //     style: pw.TextStyle(font: font, fontSize: 11)),
                // pw.Text('Bank : IDBI BANK',
                //     style: pw.TextStyle(font: font, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  } catch (e) {
    // Fallback if images fail
    _addFallbackPage(pdf, 4);
    return;
  }
}

pw.Widget _summaryRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(label + ' :',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text(value,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );
}

Future<void> _addBillOfMaterialsPage(pw.Document pdf) async {
  // Load fonts
  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

  String headerImagePath = 'assets/images/residential_header.jpg';
  Uint8List? headerImageBytes;
  pw.MemoryImage? headerImage;

  String footerImagePath = 'assets/images/residential_footer.jpg';
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
        margin: const pw.EdgeInsets.all(0),
        header: (context) => _buildHeader(headerImage),
        footer: (context) => _buildFooter(footerImage, context),
        build: (context) => [
          pw.SizedBox(height: 20),
          // Title - Now Dynamic
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 30),
            padding: const pw.EdgeInsets.all(5),
            decoration: pw.BoxDecoration(
              border:
                  pw.Border.all(color: PdfColor.fromHex('#679900'), width: 1),
            ),
            child: pw.Center(
              child: pw.Text(
                'Bill of Materials',
                style: pw.TextStyle(
                    font: boldFont,
                    color: PdfColor.fromHex('#679900'),
                    fontSize: 11),
              ),
            ),
          ),

          // Dynamic Table
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#679900'), width: 1),
              columnWidths: const {
                0: pw.FixedColumnWidth(60),
                1: pw.FlexColumnWidth(2),
                2: pw.FlexColumnWidth(),
                3: pw.FlexColumnWidth(),
                4: pw.FlexColumnWidth(),
                5: pw.FlexColumnWidth(),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#679900'),
                  ),
                  children: [
                    _tableHeader('No',
                        color: PdfColors.white, align: pw.Alignment.center),
                    _tableHeader('Description',
                        color: PdfColors.white, align: pw.Alignment.center),
                    _tableHeader('Quantity',
                        color: PdfColors.white, align: pw.Alignment.center),
                    _tableHeader('Uom',
                        color: PdfColors.white, align: pw.Alignment.center),
                    _tableHeader('Brand',
                        color: PdfColors.white, align: pw.Alignment.center),
                    _tableHeader('Comments',
                        color: PdfColors.white, align: pw.Alignment.center),
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
                          align: pw.Alignment.center, isBold: true),
                      _tableCell(item.itemsAndDescription ?? '',
                          align: pw.Alignment.center, isBold: true),
                      _tableCell(item.quantity.toString(),
                          align: pw.Alignment.center, isBold: true),
                      _tableCell(item.distributor ?? '',
                          align: pw.Alignment.center, isBold: true),
                      _tableCell(item.make ?? '',
                          align: pw.Alignment.center, isBold: true),
                      _tableCell(item.invoiceNo ?? '',
                          align: pw.Alignment.center, isBold: true),
                    ],
                  );
                }),
              ],
            ),
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
pw.Widget _tableHeader(String text,
    {PdfColor color = PdfColors.black, pw.Alignment? align}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, color: color),
      textAlign: align == pw.Alignment.center
          ? pw.TextAlign.center
          : align == pw.Alignment.centerRight
              ? pw.TextAlign.right
              : pw.TextAlign.left,
    ),
  );
}

pw.Widget _tableCell(String text, {pw.Alignment? align, bool isBold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
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

Future<void> _addSecondPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

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
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                top: 575,
                right: 75,
                left: 75,
                child: pw.Text(
                  quotation?.description ?? '',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      lineSpacing: 2,
                      color: PdfColors.black),
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
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

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
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                top: 600,
                right: 75,
                left: 75,
                child: pw.Text(
                  quotation?.description2 ?? '',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      lineSpacing: 2,
                      color: PdfColors.black),
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

Future<void> _addTwelthPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

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
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                top: 480,
                right: 75,
                left: 75,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'Signed By',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              lineSpacing: 2,
                              color: PdfColors.black),
                        ),
                        pw.Text(
                          'Consumer',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              lineSpacing: 2,
                              color: PdfColors.black),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Contractor',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              lineSpacing: 2,
                              color: PdfColors.black),
                        ),
                        pw.Text(
                          'A3S Ecosave Pvt. Ltd.',
                          style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                              lineSpacing: 2,
                              color: PdfColors.black),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              pw.Positioned(
                  bottom: 150,
                  right: 75,
                  left: 75,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'BANK ACCOUNT DETAILS',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                      pw.Text(
                        'Account Name - ${quotation?.branchDetails?.bankHolderName ?? ''}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                      pw.Text(
                        'Ac No. ${quotation?.branchDetails?.bankAccountNo ?? ''}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                      pw.Text(
                        'IFSC code - ${quotation?.branchDetails?.ifscCode ?? ''}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                      pw.Text(
                        '${quotation?.branchDetails?.branchName ?? ''}',
                        style: pw.TextStyle(font: font, fontSize: 11),
                      ),
                    ],
                  ))
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

Future<void> _addWarrantyPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

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
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                top: 300,
                right: 90,
                left: 90,
                child: pw.Text(
                  quotation?.warranty ?? '',
                  style: pw.TextStyle(
                      font: font,
                      fontSize: 10,
                      lineSpacing: 2,
                      color: PdfColors.black),
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

Future<void> _addPaymentTermsPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
  Uint8List? contentImageBytes;
  pw.MemoryImage? contentImage;

  final font = await PdfGoogleFonts.openSansRegular();
  final boldFont = await PdfGoogleFonts.openSansBold();

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
              pw.Container(
                width: PdfPageFormat.a4.width,
                height: PdfPageFormat.a4.height,
                child: pw.Image(
                  contentImage!,
                  fit: pw.BoxFit.fill,
                ),
              ),
              pw.Positioned(
                top: 370,
                right: 70,
                left: 70,
                child: pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColor.fromHex('#679900'), width: 1),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(50),
                    1: const pw.FlexColumnWidth(3),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration:
                          pw.BoxDecoration(color: PdfColor.fromHex('#679900')),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('SR.No',
                              style: pw.TextStyle(
                                  font: boldFont, color: PdfColors.white)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('STAGES',
                              style: pw.TextStyle(
                                  font: boldFont, color: PdfColors.white)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('PAYMENT SCHEDULE',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                  font: boldFont, color: PdfColors.white)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('1',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Advance payment up on conformation',
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('${quotation?.advancePercentage}%',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('2',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Upon the material ready for dispatch',
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('${quotation?.onDeliveryPercentage}%',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('3',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Installation Completion',
                              style: pw.TextStyle(font: font)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                              '${quotation?.workCompletionPercentage}%',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(font: font)),
                        ),
                      ],
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

Future<void> _addPlaceholderPage(pw.Document pdf, int pageNumber) async {
  String contentImagePath = 'assets/images/residential_${pageNumber}.jpg';
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

// Helper function to convert small numbers (less than 100)
String _convertSmallNumber(int number) {
  return _convertNumberToWordsRecursive(number);
}

// Common Header Widget
pw.Widget _buildHeader(pw.MemoryImage? headerImage) {
  if (headerImage == null) return pw.SizedBox(height: 20);

  return pw.Container(
    alignment: pw.Alignment.centerRight, // or center/left as needed
    margin: const pw.EdgeInsets.only(bottom: 0),
    child: pw.Image(
      headerImage,
      height: 150, // Adjust height as needed
      width: 600,
      fit: pw.BoxFit.fitWidth,
    ),
  );
}

// Common Footer Widget
pw.Widget _buildFooter(pw.MemoryImage? footerImage, pw.Context context) {
  return pw.Column(
    children: [
      if (footerImage != null)
        pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 20, bottom: 10),
          child: pw.Image(
            footerImage,
            height: 120,
            width: 600,
            fit: pw.BoxFit.contain,
          ),
        ),
    ],
  );
}
