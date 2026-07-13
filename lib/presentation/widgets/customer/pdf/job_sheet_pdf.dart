import 'package:vidyanexis/controller/models/job_sheet_model.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import '../../../../http/http_urls.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

pw.MemoryImage? customer;
pw.MemoryImage? technician;

Future<void> generateJobSheetPdf(
    {required JobSheetData jobSheet,
    required LeadDetails customerData,
    bool isShare = false}) async {
  final pdf = pw.Document();

  customer = await _loadImageFromNetwork(
      HttpUrls.imgBaseUrl + jobSheet.customerSignature);
  technician = await _loadImageFromNetwork(
      HttpUrls.imgBaseUrl + jobSheet.technicianSignature);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(60),
      build: (context) => [
        _buildHeader(),
        pw.SizedBox(height: 20),
        ..._buildCustomerDetails(customerData, jobSheet),
        pw.SizedBox(height: 20),
        ..._buildServiceVisitDetails(jobSheet),
        pw.SizedBox(height: 20),
        ..._buildSystemPerformance(jobSheet),
        pw.SizedBox(height: 20),
        ..._buildMaintenanceTasks(jobSheet),
        pw.SizedBox(height: 20),
        ..._buildObservationsAndActions(jobSheet),
        pw.SizedBox(height: 20),
        ..._buildNextServiceAndFeedback(jobSheet),
        pw.SizedBox(height: 20),
        ..._buildSignatures(jobSheet),
      ],
    ),
  );

  if (isShare) {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'JobSheet_${customerData.customerName}.pdf',
    );
  } else {
    // Save the PDF
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: 'JobSheet_${customerData.customerName}.pdf',
    );
  }
}

pw.Widget _buildHeader() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Text(
        'BODHIE SOLAR - PERIODICAL SERVICE REPORT',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
      ),
      pw.Divider(thickness: 1),
      pw.Text(
        'MNRE Empanelled Solar EPC Company, Kerala',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
      ),
      pw.Text(
        'Customer Service & Maintenance Department',
        style: pw.TextStyle(fontSize: 12),
      ),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text('Support: +91-XXXXXXXXXX  |',
              style: pw.TextStyle(fontSize: 12)),
          pw.SizedBox(width: 5),
          pw.Text('www.bodhiesolar.com', style: pw.TextStyle(fontSize: 12)),
        ],
      ),
    ],
  );
}

List<pw.Widget> _buildCustomerDetails(
    LeadDetails customerData, JobSheetData jobSheet) {
  return [
    pw.Text(
      '1. CUSTOMER DETAILS',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      children: [
        pw.Text('Customer Name:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(customerData.customerName.isNotEmpty
            ? customerData.customerName
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Address:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(customerData.address.isNotEmpty
              ? customerData.address
              : '________________________'),
        ),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Contact No.:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(customerData.contactNumber.isNotEmpty
              ? customerData.contactNumber
              : '________________________'),
        )
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Email ID:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(customerData.email.isNotEmpty
              ? customerData.email
              : '________________________'),
        )
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('System Location:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(customerData.location.isNotEmpty
              ? customerData.location
              : '________________________'),
        )
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('System Capacity (kWp):',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text(customerData.panelCapacity > 0
              ? customerData.inverterCapacity.toString()
              : '________________________'),
        )
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Inverter Serial No:'),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Text('________________________'),
        )
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Date of Installation:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.technicianSignatureDate.isNotEmpty
            ? jobSheet.technicianSignatureDate.toDDMMYYYY()
            : '________________________'),
      ],
    ),
  ];
}

List<pw.Widget> _buildServiceVisitDetails(JobSheetData jobSheet) {
  return [
    pw.Text(
      '2. SERVICE VISIT DETAILS',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      children: [
        pw.Text('Date of Visit:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.technicianSignatureDate.isNotEmpty
            ? jobSheet.technicianSignatureDate.toDDMMYYYY()
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Service Type:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.serviceType.isNotEmpty
            ? jobSheet.serviceType
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Weather Conditions:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.weatherCondition.isNotEmpty
            ? jobSheet.weatherCondition
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Technician(s) Name(s):',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        //
      ],
    ),
  ];
}

pw.Widget _buildCheckbox(bool value) {
  return pw.Container(
    width: 12,
    height: 12,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 1),
    ),
    child: value
        ? pw.Center(
            child: pw.Container(
              width: 8,
              height: 8,
              color: PdfColors.black,
            ),
          )
        : null,
  );
}

List<pw.Widget> _buildSystemPerformance(JobSheetData jobSheet) {
  return [
    pw.Text(
      '3. SYSTEM PERFORMANCE CHECK',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 200,
          child: pw.Text("Component",
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        ),
        pw.Container(
          width: 60,
          child: pw.Text("Status",
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        ),
        pw.Container(
          width: 200,
          child: pw.Text("Remarks",
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        ),
      ],
    ),
    pw.SizedBox(height: 8),
    ...jobSheet.systemPerformanceCheck.map((component) {
      return pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 200,
              child: pw.Text(component.component),
            ),
            pw.SizedBox(width: 10),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: _buildCheckbox(component.componentStatus == 1),
            ),
            pw.SizedBox(width: 40), // Adjusted from 40 for visual alignment
            pw.Container(
              width: 200,
              child: pw.Text(component.remarkController.text),
            ),
          ],
        ),
      );
    }),
  ];
}

