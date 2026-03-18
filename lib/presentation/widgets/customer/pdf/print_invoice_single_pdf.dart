import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../../../../controller/invoice_tab_provider.dart';
import '../../../../controller/models/invoice_print_item_model.dart';
import '../../../../controller/models/invoice_tab_model.dart';
import '../../../../controller/models/hsn_model.dart';

LeadDetails? customer;
GetQuotationbyMasterIdmodel? quotation;
InvoiceTabModel? invoice;
List<InvoicePrintItemModel> invoicePrint = [];
ItemListModel? item;
LeadDetails? leadDetailModel;
HSNResponse? hsnDetails;
Future<void> invoiceSinglePDFPrint({
  required BuildContext context,
  required LeadDetails? customerDetails,
  required InvoiceTabModel? invoiceDetails,
}) async {
  try {
    // Use the passed invoice details directly
    customer = customerDetails;
    invoice = invoiceDetails;
    final logoImageBytes =
        await rootBundle.load(AppStyles.logo());
    final logoImage = pw.MemoryImage(logoImageBytes.buffer.asUint8List());

    final sealBytes = await rootBundle.load(AppStyles.logo());
    final sealImage = pw.MemoryImage(sealBytes.buffer.asUint8List());
    // Only fetch additional data if needed (like HSN details)
    final invoiceProvider =
        Provider.of<InvoiceTabProvider>(context, listen: false);

    // Only fetch HSN details if you really need them
    if (invoiceDetails?.invoiceMasterId != null) {
      await invoiceProvider.getHSNDetails(
          invoiceDetails!.invoiceMasterId, context);
      hsnDetails = invoiceProvider.hsnDetails;
    }

    final pw.Document pdf = pw.Document();

    // Use the invoice items directly from the passed invoiceDetails
    final List<InvoiceItemModel> itemsToUse =
        invoiceDetails?.invoiceItems ?? [];

    print('Items to use in PDF: ${itemsToUse.length}');
    for (var item in itemsToUse) {
      print('Item: ${item.itemName}, Amount: ${item.amount}');
    }

    await _addIvsFirstPage(pdf, itemsToUse, logoImage, sealImage);

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
    List<InvoiceItemModel> invoiceItems,
    pw.ImageProvider logoImage,
    pw.ImageProvider sealImage) async {
  final pw.Font regularFont = await PdfGoogleFonts.robotoRegular();
  final pw.Font boldFont = await PdfGoogleFonts.robotoBold();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(regularFont, boldFont, logoImage),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildItemsTable(regularFont, boldFont, invoiceItems),
                  _buildAmountInWords(regularFont, boldFont),
                  _buildTaxSummary(regularFont, boldFont),
                  _buildtAXAmountInWords(regularFont, boldFont),
                  _buildFooterRow(regularFont, boldFont, sealImage),
                  pw.SizedBox(height: 4),
                  _buildBottomText(regularFont, boldFont),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

pw.Widget _buildHeader(
    pw.Font regularFont, pw.Font boldFont, pw.ImageProvider logoImage) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                  right: pw.BorderSide(color: PdfColors.black, width: 1)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Company section - reduced padding
                pw.Container(
                  padding: const pw.EdgeInsets.all(6), // Reduced from 8
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColors.black, width: 1)),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          border:
                              pw.Border.all(color: PdfColors.orange, width: 2),
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.ClipRRect(
                          child: pw.Image(
                            logoImage,
                            fit: pw.BoxFit.contain,
                            width: 36,
                            height: 36,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8), // Reduced from 10
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'FUTORE.NXT SYSTEMS LLP',
                              style: pw.TextStyle(font: boldFont, fontSize: 11),
                            ),
                            pw.Text('DOOR NO 11/190H,',
                                style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 8)), // Reduced from 9
                            pw.Text('LEENA TOWER,AVOLY-686670',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                            pw.Text('Ph: 0485-2997598,7025041100',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                            pw.Text('MSME No. UDYAM-KL-02-0012231',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                            pw.Text('GSTIN/UIN: 32AAFFF9231P1Z5',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                            pw.Text('State Name : Kerala, Code : 32',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                            pw.Text('E-Mail : futore.nxt@gmail.com',
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Customer details section - reduced padding
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Consignee (Ship to)
                    pw.Container(
                      width: 250,
                      padding: const pw.EdgeInsets.all(6), // Reduced from 8
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Consignee (Ship to)',
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 9)), // Reduced from 10
                          pw.SizedBox(height: 3), // Reduced from 4
                          pw.Text(
                              (invoice?.customerName.isNotEmpty ?? false)
                                  ? invoice!.customerName
                                  : (customer?.customerName ?? ''),
                              style: pw.TextStyle(
                                  font: boldFont,
                                  fontSize: 8)), // Reduced from 9
                          if ((invoice?.shippingAddress.isNotEmpty ?? false))
                            pw.Text(invoice!.shippingAddress,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8))
                          else ...[
                            if ((customer?.address ?? '').isNotEmpty)
                              pw.Text(customer!.address,
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            if ((customer?.address1 ?? '').isNotEmpty)
                              pw.Text(customer!.address1!,
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            if ((customer?.address2 ?? '').isNotEmpty)
                              pw.Text(customer!.address2!,
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            if ((customer?.address3 ?? '').isNotEmpty)
                              pw.Text(customer!.address3!,
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            if ((customer?.address4 ?? '').isNotEmpty)
                              pw.Text(customer!.address4!,
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            if (((customer?.location ?? '').isNotEmpty) ||
                                ((customer?.pinCode ?? '').isNotEmpty))
                              pw.Text(
                                  [customer?.location, customer?.pinCode]
                                      .where((e) => (e ?? '').isNotEmpty)
                                      .join('-'),
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                          ],
                        ],
                      ),
                    ),
                    // Buyer (Bill to)
                    pw.Container(
                      padding: const pw.EdgeInsets.all(6), // Reduced from 8
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Buyer (Bill to)',
                              style: pw.TextStyle(font: boldFont, fontSize: 9)),
                          pw.SizedBox(height: 3),
                          pw.Text(
                              (invoice?.customerName.isNotEmpty ?? false)
                                  ? invoice!.customerName
                                  : (customer?.customerName ?? ''),
                              style: pw.TextStyle(font: boldFont, fontSize: 8)),
                          if ((invoice?.shippingAddress.isNotEmpty ?? false))
                            pw.Text(
                              invoice!.shippingAddress,
                              style:
                                  pw.TextStyle(font: regularFont, fontSize: 8),
                            )
                          else ...[
                            if ((customer?.address ?? '').isNotEmpty)
                              pw.Text(
                                customer!.address,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                            if ((customer?.address1 ?? '').isNotEmpty)
                              pw.Text(
                                customer!.address1!,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                            if ((customer?.address2 ?? '').isNotEmpty)
                              pw.Text(
                                customer!.address2!,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                            if ((customer?.address3 ?? '').isNotEmpty)
                              pw.Text(
                                customer!.address3!,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                            if ((customer?.address4 ?? '').isNotEmpty)
                              pw.Text(
                                customer!.address4!,
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                            if (((customer?.location ?? '').isNotEmpty) ||
                                ((customer?.pinCode ?? '').isNotEmpty))
                              pw.Text(
                                [customer?.location, customer?.pinCode]
                                    .where((e) => (e ?? '').isNotEmpty)
                                    .join('-'),
                                style: pw.TextStyle(
                                    font: regularFont, fontSize: 8),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Right side table - reduced height
        pw.Expanded(
          flex: 3,
          child: pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.black),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Invoice No.',
                                style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 8), // Reduced from 9
                              ),
                              pw.Text(invoice?.invoiceNumber ?? '',
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            ]),
                        pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                'e-Way Bill No.',
                                style:
                                    pw.TextStyle(font: boldFont, fontSize: 8),
                              ),
                              pw.Text(invoice?.ewayInvoiceNo ?? '',
                                  style: pw.TextStyle(
                                      font: regularFont, fontSize: 8)),
                            ]),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Dated',
                            style: pw.TextStyle(font: boldFont, fontSize: 8),
                          ),
                          pw.Text(invoice?.dated ?? '',
                              style:
                                  pw.TextStyle(font: regularFont, fontSize: 8)),
                        ]),
                  ),
                ],
              ),
              pw.TableRow(children: [
                _buildHeaderDetailCell('Delivery Note',
                    invoice?.deliveryNoteDate ?? '', regularFont, boldFont),
                _buildHeaderDetailCell('Mode/Terms of Payment',
                    invoice?.modeOfPayment ?? '', regularFont, boldFont),
              ]),
              pw.TableRow(children: [
                _buildHeaderDetailCell(
                    'Reference No. & Date.',
                    "${invoice?.referenceNo},${invoice?.referenceDate}",
                    regularFont,
                    boldFont),
                _buildHeaderDetailCell('Other References',
                    '${invoice?.othetReference}', regularFont, boldFont),
              ]),
              pw.TableRow(children: [
                _buildHeaderDetailCell('Buyer\'s Order No.',
                    invoice?.buyerOrderNo ?? '', regularFont, boldFont),
                _buildHeaderDetailCell(
                    'Dated', invoice?.dated ?? '', regularFont, boldFont),
              ]),
              pw.TableRow(children: [
                _buildHeaderDetailCell('Dispatch Doc No.',
                    invoice?.dispatchedDocumentNo ?? '', regularFont, boldFont),
                _buildHeaderDetailCell('Delivery Note Date',
                    invoice?.deliveryNoteDate ?? '', regularFont, boldFont),
              ]),
              pw.TableRow(children: [
                _buildHeaderDetailCell('Dispatched through',
                    invoice?.dispatchedThrough ?? '', regularFont, boldFont),
                _buildHeaderDetailCell('Destination',
                    invoice?.destination ?? '', regularFont, boldFont),
              ]),
              pw.TableRow(children: [
                _buildHeaderDetailCell('Bill of Lading/LR-RR No.',
                    invoice?.billOfLading ?? '', regularFont, boldFont),
                _buildHeaderDetailCell('Motor Vehicle No.',
                    invoice?.motorVehicleNo ?? '', regularFont, boldFont),
              ]),
              pw.TableRow(
                children: [
                  pw.Container(
                    height: 70,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(width: 0.5, color: PdfColors.black),
                        left: pw.BorderSide(width: 0.5, color: PdfColors.black),
                        right:
                            pw.BorderSide(width: 0.5, color: PdfColors.black),
                        bottom: pw.BorderSide.none,
                      ),
                    ),
                    child: pw.Align(
                        alignment: pw.Alignment.topLeft,
                        child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Terms of Delivery',
                                style: pw.TextStyle(
                                    font: boldFont,
                                    fontSize: 8), // Reduced from 9
                              ),
                              pw.Text(
                                invoice?.termsOfDelivery ?? '',
                                style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 8), // Reduced from 9
                              ),
                            ])),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    ),
  );
}

