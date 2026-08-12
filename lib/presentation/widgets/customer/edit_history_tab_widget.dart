import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

class EditHistoryTabWidget extends StatelessWidget {
  final String customerId;

  const EditHistoryTabWidget({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isLeadHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.leadHistoryReportList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "No edit history found",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        final isWeb = AppStyles.isWebScreen(context);

        if (isWeb) {
          return _buildWebView(context, provider);
        } else {
          return _buildMobileView(context, provider);
        }
      },
    );
  }

  Widget _buildWebView(BuildContext context, CustomerDetailsProvider provider) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE9EDF1)),
        ),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Edit Log History",
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE9EDF1)),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2), // Field Name
                    1: FlexColumnWidth(2), // Old Value
                    3: FlexColumnWidth(2.5), // Edited On
                    4: FlexColumnWidth(2), // Edited By
                  },
                  children: [
                    // Table Header
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                      ),
                      children: [
                        _tableHeaderCell("Field Name"),
                        _tableHeaderCell("Old Value"),
                        _tableHeaderCell("Edited On"),
                        _tableHeaderCell("Edited By"),
                      ],
                    ),
                    // Table Rows
                    ...provider.leadHistoryReportList.map((history) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFE9EDF1), width: 0.5),
                          ),
                        ),
                        children: [
                          _tableCell(history.fieldName ?? ""),
                          _tableCell(history.oldValue ?? ""),
                          _tableCell(_formatDate(history.entryDate ?? "")),
                          _tableCell(history.userName ?? ""),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView(
      BuildContext context, CustomerDetailsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.leadHistoryReportList.length,
      itemBuilder: (context, index) {
        final history = provider.leadHistoryReportList[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFFE9EDF1)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        history.fieldName ?? "Field",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(history.entryDate ?? ""),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Old Value",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            history.oldValue ?? "-",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: Colors.grey),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFE9EDF1)),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "Edited by: ${history.userName}",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF475569),
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF334155),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return "-";
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy hh:mm:ss a').format(dateTime.toLocal());
    } catch (e) {
      return dateStr;
    }
  }
}
