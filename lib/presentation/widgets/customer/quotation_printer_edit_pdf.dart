import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart' as pw_format;
import 'package:pdf/widgets.dart' as pw;
import 'package:techtify/controller/models/company_details_model.dart';
import 'package:techtify/controller/models/get_quotation_master_id_model.dart';
import 'package:techtify/controller/models/lead_details_model.dart';

class QuotationPDFPrinterWeb {
  static Future<void> printQuotationDialog({
    required String title,
    required dynamic companyDetails,
    required dynamic customerDetails,
    required dynamic quotationData,
    BuildContext? context,
  }) async {
    try {
      print('Starting PDF generation process');

      if (kIsWeb) {
        print('Web platform detected');

        try {
          // Load template PDF from assets
          final ByteData templateData =
              await rootBundle.load('assets/images/cygnus.pdf');
          final Uint8List templateBytes = templateData.buffer.asUint8List();

          // Load template with Syncfusion PDF library
          final PdfDocument templateDoc =
              PdfDocument(inputBytes: templateBytes);

          // Create a new document that will contain our modified PDF
          final PdfDocument outputDoc = PdfDocument();

          // Copy all pages from template
          for (int i = 0; i < templateDoc.pages.count; i++) {
            // Copy each page from template
            final PdfPage templatePage = templateDoc.pages[i];
            final PdfPage newPage = outputDoc.pages.add();

            // Copy content using form
            final PdfTemplate template = templatePage.createTemplate();
            newPage.graphics.drawPdfTemplate(template, Offset.zero,
                Size(templatePage.size.width, templatePage.size.height));
          }

          // Now modify specific pages with our custom content

          // Page 1 modifications (index 0)
          if (outputDoc.pages.count > 0) {
            PdfPage page = outputDoc.pages[0];
            PdfGraphics graphics = page.graphics;

            // Add date, reference, and customer details
            PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

            // Date
            graphics.drawString(
              'Date: ${DateTime.now().toString().substring(0, 10)}',
              font,
              brush: PdfSolidBrush(PdfColor(0, 0, 0)),
              bounds: Rect.fromLTWH(72, 240, 400, 30),
            );

            // Reference
            graphics.drawString(
              'Reference: QT-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}',
              font,
              brush: PdfSolidBrush(PdfColor(0, 0, 0)),
              bounds: Rect.fromLTWH(72, 260, 400, 30),
            );

            // Customer name
            graphics.drawString(
              'To,\n${customerDetails.customerName ?? 'Valued Customer'}',
              font,
              brush: PdfSolidBrush(PdfColor(0, 0, 0)),
              bounds: Rect.fromLTWH(72, 320, 400, 60),
            );

            // Subject
            graphics.drawString(
              'Subject: Solar Rooftop System Quotation',
              font,
              brush: PdfSolidBrush(PdfColor(0, 0, 0)),
              bounds: Rect.fromLTWH(72, 460, 400, 30),
            );
          }

          // Page 2 modifications (index 1)
          if (outputDoc.pages.count > 1) {
            PdfPage page = outputDoc.pages[1];
            // Add custom content to page 2
            // Similar to above, use page.graphics to draw text
          }

          // Add quotation data to page 14 (if it exists)
          if (outputDoc.pages.count > 13) {
            _addQuotationDataToPage(outputDoc.pages[13], quotationData);
          } else {
            // If page 14 doesn't exist in template, add a new page for quotation data
            PdfPage newPage = outputDoc.pages.add();
            _addQuotationDataToPage(newPage, quotationData);
          }

          // Modify page 15 (if it exists)
          if (outputDoc.pages.count > 14) {
            PdfPage page = outputDoc.pages[14];
            // Add price and payment details to page 15
            _addPricingDetailsToPage(page, quotationData);
          }

          // Save the modified PDF
          final List<int> savedBytes = outputDoc.saveSync();
          final Uint8List pdfBytes = Uint8List.fromList(savedBytes);
          outputDoc.dispose();
          templateDoc.dispose();

          // Show the PDF preview
          if (context != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: PdfPreview(
                    build: (_) => pdfBytes,
                    canChangeOrientation: true,
                    canChangePageFormat: true,
                    allowPrinting: true,
                    allowSharing: false,
                    canDebug: false,
                    useActions: true,
                    pdfFileName: "quotation.pdf",
                  ),
                ),
              ),
            );
            print('Navigation to PDF viewer completed');
          }
        } catch (e) {
          print('Error generating PDF: $e');
          if (context != null) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('PDF Generation Error'),
                content: Text('Error creating PDF: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        // Non-web implementation
        print('Non-web platform detected');
      }
    } catch (e) {
      print('Unexpected error: $e');
      if (context != null) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Unexpected Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Helper method to add quotation data to a specific page
  static void _addQuotationDataToPage(
      PdfPage page, GetQuotationbyMasterIdmodel quotationData) {
    PdfGraphics graphics = page.graphics;

    // Add title
    PdfFont titleFont =
        PdfStandardFont(PdfFontFamily.helvetica, 18, style: PdfFontStyle.bold);
    graphics.drawString(
      'Quotation Details',
      titleFont,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(72, 72, 400, 30),
    );

    // Create a table for quotation items
    PdfGrid grid = PdfGrid();
    grid.style = PdfGridStyle(
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
    );

    // Add columns
    grid.columns.add(count: 4);
    grid.headers.add(1);
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Item';
    header.cells[1].value = 'Quantity';
    header.cells[2].value = 'Price';
    header.cells[3].value = 'Total';

    // Style the header
    for (int i = 0; i < header.cells.count; i++) {
      header.cells[i].style.backgroundBrush =
          PdfSolidBrush(PdfColor(68, 114, 196));
      header.cells[i].style.textBrush = PdfBrushes.white;
      header.cells[i].style.font = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
    }

    // Add rows
    if (quotationData.quotationDetails != null &&
        quotationData.quotationDetails is List) {
      for (var item in quotationData.quotationDetails) {
        PdfGridRow row = grid.rows.add();
        row.cells[0].value = item.itemName ?? '';
        row.cells[1].value = item.quantity?.toString() ?? '';
        row.cells[2].value = item.amount?.toString() ?? '';

        double total = 0;
        if (item.quantity != null && item.amount != null) {
          total = (double.parse(item.quantity.toString()) * item.amount);
        }
        row.cells[3].value = total.toString();
      }
    }

    // Draw the grid
    grid.draw(
      page: page,
      bounds: Rect.fromLTWH(72, 120, page.getClientSize().width - 144, 0),
    );

    // Add total amount at the bottom
    PdfFont totalFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    graphics.drawString(
      'Total Amount: ${quotationData.subsidyAmount?.toString() ?? ""}',
      totalFont,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(page.getClientSize().width - 250, 500, 200, 30),
    );
  }

  // Helper method to add pricing details to a page
  static void _addPricingDetailsToPage(PdfPage page, dynamic quotationData) {
    PdfGraphics graphics = page.graphics;
    PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
    PdfFont boldFont =
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);

    // Fill in the pricing table cells with actual data
    double yPosition = 180; // Starting Y position for the pricing table

    // System price
    graphics.drawString(
      quotationData.totalAmount?.toString() ?? '',
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(400, yPosition, 150, 30),
    );
    yPosition += 30;

    // Additional structure work
    graphics.drawString(
      quotationData.additionalAmount?.toString() ?? '0',
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(400, yPosition, 150, 30),
    );
    yPosition += 30;

    // Total amount
    double totalAmount = (quotationData.totalAmount ?? 0) +
        (quotationData.additionalAmount ?? 0);
    graphics.drawString(
      totalAmount.toString(),
      boldFont,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(400, yPosition, 150, 30),
    );
    yPosition += 30;

    // Subsidy amount
    graphics.drawString(
      quotationData.subsidyAmount?.toString() ?? '0',
      font,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(400, yPosition, 150, 30),
    );
    yPosition += 30;

    // Effective price
    double effectivePrice = totalAmount - (quotationData.subsidyAmount ?? 0);
    graphics.drawString(
      effectivePrice.toString(),
      boldFont,
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      bounds: Rect.fromLTWH(400, yPosition, 150, 30),
    );
  }
}