// Optimized footer with reduced height
pw.Widget _buildFooterRow(
    pw.Font regularFont, pw.Font boldFont, pw.ImageProvider sealImage) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        flex: 2,
        child: pw.Container(
          height: 112,

          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          padding: const pw.EdgeInsets.all(6), // Reduced from 8
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Company's Bank Details",
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 9)), // Reduced from 10
              pw.SizedBox(height: 3), // Reduced from 4
              pw.Text('A/c Holder\'s Name  : FUTORE.NXT SYSTEMS LLP',
                  style: pw.TextStyle(
                      font: regularFont, fontSize: 8)), // Reduced from 9
              pw.Text('Bank Name          : STATE BANK OF INDIA OD A/c SME',
                  style: pw.TextStyle(font: regularFont, fontSize: 8)),
              pw.Text('A/c No.            : 44226173458',
                  style: pw.TextStyle(font: regularFont, fontSize: 8)),
              pw.Text('Branch & IFS Code  : SME MUVATTUPUZHA & SBIN0063658',
                  style: pw.TextStyle(font: regularFont, fontSize: 8)),
              pw.Text('SWIFT Code         :',
                  style: pw.TextStyle(font: regularFont, fontSize: 8)),
              pw.SizedBox(height: 4), // Reduced from 8
              pw.Text('Declaration',
                  style: pw.TextStyle(
                      font: boldFont, fontSize: 8)), // Reduced from 9
              pw.Text(
                  'We declare that this invoice shows the actual price of the',
                  style: pw.TextStyle(
                      font: regularFont, fontSize: 7)), // Reduced from 8
              pw.Text(
                  'goods described and that all particulars are true and correct.',
                  style: pw.TextStyle(font: regularFont, fontSize: 7)),
            ],
          ),
        ),
      ),
      pw.Expanded(
        flex: 1,
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          padding: const pw.EdgeInsets.all(6), // Reduced from 8
          height: 112, // Reduced from 150
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('for FUTORE.NXT SYSTEMS LLP',
                  style: pw.TextStyle(
                      font: regularFont, fontSize: 8)), // Reduced from 9
              pw.Container(
                width: 80, // Reduced from 80
                height: 60, // Reduced from 80

                child: pw.ClipOval(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(
                        4), // Small padding inside the circle
                    child: pw.Image(
                      sealImage,
                      fit: pw.BoxFit.fill,
                      width: 80, // Reduced from 80
                      height: 60, // Reduced from 80
                    ),
                  ),
                ),
              ),
              pw.Text('Authorised Signatory',
                  style: pw.TextStyle(font: regularFont, fontSize: 8)),
            ],
          ),
        ),
      ),
    ],
  );
}

