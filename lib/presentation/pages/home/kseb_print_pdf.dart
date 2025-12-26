import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/utils/extensions.dart';

LeadDetails? customer;
Future<void> ksebPdf({
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
        ..._buildTitleSection(titleStyle),
        ..._buildIntroSection(bodyStyle),
        ..._buildWhereasSection(bodyStyle),
        ..._buildAgreementSection(bodyStyle, clauseStyle),
        ..._buildFinalSection(bodyStyle, clauseStyle),
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
        'Net Metering Agreement for Connecting Solar Energy\n System to the Distribution System of the licensee',
        style: style.copyWith(decoration: pw.TextDecoration.underline),
        textAlign: pw.TextAlign.center,
      ),
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildIntroSection(pw.TextStyle style) {
  return [
    pw.Text(
      'This Memorandum of Agreement is made on the ${customer?.nextFollowUpDate.toDayMonthYearFormat() ?? ''} at  '
      '${customer?.electricalSection ?? ''}, between ${customer?.customerName ?? ''}, residing at ${customer?.address ?? ''} ${customer?.address1 ?? ''} '
      '${customer?.address2 ?? ''} ${customer?.address3 ?? ''} ${customer?.address4 ?? ''} ${customer?.pinCode ?? ''} Consumer Number '
      '${customer?.consumerNumber ?? ''}, (hereinafter referred to as the First Party or the Consumer), and the Kerala State Electricity Board (hereinafter referred to as the Second Party or the board)',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Witness 1', style: style),
            pw.SizedBox(height: 5),
            pw.Text('Witness 2', style: style),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Sdl............ (1st party)', style: style),
            pw.SizedBox(height: 30),
            pw.Text('Sdl............ (2nd party)', style: style),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      'A company incorporated under the Indian Companies Act, 1956 (Central Act 1 of 1956), having its registered office at Vydyuthi Bhavanam, Pattom, '
      'Thiruvananthapuram, and represented by the Assistant Engineer, Kerala State Electricity Board, ${customer?.electricalSection ?? ''} hereinafter referred to as "KSEB Limited" (which expression shall, '
      'unless excluded by or repugnant to the context or meaning hereof, be deemed to include its successors, representatives, and assignees), as the Second Party to this Agreement',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
  ];
}

List<pw.Widget> _buildWhereasSection(pw.TextStyle style) {
  return [
    pw.Text(
      'Whereas, the consumer has installed a solar energy system at the premises owned and possessed by him/her or owned by and possessed by the consumer '
      'under a valid lease agreement [strike out whichever is not applicable] and has requested KSEB Limited to provide connectivity to the said plant.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'whereas, the KSEB Limited agrees to provide to the consumer, a Solar Plant Identification Number (SPIN)......................as scheduled in the agreement for the electricity',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'Generated from the above plant having capacity ${customer?.inverterCapacity ?? ''} as per conditions of this Agreement and the regulations or orders'
      ' issued by the Kerala State Electricity Regulatory Commission (Renewable energy & net metering) Regulation, 2020 as amended from time to time;',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'whereas the consumer has, in addition to those automatic and in-built isolation devices within inverter and external manual relays, '
      'installed a manually operated isolating switch and associated equipment with sufficient safeguards between the solar energy system and the distribution '
      'system of KSEB Limited to prevent injection of electricity from his solar energy system to the distribution system of the licensee when the distribution system is de-energized;',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'whereas the consumer has assured that in case of a power outage in the system of KSEB Limited his/her plant will not inject power into the distribution '
      'system of the licensee and has produced separately the documents substantiating this assurance which form part of this agreement, as if incorporated here in;',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'Whereas. the consumer has undertaken that all the equipment connected to the distribution system comply with relevant international (IEEE/IEC) or '
      'Indian standards (BIS) and that installations of electrical equipment comply with the relevant provisions of the Central Electricity Authority '
      '(Measures relating to Safety and Electric Supply) Regulations. 2010 as amended from time to time.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Witness 1', style: style),
            pw.SizedBox(height: 5),
            pw.Text('Witness 2', style: style),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Sdl............ (1st party)', style: style),
            pw.SizedBox(height: 30),
            pw.Text('Sdl............ (2nd party)', style: style),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      'And whereas, the consumer undertakes that he/she possesses all the necessary approvals and clearances, including sanction from the Electrical Inspector, '
      'as specified in the relevant regulations, for connecting the solar energy system to the distribution system and for its commissioning.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      'And whereas, the consumer has deposited an amount of Rs ${customer?.KsebExpense ?? ''} by CASH as per receipt No:....................dated...................at '
      'Electrical Section office ${customer?.electricalSection ?? ''} as security deposit for the installation of solar meter and net meter and shall remit the meter rent.',
      style: style,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
  ];
}

List<pw.Widget> _buildAgreementSection(
    pw.TextStyle bodyStyle, pw.TextStyle clauseStyle) {
  return [
    pw.Text('Now, therefore, both the parties hereby agree as follows: -',
        style: bodyStyle),
    pw.SizedBox(height: 10),
    pw.Text(
      '1. The net-metering connection shall be governed by the provisions contained in the Kerala State Electricity Regulatory Commission (Grid Interactive '
      'Distributed Solar Energy Systems) Regulations,2014 as amended from time to time and also subject to. The condition that- the - solar energy system '
      'meets the requirements as per the provisions contained in Central Electricity Authority (Technical Standard for Connectivity of the Distributed Generation Resources) Regulations.2013 as amended from time to time.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '2. KSEB Limited shall have the sole authority to decide. based on the results of necessary studies, the interface/interconnection point to the solar energy system.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '3. The validity of the agreement will be 25 years from date of this agreement',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '4. If the consumer\'s solar energy system either causes damage to and/or produces adverse effects affecting other consumers or assets of KSEB Limited the '
      'consumer will have to disconnect solar energy system immediately from the distribution system upon direction from the KSEB Limited and correct the '
      'defect at his/her own expense prior to reconnection.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '5. KSEB Limited shall have access to the metering equipment and disconnecting means for solar energy system in all required situations.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '6. KSEB Limited shall have the right to disconnect solar energy system from the distribution system of the licensee in emergency, if it is found that '
      'at that point in time providing service through the net metering system is not safe to the grid as a whole.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Witness 1', style: bodyStyle),
            pw.SizedBox(height: 5),
            pw.Text('Witness 2', style: bodyStyle),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Sdl............ (1st party)', style: bodyStyle),
            pw.SizedBox(height: 30),
            pw.Text('Sdl............ (2nd party)', style: bodyStyle),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      '7. (a) The consumer indemnifies KSEB Limited for the damages or adverse effects. if any from the negligence or intentional defective operation in the '
      'connection and operation of the solar energy system of the consumer;',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '(b) The KSEB Limited indemnifies the consumer for the damages or adverse effects, If any, from the negligence or intentional defective operation in the '
      'connection and operation of the distribution system of KSEB Limited',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '8. KSEB Limited shall not be liable for delivery to or realization by the eligible consumer of any fiscal or other incentives provided by the '
      'Central/State Government or any other authority;',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '9. All the commercial settlements under this agreement shall follow the provisions of the Kerala State Electricity Regulatory Commission '
      '(Grid Interactive Distributed Solar Energy Systems) Regulations.2020 as amended from time to time.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '10. The consumer may terminate this agreement after giving thirty days\' (30 days) clear notice in writing to the authorized authority of the Licensee.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '11. KSEB Limited has the right to terminate this agreement at any point in time after giving 30 days\' prior notice. if consumer breaches any terms '
      'of this agreement and in cases where such breaches could be rectified and the same are not provided/informed within 30days of written notice from'
      ' KSEB Limited about the breach.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '12. The consumer agrees that upon termination of this agreement, he must disconnect the solar energy system from distribution system of KSEB Limited in '
      'a timely manner to the satisfaction of KSEB Limited.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '13. The consumer shall have the right to bank and use the electricity generated and injected in excess over his/her full consumption. into the distribution '
      'system of the licensee by the solar energy system. subject to the conditions specified in the Kerala State Electricity Regulatory Commission (Renewable Energy & Net Metering) Regulations,2020 as amended from time to time.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Witness 1', style: bodyStyle),
            pw.SizedBox(height: 5),
            pw.Text('Witness 2', style: bodyStyle),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Sdl............ (1st party)', style: bodyStyle),
            pw.SizedBox(height: 30),
            pw.Text('Sdl............ (2nd party)', style: bodyStyle),
          ],
        ),
      ],
    ),
    pw.SizedBox(height: 20),
  ];
}

