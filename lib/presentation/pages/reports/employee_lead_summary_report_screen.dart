import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/employee_lead_summary_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:data_table_2/data_table_2.dart';

class EmployeeLeadSummaryReportScreen extends StatefulWidget {
  const EmployeeLeadSummaryReportScreen({super.key});

  @override
  State<EmployeeLeadSummaryReportScreen> createState() =>
      _EmployeeLeadSummaryReportScreenState();
}

class _EmployeeLeadSummaryReportScreenState
    extends State<EmployeeLeadSummaryReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  int _leadPanelCurrentPage = 0;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<EmployeeLeadSummaryProvider>(context, listen: false);
      reportsProvider.clearAllFilters();
      reportsProvider.getEmployeeLeadSummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EmployeeLeadSummaryProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final isWeb = AppStyles.isWebScreen(context);
    final hasReportPermission = (settingsProvider.menuIsViewMap[195] ?? 0).toString() == '1';

    if (!hasReportPermission) {
      return Scaffold(
        drawer: isWeb ? null : const SidebarDrawer(),
        appBar: !isWeb
            ? CustomAppBar(
                title: 'Employee Lead Summary',
                titleStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack),
                showSearch: false,
                onSearch: (_) {},
              )
            : null,
        backgroundColor: Colors.grey[50],
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
                'You do not have permission to view Employee Lead Summary Reports.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Employee Lead Summary',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack),
              onFilterTap: () => reportsProvider.toggleFilter(),
              showSearch: false,
              onSearch: (p0) {},
            ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            if (isWeb) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () {
                          ScaffoldState? parent;
                          context.visitAncestorElements((element) {
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
                          parent?.openDrawer();
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.sort,
                            size: 20,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Employee Lead Summary',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const Spacer(),
                    CustomFilterButton(
                      onPressed: () {
                        reportsProvider.toggleFilter();
                      },
                      isFilter: reportsProvider.isFilter,
                    ),
                  ],
                ),
              ),
            ],
            if (reportsProvider.isFilter)
              Expanded(
                child: _buildFilterPanel(context, reportsProvider),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 40.0),
                  child: Column(
                    children: [
                      _buildSummaryDashboard(reportsProvider),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Employee Lead Summary Report',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildReportTable(reportsProvider),
                              ],
                            ),
                          ),
                          if (isWeb && reportsProvider.selectedEmployeeLeads != null) ...[
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: _buildDetailsPanel(reportsProvider),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: reportsProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_employee_lead_summary_filter_fab',
                  onPressed: () {
                    reportsProvider
                        .setTaskSearchCriteria(searchController.text);
                    reportsProvider.getEmployeeLeadSummary(context);
                    reportsProvider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false)
                        .stopSearch();
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
            : null,
      ),
    );
  }

  Widget _buildFilterPanel(
      BuildContext context, EmployeeLeadSummaryProvider reportsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CustomText(
            'Search Employee',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by employee name...',
              prefixIcon: const Icon(Icons.search, size: 20),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomText(
            'Date Range',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CommonReportDateFilter(
                  fromDate: reportsProvider.fromDate?.toString(),
                  toDate: reportsProvider.toDate?.toString(),
                  formattedFromDate: reportsProvider.formattedFromDate,
                  formattedToDate: reportsProvider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                  label: 'Filter Date',
                ),
              ),
              if (reportsProvider.fromDate != null ||
                  reportsProvider.toDate != null) ...[
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.selectDateFilterOption(null);
                    searchController.clear();
                    reportsProvider.clearAllFilters();
                    reportsProvider.getEmployeeLeadSummary(context);
                  },
                ),
              ]
            ],
          ),
          const SizedBox(height: 40),
          if (reportsProvider.fromDate != null ||
              reportsProvider.toDate != null ||
              searchController.text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                label: 'Reset All Filters',
                onReset: () {
                  reportsProvider.selectDateFilterOption(null);
                  searchController.clear();
                  reportsProvider.clearAllFilters();
                  reportsProvider.getEmployeeLeadSummary(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textRed,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.textRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportTable(EmployeeLeadSummaryProvider provider) {
    final list = provider.employeeLeadSummary?.employeeReport ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'EMPLOYEE',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ASSIGNED',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'PENDING',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rows
          if (list.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[100]!),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item.userDetailsName ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                               if (item.userDetailsId != null && item.leadAssigned != null && item.leadAssigned! > 0) {
                                  Provider.of<EmployeeLeadSummaryProvider>(context, listen: false)
                                      .getEmployeeLeadList(context, item.userDetailsId!, 'Assigned');
                               }
                            },
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.12)),
                              ),
                              child: Text(
                                '${item.leadAssigned ?? 0}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                               if (item.userDetailsId != null && item.pendingFollowup != null && item.pendingFollowup != "0") {
                                  Provider.of<EmployeeLeadSummaryProvider>(context, listen: false)
                                      .getEmployeeLeadList(context, item.userDetailsId!, 'Pending');
                               }
                            },
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEB),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: const Color(0xFFFF3B30)
                                        .withOpacity(0.15)),
                              ),
                              child: Text(
                                '${item.pendingFollowup ?? 0}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsPanel(EmployeeLeadSummaryProvider provider) {
    final leads = provider.selectedEmployeeLeads;
    if (leads == null) {
       return const SizedBox.shrink();
    }
    
    final int totalItems = leads.length;
    final int totalPages = (totalItems / _itemsPerPage).ceil();
    final int startIndex = _leadPanelCurrentPage * _itemsPerPage;
    final int endIndex = (startIndex + _itemsPerPage > totalItems) ? totalItems : (startIndex + _itemsPerPage);
    final paginatedLeads = leads.isNotEmpty ? leads.sublist(startIndex, endIndex) : [];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lead Details',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primaryBlue,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Total: $totalItems',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        provider.clearSelectedLeads();
                        setState(() {
                          _leadPanelCurrentPage = 0;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (leads.isEmpty)
             const Padding(padding: EdgeInsets.all(32), child: Center(child: Text("No leads found.")))
          else
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 56.0 + (paginatedLeads.length * 48.0) + 20.0,
                  child: DataTable2(
                    fixedTopRows: 1,
                    minWidth: 600,
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                    columns: const [
                      DataColumn2(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold)), size: ColumnSize.L),
                      DataColumn2(label: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold)), size: ColumnSize.M),
                      DataColumn2(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold)), size: ColumnSize.L),
                      DataColumn2(label: Text('Status Name', style: TextStyle(fontWeight: FontWeight.bold)), size: ColumnSize.M),
                      DataColumn2(label: Text('Next FollowUp Date', style: TextStyle(fontWeight: FontWeight.bold)), size: ColumnSize.M),
                    ],
                    rows: paginatedLeads.map((lead) {
                      return DataRow(
                        cells: [
                          DataCell(Tooltip(message: lead.customerName ?? '', child: Text(lead.customerName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)))),
                          DataCell(Tooltip(message: lead.contactNumber ?? '', child: Text(lead.contactNumber ?? '', maxLines: 1, overflow: TextOverflow.ellipsis))),
                          DataCell(Tooltip(message: lead.address1 ?? '', child: Text(lead.address1 ?? '', maxLines: 1, overflow: TextOverflow.ellipsis))),
                          DataCell(Tooltip(message: lead.statusName ?? '', child: Text(lead.statusName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis))),
                          DataCell(Tooltip(message: lead.nextFollowUpDate ?? '', child: Text(lead.nextFollowUpDate ?? '', maxLines: 1, overflow: TextOverflow.ellipsis))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _leadPanelCurrentPage > 0
                              ? () {
                                  setState(() {
                                    _leadPanelCurrentPage--;
                                  });
                                }
                              : null,
                        ),
                        Text('Page ${_leadPanelCurrentPage + 1} of $totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _leadPanelCurrentPage < totalPages - 1
                              ? () {
                                  setState(() {
                                    _leadPanelCurrentPage++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String name, String count) {
    Color textCol = AppColors.primaryBlue;
    Color bgCol = AppColors.primaryBlue.withOpacity(0.08);
    final lowerName = name.toLowerCase();

    if (lowerName.contains('today')) {
      textCol = const Color(0xFF16A34A); // Green
      bgCol = const Color(0xFFDCFCE7);
    } else if (lowerName.contains('upcoming')) {
      textCol = const Color(0xFF2563EB); // Indigo/Blue
      bgCol = const Color(0xFFDBEAFE);
    } else if (lowerName.contains('pending')) {
      textCol = const Color(0xFFFF3B30); // Red
      bgCol = const Color(0xFFFFEBEB);
    }

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textCol.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: textCol,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard(EmployeeLeadSummaryProvider provider) {
    final summary = provider.employeeLeadSummary?.summary;
    final totalLeads = summary?.totalLeads?.toString() ?? "0";
    final pending = summary?.pendingFollowup ?? "0";
    final today = summary?.todaysFollowup ?? "0";
    final upcoming = summary?.upcomingFollowup ?? "0";

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildSummaryCard(context, 'Total Leads', totalLeads, Colors.blue, onTap: () {
             if (totalLeads != "0") provider.getEmployeeLeadList(context, 0, 'Total');
          }),
          _buildSummaryCard(context, 'Pending Followup', pending, Colors.orange, onTap: () {
             if (pending != "0") provider.getEmployeeLeadList(context, 0, 'Pending');
          }),
          _buildSummaryCard(context, 'Today\'s Followup', today, Colors.green, onTap: () {
             if (today != "0") provider.getEmployeeLeadList(context, 0, 'Today');
          }),
          _buildSummaryCard(context, 'Upcoming Followup', upcoming, Colors.purple, onTap: () {
             if (upcoming != "0") provider.getEmployeeLeadList(context, 0, 'Upcoming');
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color, {VoidCallback? onTap}) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No records found');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<EmployeeLeadSummaryProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Choose Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        final bool isSelected =
                            reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pick a custom date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!)),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.formatDate();
                          reportsProvider.getEmployeeLeadSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.getEmployeeLeadSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.08),
                          foregroundColor: AppColors.textRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Clear Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
