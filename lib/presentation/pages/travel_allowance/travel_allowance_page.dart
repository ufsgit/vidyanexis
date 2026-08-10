import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/travel_allowance_provider.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/add_ta_dialog.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/ta_details_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

class TravelAllowancePage extends StatefulWidget {
  static const String route = '/travel_allowance';
  final bool isEmbeddedInDashboard;
  const TravelAllowancePage({super.key, this.isEmbeddedInDashboard = false});

  @override
  State<TravelAllowancePage> createState() => _TravelAllowancePageState();
}

class _TravelAllowancePageState extends State<TravelAllowancePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TravelAllowanceProvider>(context, listen: false)
          .fetchTAList(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taProvider = Provider.of<TravelAllowanceProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);
    final bool hasReportPermission =
        (settingsProvider.menuIsViewMap[26] ?? 0).toString() == '1' ||
            (settingsProvider.menuIsViewMap[201] ?? 0).toString() == '1';

    if (widget.isEmbeddedInDashboard) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: RefreshIndicator(
          onRefresh: () => taProvider.fetchTAList(context: context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isWeb)
                  _buildMobileHeader(context, taProvider)
                else
                  _buildEmbeddedWebHeader(context, taProvider),

                // KPI Cards Summary
                _buildKPICardsSummary(taProvider, isWeb),
                const SizedBox(height: 20),

                // Filter & Search Controls Bar
                _buildFilterControlsBar(taProvider, isWeb),
                const SizedBox(height: 16),

                // Main List / Data Table Section
                SizedBox(
                  height: isWeb ? 550 : 600,
                  child: taProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : taProvider.filteredTaList.isEmpty
                          ? _buildEmptyState(context)
                          : isWeb
                              ? _buildWebDataTable(
                                  context, taProvider, hasReportPermission)
                              : _buildMobileCardList(
                                  context, taProvider, hasReportPermission),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: !isWeb
          ? CustomAppBar(
              title: 'Travel Allowance',
              showSearch: false,
              showFilterIcon: false,
              showSort: false,
              onSearch: (_) {},
            )
          : null,
      backgroundColor: AppColors.scaffoldColor,
      body: Column(
        children: [
          if (isWeb) _buildWebAppBar(context, taProvider),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => taProvider.fetchTAList(context: context),
              child: Padding(
                padding: EdgeInsets.all(isWeb ? 24.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isWeb) _buildMobileHeader(context, taProvider),

                    // KPI Cards Summary
                    _buildKPICardsSummary(taProvider, isWeb),
                    const SizedBox(height: 20),

                    // Filter & Search Controls Bar
                    _buildFilterControlsBar(taProvider, isWeb),
                    const SizedBox(height: 16),

                    // Main List / Data Table Section
                    Expanded(
                      child: taProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : taProvider.filteredTaList.isEmpty
                              ? _buildEmptyState(context)
                              : isWeb
                                  ? _buildWebDataTable(
                                      context, taProvider, hasReportPermission)
                                  : _buildMobileCardList(
                                      context, taProvider, hasReportPermission),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Full-width purple web header matching reference image
  Widget _buildWebAppBar(
      BuildContext context, TravelAllowanceProvider taProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Builder(
                  builder: (ctx) {
                    final bool canPop = Navigator.of(ctx).canPop();
                    return IconButton(
                      onPressed: () {
                        if (canPop) {
                          Navigator.of(ctx).pop();
                        } else {
                          ScaffoldState? parent;
                          ctx.visitAncestorElements((element) {
                            if (element is StatefulElement &&
                                element.state is ScaffoldState) {
                              ScaffoldState scaffold =
                                  element.state as ScaffoldState;
                              if (scaffold.hasDrawer) {
                                parent = scaffold;
                                return false;
                              }
                            }
                            return true;
                          });
                          if (parent != null && parent!.hasDrawer) {
                            parent!.openDrawer();
                          } else {
                            try {
                              Scaffold.of(ctx).openDrawer();
                            } catch (_) {}
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          canPop ? Icons.arrow_back_rounded : Icons.sort,
                          size: 20,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                      tooltip: canPop ? 'Back' : 'Menu',
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Travel Allowance (TA) Management',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      //   const SizedBox(height: 2),
                      //   Text(
                      //     'Track, submit, and manage employee travel claims and reimbursements',
                      //     style: GoogleFonts.plusJakartaSans(
                      //       fontSize: 13,
                      //       color: const Color(0xFF3B0764).withOpacity(0.85),
                      //     ),
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () => taProvider.exportToExcelReport(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Export Excel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.black),
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddTADialog(),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('New TA Claim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedWebHeader(
      BuildContext context, TravelAllowanceProvider taProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Travel Allowance (TA) Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => taProvider.exportToExcelReport(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Export Excel',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF15803D),
                  side: const BorderSide(color: Color(0xFFBBF7D0)),
                  backgroundColor: const Color(0xFFF0FDF4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddTADialog(),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  'Add Travel Entry',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(
      BuildContext context, TravelAllowanceProvider taProvider) {
    return Column(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => taProvider.exportToExcelReport(context),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // Summary KPI Row
  Widget _buildKPICardsSummary(TravelAllowanceProvider provider, bool isWeb) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = isWeb
            ? (constraints.maxWidth - 36) / 4
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSummaryTile(
              width: cardWidth,
              title: 'Total Claimed',
              value: '₹${provider.totalClaimedAmount.toStringAsFixed(2)}',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.secondaryBlue,
              bg: const Color(0xFFEFF6FF),
            ),
            _buildSummaryTile(
              width: cardWidth,
              title: 'Approved',
              value: '₹${provider.totalApprovedAmount.toStringAsFixed(2)}',
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF16A34A),
              bg: const Color(0xFFF0FDF4),
            ),
            _buildSummaryTile(
              width: cardWidth,
              title: 'Pending Claims',
              value: '${provider.pendingCount}',
              icon: Icons.pending_actions_rounded,
              color: const Color(0xFFD97706),
              bg: const Color(0xFFFFFBEB),
            ),
            _buildSummaryTile(
              width: cardWidth,
              title: 'Paid / Settled',
              value: '₹${provider.totalPaidAmount.toStringAsFixed(2)}',
              icon: Icons.task_alt_rounded,
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFF0F9FF),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryTile({
    required double width,
    required String title,
    required String value,
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
                    fontSize: 12,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Bar
  Widget _buildFilterControlsBar(TravelAllowanceProvider provider, bool isWeb) {
    final statusOptions = ['All', 'Pending', 'Approved', 'Rejected', 'Paid'];
    final modeOptions = [
      'All',
      'Bike',
      'Car',
      'Bus',
      'Train',
      'Flight',
      'Auto',
      'Taxi'
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Search Input
              Expanded(
                flex: isWeb ? 3 : 2,
                child: TextField(
                  controller: provider.searchController,
                  onChanged: (_) => provider.applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search employee, location, purpose...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 18, color: Colors.grey),
                    suffixIcon: provider.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 16),
                            onPressed: () {
                              provider.searchController.clear();
                              provider.applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.selectedStatusFilter,
                    icon: const Icon(Icons.filter_list_rounded, size: 18),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.black87),
                    items: statusOptions.map((s) {
                      return DropdownMenuItem(
                          value: s, child: Text('Status: $s'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) provider.setStatusFilter(val);
                    },
                  ),
                ),
              ),

              if (isWeb) ...[
                const SizedBox(width: 12),
                // Travel Mode Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedTravelModeFilter,
                      icon: const Icon(Icons.directions_car_outlined, size: 18),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, color: Colors.black87),
                      items: modeOptions.map((m) {
                        return DropdownMenuItem(
                            value: m, child: Text('Mode: $m'));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) provider.setTravelModeFilter(val);
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                // Date Range Button
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      initialDateRange:
                          provider.fromDate != null && provider.toDate != null
                              ? DateTimeRange(
                                  start: provider.fromDate!,
                                  end: provider.toDate!)
                              : null,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      provider.setDateRange(picked.start, picked.end);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded, size: 14),
                  label: Text(
                    provider.fromDate != null && provider.toDate != null
                        ? '${DateFormat('dd MMM').format(provider.fromDate!)} - ${DateFormat('dd MMM').format(provider.toDate!)}'
                        : 'Date Range',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Web Data Table View stretched across full width
  Widget _buildWebDataTable(BuildContext context,
      TravelAllowanceProvider provider, bool hasReportPermission) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double containerWidth = constraints.maxWidth;

        // Base widths for each column
        const double baseId = 55.0;
        const double baseStaff = 130.0;
        const double baseDate = 90.0;
        const double baseMode = 85.0;
        const double baseFrom = 130.0;
        const double baseTo = 130.0;
        const double basePurpose = 140.0;
        const double baseDist = 75.0;
        const double baseRate = 65.0;
        const double baseOther = 75.0;
        const double baseAmount = 85.0;
        const double baseStatus = 95.0;
        const double baseActions = 110.0;

        const double columnSpacing = 12.0;
        const double horizontalMargin = 16.0;

        final double baseColumnsSum = baseId +
            baseStaff +
            baseDate +
            baseMode +
            baseFrom +
            baseTo +
            basePurpose +
            baseDist +
            baseRate +
            baseOther +
            baseAmount +
            baseStatus +
            baseActions;

        final double baseTotalWidth =
            baseColumnsSum + (columnSpacing * 12) + (horizontalMargin * 2);

        final double extraWidth = (containerWidth > baseTotalWidth)
            ? (containerWidth - baseTotalWidth)
            : 0.0;

        // Distribute available additional width across key columns
        final double colId = baseId;
        final double colStaff = baseStaff + (extraWidth * 0.10);
        final double colDate = baseDate;
        final double colMode = baseMode;
        final double colFrom = baseFrom + (extraWidth * 0.25);
        final double colTo = baseTo + (extraWidth * 0.25);
        final double colPurpose = basePurpose + (extraWidth * 0.28);
        final double colDist = baseDist;
        final double colRate = baseRate;
        final double colOther = baseOther;
        final double colAmount = baseAmount;
        final double colStatus = baseStatus;
        final double colActions = baseActions + (extraWidth * 0.02);

        final double tableWidth =
            (containerWidth > baseTotalWidth) ? containerWidth : baseTotalWidth;

        return Container(
          width: double.infinity,
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: tableWidth),
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    horizontalMargin: horizontalMargin,
                    columnSpacing: columnSpacing,
                    columns: [
                      _buildDataColumn('# ID', colId),
                      _buildDataColumn('Staff Name', colStaff),
                      _buildDataColumn('Travel Date', colDate),
                      _buildDataColumn('Mode', colMode),
                      _buildDataColumn('From Location', colFrom),
                      _buildDataColumn('To Location', colTo),
                      _buildDataColumn('Purpose', colPurpose),
                      _buildDataColumn('Distance', colDist),
                      _buildDataColumn('Rate/KM', colRate),
                      _buildDataColumn('Other Exp.', colOther),
                      _buildDataColumn('TA Amount', colAmount),
                      _buildDataColumn('Status', colStatus),
                      _buildDataColumn('Actions', colActions),
                    ],
                    rows: provider.filteredTaList.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(SizedBox(
                            width: colId,
                            child: Text('#${item.taId ?? ''}',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(SizedBox(
                            width: colStaff,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor:
                                      AppColors.secondaryBlue.withOpacity(0.1),
                                  child: Text(
                                    (item.userName ?? 'E')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryBlue),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(item.userName ?? '-',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colDate,
                            child: Text(item.formattedTravelDate,
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12)),
                          )),
                          DataCell(SizedBox(
                            width: colMode,
                            child: Row(
                              children: [
                                Icon(item.travelModeIcon,
                                    size: 16, color: Colors.grey[700]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(item.travelMode ?? '-',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colFrom,
                            child: Text(
                              item.fromLocation ?? '-',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colTo,
                            child: Text(
                              item.toLocation ?? '-',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colPurpose,
                            child: Text(
                              item.purpose ?? '-',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colDist,
                            child: Text(
                                '${item.computedTotalKm.toStringAsFixed(1)} KM',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12)),
                          )),
                          DataCell(SizedBox(
                            width: colRate,
                            child: Text('₹${item.ratePerKm ?? 0}',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12)),
                          )),
                          DataCell(SizedBox(
                            width: colOther,
                            child: Text('₹${item.otherExpenses ?? 0}',
                                style:
                                    GoogleFonts.plusJakartaSans(fontSize: 12)),
                          )),
                          DataCell(SizedBox(
                            width: colAmount,
                            child: Text(
                              '₹${item.computedTotalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF16A34A)),
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colStatus,
                            child: UnconstrainedBox(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
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
                            ),
                          )),
                          DataCell(SizedBox(
                            width: colActions,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined,
                                      size: 18, color: AppColors.secondaryBlue),
                                  tooltip: 'View Details',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) =>
                                          TADetailsDialog(model: item),
                                    );
                                  },
                                ),
                                if (hasReportPermission ||
                                    (item.status ?? '').toLowerCase() ==
                                        'pending') ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18, color: Colors.grey),
                                    tooltip: 'Edit Claim',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AddTADialog(editModel: item),
                                      );
                                    },
                                  ),
                                ],
                                if (hasReportPermission) ...[
                                  IconButton(
                                    icon: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: Colors.red),
                                    tooltip: 'Delete Claim',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                        minWidth: 32, minHeight: 32),
                                    onPressed: () => _confirmDelete(
                                        context, provider, item.taId!),
                                  ),
                                ],
                              ],
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataColumn _buildDataColumn(String label, double width) {
    return DataColumn(
      label: SizedBox(
        width: width,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Mobile Card List View
  Widget _buildMobileCardList(BuildContext context,
      TravelAllowanceProvider provider, bool hasReportPermission) {
    return ListView.separated(
      itemCount: provider.filteredTaList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = provider.filteredTaList[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(item.travelModeIcon,
                          color: AppColors.secondaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.userName ?? 'Employee',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

              // Route Info (From -> To)
              Row(
                children: [
                  const Icon(Icons.route_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item.fromLocation} → ${item.toLocation}',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if ((item.purpose ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.assignment_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Purpose: ${item.purpose}',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),

              // Details & Amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.formattedTravelDate} • ${item.computedTotalKm.toStringAsFixed(1)} KM',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    '₹${item.computedTotalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => TADetailsDialog(model: item),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (hasReportPermission ||
                      (item.status ?? '').toLowerCase() == 'pending') ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddTADialog(editModel: item),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No Travel Allowance Claims Found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Submit a new TA claim or adjust search filters to view records',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TravelAllowanceProvider provider, int taId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Claim',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        content: Text(
            'Are you sure you want to delete this travel allowance claim?',
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await provider.deleteTAClaim(context, taId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
