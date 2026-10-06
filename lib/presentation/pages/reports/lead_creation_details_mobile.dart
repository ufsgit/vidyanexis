import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/lead_creation_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';

class LeadCreationDetailsMobile extends StatelessWidget {
  final int employeeId;
  final String fromDate;
  final String toDate;

  const LeadCreationDetailsMobile({
    super.key,
    required this.employeeId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Creation Details',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<LeadCreationDetailsProvider>(
        builder: (context, detailsProvider, child) {
          return _buildReportList(context, detailsProvider);
        },
      ),
    );
  }

  Widget _buildReportList(
      BuildContext context, LeadCreationDetailsProvider detailsProvider) {
    if (detailsProvider.isLoading && detailsProvider.detailedReports.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (detailsProvider.detailedReports.isEmpty) {
      return const CommonEmptyState(message: 'No lead creation details found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detailsProvider.detailedReports.length,
      itemBuilder: (context, index) {
        var record = detailsProvider.detailedReports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer: ${record.customerName}',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    InkWell(
                      onTap: () {
                        if (record.customerId != 0) {
                          context.push(
                              '${CustomerDetailsScreen.route}${record.customerId.toString()}/${'true'}');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.account_circle, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Created By: ${record.createdByName}',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.black87, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Contact: ${record.contactNumber}',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.black87, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.source, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Source: ${record.enquirySourceName}',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.black87, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Created At: ${_formatDateTime(record.creationDate)}',
                        style: GoogleFonts.plusJakartaSans(
                            color: Colors.black87, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
