import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/utils/extensions.dart' show DateStringFormatter;

LeadDetails? customer;
Future<void> vendorAgreementPdf({
  LeadDetails? customerDetails,
  required BuildContext context,
}) async {
  final pdf = pw.Document();
  customer = customerDetails;

  // Define text styles
  final titleStyle = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
  final bodyStyle = pw.TextStyle(fontSize: 12);
  final clauseStyle = pw.TextStyle(fontSize: 12, height: 1.5);

  // Add pages with the agreement content
  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        // ..._buildTitleSection(titleStyle),
        ..._buildIntroSection(bodyStyle),
        ..._buildWhereasSection(bodyStyle),
        ..._buildAgreementSection(bodyStyle, clauseStyle),
        ..._buildFinalSection(bodyStyle),
      ],
    ),
  );

  // Save or share the PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

List<pw.Widget> _buildTitleSection(pw.TextStyle style) {
  return [
    pw.Center(
      child: pw.Text(
        'Vendor Agreement for Rooftop Solar System Installation',
        style: style,
        textAlign: pw.TextAlign.center,
      ),
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildIntroSection(pw.TextStyle style) {
  return [
    pw.Text(
      'This Agreement is executed on ${customer?.nextFollowUpDate.toDayMonthYearFormat() ?? ''} for the design, installation, commissioning, and five years of comprehensive maintenance of a rooftop solar system to be installed under the Simplified Procedure of the Rooftop Solar Programme Phase-II.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Center(
      child: pw.Text(
        'BETWEEN',
        style: style.copyWith(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    ),
    pw.Text(
      '${customer?.customerName ?? ''} (hereinafter referred to as the First Party/Applicant), having a residential electricity connection with Consumer Number ${customer?.consumerNumber ?? ''} from KSEB Ltd (DISCOM), residing at ${customer?.address ?? ''} ${customer?.address1 ?? ''} ${customer?.address2 ?? ''} ${customer?.address3 ?? ''} ${customer?.address4 ?? ''} - ${customer?.pinCode ?? ''} Consumer Number  ${customer?.consumerNumber ?? ''}',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Center(
      child: pw.Text(
        'AND',
        style: style.copyWith(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
      ),
    ),
    pw.Text(
      'FRAMES SOLAR AND SECURITY (hereinafter referred to as the Second Party/Vendor), registered/empaneled with the Kerala State Electricity Board (KSEB) (hereinafter referred to as the DISCOM), having a registered/functional office at Shop No. 402-8, Kattissery Center, Chittanjoor, Thrissur, Kerala - 680523.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text(
      'Both the Applicant and the Vendor are hereinafter collectively referred to as the "Parties"',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildWhereasSection(pw.TextStyle style) {
  return [
    pw.Text(
      'WHEREAS',
      style: style.copyWith(fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.center,
    ),
    pw.Bullet(
      text:
          'The Applicant intends to install a rooftop solar system under the Simplified Procedure of the Rooftop Solar Programme Phase-II of MNRE.',
      style: style,
    ),
    pw.Bullet(
      text:
          'The Vendor is a registered/empaneled vendor with KSEB (DISCOM) for the installation of rooftop solar systems under MNRE schemes.',
      style: style,
    ),
    pw.Bullet(
      text:
          'Both Parties mutually understand and agree upon their roles and responsibilities, and declare that no liability shall fall on any third party, including the DISCOM or MNRE.',
      style: style,
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildAgreementSection(
    pw.TextStyle bodyStyle, pw.TextStyle clauseStyle) {
  return [
    pw.Text('1. GENERAL TERMS',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'i. The Applicant confirms that they have the legal authority to enter into this Agreement and to authorize the construction, installation, and commissioning of the Rooftop Solar System ("RTS System") on the Applicants premises ("Applicant Site"). The Vendor reserves the right to verify ownership of the Applicant Site, and the Applicant agrees to provide all necessary documents for verification.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'ii. The Vendor may propose changes to the scope, nature, or schedule of services. Any proposed changes must be mutually agreed upon. If no agreement is reached, either Party may terminate this Agreement as per Clause 13.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'iii. The Applicant acknowledges that changes in electricity load, usage patterns, or tariff rates may affect the performance or financial benefits of the RTS System, and such factors have not been considered in any estimates provided by the Vendor.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('2. RTS SYSTEM',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text:
          'The total capacity of the RTS System shall be a minimum of ${customer?.inverterCapacity ?? ''}.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'All solar modules, inverters, and Balance of System (BOS) components will meet MNRE specifications and DCR requirements.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Solar Modules: Make -${customer?.inverterTypeName ?? ''},${customer?.inverterBrandName ?? ''},${customer?.inverterCapacity ?? ''},${customer?.panelTypeName ?? ''},${customer?.panelBrandName ?? ''},${customer?.panelCapacity ?? ''},${customer?.noOfPanels ?? ''},${customer?.Efficiency ?? ''}',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'Inverter: Make - DEYE; Model - SUN-3K-G03- Capacity - 3KWP.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'The mounting structure will withstand wind load pressures as specified by MNRE.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'All BOS installations will adhere to best industry practices and include necessary safety and protection devices.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('3. PRICE AND PAYMENT TERMS',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text:
          'Total cost: Rs.${customer?.totalProjectCost ?? ''}/- (to be mutually agreed).',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'Payment to Vendor shall be made as follows:',
      style: clauseStyle,
    ),
    pw.Text('   1. 50% advance upon order confirmation.', style: clauseStyle),
    pw.Text('   2. 40% after work completion.', style: clauseStyle),
    pw.Text('   3. 10% upon final commissioning.', style: clauseStyle),
    pw.Bullet(
      text:
          "Payment modes: Banker's cheque / NEFT / RTGS / Online transfer. No cash payments will be accepted.",
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('4. REPRESENTATIONS BY THE APPLICANT',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'The Applicant acknowledges that:',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'i. Project timelines are estimates and Vendor is not liable for delays not attributable to it.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'ii. All information provided by the Applicant (load profile, bills, etc.) is accurate.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      "iii. All drawings and specifications sent by the Vendor require the Applicant's approval within five (5) days. No response will be deemed approval.",
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'iv. The RTS System will not be misused, and any misuse will be the sole responsibility of the Applicant.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'The Applicant further agrees:',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Bullet(
      text: 'All electrical and plumbing at the site complies with laws.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'The Applicant will ensure unobstructed access to the Vendor.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'The Applicant will provide water, electricity, storage, and support for site preparation.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'The system will be kept shadow-free throughout its lifetime.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'The Applicant is responsible for regular cleaning and safety.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'The Vendor may geo-tag the site and use media for promotional purposes unless objected in writing.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'The structure is suitable for solar panel installation.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('5. MAINTENANCE',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text: 'Vendor shall provide five years of free maintenance.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'At least one quarterly visit shall be made by the Vendor.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'Vendor will inspect all nuts, bolts, fuses, and grounding.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Cleaning is the responsibility of the Applicant, as per dust accumulation.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('6. ACCESS AND RIGHT OF ENTRY',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'The Applicant grants the Vendor and its Authorized Persons the right to access the site for:',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text('a) Feasibility study', style: clauseStyle),
    pw.Text('b) Storing and delivering system components', style: clauseStyle),
    pw.Text('c) Installation', style: clauseStyle),
    pw.Text('d) Inspection', style: clauseStyle),
    pw.Text('e) Repairs and maintenance', style: clauseStyle),
    pw.Text('f) System removal if necessary', style: clauseStyle),
    pw.Text('g) Execution of rights under this Agreement', style: clauseStyle),
    pw.SizedBox(height: 10),
    pw.Text(
      'Applicant shall ensure third-party access permissions, if applicable.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('7. WARRANTIES',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text: 'Product Warranty: Provided by the manufacturer.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Installation Warranty: Five years against workmanship/BOS defects.',
      style: clauseStyle,
    ),
    pw.Text(
      'Applicant must notify defects within 15 days of occurrence.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'Exceptions:',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Bullet(
      text: 'Unauthorized repairs void warranty.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Vendor is not liable for damage due to negligence, misuse, external forces, or modifications by the Applicant.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text: 'Warranty excludes accessories not provided by Vendor.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('8. PERFORMANCE GUARANTEE',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'Vendor guarantees a Performance Ratio (PR) of at least 75%, measured as per IEC 61724 or equivalent BIS standard, for five years.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('9. INSURANCE',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text: 'Vendor may insure the system until commissioning.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Post-installation, the Applicant assumes all risk and may obtain insurance.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('10. CANCELLATION',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Bullet(
      text:
          'The Applicant may cancel the order within 7 days of placing the order or advance payment.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'Post 7 days, a cancellation fee 25% and incurred costs shall apply.',
      style: clauseStyle,
    ),
    pw.Bullet(
      text:
          'No cancellations allowed after dispatch of system/components. Paid amounts shall be forfeited.',
      style: clauseStyle,
    ),
    pw.SizedBox(height: 10),
    pw.Text('11. LIMITATION OF LIABILITY',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      "Vendor's liability is limited to:",
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text('a) Repair or replacement of the system/component, or',
        style: clauseStyle),
    pw.Text('b) Refund if unable to fulfill the order.', style: clauseStyle),
    pw.SizedBox(height: 10),
    pw.Text('12. SUSPENSION AND TERMINATION',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'Vendor may suspend work if the Applicant delays payments.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('13. NOTICES',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'All communications must be in English, and sent via:',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Bullet(text: 'Email', style: clauseStyle),
    pw.Bullet(
        text: 'Hand delivery / Courier / Registered Post', style: clauseStyle),
    pw.Text(
      'to the addresses of the Applicant and the Vendor.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('14. FORCE MAJEURE',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'Neither Party shall be liable for delays or non-performance due to events beyond control including war, natural disasters, pandemics, or government restrictions.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Text('15. GOVERNING LAW AND DISPUTE RESOLUTION',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text(
      'a. Governed by Indian Law.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'b. Parties shall first attempt amicable resolution.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'c. If unresolved, disputes shall be referred to arbitration under the Arbitration and Conciliation Act, 1996, by a mutually appointed sole arbitrator.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildFinalSection(pw.TextStyle bodyStyle) {
  return [
    pw.Text(
      'In witness whereof, the said RAJAN KK (First Party) and SATHEESH KUMAR K, FRAMES SOLAR AND SECURITY (Second Party), have hereunto signed this Agreement on the day and year first above written.',
      style: bodyStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 20),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(customer?.consumerNumber ?? '',
                style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
            pw.Text(customer?.customerName ?? '', style: bodyStyle),
            pw.Text(
                '${customer?.address ?? ''} ${customer?.address1 ?? ''} ${customer?.address2 ?? ''} ${customer?.address3 ?? ''} ${customer?.address4 ?? ''} ',
                style: bodyStyle),
            pw.Text(customer?.pinCode ?? '', style: bodyStyle),
            // pw.Text('${customer?.pinCode ?? ''}', style: bodyStyle),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SATHEESH KUMAR K',
                style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
            pw.Text('FRAMES SOLAR AND SECURITY', style: bodyStyle),
            pw.Text('Shop No. 402-8, Kattissery Center', style: bodyStyle),
            pw.Text('Chittanjoor, Thrissur, Kerala - 680523', style: bodyStyle),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 20),
    pw.Text('Witnesses:',
        style: bodyStyle.copyWith(fontWeight: pw.FontWeight.bold)),
    pw.Text('1. ___________________________', style: bodyStyle),
    pw.Text('2. ___________________________', style: bodyStyle),
  ];
}
