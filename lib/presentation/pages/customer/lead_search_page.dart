import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_lead_search_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class LeadSearchPage extends StatelessWidget {
  static const String route = '/leadSearch';

  const LeadSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerLeadSearchProvider>(context);

    // Completely disable on mobile as per user request
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(
          child: Text('Page Not Found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildWebHeader(context, provider),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.leadResults.isEmpty
                    ? _buildEmptyState()
                    : _buildWebTable(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          CustomText(
            'No Leads Found',
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildWebHeader(
      BuildContext context, CustomerLeadSearchProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          const Spacer(),
          Container(
            width: 280,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: const Color(0xFFCBD5E1), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: provider.contactNoController,
              textAlignVertical: TextAlignVertical.center,
              onTap: () {
                Future.microtask(() {
                  if (provider.contactNoController.text.isNotEmpty &&
                      provider.contactNoController.selection.baseOffset == 0 &&
                      provider.contactNoController.selection.extentOffset == provider.contactNoController.text.length) {
                    provider.contactNoController.selection = TextSelection.collapsed(offset: provider.contactNoController.text.length);
                  }
                });
              },
              onSubmitted: (query) => provider.searchLeadByContact(),
              decoration: InputDecoration(
                hintText: 'Search Contact Number...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                suffixIcon: GestureDetector(
                  onTap: () => provider.searchLeadByContact(),
                  child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildWebTable(
      BuildContext context, CustomerLeadSearchProvider provider) {
    const tableHeaderHeight = 40.0;
    const rowHeight = 45.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Table Header
          Container(
            height: tableHeaderHeight,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: const [
                TableWidget(
                  width: 60,
                  alignment: Alignment.center,
                  title: 'SL',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 80,
                  alignment: Alignment.center,
                  title: 'ID',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  flex: 2,
                  title: 'Name',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 120,
                  title: 'Contact',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 120,
                  title: 'Entry Date',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 150,
                  title: 'Status',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 150,
                  title: 'Department',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 150,
                  title: 'Assigned To',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 150,
                  title: 'Follow-up',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  width: 100,
                  title: 'Branch',
                  color: Colors.white,
                  fontSize: 13,
                ),
                TableWidget(
                  flex: 3,
                  title: 'Remark',
                  color: Colors.white,
                  fontSize: 13,
                ),
              ],
            ),
          ),
          // Table Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: ListView.builder(
                itemCount: provider.leadResults.length,
                itemBuilder: (context, index) {
                  final lead = provider.leadResults[index];
                  return Container(
                    height: rowHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[100]!),
                      ),
                      color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        TableWidget(
                          width: 60,
                          alignment: Alignment.center,
                          data: Text('${index + 1}',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 80,
                          alignment: Alignment.center,
                          data: Text('${lead.customerId}',
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        TableWidget(
                          flex: 2,
                          data: Text(lead.customerName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 120,
                          data: Text(lead.contactNumber ?? '',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 120,
                          data: Text(_formatDate(lead.entryDate),
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 150,
                          data: _buildWebStatusBadge(lead.statusName ?? ''),
                        ),
                        TableWidget(
                          width: 150,
                          data: Text(lead.departmentName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 150,
                          data: Text(lead.toUserName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 150,
                          data: Text(lead.nextFollowUpDate ?? '',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          width: 100,
                          data: Text(lead.branchName ?? '',
                              style: const TextStyle(fontSize: 12)),
                        ),
                        TableWidget(
                          flex: 3,
                          data: Text(lead.remark ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatusBadge(String status) {
    Color color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final s = status.toLowerCase();
    if (s.contains('sitevisit')) return Colors.orange;
    if (s.contains('converted')) return Colors.green;
    if (s.contains('ready')) return Colors.green;
    if (s.contains('follow')) return Colors.blue;
    if (s.contains('pending')) return Colors.red;
    return AppColors.primaryBlue;
  }
}