// Updated header detail cell with reduced height
pw.Widget _buildHeaderDetailCell(
  String label,
  String value,
  pw.Font regularFont,
  pw.Font boldFont,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(
        horizontal: 3, vertical: 2), // Reduced padding
    height: 22, // Reduced from 28
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(label,
            style:
                pw.TextStyle(font: regularFont, fontSize: 6)), // Reduced from 7
        pw.SizedBox(height: 1), // Reduced from 2
        pw.Text(
          value,
          style: pw.TextStyle(
            font: value.isNotEmpty ? boldFont : regularFont,
            fontSize: 6, // Reduced from 7
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildItemsTable(pw.Font regularFont, pw.Font boldFont,
    List<InvoiceItemModel> invoiceItems) {
  double parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
  }

  String formatAmount(double value) {
    return value.toStringAsFixed(2);
  }

  bool isConsumable(InvoiceItemModel item) {
    final name = item.itemName.toLowerCase();
    return name.contains('consumable') || name.contains('installation');
  }

  final List<InvoiceItemModel> goodsItems =
      invoiceItems.where((i) => !isConsumable(i)).toList();

  final InvoiceItemModel? consumableItem =
      invoiceItems.where((i) => isConsumable(i)).isNotEmpty
          ? invoiceItems.firstWhere((i) => isConsumable(i))
          : null;

  // Calculate subtotal using 'amount' field from each item
  final double subtotalGoodsAmount =
      goodsItems.fold(0.0, (sum, item) => sum + parseDouble(item.amount));

  final double totalQuantity =
      goodsItems.fold(0.0, (sum, item) => sum + parseDouble(item.quantity));

  // Calculate total using all items' 'amount' field
  final double subtotalAllAmount =
      invoiceItems.fold(0.0, (sum, item) => sum + parseDouble(item.amount));

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    child: pw.Table(
      border: const pw.TableBorder(
        left: pw.BorderSide.none,
        right: pw.BorderSide.none,
        top: pw.BorderSide.none,
        bottom: pw.BorderSide.none,
        horizontalInside: pw.BorderSide.none,
        verticalInside: pw.BorderSide(width: 0.5, color: PdfColors.black),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(30), // SI No
        1: const pw.FlexColumnWidth(3), // Description
        2: const pw.FixedColumnWidth(70), // HSN/SAC
        3: const pw.FixedColumnWidth(60), // Quantity
        4: const pw.FlexColumnWidth(2), // Rate
        5: const pw.FixedColumnWidth(40), // per
        6: const pw.FixedColumnWidth(80), // Amount
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey100,
            border: pw.Border(
              top: pw.BorderSide(width: 0.5, color: PdfColors.black),
              bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
              left: pw.BorderSide(width: 0.5, color: PdfColors.black),
              right: pw.BorderSide(width: 0.5, color: PdfColors.black),
            ),
          ),
          children: [
            _buildTableHeaderCell('SI\nNo.', boldFont),
            _buildTableHeaderCell('Description of Goods', boldFont),
            _buildTableHeaderCell('HSN/SAC', boldFont),
            _buildTableHeaderCell('Quantity', boldFont),
            _buildTableHeaderCell('Rate\n', boldFont),
            _buildTableHeaderCell('per', boldFont),
            _buildTableHeaderCell('Amount', boldFont),
          ],
        ),
        // Dynamic item rows (goods only)
        ...goodsItems.asMap().entries.map((entry) {
          final int index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableDataCell('${index + 1}', regularFont,
                  alignment: pw.Alignment.center),
              _buildTableDataCell(item.itemName, regularFont,
                  alignment: pw.Alignment.centerLeft),
              _buildTableDataCell(item.hsnCode, regularFont,
                  alignment: pw.Alignment.center),
              _buildTableDataCell(item.quantity, regularFont,
                  alignment: pw.Alignment.center),
              _buildTableDataCell(item.rate, regularFont,
                  alignment: pw.Alignment.centerRight),
              _buildTableDataCell('nos', regularFont,
                  alignment: pw.Alignment.center),
              // Show the 'amount' field (base amount without GST)
              _buildTableDataCell(item.amount, regularFont,
                  alignment: pw.Alignment.centerRight),
            ],
          );
        }),
        // Subtotal row
        pw.TableRow(
          children: [
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            // _buildTableDataCell(_formatAmount(subtotalGoodsAmount), regularFont,
            //     alignment: pw.Alignment.centerRight),
          ],
        ),
        // Consumable item row (if exists)
        if (consumableItem != null)
          pw.TableRow(
            children: [
              _buildTableDataCell('', regularFont),
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(consumableItem.itemName,
                        style: pw.TextStyle(font: boldFont, fontSize: 9)),
                  ],
                ),
              ),
              _buildTableDataCell(consumableItem.hsnCode, regularFont,
                  alignment: pw.Alignment.center),
              _buildTableDataCell('', regularFont),
              _buildTableDataCell('', regularFont),
              _buildTableDataCell('', regularFont),
              // Show consumable amount
              _buildTableDataCell(consumableItem.amount, regularFont,
                  alignment: pw.Alignment.centerRight),
            ],
          ),
        // CGST row (empty for now)
        pw.TableRow(
          children: [
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
          ],
        ),
        // SGST row (empty for now)
        pw.TableRow(
          children: [
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
          ],
        ),
        // Round Off row (empty for now)
        pw.TableRow(
          children: [
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
          ],
        ),
        // Total row
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            border:
                pw.Border(top: pw.BorderSide(width: 2, color: PdfColors.black)),
          ),
          children: [
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell(
                'Total\n${totalQuantity.toStringAsFixed(0)} nos', boldFont,
                alignment: pw.Alignment.center),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell('', regularFont),
            _buildTableDataCell(
                '₹ ${formatAmount(subtotalAllAmount)}', boldFont,
                alignment: pw.Alignment.centerRight),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildTableHeaderCell(String text, pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    height: 35,
    child: pw.Center(
      child: pw.Text(text,
          style: pw.TextStyle(font: font, fontSize: 9),
          textAlign: pw.TextAlign.center),
    ),
  );
}

