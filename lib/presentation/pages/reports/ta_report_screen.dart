import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/travel_allowance_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/travel_allowance_provider.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/add_ta_dialog.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/ta_details_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';

class TAReportScreen extends StatefulWidget {
  static const String route = '/ta_report';
  const TAReportScreen({super.key});

  @override
  State<TAReportScreen> createState() => _TAReportScreenState();
}

class _TAReportScreenState extends State<TAReportScreen> {
  String _approvalFilterMode = 'ALL'; // ALL, PENDING, APPROVED, REJECTED, Approved Only, Non-Approved Only

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taProvider = Provider.of<TravelAllowanceProvider>(context, listen: false);
      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);

      dropDownProvider.getUserDetails(context);
      if (!taProvider.hasFetched) {
        taProvider.fetchTAList(context: context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final taProvider = Provider.of<TravelAllowanceProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    // Permission enforcement: using menuIsViewMap (Attendance / Expense report level or fallback)
    final bool hasReportPermission =
        (settingsProvider.menuIsViewMap[26] ?? 0).toString() == '1' ||
        (settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1' ||
        (settingsProvider.menuIsViewMap[201] ?? 0).toString() == '1';

    if (!hasReportPermission) {
      return Scaffold(
        drawer: isWeb ? null : const SidebarDrawer(),
        appBar: !isWeb
            ? CustomAppBar(
                title: 'TA Reports',
                showSearch: false,
                showFilterIcon: false,
                showSort: false,
                onSearch: (_) {},
              )
            : null,
        backgroundColor: AppColors.scaffoldColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Access Restricted',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view Travel Allowance Reports.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Filter report list based on selected approval filter mode
    final reportItems = taProvider.taList.where((item) {
      final status = (item.status ?? 'Pending').toLowerCase();

      // 1. Staff Filter
      if (taProvider.selectedUserFilter != null &&
          taProvider.selectedUserFilter != 0 &&
          item.userId != taProvider.selectedUserFilter) {
        return false;
      }

      // 2. Date Filter
      if (taProvider.fromDate != null && taProvider.toDate != null && (item.travelDate ?? '').isNotEmpty) {
        try {
          final rawDateStr = item.travelDate!;
          final datePart = rawDateStr.contains('T')
              ? rawDateStr.split('T')[0]
              : (rawDateStr.contains(' ') ? rawDateStr.split(' ')[0] : rawDateStr);
          final formattedIso = datePart.toUniversalYyyyMmDd();
          final tDate = DateTime.parse(formattedIso.isNotEmpty ? formattedIso : datePart);
          final fDate = DateTime(taProvider.fromDate!.year, taProvider.fromDate!.month, taProvider.fromDate!.day);
          final tDateEnd = DateTime(taProvider.toDate!.year, taProvider.toDate!.month, taProvider.toDate!.day, 23, 59, 59);
          if (tDate.isBefore(fDate) || tDate.isAfter(tDateEnd)) return false;
        } catch (_) {}
      }

      // 3. Approval Status Filter Mode
      switch (_approvalFilterMode) {
        case 'APPROVED':
        case 'Approved Only':
          return status == 'approved';
        case 'PENDING':
          return status == 'pending';
        case 'REJECTED':
          return status == 'rejected';
        case 'Non-Approved Only':
          return status != 'approved';
        case 'ALL':
        default:
          return true;
      }
    }).toList();

    // KPI Metrics
    // KPI Metrics Calculation for Requirement 9
    final pendingCount = reportItems.where((i) => (i.status ?? '').toLowerCase() == 'pending').length;
    final approvedCount = reportItems.where((i) => (i.status ?? '').toLowerCase() == 'approved').length;
    final rejectedCount = reportItems.where((i) => (i.status ?? '').toLowerCase() == 'rejected').length;
    final totalDistance = reportItems.fold(0.0, (sum, i) => sum + i.computedTotalKm);
    final totalApproved = reportItems
        .where((i) => (i.status ?? '').toLowerCase() == 'approved')
        .fold(0.0, (sum, i) => sum + i.computedTotalAmount);

    return Scaffold(
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: !isWeb
          ? CustomAppBar(
              title: 'TA Reports',
              showSearch: false,
              showFilterIcon: false,
              showSort: false,
              onSearch: (_) {},
            )
          : null,
      backgroundColor: AppColors.scaffoldColor,
      body: RefreshIndicator(
        onRefresh: () => taProvider.fetchTAList(context: context),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Main Title
              if (isWeb)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.assessment_rounded,
                              color: AppColors.secondaryBlue, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Travel Allowance (TA) Report',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Monthly summary metrics, staff breakdown, and approval status analytics',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => taProvider.exportToExcelReport(context, itemsToExport: reportItems),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Export Excel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF15803D),
                            side: const BorderSide(color: Color(0xFFBBF7D0)),
                            backgroundColor: const Color(0xFFF0FDF4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => taProvider.exportToPDFReport(context, itemsToExport: reportItems),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: const Text('Export PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFDC2626),
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            backgroundColor: const Color(0xFFFEF2F2),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travel Allowance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddTADialog(),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: Text(
                              'Add TA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => taProvider.exportToExcelReport(context, itemsToExport: reportItems),
                            icon: const Icon(Icons.download_rounded, size: 16),
                            label: Text(
                              'Export Excel',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF15803D),
                              side: const BorderSide(color: Color(0xFFBBF7D0)),
                              backgroundColor: const Color(0xFFF0FDF4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // KPI Summary Cards Grid (6 Metric Summary Cards as requested in Req 9)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = isWeb ? (constraints.maxWidth - 60) / 6 : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Total Entries',
                        value: '${reportItems.length}',
                        subtitle: 'Total Claims',
                        icon: Icons.list_alt_rounded,
                        color: AppColors.secondaryBlue,
                        bg: const Color(0xFFEFF6FF),
                      ),
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Pending Entries',
                        value: '$pendingCount',
                        subtitle: 'Awaiting Action',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFD97706),
                        bg: const Color(0xFFFFFBEB),
                      ),
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Approved Entries',
                        value: '$approvedCount',
                        subtitle: 'Verified & Approved',
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF16A34A),
                        bg: const Color(0xFFF0FDF4),
                      ),
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Rejected Entries',
                        value: '$rejectedCount',
                        subtitle: 'Declined Claims',
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFDC2626),
                        bg: const Color(0xFFFEF2F2),
                      ),
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Total Distance',
                        value: '${totalDistance.toStringAsFixed(1)} KM',
                        subtitle: 'Distance Travelled',
                        icon: Icons.directions_car_rounded,
                        color: const Color(0xFF0284C7),
                        bg: const Color(0xFFF0F9FF),
                      ),
                      _buildSummaryTile(
                        width: cardWidth,
                        title: 'Approved TA Amount',
                        value: '₹${totalApproved.toStringAsFixed(2)}',
                        subtitle: 'Total Approved Pay',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF16A34A),
                        bg: const Color(0xFFDCFCE7),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Comprehensive Period & Status Filters Bar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Quick Month Buttons
                    ChoiceChip(
                      label: Text('This Month', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                      selected: false,
                      onSelected: (_) => taProvider.selectThisMonth(),
                      selectedColor: AppColors.secondaryBlue.withOpacity(0.2),
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                    ChoiceChip(
                      label: Text('Last Month', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                      selected: false,
                      onSelected: (_) => taProvider.selectLastMonth(),
                      selectedColor: AppColors.secondaryBlue.withOpacity(0.2),
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),

                    // Date Range Picker
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          initialDateRange: taProvider.fromDate != null && taProvider.toDate != null
                              ? DateTimeRange(start: taProvider.fromDate!, end: taProvider.toDate!)
                              : null,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          taProvider.setDateRange(picked.start, picked.end);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded, size: 16),
                      label: Text(
                        taProvider.fromDate != null && taProvider.toDate != null
                            ? 'Period: ${DateFormat('dd MMM').format(taProvider.fromDate!)} - ${DateFormat('dd MMM').format(taProvider.toDate!)}'
                            : 'Select Month / Date Range',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),

                    // Staff Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: taProvider.selectedUserFilter,
                          icon: const Icon(Icons.person_outline_rounded, size: 18),
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black87),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Staff Members'),
                            ),
                            ...dropDownProvider.searchUserDetails.map((user) {
                              return DropdownMenuItem<int?>(
                                value: user.userDetailsId,
                                child: Text(user.userDetailsName),
                              );
                            }),
                          ],
                          onChanged: (val) => taProvider.setUserFilter(val),
                        ),
                      ),
                    ),

                    // Approval Status Filter Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _approvalFilterMode,
                          icon: const Icon(Icons.filter_list_rounded, size: 18),
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.black87),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('Status: ALL')),
                            DropdownMenuItem(value: 'PENDING', child: Text('Status: PENDING')),
                            DropdownMenuItem(value: 'APPROVED', child: Text('Status: APPROVED')),
                            DropdownMenuItem(value: 'REJECTED', child: Text('Status: REJECTED')),
                            DropdownMenuItem(value: 'Approved Only', child: Text('Approved Only')),
                            DropdownMenuItem(value: 'Non-Approved Only', child: Text('Non-Approved Only')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _approvalFilterMode = val);
                            }
                          },
                        ),
                      ),
                    ),

                    // Reset Filters
                    TextButton.icon(
                      onPressed: () {
                        taProvider.setDateRange(
                          DateTime.now().subtract(const Duration(days: 30)),
                          DateTime.now(),
                        );
                        taProvider.setUserFilter(null);
                        setState(() => _approvalFilterMode = 'ALL');
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.grey),
                      label: Text('Reset Filters', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700])),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Report Table / Cards
              Expanded(
                child: taProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : reportItems.isEmpty
                        ? _buildEmptyReportState(context)
                        : isWeb
                            ? _buildReportDataTable(context, reportItems)
                            : _buildReportMobileList(context, reportItems),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportDataTable(BuildContext context, List<TravelAllowanceModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              horizontalMargin: 16,
              columnSpacing: 20,
              columns: [
                _buildDataColumn('# ID'),
                _buildDataColumn('Staff Name'),
                _buildDataColumn('Travel Date'),
                _buildDataColumn('Mode'),
                _buildDataColumn('From Location'),
                _buildDataColumn('To Location'),
                _buildDataColumn('Purpose'),
                _buildDataColumn('Distance'),
                _buildDataColumn('Rate/KM'),
                _buildDataColumn('Other Exp.'),
                _buildDataColumn('TA Amount'),
                _buildDataColumn('Approval Status'),
                _buildDataColumn('Action'),
              ],
              rows: items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text('#${item.taId ?? ''}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold))),
                    DataCell(Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.secondaryBlue.withOpacity(0.1),
                          child: Text(
                            (item.userName ?? 'E').substring(0, 1).toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item.userName ?? '-',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    )),
                    DataCell(Text(item.formattedTravelDate, style: GoogleFonts.plusJakartaSans(fontSize: 12))),
                    DataCell(Row(
                      children: [
                        Icon(item.travelModeIcon, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Text(item.travelMode ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                      ],
                    )),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(item.fromLocation ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 12), overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(item.toLocation ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 12), overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(item.purpose ?? '-', style: GoogleFonts.plusJakartaSans(fontSize: 12), overflow: TextOverflow.ellipsis),
                    )),
                    DataCell(Text('${item.computedTotalKm.toStringAsFixed(1)} KM', style: GoogleFonts.plusJakartaSans(fontSize: 12))),
                    DataCell(Text('₹${item.ratePerKm ?? 0}', style: GoogleFonts.plusJakartaSans(fontSize: 12))),
                    DataCell(Text('₹${item.otherExpenses ?? 0}', style: GoogleFonts.plusJakartaSans(fontSize: 12))),
                    DataCell(Text(
                      '₹${item.computedTotalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (item.status ?? 'PENDING').toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.statusColor,
                        ),
                      ),
                    )),
                    DataCell(IconButton(
                      icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.secondaryBlue),
                      tooltip: 'View Claim Details',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => TADetailsDialog(model: item),
                        );
                      },
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportMobileList(BuildContext context, List<TravelAllowanceModel> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(item.travelModeIcon, color: AppColors.secondaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.userName ?? 'Employee',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (item.status ?? 'PENDING').toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${item.fromLocation} → ${item.toLocation}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600),
              ),
              if ((item.purpose ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Purpose: ${item.purpose}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.formattedTravelDate} • ${item.computedTotalKm.toStringAsFixed(1)} KM',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '₹${item.computedTotalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)),
                  ),
                ],
              ),
              const Divider(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => TADetailsDialog(model: item),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 14),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildEmptyReportState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No Travel Allowance Records Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try selecting a different date range, staff member, or status filter',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