List<pw.Widget> _buildMaintenanceTasks(JobSheetData jobSheet) {
  return [
    pw.Text(
      '4. CLEANING & MAINTENANCE TASKS',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    ...jobSheet.cleaningMaintenanceTask.map((task) {
      return pw.Row(
        children: [
          pw.Container(
            width: 200, // set your max width here
            child: pw.Text(
              '${task.taskName}:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Padding(
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Row(
              children: [
                _buildCheckbox(task.isYes == 1),
                pw.SizedBox(width: 5),
                pw.Text('Yes'),
                pw.SizedBox(width: 40),
                _buildCheckbox(task.isNo == 1),
                pw.SizedBox(width: 5),
                pw.Text('No'),
                pw.SizedBox(width: 40),
                _buildCheckbox(task.isYes != 1 && task.isNo != 1),
                pw.SizedBox(width: 5),
                pw.Text('N/A'),
              ],
            ),
          )
        ],
      );
    }),
    pw.SizedBox(height: 8),
    pw.Row(
      children: [
        pw.Text('Net Meter Reading (Today):',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.nextMeterReading.isNotEmpty
            ? '${jobSheet.nextMeterReading} kWh'
            : '________________________ kWh'),
      ],
    ),
  ];
}

List<pw.Widget> _buildObservationsAndActions(JobSheetData jobSheet) {
  return [
    pw.Text(
      '5. OBSERVATIONS & ISSUES (If Any)',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Container(
      width: double.infinity,
      // padding: pw.EdgeInsets.all(8),
      // decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Text(jobSheet.observation.isNotEmpty
          ? jobSheet.observation
          : '______________________________________________________________________________________\n'
              '______________________________________________________________________________________'),
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      '6. ACTION TAKEN',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Container(
      width: double.infinity,
      // padding: pw.EdgeInsets.all(8),
      // decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Text(jobSheet.actionTaken.isNotEmpty
          ? jobSheet.actionTaken
          : '______________________________________________________________________________________\n'
              '______________________________________________________________________________________'),
    ),
  ];
}

List<pw.Widget> _buildNextServiceAndFeedback(JobSheetData jobSheet) {
  return [
    pw.Text(
      '7. NEXT SCHEDULED SERVICE',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      children: [
        pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.nextScheduledDate.isNotEmpty
            ? jobSheet.nextScheduledDate.toDDMMYYYY()
            : '________________________'),
        pw.SizedBox(width: 20),
        pw.Text('Type:', style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.nextScheduledDateName.isNotEmpty
            ? jobSheet.nextScheduledDateName
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 20),
    pw.Text(
      '8. CUSTOMER FEEDBACK',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 10),
    pw.Row(
      children: [
        pw.Text('Overall Satisfaction:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(width: 10),
        pw.Text(jobSheet.customerOverallSatisfactionName.isNotEmpty
            ? jobSheet.customerOverallSatisfactionName
            : '________________________'),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Additional Remarks:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal)),
        pw.SizedBox(height: 5),
        pw.Container(
          width: double.infinity,
          // padding: pw.EdgeInsets.all(8),
          // decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Text(jobSheet.additionalRemark.isNotEmpty
              ? jobSheet.additionalRemark
              : '______________________________________________________________________________________'),
        ),
      ],
    ),
  ];
}

List<pw.Widget> _buildSignatures(JobSheetData jobSheet) {
  return [
    pw.Text(
      '9. SIGNATURES',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
    ),
    pw.SizedBox(height: 20),
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Technician:'),
            pw.SizedBox(height: 5),
            pw.Image(technician!, width: 100, height: 100),
            pw.SizedBox(height: 5),
            pw.Text(
                'Date: ${jobSheet.technicianSignatureDate.isNotEmpty ? jobSheet.technicianSignatureDate.toDDMMYYYY() : '________________________'}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Customer:'),
            pw.SizedBox(height: 5),
            pw.Image(customer!, width: 100, height: 100),
            pw.SizedBox(height: 5),
            pw.Text(
                'Date: ${jobSheet.customerSignatureDate.isNotEmpty ? jobSheet.customerSignatureDate.toDDMMYYYY() : '________________________'}'),
          ],
        ),
      ],
    ),
  ];
}


Future<pw.MemoryImage> _loadImageFromNetwork(String logoUrl) async {
  final response = await http.get(Uri.parse(logoUrl));
  if (response.statusCode == 200) {
    final imageBytes = response.bodyBytes;
    return pw.MemoryImage(imageBytes); // Return as MemoryImage
  } else {
    throw Exception('Failed to load logo');
  }
}
