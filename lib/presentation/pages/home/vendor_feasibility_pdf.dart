import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';

LeadDetails? customer;
Future<void> rtsFeasibilityReportPdf({
  LeadDetails? customerDetails,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  customer = customerDetails;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(50),
      build: (pw.Context context) => [
        buildHeader(),
        buildBasicInfoSection(),
        pw.SizedBox(height: 50),
        buildEhsChecklistSection(),
        buildEHSRequirementHeaderTable(),
        singleTable('Proposal Appraisal Phase'),
        buildTableRow(
            '1',
            'Lopping/pruning of tree branches for shadow-free area',
            'Yes / No / Not Applicable',
            'Check validity and conditions of permissions',
            'Review compliance with permissions'),
        buildTableRow(
            '2',
            '24x365 access availability',
            'Yes / No / Not Applicable',
            'Seek details of alternative safe access',
            'Review safety of alternate access'),
        buildTableRow(
            '3',
            'Structural safety and roof condition assessment',
            'Yes / No / Not Applicable',
            'Seek structural safety certificate',
            'Check validity and adequacy'),
        buildTableRow(
            '4',
            'Consent from residents/owners and construction timelines',
            'Yes / No / Not Applicable',
            'Verify consent document and timelines',
            'Review compliance through site inspection'),
        buildTableRow(
            '5',
            'Water requirements for panel washing',
            'Yes / No / Not Applicable',
            'Seek details of water sources and permissions',
            'Review adequacy of arrangements'),
        buildTableRow(
            '6',
            'Financial assistance for batteries',
            'Yes / No / Not Applicable',
            'Ensure compliance with Batteries Rules 2021',
            'Check agreement with authorized recycler'),
        singleTable('Installation and Operation Phase'),
        buildTableRow(
            '7',
            'Electrical Safety Approval',
            'Yes / No / Not Applicable',
            'Seek certification from Chief Electrical Inspector',
            'Undertaking for compliance'),
        pw.SizedBox(height: 40),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text:
                    'B.	Safety guidelines to be adhered to by Installer / supplier / RESCO developer.\n ',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              const pw.TextSpan(
                text: '(only Advisory in nature)',
                style: pw.TextStyle(),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        buildEHSRequirementHeaderTable(),
        buildTableRow('1', 'Accreditation of ISO 14000, OHSAS 18001',
            'Yes / No / Not Applicable', 'Seek details of certifications', ''),
        buildTableRow(
            '2',
            'Safety provisions (rubber mats, fire extinguishers, etc.)',
            'Yes / No / Not Applicable',
            'Seek details of safety measures',
            'Assess adequacy during site inspections'),
        buildTableRow(
            '3',
            'Safety wear for personnel',
            'Yes / No / Not Applicable',
            'Seek details of safety provisions',
            'Assess adequacy during site inspections'),
        buildTableRow(
            '4',
            'Training in first aid and firefighting',
            'Yes / No / Not Applicable',
            'Undertaking for training provision',
            ''),
        buildTableRow('5', 'Compliance with Minimum Wages Act',
            'Yes / No / Not Applicable', 'Undertaking for compliance', ''),
        buildTableRow(
            '6',
            'Workmen compensation insurance, EPF, Gratuity',
            'Yes / No / Not Applicable',
            'Undertaking for insurance coverage',
            'Check adequacy of insurances'),
        buildTableRow(
            '7',
            'Consumer sensitization to safety issues',
            'Yes / No / Not Applicable',
            'Share material about safety hazards',
            'Review compliance through site inspection'),
        pw.SizedBox(height: 10),
        buildFooter(),
      ],
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        );
      },
    ),
  );
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

pw.Widget buildEHSRequirementHeaderTable() {
  return pw.Table(
    border: pw.TableBorder.all(),
    columnWidths: {
      0: const pw.FixedColumnWidth(50), // S. No.
      1: const pw.FlexColumnWidth(3), // Requirement
      2: const pw.FlexColumnWidth(2), // Status
      3: const pw.FlexColumnWidth(3), // Guidance
      4: const pw.FlexColumnWidth(2.5), // Review
    },
    children: [
      pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('S. No.',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('EHS Requirements of GRPV Program',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Status (StateYes/No/Not Applicable)',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                  'Guidance for ensuring compliance of EHS requirements by SBI',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                  'Review and Monitoring by SBI for adequacy and compliance of EHS requirements',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ]),
    ],
  );
}

pw.Widget buildHeader() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Center(
        child: pw.Text(
          'Residential Roof Top Solar Installation \nVendor Feasibility Report',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
      pw.SizedBox(height: 20),
    ],
  );
}

pw.Widget buildInfoRow(String label, String value, {bool highlight = false}) {
  return pw.Container(
    color: highlight ? PdfColors.yellow : null,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 170,
          child: pw.Text(label, textAlign: pw.TextAlign.left),
        ),
        pw.Text(' :  '),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );
}

