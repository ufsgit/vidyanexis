import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_check_in_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';

class LeadCheckInReportMobile extends StatefulWidget {
  const LeadCheckInReportMobile({super.key});

  @override
  State<LeadCheckInReportMobile> createState() =>
      _LeadCheckInReportMobileState();
}

class _LeadCheckInReportMobileState extends State<LeadCheckInReportMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportProvider =
          Provider.of<LeadCheckInReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      // Load staff list if not already loaded
      if (dropdownProvider.searchUserDetails.isEmpty) {
        dropdownProvider.getUserDetails(context);
      }

      // Fetch initial reports if filters are set or just to show recent
      if (reportProvider.reports.isEmpty && !reportProvider.isLoading) {
        reportProvider.fetchReports(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<LeadCheckInReportProvider>(context);
    final dropdownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: 'Check-in Reports',
        showExcel: false,
        showSearch: false,
        onSearch: (query) {},
        leadingWidget: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        onFilterTap: () => reportProvider.toggleFilter(),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (reportProvider.isFilter)
              _buildFilters(context, reportProvider, dropdownProvider),
            Expanded(
              child: reportProvider.isLoading && reportProvider.reports.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : reportProvider.reports.isEmpty
                      ? _buildEmptyState()
                      : _buildReportList(reportProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => reportProvider.fetchReports(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No check-in reports found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(LeadCheckInReportProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.reports.length,
      itemBuilder: (context, index) {
        final record = provider.reports[index];
        return _buildReportCard(record, provider);
      },
    );
  }

  Widget _buildReportCard(
      LeadCheckIn record, LeadCheckInReportProvider provider) {
    final diff = provider.calculateTimeDifference(record);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    record.userDetailsName ?? 'Unknown Staff',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    diff,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.leadName ?? 'Unknown Lead',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTimeInfo('Check-in', record.checkinDate,
                      record.checkinLocation, Icons.login),
                ),
                Container(
                  height: 100,
                  width: 1,
                  color: Colors.grey[100],
                ),
                Expanded(
                  child: _buildTimeInfo('Check-out', record.checkoutDate,
                      record.checkoutLocation, Icons.logout),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(
      String label, String? dateStr, String? location, IconData icon) {
    String formatted = 'N/A';
    if (dateStr != null && dateStr.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(dateStr);
        formatted = DateFormat('hh:mm a').format(dt);
      } catch (e) {
        formatted = dateStr;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14, color: AppColors.primaryBlue.withOpacity(0.6)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatted,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          if (dateStr != null && dateStr.isNotEmpty)
            Text(
              DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr)),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: Colors.grey[400],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            location ?? 'No location captured',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, LeadCheckInReportProvider provider,
      DropDownProvider dropdownProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterLabel('Lead Name'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: (val) => provider.setLeadSearch(val),
              decoration: const InputDecoration(
                hintText: 'Search leads...',
                border: InputBorder.none,
                icon: Icon(Icons.search, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterLabel('Quick Select Date'),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(provider.dateButtonTitles.length,
                  (index) {
                String title = provider.dateButtonTitles[index];
                bool isSelected = provider.selectedDateFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    onPressed: () {
                      provider.setDateFilter(title);
                      provider.selectDateFilterOption(index);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    label: Text(title, style: const TextStyle(fontSize: 11)),
                    backgroundColor:
                        isSelected ? AppColors.primaryBlue : Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilterLabel('Custom Date Range'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  context,
                  'From',
                  provider.fromDate,
                  (date) {
                    provider.setDates(date, provider.toDate);
                    provider.selectDateFilterOption(null);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTile(
                  context,
                  'To',
                  provider.toDate,
                  (date) {
                    provider.setDates(provider.fromDate, date);
                    provider.selectDateFilterOption(null);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterLabel('Staff'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<int>(
              isExpanded: true,
              underline: const SizedBox(),
              value: provider.selectedUserId,
              hint: const Text('All Staff'),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('All Staff'),
                ),
                ...dropdownProvider.searchUserDetails.map((staff) {
                  return DropdownMenuItem<int>(
                    value: staff.userDetailsId,
                    child: Text(staff.userDetailsName),
                  );
                }),
              ],
              onChanged: (val) {
                provider.setUserId(val);
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => provider.fetchReports(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Show',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  provider.clearFilters();
                  provider.fetchReports(context);
                },
                child: const Text('Reset', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildDateTile(BuildContext context, String label, DateTime? date,
      Function(DateTime?) onSelected) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 10, color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('dd MMM yyyy').format(date)
                  : 'Select Date',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