List<pw.Widget> _buildFinalSection(
    pw.TextStyle bodyStyle, pw.TextStyle clauseStyle) {
  return [
    pw.Text(
      '14. The consumer shall have the right for wheeling the electricity generated. by the solar energy system installed in the premises of the consumer '
      '(detailed under item II of the attached schedule) in accordance with regulation 17 of KSERC (Renewable energy & net metering) Regulation, 2020 as '
      'amended from time to time and shall be used in the premises owned by the consumer and in the order of preference as detailed under Item III of the attached schedule.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '15. The Licensee shall commission the solar energy system within seven days from the date of execution of this Agreement.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.Text(
      '16. The licensee shall pay for the net energy banked by the consumer at the end of the settlement period at the average pooled purchase cost of electricity '
      'as approved by the Commission for that year, as provided for in the Kerala State Electricity Regulatory Commission (Renewable energy & net metering)'
      ' Regulations,2020 as amended from time to time.',
      style: clauseStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      'In witness whereof, the said ${customer?.customerName ?? ''} (First Party) the said Assistant Engineer, Kerala State Electricity Board,'
      ' ${customer?.electricalSection ?? ''} (Second Party), have here into signed this Agreement on the day and year first above written.',
      style: bodyStyle,
      textAlign: pw.TextAlign.justify,
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Witness 1', style: bodyStyle),
            pw.SizedBox(height: 5),
            pw.Text('Witness 2', style: bodyStyle),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Sdl............ (1st party)', style: bodyStyle),
            pw.SizedBox(height: 30),
            pw.Text('Sdl............ (2nd party)', style: bodyStyle),
          ],
        ),
      ],
    ),
  ];
}