pw.Widget buildBasicInfoSection() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      buildInfoRow('1. Consumer Name', customer?.customerName ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('2. Contact Phone Number', customer?.phoneNumber ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('3. Discom Consumer ID', '1167444010653'),
      pw.SizedBox(height: 10),
      buildInfoRow('4. PM Surya Shakti Portal ID',
          customer?.PMSuryaShakthiPortalid ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('5. JAN Samarth ID', customer?.JanSamarthid ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('6. Address for Installation', customer?.address ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('7. State of Installation', customer?.address4 ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('8. Pin Code of Installation', customer?.pinCode ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow(
          '9. Name of the Bank and Branch', customer?.bankbranch ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('10. OEM Name', customer?.inverterBrandName ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('11. Channel Partner', 'Not Provided'),
      pw.SizedBox(height: 10),
      buildInfoRow('12. EPC Contractor Address',
          'M/s FRAMES SOLAR AND SECURITY, CHITTANJOOR, THRISSUR PIN: 680523, Ph: +91 9778367135, +91 9567501982, Email: framessolar@gmail.com, Vendor Serial No: 1153',
          highlight: true),
      pw.SizedBox(height: 10),
      buildInfoRow('13. EPC Contractor Bank Details',
          'HDFC BANK, NH BYPASS, VYTTILA, A/c No: 50200108212310, IFSC Code: HDFC0007644',
          highlight: true),
      pw.SizedBox(height: 10),
      buildInfoRow('14. RTS Capacity in KW Applied',
          '${customer?.inverterCapacity ?? ''}'),
      pw.SizedBox(height: 10),
      buildInfoRow('15. Actual RTS Capacity to be installed',
          customer?.actualRTSCapacity ?? ''),
      pw.SizedBox(height: 10),
      buildInfoRow('16. Feasibility Report Status', 'Feasible'),
      // pw.SizedBox(height: 10),
      // buildInfoRow('17. Project Cost', customer?.projectCost ?? ''),
      // pw.SizedBox(height: 10),
      buildInfoRow('18. Site Layout - Images', '(2-4 images to be uploaded)'),
      pw.SizedBox(height: 10),
      buildFooter(),
    ],
  );
}

pw.Widget buildEhsChecklistSection() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'Guidance Checklist and Consumer Education for verification of adequacy on Environmental, Health, and Safety (EHS) requirements during appraisal and monitoring \n(Installation and Operation phases) of an individual project funded by SBI under the',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      pw.Center(
        child: pw.Text(
          'Additional Financing: Rooftop Solar Program for Residential Sector',
          style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline),
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Text(
        'A. Guidance Checklist for EPC / Project Developer \nGo / No-Go Criteria',
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            decoration: pw.TextDecoration.underline),
      ),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: {
          0: const pw.FixedColumnWidth(50), // S. No.
          1: const pw.FlexColumnWidth(3), // EHS Requirement
          2: const pw.FlexColumnWidth(2), // Status
        },
        children: [
          pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('S. No.',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('EHS Requirement of GRPV Program',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Status',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ]),
          pw.TableRow(children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('1'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text(
                  'Confirm that Roofing material where the rooftop solar system is installed does not contain any carcinogenic material like broken or dilapidated Asbestos.'),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('Yes / No'),
            ),
          ]),
        ],
      ),
      pw.SizedBox(height: 40),
    ],
  );
}

pw.Widget buildTableRow(String sNo, String requirement, String status,
    String guidance, String review) {
  return pw.Table(
    border: pw.TableBorder.all(),
    columnWidths: {
      0: const pw.FixedColumnWidth(50), // S. No.
      1: const pw.FlexColumnWidth(3), // Requirement
      2: const pw.FlexColumnWidth(2), // Status
      3: const pw.FlexColumnWidth(3), // Guidance
      4: const pw.FlexColumnWidth(2.5), // Review
    },
    children: [
      pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Center(child: pw.Text(sNo)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(requirement),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(status),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(guidance),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(review),
        ),
      ]),
    ],
  );
}

pw.Widget singleTable(String text) {
  return pw.Table(
    border: pw.TableBorder.all(),
    children: [
      pw.TableRow(children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Center(
            child: pw.Text(
              text,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      ]),
    ],
  );
}

pw.Widget buildFooter() {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Date: Not Provided'),
        pw.Text('Place: THRISSUR'),
      ]),
      pw.Text('Signature: Authorized Person of Vendor with Stamp'),
    ],
  );
}
