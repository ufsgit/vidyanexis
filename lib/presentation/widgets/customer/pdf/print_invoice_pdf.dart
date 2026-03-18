import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/invoice_tab_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/controller/models/quotaion_list_model.dart';
import 'package:vidyanexis/controller/models/reciept_list_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

LeadDetails? customer;

Future<void> invoicePDFPrint({
  required BuildContext context,
  required LeadDetails? customerDetails,
  required List<QuatationListModel> quotationList,
  required List<ReceiptListModel> receiptList,
}) async {
  String formatAmount(dynamic amount) {
    try {
      if (amount == null) return '0.00';
      final double value =
          amount is String ? double.parse(amount) : amount.toDouble();
      return value.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  String calculateTotalAmount(List<QuatationListModel> quotations) {
    double total = 0.0;
    for (var quotation in quotations) {
      try {
        total += double.parse(quotation.totalAmount ?? '0');
      } catch (e) {
        // Skip invalid amounts
      }
    }
    return total.toStringAsFixed(2);
  }

  String calculateTotalNetAmount(List<QuatationListModel> quotations) {
    double total = 0.0;
    for (var quotation in quotations) {
      try {
        total += double.parse(quotation.netTotal ?? '0');
      } catch (e) {
        // Skip invalid amounts
      }
    }
    return total.toStringAsFixed(2);
  }

  String calculateTotalSubsidyAmount(List<QuatationListModel> quotations) {
    double total = 0.0;
    for (var quotation in quotations) {
      try {
        total += double.parse(quotation.subsidyAmount ?? '0');
      } catch (e) {
        // Skip invalid amounts
      }
    }
    return total.toStringAsFixed(2);
  }

  // String _calculateTotalGstAmount(List<QuatationListModel> quotations) {
  //   double total = 0.0;
  //   for (var quotation in quotations) {
  //     try {
  //       total += double.parse(quotation.gstAmount ?? '0');
  //     } catch (e) {
  //       // Skip invalid amounts
  //     }
  //   }
  //   return total.toStringAsFixed(2);
  // }

  // String _calculateTotalKsebCharges(List<QuatationListModel> quotations) {
  //   double total = 0.0;
  //   for (var quotation in quotations) {
  //     // Calculate KSEB charges (sum of all KSEB related fees)
  //     double ksebCharges = (double.tryParse(
  //                 quotation.systemPriceExcludingKsebPaperwork ?? '0') ??
  //             0) +
  //         (double.tryParse(quotation.ksebFeasibilityStudyFees ?? '0') ?? 0) +
  //         (double.tryParse(quotation.ksebRegistrationFeesPhase3 ?? '0') ?? 0) +
  //         (double.tryParse(quotation.ksebFeasibilityPhase3 ?? '0') ?? 0) +
  //         (double.tryParse(quotation.todBiDirectionalMeterPhase3 ?? '0') ?? 0);
  //     total += ksebCharges;
  //   }
  //   return total.toStringAsFixed(2);
  // }

  String calculateTotalPayments(List<ReceiptListModel> receipts) {
    double total = 0.0;
    for (var receipt in receipts) {
      total += receipt.amount;
    }
    return total.toStringAsFixed(2);
  }

  String calculateOutstandingBalance(
      List<QuatationListModel> quotations, List<ReceiptListModel> receipts) {
    double totalInvoices = double.parse(calculateTotalAmount(quotations));
    double totalPayments = double.parse(calculateTotalPayments(receipts));
    double balance = totalInvoices - totalPayments;
    return balance.toStringAsFixed(2);
  }

  PdfColor getOutstandingBalanceColor(
      List<QuatationListModel> quotations, List<ReceiptListModel> receipts) {
    double balance =
        double.parse(calculateOutstandingBalance(quotations, receipts));
    if (balance > 0) {
      return PdfColors.red; // Outstanding amount
    } else if (balance < 0) {
      return PdfColors.green; // Overpaid
    } else {
      return PdfColors.black; // Balanced
    }
  }

  try {
    customer = customerDetails;

    final pw.Document pdf = pw.Document();

    await _addIvsFirstPage(pdf, customerDetails, quotationList);

    pdf.addPage(
      pw.MultiPage(
        margin: pw.EdgeInsets.all(50),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green, width: 1),
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(16.0),
                  child: pw.Column(children: [
                    pw.Text(
                      'Invoice Summary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.Table(
                      border:
                          pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(1.5), // Quotation No
                        1: const pw.FlexColumnWidth(2), // Product Name
                        2: const pw.FlexColumnWidth(1.5), // Subsidy Amount
                        3: const pw.FlexColumnWidth(1.5), // GST Amount
                        4: const pw.FlexColumnWidth(1.5), // KSEB Charges
                        5: const pw.FlexColumnWidth(1.5), // Net Total
                        6: const pw.FlexColumnWidth(1.5), // Total Amount
                      },
                      children: [
                        // Header row
                        pw.TableRow(
                          decoration:
                              const pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Quotation No.',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Product Name',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Subsidy Amount',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'GST Amount',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            // pw.Padding(
                            //   padding: const pw.EdgeInsets.all(8),
                            //   child: pw.Text(
                            //     'KSEB Charges',
                            //     style: pw.TextStyle(
                            //         fontWeight: pw.FontWeight.bold),
                            //     textAlign: pw.TextAlign.center,
                            //   ),
                            // ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Net Total',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'Total Amount',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        // Data rows for quotations
                        ...quotationList.map((quotation) {
                          return pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  quotation.quotationNo.toString() ?? 'N/A',
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  quotation.productName ?? 'N/A',
                                  textAlign: pw.TextAlign.left,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${formatAmount(quotation.subsidyAmount)}',
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              // pw.Padding(
                              //   padding: const pw.EdgeInsets.all(8),
                              //   child: pw.Text(
                              //     'Rs. ${_formatAmount(quotation.gstAmount)}',
                              //     textAlign: pw.TextAlign.right,
                              //   ),
                              // ),
                              // pw.Padding(
                              //   padding: const pw.EdgeInsets.all(8),
                              //   child: pw.Text(
                              //     'Rs. ${_formatAmount(ksebCharges)}',
                              //     textAlign: pw.TextAlign.right,
                              //   ),
                              // ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${formatAmount(quotation.netTotal)}',
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${formatAmount(quotation.totalAmount)}',
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }),

                        // Total row
                        if (quotationList.isNotEmpty)
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey100),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'TOTAL',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(), // Empty cell for Product Name
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${calculateTotalSubsidyAmount(quotationList)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              // pw.Padding(
                              //   padding: const pw.EdgeInsets.all(8),
                              //   child: pw.Text(
                              //     'Rs. ${_calculateTotalGstAmount(quotationList)}',
                              //     style: pw.TextStyle(
                              //         fontWeight: pw.FontWeight.bold),
                              //     textAlign: pw.TextAlign.right,
                              //   ),
                              // ),
                              // pw.Padding(
                              //   padding: const pw.EdgeInsets.all(8),
                              //   child: pw.Text(
                              //     'Rs. ${_calculateTotalKsebCharges(quotationList)}',
                              //     style: pw.TextStyle(
                              //         fontWeight: pw.FontWeight.bold),
                              //     textAlign: pw.TextAlign.right,
                              //   ),
                              // ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${calculateTotalNetAmount(quotationList)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${calculateTotalAmount(quotationList)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    pw.SizedBox(height: 30),

                    // Payment History Table (only if there are receipts)
                    if (receiptList.isNotEmpty) ...[
                      pw.Text(
                        'Payment History',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(
                            color: PdfColors.grey, width: 0.5),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(2),
                          1: const pw.FlexColumnWidth(2),
                          2: const pw.FlexColumnWidth(3),
                          3: const pw.FlexColumnWidth(2),
                          4: const pw.FlexColumnWidth(2),
                        },
                        children: [
                          // Header row
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey200),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Receipt No',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Date',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Description',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Amount',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Received By',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          // Data rows for receipts
                          ...receiptList.map((receipt) {
                            return pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(receipt.receiptNo),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    _formatDate(receipt.receiptDate),
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    receipt.description,
                                    maxLines: 2,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    'Rs. ${receipt.amount.toStringAsFixed(2)}',
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(receipt.byUserName),
                                ),
                              ],
                            );
                          }),

                          // Total payments row
                          pw.TableRow(
                            decoration: const pw.BoxDecoration(
                                color: PdfColors.grey100),
                            children: [
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'TOTAL PAYMENTS',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.Container(),
                              pw.Container(),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  'Rs. ${calculateTotalPayments(receiptList)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.Container(),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 30),
                    ],

                    // Summary section
                    pw.Container(
                      padding: const pw.EdgeInsets.all(15),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey100,
                        border: pw.Border.all(color: PdfColors.grey),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Summary',
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Total Invoice Amount:'),
                              pw.Text(
                                'Rs. ${calculateTotalAmount(quotationList)}',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                          if (receiptList.isNotEmpty)
                            pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Total Payments Received:'),
                                pw.Text(
                                  'Rs. ${calculateTotalPayments(receiptList)}',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold),
                                ),
                              ],
                            ),
                          pw.Divider(),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Outstanding Balance:',
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'Rs. ${calculateOutstandingBalance(quotationList, receiptList)}',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: getOutstandingBalanceColor(
                                      quotationList, receiptList),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ))
          ];
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
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

Future<void> _addIvsFirstPage(
  pw.Document pdf,
  LeadDetails? customerDetails,
  List<QuatationListModel> quotationList,
) async {
  try {
    // Load image from assets (replace with your actual image path)
    final ByteData imageData =
        await rootBundle.load('assets/images/solar_panels.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final pw.MemoryImage solarImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(50),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.green, width: 1),
            ),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Company Name
                  pw.Text(
                    "Futore.Nxt Systems",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    "The Complete Solar Solution",
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.black,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 12),

                  // Green Header Section
                  pw.Container(
                    width: double.infinity,
                    color: PdfColor.fromHex("#2E7D32"), // dark green
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text(
                          "SOLAR PHOTOVOLTAIC GRID TIE POWER PLANT",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "INVOICE SUMMARY",
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "Client: ${customerDetails?.customerName ?? 'N/A'}",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.Text(
                          "DATE: ${_formatDate(DateTime.now().toString())}",
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.white,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 12),

                  // Solar Image
                  pw.Image(solarImage, fit: pw.BoxFit.contain, height: 650),
                  pw.SizedBox(height: 20),

                  // Footer Details
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        "Futore.NXT Systems LLP",
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "Door No 11/190H, LeenaTower,\nAvoly, Muvattupuzha, KERALA-686670",
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.Text(
                        "Ph: 0485-2997598, Mob: 7907024527, 9447776598",
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.UrlLink(
                        destination: "mailto:futore.nxt@gmail.com",
                        child: pw.Text(
                          "E Mail: futore.nxt@gmail.com",
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 12),
                    ],
                  ),

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        "PAGE 1",
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  } catch (e) {
    print('FirstPage error: $e');
  }
}

String _formatDate(String dateString) {
  try {
    if (dateString.isEmpty) return 'N/A';
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  } catch (e) {
    return dateString;
  }
}