pw.Widget _buildTableDataCell(String text, pw.Font font,
    {pw.Alignment alignment = pw.Alignment.center}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: alignment,
    child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
  );
}

double _parseAmount(String? value) {
  if (value == null) return 0.0;
  return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
}

String _convertNumberToWordsIndian(int number) {
  if (number == 0) return 'Zero';

  const List<String> ones = [
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

  String twoDigits(int n) {
    if (n < 20) return ones[n];
    final t = n ~/ 10;
    final o = n % 10;
    return [tens[t], ones[o]].where((s) => s.isNotEmpty).join(' ');
  }

  String threeDigits(int n) {
    final h = n ~/ 100;
    final r = n % 100;
    final parts = <String>[];
    if (h > 0) parts.add('${ones[h]} Hundred');
    if (r > 0) parts.add(twoDigits(r));
    return parts.join(' ');
  }

  final parts = <String>[];
  final crore = number ~/ 10000000;
  number %= 10000000;
  final lakh = number ~/ 100000;
  number %= 100000;
  final thousand = number ~/ 1000;
  number %= 1000;
  final hundred = number;

  if (crore > 0) parts.add('${twoDigits(crore)} Crore');
  if (lakh > 0) parts.add('${twoDigits(lakh)} Lakh');
  if (thousand > 0) parts.add('${twoDigits(thousand)} Thousand');
  if (hundred > 0) parts.add(threeDigits(hundred));

  return parts.join(' ');
}

String _amountInWordsINR(double amount) {
  final rupees = amount.floor();
  // Ignoring paise for now as in the original static text
  final words = _convertNumberToWordsIndian(rupees);
  return 'INR $words Only';
}

// Updated _buildAmountInWords to match items table total
pw.Widget _buildAmountInWords(pw.Font regularFont, pw.Font boldFont) {
  // Calculate total from invoice items' amount field (base amount without GST)
  double totalBaseAmount = 0.0;
  if (invoice?.invoiceItems != null) {
    for (var item in invoice!.invoiceItems) {
      totalBaseAmount +=
          double.tryParse(item.amount.replaceAll(',', '')) ?? 0.0;
    }
  }

  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    padding: const pw.EdgeInsets.all(4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Amount Chargeable (in words)',
            style: pw.TextStyle(font: boldFont, fontSize: 8)),
        pw.Text(_amountInWordsINR(totalBaseAmount),
            style: pw.TextStyle(font: boldFont, fontSize: 8)),
        pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Text('E. & O.E',
              style: pw.TextStyle(font: regularFont, fontSize: 8)),
        ),
      ],
    ),
  );
}

