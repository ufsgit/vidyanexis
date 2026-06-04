import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_check_in_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

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

      // Fetch initial reports for login user
      if (reportProvider.reports.isEmpty && !reportProvider.isLoading) {
        reportProvider.initializeWithLoginUser().then((_) {
          reportProvider.fetchReports(context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<LeadCheckInReportProvider>(context);
    final dropdownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const SidebarDrawer(),
      appBar: CustomAppBar(
        title: 'Check-in Reports',
        showExcel: false,
        showSearch: false,
        onSearch: (query) {},
        onFilterTap: () => reportProvider.toggleFilter(),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (reportProvider.isFilter)
              _buildFilters(context, reportProvider, dropdownProvider),
            if (!reportProvider.isFilter)
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: reportProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_lead_check_in_filter_fab',
                  onPressed: () {
                    reportProvider.fetchReports(context);
                    reportProvider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false).stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : FloatingActionButton(
                onPressed: () => reportProvider.fetchReports(context),
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No check-in reports found');
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
        borderRadius: BorderRadius.circular(4),
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
                    record.userDetailsName ??
                        provider.selectedUserName ??
                        'Unknown Staff',
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
                    borderRadius: BorderRadius.circular(4),
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
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _showDateFilterDialog(context);
                  },
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: CustomText(
                                provider.fromDate == null && provider.toDate == null
                                    ? 'Date'
                                    : 'Date : ${provider.formattedFromDate.toString().toDayMonthYearFormat()} - ${provider.formattedToDate.toString().toDayMonthYearFormat()}',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: AppColors.textGrey3, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomText('Staff',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                if (provider.userType != "1")
                  FilterChipWidget(
                    label: 'All',
                    isSelected: provider.selectedUserId == null,
                    onTap: () => provider.setUserId(null, userName: null),
                  ),
                ...dropdownProvider.searchUserDetails
                    .where((staff) =>
                        provider.userType != "1" ||
                        staff.userDetailsId == provider.selectedUserId)
                    .map((staff) => FilterChipWidget(
                          label: staff.userDetailsName ?? 'Unknown',
                          isSelected:
                              provider.selectedUserId == staff.userDetailsId,
                          onTap: () => provider.setUserId(staff.userDetailsId,
                              userName: staff.userDetailsName),
                        )),
              ],
            ),
            const SizedBox(height: 24),
            if (provider.fromDate != null ||
                provider.toDate != null ||
                provider.selectedUserId != null)
              SizedBox(
                width: double.infinity,
                child: CommonReportResetButton(
                  label: 'Reset All Filters',
                  onReset: () {
                    provider.clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textRed,
                    elevation: 0,
                    side: BorderSide(color: AppColors.textRed),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<LeadCheckInReportProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Choose Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: List.generate(provider.dateButtonTitles.length, (index) {
                    return ChoiceChip(
                      label: Text(provider.dateButtonTitles[index]),
                      selected: provider.selectedDateFilterIndex == index,
                      onSelected: (selected) {
                        provider.setDateFilter(provider.dateButtonTitles[index]);
                        provider.selectDateFilterOption(index);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(provider.fromDate != null
                              ? provider.formattedFromDate
                              : 'From'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(provider.toDate != null
                              ? provider.formattedToDate
                              : 'To'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
