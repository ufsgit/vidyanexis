import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:http/http.dart' as http;

import 'package:vidyanexis/http/http_urls.dart';

class QuotationPDFPrinter {
  static Future<void> printQuotationDialog({
    required String title,
    required GetQuotationbyMasterIdmodel quotationData,
    required Company companyDetails,
    required LeadDetails customerDetails,
  }) async {
    final pdf = pw.Document();

    // Fetch the logo image before generating the PDF
    pw.MemoryImage? companyLogo;
    companyLogo = await _fetchLogo(HttpUrls.imgBaseUrl + companyDetails.logo);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Include company details with the logo
            _buildCompanyHeader(companyDetails, companyLogo),
            pw.SizedBox(height: 6),
            _buildHeader(title),
            // pw.SizedBox(height: 20),

            // Customer Details Section
            _buildCustomerDetailsSection(customerDetails, quotationData),
            pw.SizedBox(height: 5),

            // Title Section

            // Status Section
            // _buildStatusSection(quotationData.quotationStatusName),
            // pw.SizedBox(height: 20),

            // Basic Details Section
            _buildBasicDetailsSection(quotationData),
            pw.SizedBox(height: 10),

            // Terms and Conditions Section (only if present)
            if (quotationData.termsAndConditions.isNotEmpty)
              _buildSection(
                'Terms and Conditions',
                pw.Text('*${quotationData.termsAndConditions}'),
              ),
            pw.SizedBox(height: 4),

            // Warranty Section (only if present)
            if (quotationData.warranty.isNotEmpty)
              _buildSection(
                'Warranty',
                pw.Text('*${quotationData.warranty}'),
              ),
            pw.SizedBox(height: 4),

            // Bill of Materials Section
            if (quotationData.billOfMaterials.isNotEmpty)
              _buildBillOfMaterialsSection(quotationData.billOfMaterials),
            pw.SizedBox(height: 4),
          ];
        },
        footer: (pw.Context context) {
          // Check if it's the last page
          if (context.pageNumber == context.pagesCount) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Spacer(), // Space before the "Authority Signature" text
                pw.Text(
                  'Authority Signature',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }
          return pw.SizedBox(); // Return an empty widget for other pages
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Fetch the logo image from the URL and return as MemoryImage
  static Future<pw.MemoryImage> _fetchLogo(String logoUrl) async {
    final response = await http.get(Uri.parse(logoUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return pw.MemoryImage(imageBytes); // Return as MemoryImage
    } else {
      throw Exception('Failed to load logo');
    }
  }

  // Build the company header (Company Name, Email, Phone, Location, and Logo)
  static pw.Widget _buildCompanyHeader(
      Company companyDetails, pw.MemoryImage? companyLogo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      // decoration: pw.BoxDecoration(
      //   border: pw.Border.all(color: PdfColors.grey),
      //   borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      // ),
      child: pw.Stack(
        children: [
          // Positioned Image
          if (companyLogo != null)
            pw.Positioned(
              left: 0,
              child:
                  pw.Image(companyLogo, height: 40), // Adjust height as needed
            ),

          // Centered Column
          pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  companyDetails.companyName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Email: ${companyDetails.email}'),
                pw.Text('Phone: ${companyDetails.mobileNumber}'),
                pw.Text(
                  '${companyDetails.address1}, ${companyDetails.address2}, ${companyDetails.address3}, ${companyDetails.address3}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Header(
      margin: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Center(
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildStatusSection(String status) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Status: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(status),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerDetailsSection(
      LeadDetails customerDetails, GetQuotationbyMasterIdmodel quotationData) {
    return pw.Row(
      children: [
        // Customer Details Container (Left Side)
        pw.Expanded(
          flex: 2,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            // decoration: pw.BoxDecoration(
            //   border: pw.Border.all(color: PdfColors.grey),
            //   borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            // ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Customer Details',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    // pw.Text(
                    //   'Name: ',
                    //   style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    // ),
                    pw.Text(customerDetails.customerName),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    // pw.Text(
                    //   'Location: ',
                    //   style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    // ),
                    pw.Expanded(
                      child: pw.Text(
                        '${customerDetails.address1},${customerDetails.address2},${customerDetails.address3},${customerDetails.address4}',
                      ),
                    )
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    // pw.Text(
                    //   'Phone: ',
                    //   style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    // ),
                    pw.Text(customerDetails.contactNumber.toString()),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    // pw.Text(
                    //   'Email: ',
                    //   style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    // ),
                    pw.Text(customerDetails.email),
                  ],
                ),
                pw.SizedBox(height: 0),
              ],
            ),
          ),
        ),
        pw.SizedBox(
            width:
                20), // Add spacing between customer details and quotation info

        // Quotation Number and Date Container (Right Side)
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            // decoration: pw.BoxDecoration(
            //   border: pw.Border.all(color: PdfColors.grey),
            //   borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
            // ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Text(
                    'Quotation Number: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(quotationData.quotationNo),
                ]),
                pw.SizedBox(height: 10),
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                  pw.Text(
                    'Date: ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(formatDate(quotationData.entryDate)),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicDetailsSection(GetQuotationbyMasterIdmodel data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // pw.Text(
          //   'Basic Details',
          //   style: pw.TextStyle(
          //     fontSize: 16,
          //     fontWeight: pw.FontWeight.bold,
          //   ),
          // ),
          // pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Text(
                'Product Name: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(data.productName),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildQuotationDetailsTable(data),
          pw.SizedBox(height: 10),
          pw.Padding(
              padding: const pw.EdgeInsets.all(0),
              child: pw.Row(children: [
                pw.Text(
                  'Amount in Words : ',
                ),
                pw.Expanded(
                  child: pw.Text(
                    convertNumberToWords(double.parse(data.netTotal)),
                  ),
                ),
              ])),
        ],
      ),
    );
  }

  static pw.Widget _buildQuotationDetailsTable(
      GetQuotationbyMasterIdmodel data) {
    final headers = ['Item Name', 'MRP', 'Price', 'QTY', 'Total'];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: headers.map((header) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                header,
                softWrap: false,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        // Data rows
        ...data.quotationDetails.map((detail) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.ConstrainedBox(
                  constraints: const pw.BoxConstraints(
                    maxWidth: 100,
                  ),
                  child: pw.Text(
                    detail.itemName,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${detail.MRP}',
                  softWrap: false,
                ), // MRP
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${detail.unitPrice}',
                  softWrap: false,
                ), // Amount
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${detail.quantity}',
                  softWrap: false,
                ), // Quantity
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  '${detail.amount}',
                  softWrap: false,
                ), // Total
              ),
            ],
          );
        }),
        // Total row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Sub Total',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Spacer(),
            pw.Spacer(),
            pw.Spacer(),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                data.totalAmount,
                softWrap: false,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Subsidy row
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text('Subsidy'),
            ),
            pw.Spacer(),
            pw.Spacer(),
            pw.Spacer(),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                data.subsidyAmount,
                softWrap: false,
              ),
            ),
          ],
        ),
        // Net Total row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                'Total',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Spacer(),
            pw.Spacer(),
            pw.Spacer(),
            pw.Padding(
              padding: const pw.EdgeInsets.all(5),
              child: pw.Text(
                data.netTotal,
                softWrap: false,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSection(String title, pw.Widget content) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          content,
        ],
      ),
    );
  }

  static pw.Widget _buildBillOfMaterialsSection(
      List<BillOfMaterial> materials) {
    return pw.Container(
      // padding: const pw.EdgeInsets.all(10),
      // decoration: pw.BoxDecoration(
      //   border: pw.Border.all(color: PdfColors.grey),
      //   borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      // ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bill of Materials',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  'Sl No',
                  'Items',
                  'Make',
                  'Quantity',
                  // 'Invoice No',
                  // 'Distributor',
                ].map((header) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              // Data rows
              ...materials.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('${index + 1}'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.itemsAndDescription),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.make),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(item.quantity.toString()),
                    ),
                    // pw.Padding(
                    //   padding: const pw.EdgeInsets.all(5),
                    //   child: pw.Text(item.invoiceNo),
                    // ),
                    // pw.Padding(
                    //   padding: const pw.EdgeInsets.all(5),
                    //   child: pw.Text(item.distributor),
                    // ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  static String convertNumberToWords(double number) {
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

  static String _convertNumberToWordsRecursive(int number) {
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
  static String _convertSmallNumber(int number) {
    return _convertNumberToWordsRecursive(number);
  }

  static formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return ''; // Return empty string if null or empty
    }
    try {
      // Parse the date and format it to 'dd-MM-yyyy'
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return ''; // Return empty string if parsing fails
    }
  }
}
