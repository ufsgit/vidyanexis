import 'dart:core';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/lead_details_model.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';

Future<pw.MemoryImage?> _loadLogoImage() async {
  try {
    final logoPath = AppStyles.logo();
    if (logoPath.startsWith('http')) {
      final response = await http.get(Uri.parse(logoPath));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } else if (logoPath.startsWith('assets/')) {
      final bytes = await rootBundle.load(logoPath);
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } else {
      final bytes = await rootBundle.load('assets/images/Icon-512.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    }
  } catch (e) {
    print('Error loading logo: $e');
    try {
      final bytes = await rootBundle.load('assets/images/Icon-512.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }
  return null;
}

bool _isValidValue(dynamic val) {
  if (val == null) return false;
  final str = val.toString().trim();
  if (str.isEmpty ||
      str == 'null' ||
      str == '0' ||
      str == '0.0' ||
      str == '0.00' ||
      str == 'false') {
    return false;
  }
  return true;
}

Future<void> generateCustomerDetailsPdf({
  required LeadDetails customerData,
  required List<CustomFieldByStatusId> customFields,
  required String companyName,
}) async {
  final logoImage = await _loadLogoImage();
  final pdf = pw.Document();

  // Filter and map custom fields
  final activeCustomFields = customFields
      .where((field) =>
          field.customFieldName != null &&
          field.customFieldName!.toString().isNotEmpty &&
          _isValidValue(field.datavalue))
      .toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      header: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        );
      },
      build: (pw.Context context) {
        final sectionHeaderStyle = pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.indigo900,
        );
        final labelStyle = pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.indigo900,
        );
        final valueStyle = const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey900,
        );

        pw.Widget buildDetailRow(String label, String value, bool isEven) {
          return pw.Container(
            color: isEven ? PdfColor.fromHex('#F9FAFB') : PdfColors.white,
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 150,
                  child: pw.Text(label, style: labelStyle),
                ),
                pw.Expanded(
                  child: pw.Text(value, style: valueStyle),
                ),
              ],
            ),
          );
        }

        pw.Widget? buildSectionCard(String title, List<MapEntry<String, String>> fields) {
          final validFields = fields.where((entry) => _isValidValue(entry.value)).toList();
          if (validFields.isEmpty) return null;

          return pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.only(bottom: 14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.only(
                      topLeft: pw.Radius.circular(6),
                      topRight: pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 3,
                        height: 12,
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.indigo700,
                          borderRadius: pw.BorderRadius.all(pw.Radius.circular(1.5)),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Text(title, style: sectionHeaderStyle),
                    ],
                  ),
                ),
                pw.Divider(height: 1, color: PdfColors.grey200, thickness: 0.5),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Column(
                    children: List.generate(validFields.length, (index) {
                      final field = validFields[index];
                      return buildDetailRow(field.key, field.value, index % 2 == 0);
                    }),
                  ),
                ),
              ],
            ),
          );
        }

        final sectionWidgets = <pw.Widget?>[
          // Basic Info with Consumer Name, Consumer Contact No, & Lead Contact No right after Lead Name
          buildSectionCard('Basic Info', [
            MapEntry('Lead Name', customerData.customerName),
            MapEntry('Consumer Name', customerData.consumerName),
            MapEntry('Consumer Contact No', customerData.consumerContactNo),
            MapEntry('Lead Contact No', customerData.contactNumber),
            MapEntry('Status', customerData.statusName),
            MapEntry('Source', customerData.sourceCategoryName),
            MapEntry('Enquiry Source', customerData.enquirySourceName),
            MapEntry('Enquiry For', customerData.enquiryForName),
            MapEntry('Sub Source', customerData.referenceName),
            MapEntry('Branch', customerData.branchName),
            MapEntry('Department', customerData.departmentName),
            MapEntry('Lead Type', customerData.leadTypeName),
            MapEntry('Lead By', customerData.leadBy),
            MapEntry('Sales Rep', customerData.rep),
            MapEntry('Created By', customerData.createdByName ?? ''),
            MapEntry('Assigned To', customerData.toUserName),
            MapEntry('Follow Up By', customerData.byUserName),
            MapEntry('Entry Date', customerData.entryDate ?? ''),
            MapEntry('Next Follow-Up Date', customerData.nextFollowUpDate),
            MapEntry('Remark', customerData.remark),
          ]),

          // Contact Details
          buildSectionCard('Contact Info', [
            MapEntry('Email', customerData.email),
          ]),

          // Address Details
          buildSectionCard('Address Details', [
            MapEntry('Address', customerData.address),
            MapEntry('Address Line 1', customerData.address1 ?? ''),
            MapEntry('Address Line 2', customerData.address2 ?? ''),
            MapEntry('Address Line 3', customerData.address3 ?? ''),
            MapEntry('Address Line 4', customerData.address4 ?? ''),
            MapEntry('District', customerData.districtName ?? ''),
            MapEntry('Pincode', customerData.pinCode ?? ''),
            MapEntry('Latitude', customerData.latitude ?? ''),
            MapEntry('Longitude', customerData.longitude ?? ''),
            MapEntry('Location', customerData.location),
            MapEntry('Map Link', customerData.mapLink ?? ''),
          ]),

          // Technical & System Details
          buildSectionCard('Technical & System Details', [
            MapEntry('Consumer Number', customerData.consumerNumber),
            MapEntry('Electrical Section', customerData.electricalSection),
            MapEntry('Connected Load', customerData.connectedLoad.toString()),
            MapEntry('Phase', customerData.phaseName),
            MapEntry('Roof Type', customerData.roofTypeName),
            MapEntry('Inverter Brand', customerData.inverterBrandName),
            MapEntry('Inverter Type', customerData.inverterTypeName),
            MapEntry('Inverter Capacity', customerData.inverterCapacity.toString()),
            MapEntry('Panel Brand', customerData.panelBrandName),
            MapEntry('Panel Type', customerData.panelTypeName),
            MapEntry('Panel Capacity', customerData.panelCapacity.toString()),
            MapEntry('No of Panels', customerData.noOfPanels),
            MapEntry('Panel Serial No', customerData.panelSerialNo ?? ''),
            MapEntry('Efficiency', customerData.Efficiency),
            MapEntry('Actual RTS Capacity', customerData.actualRTSCapacity),
            MapEntry('Work Type', customerData.workTypeName),
            MapEntry('Subsidy Type', customerData.subsidyTypeName),
          ]),

          // Financial Details
          buildSectionCard('Financial Details', [
            MapEntry('Total Project Cost', customerData.displayProjectCost),
            MapEntry('Additional Cost', customerData.additionalCost.toString()),
            MapEntry('Advance Amount', customerData.advanceAmount.toString()),
            MapEntry('Amount Paid Through', customerData.amountPaidThroughName),
            MapEntry('Cost Includes', customerData.costIncName),
            MapEntry('Commission', customerData.displayCommission),
            MapEntry('KSEB Expense', customerData.KsebExpense),
            MapEntry('Invoice No', customerData.invoiceNo ?? ''),
            MapEntry('Invoice Date', customerData.invoiceDate ?? ''),
            MapEntry('Invoice Amount', customerData.invoiceAmount?.toString() ?? ''),
          ]),

          // Additional & Portal Details
          buildSectionCard('Additional & Portal Details', [
            MapEntry('PE Name', customerData.peName),
            MapEntry('CRE Name', customerData.creName),
            MapEntry('Engineer Name', customerData.engineerName),
            MapEntry('Engineer Mobile', customerData.engineerMobile),
            MapEntry('Engineer City', customerData.engineerCity),
            MapEntry('Engineer District', customerData.engineerDistrict),
            MapEntry('Organization', customerData.organization),
            MapEntry('PM Surya Shakthi Portal ID', customerData.PMSuryaShakthiPortalid),
            MapEntry('Jan Samarth ID', customerData.JanSamarthid),
            MapEntry('Bank Branch', customerData.bankbranch),
            MapEntry('Stage Name', customerData.stageName ?? ''),
            MapEntry('Additional Comments', customerData.additionalComments),
          ]),

          // Custom Fields
          if (activeCustomFields.isNotEmpty)
            buildSectionCard('Additional Details', [
              ...activeCustomFields.map((field) {
                final label = field.customFieldName.toString().replaceAll('_', ' ');
                final value = field.datavalue?.toString() ?? '';
                return MapEntry(label, value);
              }),
            ]),
        ];

        return [
          // Header section
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.indigo700, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null) ...[
                      pw.Container(
                        padding: const pw.EdgeInsets.all(3),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                        ),
                        child: pw.Image(logoImage, width: 42, height: 42, fit: pw.BoxFit.contain),
                      ),
                      pw.SizedBox(width: 12),
                    ],
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          companyName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.indigo900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Customer & Lead Details Report',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'DATE: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'RECORD ID: ${customerData.customerId}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          ...sectionWidgets.whereType<pw.Widget>(),
        ];
      },
    ),
  );

  final leadId = customerData.customerId != 0
      ? customerData.customerId
      : customerData.leadDetailsId;
  final consumerName = customerData.consumerName.trim().isNotEmpty
      ? customerData.consumerName.trim()
      : customerData.customerName.trim();

  final pdfFileName = [
    if (leadId != 0) leadId.toString(),
    if (consumerName.isNotEmpty) consumerName,
  ].join(' ');

  // Layout / print the PDF
  await Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
    name: '${pdfFileName.isNotEmpty ? pdfFileName : companyName}.pdf',
  );
}
