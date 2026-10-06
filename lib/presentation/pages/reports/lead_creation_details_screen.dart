import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_creation_details_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_creation_details_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class LeadCreationDetailsScreen extends StatefulWidget {
  static const String route = '/leadCreationDetails';
  final int employeeId;
  final String fromDate;
  final String toDate;

  const LeadCreationDetailsScreen({
    super.key,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  _LeadCreationDetailsScreenState createState() => _LeadCreationDetailsScreenState();
}

class _LeadCreationDetailsScreenState extends State<LeadCreationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final detailsProvider =
          Provider.of<LeadCreationDetailsProvider>(context, listen: false);
      detailsProvider.fetchDetailedReports(
        context,
        employeeId: widget.employeeId,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return LeadCreationDetailsMobile(
        employeeId: widget.employeeId,
        fromDate: widget.fromDate,
        toDate: widget.toDate,
      );
    }

    final detailsProvider = Provider.of<LeadCreationDetailsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Creation Details',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            _buildHeader(context, detailsProvider),
            Expanded(
              child: _buildReportList(context, detailsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, LeadCreationDetailsProvider detailsProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Spacer(),
          CommonReportExportButton(
            onPressed: () {
              exportToExcel(
                headers: [
                  'Created By',
                  'Customer Name',
                  'Contact Number',
                  'Enquiry Source',
                  'Address',
                  'Creation Date',
                ],
                data: detailsProvider.detailedReports.map((record) {
                  return {
                    'Created By': record.createdByName,
                    'Customer Name': record.customerName,
                    'Contact Number': record.contactNumber,
                    'Enquiry Source': record.enquirySourceName,
                    'Address': record.address1,
                    'Creation Date': _formatDateTime(record.creationDate),
                  };
                }).toList(),
                fileName: 'Lead_Creation_Details',
              );
            },
            label: 'Export to Excel',
          ),
        ],
      ),
    );
  }

  Widget _buildWebTableHeader() {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Center(
                    child: Text('No.',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF607185))),
                  ),
                ),
              ),
              const TableWidget(
                  flex: 2, title: 'Customer Name', color: Color(0xFF607185)),
              const TableWidget(
                  flex: 2, title: 'Created By', color: Color(0xFF607185)),
              const TableWidget(
                  flex: 2, title: 'Contact No', color: Color(0xFF607185)),
              const TableWidget(
                  flex: 2, title: 'Enquiry Source', color: Color(0xFF607185)),
              const TableWidget(
                  width: 180, title: 'Creation Date', color: Color(0xFF607185)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebTableRow(
      dynamic record, int index, BuildContext context) {
    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.white : const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Center(
                    child: Text((index + 1).toString(),
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ),
              TableWidget(
                flex: 2,
                data: InkWell(
                  onTap: () {
                    if (record.customerId != 0) {
                      context.push(
                          '${CustomerDetailsScreen.route}${record.customerId.toString()}/${'true'}');
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 15,
                          color: Color(0xFF152D70),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            record.customerName.isEmpty ? 'N/A' : record.customerName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Color(0xFF152D70),
                        ),
                      ],
                    ),
                  ),
                ),
              TableWidget(
                flex: 2,
                data: Row(
                  mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 15,
                        color: Color(0xFF152D70),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          record.createdByName.isEmpty ? 'N/A' : record.createdByName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              TableWidget(
                  flex: 2,
                  fontSize: 12,
                  title: record.contactNumber.isEmpty ? 'N/A' : record.contactNumber),
              TableWidget(
                  flex: 2,
                  fontSize: 12,
                  title: record.enquirySourceName.isEmpty ? 'N/A' : record.enquirySourceName),
              TableWidget(
                  width: 180,
                  fontSize: 12,
                  title: _formatDateTime(record.creationDate)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportList(
      BuildContext context, LeadCreationDetailsProvider detailsProvider) {
    if (detailsProvider.isLoading && detailsProvider.detailedReports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildWebTableHeader(),
        Expanded(
          child: detailsProvider.detailedReports.isEmpty
              ? const CommonEmptyState(message: 'No lead creation details found')
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: detailsProvider.detailedReports.length,
                  itemBuilder: (context, index) {
                    var record = detailsProvider.detailedReports[index];
                    return _buildWebTableRow(record, index, context);
                  },
                ),
        ),
        if (detailsProvider.detailedReports.isNotEmpty)
          Container(
            color: Colors.grey[50],
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Container(
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
