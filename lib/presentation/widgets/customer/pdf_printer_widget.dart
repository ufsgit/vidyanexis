import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/controller/models/solar_panel_details_model.dart';
import 'package:vidyanexis/http/http_urls.dart';

class PDFPrinter {
  static Future<void> buildPdf(List<LeadDetails>? leadDetails,
      List<SolarPanelDetails> formDetails) async {
    final pdf = pw.Document();

    pw.MemoryImage? customerLogo;
    if (formDetails[0].customerSign.isNotEmpty) {
      customerLogo =
          await _fetchLogo(HttpUrls.imgBaseUrl + formDetails[0].customerSign);
    }
    pw.MemoryImage? engineerLogo;
    if (formDetails[0].serviceEngSign.isNotEmpty) {
      engineerLogo =
          await _fetchLogo(HttpUrls.imgBaseUrl + formDetails[0].serviceEngSign);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.black, // Set the border color
                  width: 1, // Set the border width
                ),
              ),
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: _buildCustomerDetails(leadDetails),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _buildInverterDetails(leadDetails),
                      ),
                      pw.Expanded(
                        child: _buildPanelDetails(leadDetails),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  _buildTableSection(formDetails),
                  pw.SizedBox(height: 20),
                  _buildSummarySection(formDetails),
                  // pw.Divider(),
                ],
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          // Check if it's the last page
          if (context.pageNumber == context.pagesCount) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    if (customerLogo != null)
                      pw.Image(customerLogo, width: 50, height: 50),
                    pw.SizedBox(height: 10),
                    pw.Text('Customer Sign:'),
                  ],
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    if (engineerLogo != null)
                      pw.Image(engineerLogo, width: 50, height: 50),
                    pw.SizedBox(height: 10),
                    pw.Text('Service Eng Sign: '),
                  ],
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

  static Future<pw.MemoryImage> _fetchLogo(String logoUrl) async {
    final response = await http.get(Uri.parse(logoUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return pw.MemoryImage(imageBytes); // Return as MemoryImage
    } else {
      throw Exception('Failed to load logo');
    }
  }

  static pw.Widget _buildCustomerDetails(List<LeadDetails>? leadDetails) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("CUSTOMER DETAILS",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(leadDetails![0].customerName),
        pw.Text(leadDetails[0].address1.toString()),
        // pw.Text(leadDetails[0].pincode),
        pw.Text(leadDetails[0].contactNumber.toString()),
      ],
    );
  }

  static pw.Widget _buildInverterDetails(List<LeadDetails>? leadDetails) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("INVERTER DETAILS",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        // pw.Text("BRAND: ${leadDetails![0].inverterBrand}"),
        pw.Text("CAPACITY: ${leadDetails![0].inverterCapacity}"),
        // pw.Text("MODEL: ${leadDetails[0].inverterModel}"),
        // pw.Text("SN: ${leadDetails[0].inverterSn}"),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildPanelDetails(List<LeadDetails>? leadDetails) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("PANEL DETAILS",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        // pw.Text("BRAND: ${leadDetails![0].panelBrand}"),
        // pw.Text("WATTS: ${leadDetails[0].panelWatts}"),
        // pw.Text("SN:  ${leadDetails[0].panelSn}"),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _buildTableSection(List<SolarPanelDetails> formDetails) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("DC DB", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("SPD: ${formDetails[0].dcspdName}"),
            pw.Text("Fuse: ${formDetails[0].dcFuseName}"),
            pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.start, // Align texts to the left
              children: [
                pw.Text("MCB"),
                pw.SizedBox(height: 10),
                pw.Text("Make: ${formDetails[0].make}"), // First text
                pw.Text(
                    "AMP: ${formDetails[0].amp}"), // Second text (e.g., AMP)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment
                      .start, // Align the items to the start (left)
                  children: [
                    pw.Text("PV1: ${formDetails[0].pb1}",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(
                        width: 10), // Adds some space between PV1 and PV2
                    pw.Text("PV2: ${formDetails[0].pb2}",
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment
                      .start, // Align the items to the start (left)
                  children: [
                    pw.Text("PV3: ${formDetails[0].pb3}",
                        style: const pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(
                        width: 10), // Adds some space between PV1 and PV2
                    pw.Text("PV4: ${formDetails[0].pb4}",
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ) // Fourth text (e.g., PB2)
              ],
            )
          ],
        ),
        pw.Divider(),
        pw.Text("AC DB", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text("SPD: ${formDetails[0].acspdName}"),
            pw.Text("MCB: ${formDetails[0].acmcbName}"),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("AC Voltage: ${formDetails[0].acVolt}"),
                pw.SizedBox(width: 10), // Add space between text
                pw.Text("Phase to Earth: ${formDetails[0].phaseToEarth}"),
                pw.Text("Neutral to Earth: ${formDetails[0].neutralToEarth}"),
              ],
            )
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummarySection(List<SolarPanelDetails> formDetails) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.Text(
          "INVERTER",
          textAlign: pw.TextAlign.center, // Center the text
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, // Make the text bold
          ),
        ),
        pw.Text("Status: ${formDetails[0].inverterStatus}"),
        pw.Divider(),
        pw.Text(
          "PANNEL",
          textAlign: pw.TextAlign.center, // Center the text
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, // Make the text bold
          ),
        ),
        pw.Text("Status: ${formDetails[0].panelStatus}"),
        pw.Divider(),
        pw.Text(
          "SUMMARY",
          textAlign: pw.TextAlign.center, // Center the text
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, // Make the text bold
          ),
        ),
        pw.Text("Status: ${formDetails[0].summary}"),
      ],
    );
  }
}
