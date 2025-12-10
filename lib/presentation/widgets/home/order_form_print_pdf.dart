import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/get_quotation_master_id_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:http/http.dart' as http;

import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/utils/extensions.dart';

class QuotationPrintNewDesign {
  static Future<void> printQuotationDialog({
    required String title,
    required GetQuotationbyMasterIdmodel quotationData,
    required Company companyDetails,
    required LeadDetails customerDetails,
  }) async {
    final pdf = pw.Document();

    final ttfRegular = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

    pw.MemoryImage? companyLogo;
    companyLogo = await _fetchLogo(HttpUrls.imgBaseUrl + companyDetails.logo);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            buildOrderFormHeader(
                companyDetails, ttfBold, ttfRegular, companyLogo),
            pw.SizedBox(height: 10),
            buildCustomerInfo(
                customerDetails, quotationData, ttfRegular, ttfBold),
            buildOrderDetails(quotationData, ttfRegular, ttfBold),
            buildFinancialDetails(quotationData, ttfRegular, ttfBold),
            buildPaymentTerms(quotationData, ttfRegular, ttfBold),
            buildTermsAndConditions(quotationData, ttfRegular, ttfBold),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<pw.MemoryImage> _fetchLogo(String logoUrl) async {
    final response = await http.get(Uri.parse(logoUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return pw.MemoryImage(imageBytes); // Return as MemoryImage
    } else {
      throw Exception('Failed to load logo');
    }
  }

  static pw.Widget buildOrderFormHeader(Company companyDetails, pw.Font ttfBold,
      pw.Font ttfRegular, pw.MemoryImage? companyLogo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            if (companyLogo != null)
              pw.Image(companyLogo, height: 40), // Adjust height as needed
          ],
        ),
        pw.Container(
          alignment: pw.Alignment.center,
          child: pw.Text('ORDER FORM',
              style: pw.TextStyle(font: ttfBold, fontSize: 18)),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(companyDetails.companyName,
                style: pw.TextStyle(font: ttfBold, fontSize: 8)),
            pw.Text(companyDetails.address1,
                style: pw.TextStyle(font: ttfRegular, fontSize: 8)),
            pw.Text(companyDetails.address2,
                style: pw.TextStyle(font: ttfRegular, fontSize: 8)),
            pw.Text(companyDetails.address3 + "," + companyDetails.address4,
                style: pw.TextStyle(font: ttfRegular, fontSize: 8)),
            pw.Text(
                companyDetails.mobileNumber +
                    " | " +
                    companyDetails.phoneNumber,
                style: pw.TextStyle(font: ttfRegular, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildCustomerInfo(
      LeadDetails customerDetails,
      GetQuotationbyMasterIdmodel quotationData,
      pw.Font ttfRegular,
      pw.Font ttfBold) {
    return pw.Column(
      children: [
        // Row 1
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Name',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(customerDetails.customerName,
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Ref No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(' ',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Date',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(quotationData.entryDate.toDDMMYYYY(),
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
          ],
        ),
        // Row 2 - Address
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Address',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                        customerDetails.address1.toString() +
                            " " +
                            customerDetails.address2.toString(),
                        style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                    pw.Text(
                        customerDetails.address3.toString() +
                            " " +
                            customerDetails.address4.toString(),
                        style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              flex: 4,
              child: pw.Container(
                height: 40,
                child: pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text('Capacity',
                                style: pw.TextStyle(
                                    font: ttfRegular, fontSize: 10)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text(
                                customerDetails.inverterCapacity.toString(),
                                style:
                                    pw.TextStyle(font: ttfBold, fontSize: 10)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text('Load',
                                style: pw.TextStyle(
                                    font: ttfRegular, fontSize: 10)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text(
                                customerDetails.connectedLoad.toString(),
                                style:
                                    pw.TextStyle(font: ttfBold, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text('Email',
                                style: pw.TextStyle(
                                    font: ttfRegular, fontSize: 10)),
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Container(
                            height: 20,
                            padding: const pw.EdgeInsets.all(4),
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(width: 0.5),
                            ),
                            child: pw.Text(customerDetails.email,
                                style:
                                    pw.TextStyle(font: ttfBold, fontSize: 10)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Row 3 - Aadhaar
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Adhaar No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Mob No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(customerDetails.contactNumber.toString(),
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
          ],
        ),
        // Row 4 - Contact Person
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Contact Person',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(customerDetails.customerName,
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Mob No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(customerDetails.contactNumber.toString(),
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
          ],
        ),
        // Row 5 - Consumer Number
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Consumer No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(customerDetails.consumerNumber,
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            // pw.Expanded(
            //   flex: 1,
            //   child: pw.Container(
            //     height: 20,
            //     padding: const pw.EdgeInsets.all(4),
            //     decoration: pw.BoxDecoration(
            //       border: pw.Border.all(width: 0.5),
            //     ),
            //     child: pw.Text('Section',
            //         style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
            //   ),
            // ),
            // pw.Expanded(
            //   flex: 3,
            //   child: pw.Container(
            //     height: 20,
            //     padding: const pw.EdgeInsets.all(4),
            //     decoration: pw.BoxDecoration(
            //       border: pw.Border.all(width: 0.5),
            //     ),
            //     child: pw.Text(customerDetails.section,
            //         style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
            //   ),
            // ),
          ],
        ),
        // Row 6 - AKN No
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Akn No',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            // pw.Expanded(
            //   flex: 1,
            //   child: pw.Container(
            //     height: 20,
            //     padding: const pw.EdgeInsets.all(4),
            //     decoration: pw.BoxDecoration(
            //       border: pw.Border.all(width: 0.5),
            //     ),
            //     child: pw.Text('Panel W',
            //         style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
            //   ),
            // ),
            // pw.Expanded(
            //   flex: 3,
            //   child: pw.Container(
            //     height: 20,
            //     padding: const pw.EdgeInsets.all(4),
            //     decoration: pw.BoxDecoration(
            //       border: pw.Border.all(width: 0.5),
            //     ),
            //     child: pw.Text(customerDetails.panelWatts,
            //         style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildOrderDetails(GetQuotationbyMasterIdmodel quotationData,
      pw.Font ttfRegular, pw.Font ttfBold) {
    return pw.Column(
      children: [
        // Header row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Sl No.',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text('Particulars',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text('Qty.',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                ),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text('Cost',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                ),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Center(
                  child: pw.Text('Total',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
        // Item 1 row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 70,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 70,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 70,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 70,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 70,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
          ],
        ),
        // Item 2 row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 40,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('',
                        style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Empty row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildFinancialDetails(
      GetQuotationbyMasterIdmodel quotationData,
      pw.Font ttfRegular,
      pw.Font ttfBold) {
    return pw.Column(
      children: [
        // Additionals row
        pw.Row(children: [
          pw.Expanded(
            flex: 4,
            child: pw.Container(
              height: 60,
              padding: const pw.EdgeInsets.all(4),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 0.5),
              ),
              child: pw.Text('Additionals',
                  style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
            ),
          ),
          pw.Expanded(
              flex: 4,
              child: pw.Column(children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('Taxes',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                // Adjustment row
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('Adj.',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
                // Total row
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('Total',
                            style: pw.TextStyle(font: ttfBold, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text('',
                            style:
                                pw.TextStyle(font: ttfRegular, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Container(
                        height: 20,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('',
                                style:
                                    pw.TextStyle(font: ttfBold, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ])),
        ]),

        // KSEB Charges row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('KSEB Charges',
                    style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 10,
                        decoration: pw.TextDecoration.underline)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Total (+18% GST)',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 4,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
          ],
        ),
        // KSEB Feasibility row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('KSEB Feasibility Fee',
                    style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 10,
                        decoration: pw.TextDecoration.underline)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Adv',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
          ],
        ),
        // KSEB Registration row
        pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text(
                    'KSEB Registration Fee - 1000/ kW (80% Refundable)',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('Balance',
                    style: pw.TextStyle(font: ttfRegular, fontSize: 10)),
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                height: 20,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 0.5),
                ),
                child: pw.Text('',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget buildPaymentTerms(GetQuotationbyMasterIdmodel quotationData,
      pw.Font ttfRegular, pw.Font ttfBold) {
    return pw.Row(
      children: [
        // Left Column: Payment Term
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            height: 120,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Payment Term',
                      style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    ),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '',
                  style: pw.TextStyle(font: ttfRegular, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        // Right Column: Declaration
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      'Declaration',
                      style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    ),
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Consumer Signature Section
                    pw.Expanded(
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text(
                          'Name and Signature of the Consumer',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 10),
                        ),
                      ),
                    ),
                    // Executive Signature Section
                    pw.Expanded(
                      child: pw.Container(
                        height: 100,
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.5),
                        ),
                        child: pw.Text(
                          'Name and Signature of the Executive',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget buildTermsAndConditions(
      GetQuotationbyMasterIdmodel quotationData,
      pw.Font ttfRegular,
      pw.Font ttfBold) {
    return pw.Row(children: [
      pw.Expanded(
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.max,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                child: pw.Text(
                  'Terms and Conditions',
                  style: pw.TextStyle(
                    font: ttfRegular,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Text(
                  '',
                  style: pw.TextStyle(font: ttfRegular, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
