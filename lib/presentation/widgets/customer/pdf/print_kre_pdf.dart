import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

pw.MemoryImage? logo;
pw.MemoryImage? qr;

Future<void> generateAndPrintPDFs({
  required BuildContext context,
  required GetQuotationbyMasterIdmodel quotationData,
  required Company companyDetails,
  required LeadDetails customerDetails,
}) async {
  try {
    final pw.Document pdf = pw.Document();
    logo = await fetchLogoFromAsset("assets/images/logo_2.png");

    // logo = await _fetchLogo(HttpUrls.imgBaseUrl + companyDetails.logo);
    // qr = await fetchLogoFromAsset("assets/images/logo_2.png");

    await _addMultiPage(pdf, quotationData, customerDetails, companyDetails);

    final Uint8List pdfBytes = await pdf.save();
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
      name: "",
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

Future<void> _addMultiPage(
  pw.Document pdf,
  GetQuotationbyMasterIdmodel quotationData,
  LeadDetails customerDetails,
  Company companyDetails,
) async {
  double amount = double.tryParse(quotationData.netTotal) ?? 0.0;
  String amountInWords = convertNumberToWords(amount);

  pdf.addPage(
    pw.MultiPage(
      margin: const pw.EdgeInsets.all(35),
      pageFormat: PdfPageFormat.a4,
      header: (context) => _buildHeader(companyDetails, quotationData),
      build: (pw.Context context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildQuotationHeader(
                quotationData, customerDetails, companyDetails),
            pw.SizedBox(height: 15),
            _buildItemsTable(quotationData.quotationDetails, quotationData),
            pw.SizedBox(height: 15),
            _buildTotalSummary(quotationData, amountInWords, companyDetails),
            pw.SizedBox(height: 10),
            _buildBankDetails(companyDetails),
            pw.SizedBox(height: 15),
            pw.Container(
              height: 1,
              color: PdfColors.grey300,
            ),
            pw.SizedBox(height: 10),
            pw.Text('Terms & Conditions',
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            _buildTermsList(quotationData.termsAndConditions, companyDetails),
            pw.SizedBox(height: 20),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildHeader(
    Company companyDetails, GetQuotationbyMasterIdmodel quotationData) {
  return pw.Column(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Logo
          pw.Image(logo!, width: 80, height: 60, fit: pw.BoxFit.contain),

          pw.Spacer(),

          // Right Side (Quotation info)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              // Top Row (Quotation + Number)
              pw.Container(
                width: 250,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'QUOTATION',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      quotationData.quotationNo,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
    ],
  );
}

pw.Widget _buildQuotationHeader(GetQuotationbyMasterIdmodel quotationData,
    LeadDetails customerDetails, Company companyDetails) {
  // Build company address from Company model
  List<String> addressParts = [];
  if (companyDetails.address1.isNotEmpty)
    addressParts.add(companyDetails.address1);
  if (companyDetails.address2.isNotEmpty)
    addressParts.add(companyDetails.address2);
  if (companyDetails.address3.isNotEmpty)
    addressParts.add(companyDetails.address3);
  if (companyDetails.address4.isNotEmpty)
    addressParts.add(companyDetails.address4);

  String companyAddress = addressParts.join(', ');

  // Build customer address from LeadDetails model
  List<String> customerAddressParts = [];
  if (customerDetails.address.isNotEmpty)
    customerAddressParts.add(customerDetails.address);
  if (customerDetails.address1?.isNotEmpty == true)
    customerAddressParts.add(customerDetails.address1!);
  if (customerDetails.address2?.isNotEmpty == true)
    customerAddressParts.add(customerDetails.address2!);
  if (customerDetails.location.isNotEmpty)
    customerAddressParts.add(customerDetails.location);

  String customerAddress = customerAddressParts.join(', ');
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Left side: Company details
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 10),
            pw.Text('3rd Eye Security Systems',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            pw.SizedBox(height: 4),
            pw.Text(
              companyAddress,
              style: pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 2),
            pw.Text(companyDetails.mobileNumber,
                style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 2),
            pw.Text(
                companyDetails.email.isNotEmpty
                    ? companyDetails.email
                    : "hello@3rdeyess.com",
                style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Row(children: [
              pw.Text('GSTIN: ',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  companyDetails.gstNo.isNotEmpty
                      ? companyDetails.gstNo
                      : '32A48J7775OP1ZT',
                  style: pw.TextStyle(fontSize: 10))
            ]),
            pw.Row(children: [
              pw.Text('MSME: ',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('UDYAM-KL-13-0006367', style: pw.TextStyle(fontSize: 10))
            ]),
            pw.Row(children: [
              pw.Text('PAN: ',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  companyDetails.panNo.isNotEmpty
                      ? companyDetails.panNo
                      : "AABFZ7710P",
                  style: pw.TextStyle(fontSize: 10))
            ]),
            pw.SizedBox(height: 2),
            pw.Row(children: [
              pw.Text('Website: ',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  companyDetails.website.isNotEmpty
                      ? companyDetails.website
                      : "www.3rdeyess.com",
                  style: pw.TextStyle(fontSize: 10))
            ]),
            pw.Row(children: [
              pw.Text('Contact Name: ',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              pw.Text('Aslam Basheer', style: pw.TextStyle(fontSize: 10))
            ]),
            pw.SizedBox(height: 15),
            pw.Text('Quote To',
                style:
                    pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            pw.Text(customerDetails.customerName.toUpperCase(),
                style:
                    pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              customerAddress,
              maxLines: 2,
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),

      // Right side: Amount Due + Dates
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            // Blue Amount Due box
            pw.Container(
              width: 250,
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1f4e79'),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Amount Due:',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'INR ${quotationData.netTotal ?? "0.00"}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Dates and Place of Supply
            pw.Container(
              width: 180,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Issue Date:', style: pw.TextStyle(fontSize: 10)),
                      pw.Text('Valid Until:',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Text('Place of Supply:',
                          style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          quotationData.entryDate?.toDDMMYYYY() ??
                              '09 / 09 / 2025',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Text('24 / 09 / 2025',
                          style: pw.TextStyle(fontSize: 10)),
                      pw.Text('KL(32)', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildItemsTable(List<QuotationDetail> materials,
    GetQuotationbyMasterIdmodel quotationData) {
  final headers = [
    'S.No',
    'Item\nDescription',
    'HSN/SAC',
    'Qty\nUoM',
    'Price\n(INR)',
    'Taxable Value\n(INR)',
    'CGST\n(INR)',
    'SGST\n(INR)',
    'Amount\n(INR)'
  ];

  final columnWidths = <int, pw.TableColumnWidth>{
    0: const pw.FixedColumnWidth(30), // S.No
    1: const pw.FlexColumnWidth(4), // Item Description
    2: const pw.FixedColumnWidth(60), // HSN/SAC
    3: const pw.FixedColumnWidth(40), // Qty/UoM
    4: const pw.FixedColumnWidth(60), // Price
    5: const pw.FixedColumnWidth(70), // Taxable Value
    6: const pw.FixedColumnWidth(50), // CGST
    7: const pw.FixedColumnWidth(50), // SGST
    8: const pw.FixedColumnWidth(60), // Amount
  };

  // Calculate totals from quotation data
  double totalTaxableValue = double.tryParse(quotationData.taxableAmount) ?? 0;
  double totalCGST = (double.tryParse(quotationData.gstAmount) ?? 0) / 2;
  double totalSGST = (double.tryParse(quotationData.gstAmount) ?? 0) / 2;
  double totalAmount = double.tryParse(quotationData.totalAmount) ?? 0;

  final data = materials.asMap().entries.map((entry) {
    int index = entry.key + 1;
    QuotationDetail item = entry.value;

    double taxableValue = (item.unitPrice ?? 0) * (item.quantity ?? 0);
    double cgstAmount = (item.GST ?? 0) / 2;
    double sgstAmount = (item.GST ?? 0) / 2;
    double amount = item.amount ?? 0;

    return [
      index.toString(),
      item.itemName ?? '',
      '85176290', // Default HSN - you might want to add this to QuotationDetail model
      '${item.quantity ?? 1}\n${item.Unit ?? 'PCS'}',
      '${(item.unitPrice ?? 0).toStringAsFixed(2)}',
      '${taxableValue.toStringAsFixed(2)}',
      '${((item.GSTPercent ?? 0) / 2).toStringAsFixed(1)}%\n${cgstAmount.toStringAsFixed(2)}',
      '${((item.GSTPercent ?? 0) / 2).toStringAsFixed(1)}%\n${sgstAmount.toStringAsFixed(2)}',
      '${amount.toStringAsFixed(2)}',
    ];
  }).toList();

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 1),
    ),
    child: pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: columnWidths,
      children: [
        // Header Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#1f4e79')),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: headers
              .asMap()
              .entries
              .map((entry) => pw.Container(
                    height: 40,
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 4, vertical: 3),
                    child: pw.Align(
                      alignment: entry.key == 1
                          ? pw.Alignment.centerLeft
                          : entry.key == 0
                              ? pw.Alignment.center
                              : pw.Alignment.centerRight,
                      child: pw.Text(
                        entry.value,
                        textAlign: entry.key == 1
                            ? pw.TextAlign.left
                            : entry.key == 0
                                ? pw.TextAlign.center
                                : pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        // Data Rows
        ...data.asMap().entries.map(
              (entry) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key.isEven
                      ? PdfColors.white
                      : PdfColor.fromHex('#F8F9FA'),
                ),
                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: entry.value
                    .asMap()
                    .entries
                    .map(
                      (cellEntry) => pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 4, vertical: 6),
                        constraints: const pw.BoxConstraints(minHeight: 30),
                        child: pw.Align(
                          alignment: cellEntry.key == 1
                              ? pw.Alignment.centerLeft
                              : cellEntry.key == 0
                                  ? pw.Alignment.center
                                  : pw.Alignment.centerRight,
                          child: pw.Text(
                            cellEntry.value.toString(),
                            textAlign: cellEntry.key == 1
                                ? pw.TextAlign.left
                                : cellEntry.key == 0
                                    ? pw.TextAlign.center
                                    : pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: cellEntry.key == 1
                                  ? pw.FontWeight.bold
                                  : pw.FontWeight.normal,
                              color: cellEntry.key == 1
                                  ? PdfColor.fromHex(
                                      '#26597F') // Item Description rows
                                  : PdfColors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        // Total Row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E8F4FD')),
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Text(''),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Text(
                'Total @${quotationData.gstPer ?? "18"}%',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Text(''),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Text(''),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Text(''),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${totalTaxableValue.toStringAsFixed(2)}',
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${totalCGST.toStringAsFixed(2)}',
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${totalSGST.toStringAsFixed(2)}',
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '${totalAmount.toStringAsFixed(2)}',
                  style:
                      pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildTotalSummary(
  GetQuotationbyMasterIdmodel quotationData,
  String amountInWords,
  Company companyDetails,
) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Left side - Bank Details
      pw.Expanded(
        flex: 2,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('Account Holder Name: ',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('3rd Eye Security Systems',
                    style: pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                pw.Text('Bank Name: ',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('FEDERAL BANK', style: pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                pw.Text('Account Number: ',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('19720000000231', style: pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                pw.Text('Branch Name: ',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('CHITTILAPPILLY', style: pw.TextStyle(fontSize: 9)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              children: [
                pw.Text('IFSC Code: ',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('FDRL0001972', style: pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),

      pw.SizedBox(width: 30),

      // Right side - Total calculations without borders, just aligned text
      pw.Expanded(
        flex: 3,
        child: pw.Column(
          children: [
            // Each row with proper alignment
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Taxable Value',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('INR 24,330.00',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Tax Amount',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('INR 4,379.40',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Rounded Off',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('(-) INR 0.40',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Value (in figure)',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Text('INR 28,709',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Total Value (in words)',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(
                  child: pw.Text(
                    'INR Twenty-eight Thousand Seven Hundred Nine Only',
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget _buildBankDetails(
  Company companyDetails,
) {
  return pw.Container(); // Bank details are now included in _buildTotalSummary
}

pw.Widget _buildTermsList(
  String terms,
  Company companyDetails,
) {
  List<String> termsList = terms.isNotEmpty
      ? terms.split('\n')
      : [
          'WIRING CHARGES EXTRA.',
          '3 YEAR WARRANTY',
          'POWER CONNECTION SHOULD BE PROVIDED BY PARTY.',
          'WARRANTY AS PER MANUFACTURERS POLICY ONLY.',
          'WARRANTY DOES NOT COVER DAMAGES DUE TO NATURAL CALAMITIES, LIGHTNING, TAMPERING AND UNAUTHORIZED SERVICE.',
          '',
          'PAYMENT TERMS:',
          '>75% ADVANCE ON PLACING WORK ORDER',
          '>25% AFTER INSTALLATION, TESTING & COMMISSIONING.',
          '>VIOLATION IN PAYMENT TERMS WILL LEAD TO CANCELLATION OF AMC.',
        ];

  return pw.Container(
    width: double.infinity,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left side - Terms & Conditions
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 8),
              ...termsList.map((term) {
                if (term.isEmpty) {
                  return pw.SizedBox(height: 8);
                }
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                    term,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: term.contains('PAYMENT TERMS:')
                          ? pw.FontWeight.normal
                          : pw.FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),

        pw.SizedBox(width: 20),

        // Middle - For 3rd Eye Security Systems
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 60),
              pw.Container(
                height: 1,
                width: 120,
                color: PdfColors.grey300,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'For 3rd Eye Security\nSystems',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),

        pw.SizedBox(width: 20),

        // Right side - Customer Signature
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 60),
              pw.Container(
                height: 1,
                width: 100,
                color: PdfColors.grey300,
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Customer Signature',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<pw.MemoryImage> _fetchLogo(String logoUrl) async {
  final response = await http.get(Uri.parse(logoUrl));
  if (response.statusCode == 200) {
    final imageBytes = response.bodyBytes;
    return pw.MemoryImage(imageBytes);
  } else {
    throw Exception('Failed to load logo');
  }
}

Future<pw.MemoryImage> fetchLogoFromAsset(String assetPath) async {
  final ByteData bytes = await rootBundle.load(assetPath);
  return pw.MemoryImage(bytes.buffer.asUint8List());
}

String convertNumberToWords(double number) {
  // Define word lists
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

  // For zero amount
  if (number == 0) return "Zero";

  int intNumber = number.floor();
  String words = '';

  // Handle crores (up to 100 crore)
  if (intNumber >= 10000000) {
    int crores = (intNumber ~/ 10000000);
    words += "${_convertSmallNumber(crores)} Crore ";
    intNumber %= 10000000;
  }

  // Handle lakhs
  if (intNumber >= 100000) {
    int lakhs = (intNumber ~/ 100000);
    words += "${_convertSmallNumber(lakhs)} Lakh ";
    intNumber %= 100000;
  }

  // Handle thousands
  if (intNumber >= 1000) {
    int thousands = (intNumber ~/ 1000);
    words += "${_convertSmallNumber(thousands)} Thousand ";
    intNumber %= 1000;
  }

  // Handle hundreds
  if (intNumber >= 100) {
    words += "${units[intNumber ~/ 100]} Hundred ";
    intNumber %= 100;
  }

  // Handle remaining number
  if (intNumber > 0) {
    if (words.isNotEmpty && !words.trim().endsWith('Hundred')) {
      words += "and ";
    }
    if (intNumber < 20) {
      words += units[intNumber];
    } else {
      words += tens[intNumber ~/ 10];
      if (intNumber % 10 > 0) {
        words += " ${units[intNumber % 10]}";
      }
    }
  }

  return words.trim();
}

// Helper function to convert small numbers (less than 100)
String _convertSmallNumber(int number) {
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

  if (number < 20) {
    return units[number];
  } else {
    if (number % 10 == 0) {
      return tens[number ~/ 10];
    } else {
      return "${tens[number ~/ 10]} ${units[number % 10]}";
    }
  }
}