pw.Widget _buildtAXAmountInWords(pw.Font regularFont, pw.Font boldFont) {
  return pw.Container(
    width: double.infinity,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    padding: const pw.EdgeInsets.all(4),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Tax amount (in words)',
            style: pw.TextStyle(font: boldFont, fontSize: 8)),
        pw.Text(_amountInWordsINR(_parseAmount(invoice?.totalGst)),
            style: pw.TextStyle(font: boldFont, fontSize: 8)),
        pw.Align(
          alignment: pw.Alignment.topRight,
          child: pw.Text('E. & O.E',
              style: pw.TextStyle(font: regularFont, fontSize: 8)),
        ),
      ],
    ),
  );
}

// New method for rate and amount cells
pw.Widget _buildTaxRateAmountCell(String rate, String amount, pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            rate,
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            amount,
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ),
      ],
    ),
  );
} // Tax summary table

pw.Widget _buildTaxSummary(pw.Font regularFont, pw.Font boldFont) {
  // Fallback-safe parser
  double p(String v) =>
      double.tryParse((v).toString().replaceAll(',', '')) ?? 0.0;

  final rows = <pw.TableRow>[];

  // Header row
  rows.add(
    pw.TableRow(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(width: 0.5, color: PdfColors.black),
      ),
      children: [
        _buildTaxHeaderCell('HSN/SAC', boldFont),
        _buildTaxHeaderCell('Taxable\nValue', boldFont),
        _buildTaxRateAmountHeaderCell('CGST', boldFont),
        _buildTaxRateAmountHeaderCell('SGST/UTGST', boldFont),
        _buildTaxHeaderCell('Total\nTax Amount', boldFont),
      ],
    ),
  );

  double totalTaxable = 0.0;
  double totalCgst = 0.0;
  double totalSgst = 0.0;

  // Group items by HSN code and calculate totals
  Map<String, Map<String, dynamic>> hsnGroups = {};

  if (invoice?.invoiceItems != null) {
    for (var item in invoice!.invoiceItems) {
      String hsnCode = item.hsnCode;
      double amount = p(item.amount);
      double cgstAmount = p(item.cgstAmount);
      double sgstAmount = p(item.sgstAmount);
      String cgstRate = item.cgst;
      String sgstRate = item.sgst;

      if (hsnGroups.containsKey(hsnCode)) {
        hsnGroups[hsnCode]!['amount'] += amount;
        hsnGroups[hsnCode]!['cgstAmount'] += cgstAmount;
        hsnGroups[hsnCode]!['sgstAmount'] += sgstAmount;
      } else {
        hsnGroups[hsnCode] = {
          'amount': amount,
          'cgstAmount': cgstAmount,
          'sgstAmount': sgstAmount,
          'cgstRate': cgstRate,
          'sgstRate': sgstRate,
        };
      }
    }
  }

  // Create rows for each HSN group
  hsnGroups.forEach((hsnCode, data) {
    double taxable = data['amount'];
    double cgstAmt = data['cgstAmount'];
    double sgstAmt = data['sgstAmount'];

    totalTaxable += taxable;
    totalCgst += cgstAmt;
    totalSgst += sgstAmt;

    rows.add(
      pw.TableRow(
        children: [
          _buildTaxDataCell(hsnCode, regularFont,
              alignment: pw.Alignment.center),
          _buildTaxDataCell(taxable.toStringAsFixed(2), regularFont,
              alignment: pw.Alignment.centerRight),
          _buildTaxRateAmountCell(
              '${data['cgstRate']}%', cgstAmt.toStringAsFixed(2), regularFont),
          _buildTaxRateAmountCell(
              '${data['sgstRate']}%', sgstAmt.toStringAsFixed(2), regularFont),
          _buildTaxDataCell((cgstAmt + sgstAmt).toStringAsFixed(2), regularFont,
              alignment: pw.Alignment.centerRight),
        ],
      ),
    );
  });

  // Totals row
  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(width: 2, color: PdfColors.black)),
      ),
      children: [
        _buildTaxDataCell('Total', boldFont, alignment: pw.Alignment.center),
        _buildTaxDataCell(totalTaxable.toStringAsFixed(2), boldFont,
            alignment: pw.Alignment.centerRight),
        _buildTaxDataCell(totalCgst.toStringAsFixed(2), boldFont,
            alignment: pw.Alignment.centerRight),
        _buildTaxDataCell(totalSgst.toStringAsFixed(2), boldFont,
            alignment: pw.Alignment.centerRight),
        _buildTaxDataCell((totalCgst + totalSgst).toStringAsFixed(2), boldFont,
            alignment: pw.Alignment.centerRight),
      ],
    ),
  );

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 1),
    ),
    child: pw.Table(
      border: pw.TableBorder(
        left: pw.BorderSide.none,
        right: pw.BorderSide.none,
        top: pw.BorderSide.none,
        bottom: pw.BorderSide.none,
        horizontalInside: pw.BorderSide.none,
        verticalInside: const pw.BorderSide(width: 0.5, color: PdfColors.black),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.2),
      },
      children: rows,
    ),
  );
}

pw.Widget _buildTaxHeaderCell(String text, pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    height: 30,
    child: pw.Center(
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 9),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
}

pw.Widget _buildTaxDataCell(String text, pw.Font font,
    {pw.Alignment? alignment}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: alignment ?? pw.Alignment.centerRight,
    child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
  );
}

// New method for tax header cells with rate and amount sub-headers
pw.Widget _buildTaxRateAmountHeaderCell(String mainText, pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    height: 30,
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          mainText,
          style: pw.TextStyle(font: font, fontSize: 9),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Rate',
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
            pw.Text(
              'Amount',
              style: pw.TextStyle(font: font, fontSize: 8),
            ),
          ],
        ),
      ],
    ),
  );
}

// Bottom text
pw.Widget _buildBottomText(pw.Font regularFont, pw.Font boldFont) {
  return pw.Column(
    children: [
      pw.Center(
        child: pw.Text('SUBJECT TO MUVATTUPUZHA JURISDICTION',
            style: pw.TextStyle(font: regularFont, fontSize: 10)),
      ),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Text('This is a Computer Generated Invoice',
            style: pw.TextStyle(font: regularFont, fontSize: 9)),
      ),
    ],
  );
}
