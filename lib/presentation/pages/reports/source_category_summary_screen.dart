import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/source_category_summary_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class SourceCategorySummaryReportScreen extends StatefulWidget {
  static const String route = '/sourceCategorySummary';
  static const int menuId = 218;

  const SourceCategorySummaryReportScreen({super.key});

  @override
  State<SourceCategorySummaryReportScreen> createState() =>
      _SourceCategorySummaryReportScreenState();
}

class _SourceCategorySummaryReportScreenState
    extends State<SourceCategorySummaryReportScreen> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final ScrollController horizontalScrollController = ScrollController();
  final ScrollController verticalScrollController = ScrollController();

  final List<String> dateFilterTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<SourceCategorySummaryProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getEnquirySource(context);
      provider.fetchEnquirySources(context);
      provider.clearAllFilters();
      provider.getSourceCategorySummary(context);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNodeWeb.dispose();
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    try {
      final format = NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 2,
      );
      return format.format(amount);
    } catch (_) {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SourceCategorySummaryProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Source category Summary',
              titleStyle: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
              onFilterTap: () => provider.toggleFilter(),
              showSearch: false,
              onSearch: (val) => provider.setSearchQuery(val),
              showExcel: true,
              onExcelTap: () => _exportData(provider),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Web Header or Filter Bar
            if (isWeb) _buildWebHeader(provider),

            // Collapsible Filter Panel
            if (provider.isFilter) _buildFilterPanel(provider, isWeb),

            // Top Summary Cards
            _buildMetricsCards(provider, isWeb),

            // Tab Bar for Converted Leads & Agency Payments
            if (provider.agencyPayments.isNotEmpty ||
                provider.paymentSummary != null)
              _buildTabBar(provider, isWeb),

            // Content Table / List
            Expanded(
              child: provider.selectedTabIndex == 1
                  ? (provider.agencyPayments.isEmpty
                      ? const CommonEmptyState(
                          message: 'No agency payment records found',
                        )
                      : (isWeb
                          ? _buildAgencyPaymentsTableView(provider)
                          : _buildMobilePaymentsListView(provider)))
                  : (provider.sourceCategoryReport.isEmpty
                      ? const CommonEmptyState(
                          message: 'No source category records found',
                        )
                      : (isWeb
                          ? _buildWebTableView(provider)
                          : _buildMobileListView(provider))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(SourceCategorySummaryProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                ScaffoldState? parent;
                context.visitAncestorElements((element) {
                  if (element is StatefulElement &&
                      element.state is ScaffoldState) {
                    ScaffoldState scaffold = element.state as ScaffoldState;
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
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.sort,
                  size: 20,
                  color: AppColors.secondaryBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Source category Summary',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),

          // Search Field
          Container(
            width: 260,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNodeWeb,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) => provider.setSearchQuery(val),
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search lead, source...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () {
                          searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter Button
          CustomFilterButton(
            onPressed: () => provider.toggleFilter(),
            isFilter: provider.isFilter,
          ),
          const SizedBox(width: 12),

          // Export Button
          CommonReportExportButton(
            onPressed: () => _exportData(provider),
            label: 'Export',
          ),
          const SizedBox(width: 12),

          // Refresh Button
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => provider.getSourceCategorySummary(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: const Icon(
                Icons.refresh,
                size: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(
      SourceCategorySummaryProvider provider, bool isWeb) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Quick Dates:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              for (int i = 0; i < dateFilterTitles.length; i++)
                ChoiceChip(
                  label: Text(dateFilterTitles[i]),
                  selected: provider.selectedDateFilterIndex == i,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: provider.selectedDateFilterIndex == i
                        ? Colors.white
                        : const Color(0xFF334155),
                  ),
                  backgroundColor: const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: BorderSide.none,
                  onSelected: (selected) {
                    provider.selectDateFilterOption(selected ? i : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Filters Row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Date Range Button
              CommonReportDateFilter(
                fromDate: provider.fromDate?.toString(),
                toDate: provider.toDate?.toString(),
                formattedFromDate: provider.displayFromDate,
                formattedToDate: provider.displayToDate,
                label: 'Conversion Date',
                onTap: () => _showDateRangeDialog(provider),
              ),

              // Parent Category Dropdown (commented out for now)
              // if (provider.uniqueParentCategories.isNotEmpty)
              //   Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(4),
              //       border: Border.all(
              //         color: provider.selectedParentCategory != null
              //             ? AppColors.primaryBlue
              //             : const Color(0xFFCBD5E1),
              //       ),
              //     ),
              //     child: DropdownButtonHideUnderline(
              //       child: DropdownButton<String>(
              //         value: provider.selectedParentCategory,
              //         hint: Text(
              //           'All Parent Categories',
              //           style: GoogleFonts.plusJakartaSans(
              //             fontSize: 13,
              //             color: const Color(0xFF64748B),
              //           ),
              //         ),
              //         icon: const Icon(Icons.arrow_drop_down, size: 20),
              //         style: GoogleFonts.plusJakartaSans(
              //           fontSize: 13,
              //           color: const Color(0xFF0F172A),
              //           fontWeight: FontWeight.w500,
              //         ),
              //         items: [
              //           DropdownMenuItem<String>(
              //             value: null,
              //             child: Text(
              //               'All Parent Categories',
              //               style: GoogleFonts.plusJakartaSans(
              //                 fontSize: 13,
              //                 color: const Color(0xFF64748B),
              //               ),
              //             ),
              //           ),
              //           ...provider.uniqueParentCategories.map(
              //             (cat) => DropdownMenuItem<String>(
              //               value: cat,
              //               child: Text(cat),
              //             ),
              //           ),
              //         ],
              //         onChanged: (val) =>
              //             provider.setParentCategoryFilter(val),
              //       ),
              //     ),
              //   ),

              // Enquiry Source Dropdown
              Consumer<DropDownProvider>(
                builder: (context, dropDownProvider, child) {
                  final rawSources = provider.enquirySources.isNotEmpty
                      ? provider.enquirySources
                      : dropDownProvider.enquiryData;
                  final seenIds = <int>{};
                  final sources = rawSources
                      .where((s) => seenIds.add(s.enquirySourceId))
                      .toList();
                  final hasSelected = provider.selectedEnquirySourceId != null &&
                      sources.any((s) =>
                          s.enquirySourceId == provider.selectedEnquirySourceId);
                  final selectedValue =
                      hasSelected ? provider.selectedEnquirySourceId : null;

                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: provider.selectedEnquirySourceId != null
                            ? AppColors.primaryBlue
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedValue,
                        hint: Text(
                          'All Enquiry Sources',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: const Color(0xFF0F172A),
                          fontWeight: FontWeight.w500,
                        ),
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'All Enquiry Sources',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          ...sources.map(
                            (src) => DropdownMenuItem<int?>(
                              value: src.enquirySourceId,
                              child: Text(src.enquirySourceName),
                            ),
                          ),
                        ],
                        onChanged: (val) =>
                            provider.setEnquirySourceFilter(val),
                      ),
                    ),
                  );
                },
              ),

              // Apply Button
              ElevatedButton.icon(
                onPressed: () =>
                    provider.getSourceCategorySummary(context),
                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                label: Text(
                  'Apply',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Reset Button
              CommonReportResetButton(
                onReset: () => provider.resetFilters(context),
                label: 'Reset Filters',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDateRangeDialog(SourceCategorySummaryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Date Range',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => provider.selectCustomDate(context, true),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      provider.displayFromDate.isNotEmpty
                          ? provider.displayFromDate
                          : 'From Date',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => provider.selectCustomDate(context, false),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      provider.displayToDate.isNotEmpty
                          ? provider.displayToDate
                          : 'To Date',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.getSourceCategorySummary(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCards(
      SourceCategorySummaryProvider provider, bool isWeb) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int crossAxisCount = width > 1100 ? 4 : (width > 600 ? 2 : 1);

          final hasPaymentSummary = provider.paymentSummary != null;
          final double commission = hasPaymentSummary
              ? provider.paymentSummary!.totalCommissionAmount
              : provider.totalCommissionAmount;
          final double amountPaid = provider.totalAgencyPaymentsAmount;
          final double balance = provider.balanceAmount;

          final cards = [
            _buildMetricTile(
              title: 'Total Converted Leads',
              value: provider.totalLeadsCount.toString(),
              subtitle: 'Active conversions',
              icon: Icons.people_alt_outlined,
              iconColor: const Color(0xFF2563EB),
              bgColor: const Color(0xFFEFF6FF),
              accentColor: const Color(0xFF3B82F6),
            ),
            if (!hasPaymentSummary)
              _buildMetricTile(
                title: 'Total Project Cost',
                value: _formatCurrency(provider.totalProjectCost),
                subtitle: 'Combined deal value',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                accentColor: const Color(0xFF10B981),
              ),
            _buildMetricTile(
              title: 'Total Commission',
              value: _formatCurrency(commission),
              subtitle: 'Commission earned',
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
              accentColor: const Color(0xFF8B5CF6),
            ),
            if (hasPaymentSummary) ...[
              _buildMetricTile(
                title: 'Total Amount Paid',
                value: _formatCurrency(amountPaid),
                subtitle: 'Disbursed to agency',
                icon: Icons.payments_outlined,
                iconColor: const Color(0xFF059669),
                bgColor: const Color(0xFFECFDF5),
                accentColor: const Color(0xFF10B981),
              ),
              _buildMetricTile(
                title: 'Balance Amount',
                value: _formatCurrency(balance),
                subtitle: balance > 0 ? 'Pending payout' : 'Settled',
                icon: Icons.account_balance_outlined,
                iconColor: balance > 0
                    ? const Color(0xFFD97706)
                    : const Color(0xFF059669),
                bgColor: balance > 0
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFECFDF5),
                accentColor: balance > 0
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF10B981),
              ),
            ] else
              _buildMetricTile(
                title: 'Average Commission',
                value:
                    '${provider.avgCommissionPercentage.toStringAsFixed(1)}%',
                subtitle: 'Mean percentage rate',
                icon: Icons.pie_chart_outline_rounded,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
                accentColor: const Color(0xFFF59E0B),
              ),
          ];

          if (crossAxisCount == 1) {
            return Column(
              children: cards
                  .map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: c,
                      ))
                  .toList(),
            );
          }

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: width > 1100 ? 2.6 : 2.4,
            children: cards,
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebTableView(SourceCategorySummaryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          // Minimum width required to display columns legibly
          const double minTableWidth = 900.0;
          final double tableWidth = availableWidth > minTableWidth
              ? availableWidth
              : minTableWidth;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Scrollbar(
              controller: horizontalScrollController,
              thumbVisibility: tableWidth > availableWidth,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 45,
                              child: Text(
                                '#',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            _buildColumnHeader('PARENT SOURCE'),
                            _buildColumnHeader('ENQUIRY SOURCE'),
                            _buildColumnHeader('LEAD NAME'),
                            _buildColumnHeader('CONVERSION DATE'),
                            _buildColumnHeader('PROJECT COST',
                                alignment: Alignment.centerRight),
                            _buildColumnHeader('COMMISSION %',
                                alignment: Alignment.center),
                            _buildColumnHeader('COMMISSION AMOUNT',
                                alignment: Alignment.centerRight),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: Scrollbar(
                          controller: verticalScrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: verticalScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: provider.sourceCategoryReport.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              final item = provider.sourceCategoryReport[index];
                              final isEven = index % 2 == 0;

                              return Container(
                                color: isEven
                                    ? Colors.white
                                    : const Color(0xFFFAFAFB),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    // Index
                                    SizedBox(
                                      width: 45,
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // Parent Enquiry Source
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: const Color(0xFFC7D2FE),
                                            ),
                                          ),
                                          child: Text(
                                            item.parentEnquirySource.isEmpty
                                                ? '-'
                                                : item.parentEnquirySource,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4338CA),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Enquiry Source
                                    Expanded(
                                      child: Text(
                                        item.enquirySource.isEmpty
                                            ? '-'
                                            : item.enquirySource,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Lead Name
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: AppColors.primaryBlue
                                                .withOpacity(0.12),
                                            child: Text(
                                              item.leadName.isNotEmpty
                                                  ? item.leadName[0].toUpperCase()
                                                  : 'L',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              item.leadName.isEmpty
                                                  ? '-'
                                                  : item.leadName,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E293B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Conversion Date
                                    Expanded(
                                      child: Text(
                                        _formatDateString(item.conversionDate),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Project Cost
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _formatCurrency(item.projectCost),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // Commission %
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${item.commissionPercentage.toStringAsFixed(2)}%',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF92400E),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Commission Amount
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _formatCurrency(item.commissionAmount),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF059669),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Table Footer (Totals)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          border: Border(
                            top: BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 45),
                            Expanded(
                              flex: 4, // 4 equal text columns: Parent, Enquiry, Lead, Date
                              child: Text(
                                'TOTALS (${provider.sourceCategoryReport.length} Entries)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1, // Project Cost
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatCurrency(provider.totalProjectCost),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1, // Commission %
                              child: Center(
                                child: Text(
                                  '${provider.avgCommissionPercentage.toStringAsFixed(1)}% avg',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF64748B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1, // Commission Amount
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _formatCurrency(provider.totalCommissionAmount),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF059669),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColumnHeader(String title,
      {Alignment alignment = Alignment.centerLeft, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignment,
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
            letterSpacing: 0.5,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMobileListView(SourceCategorySummaryProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.getSourceCategorySummary(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.sourceCategoryReport.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = provider.sourceCategoryReport[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Lead Name & Conversion Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.leadName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      _formatDateString(item.conversionDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sources tags
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        item.parentEnquirySource.isEmpty
                            ? '-'
                            : item.parentEnquirySource,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4338CA),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.enquirySource.isEmpty ? '-' : item.enquirySource,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18, color: Color(0xFFF1F5F9)),

                // Cost and Commission Metrics
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Project Cost',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _formatCurrency(item.projectCost),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Commission %',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${item.commissionPercentage.toStringAsFixed(2)}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Commission',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          _formatCurrency(item.commissionAmount),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar(SourceCategorySummaryProvider provider, bool isWeb) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            title: 'Converted Leads',
            count: provider.sourceCategoryReport.length,
            isSelected: provider.selectedTabIndex == 0,
            onTap: () => provider.setSelectedTabIndex(0),
          ),
          const SizedBox(width: 4),
          _buildTabButton(
            title: 'Agency Payments',
            count: provider.agencyPayments.length,
            isSelected: provider.selectedTabIndex == 1,
            onTap: () => provider.setSelectedTabIndex(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color:
                    isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue.withOpacity(0.12)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppColors.primaryBlue
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgencyPaymentsTableView(
      SourceCategorySummaryProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          const double minTableWidth = 750.0;
          final double tableWidth = availableWidth > minTableWidth
              ? availableWidth
              : minTableWidth;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Scrollbar(
              controller: horizontalScrollController,
              thumbVisibility: tableWidth > availableWidth,
              child: SingleChildScrollView(
                controller: horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 45,
                              child: Text(
                                '#',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            _buildColumnHeader('PAYMENT DATE'),
                            _buildColumnHeader('ENQUIRY SOURCE'),
                            _buildColumnHeader('AMOUNT PAID'),
                            _buildColumnHeader('REMARK'),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: Scrollbar(
                          controller: verticalScrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: verticalScrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: provider.agencyPayments.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFF1F5F9),
                            ),
                            itemBuilder: (context, index) {
                              final item = provider.agencyPayments[index];
                              final isEven = index % 2 == 0;

                              return Container(
                                color: isEven
                                    ? Colors.white
                                    : const Color(0xFFFAFAFB),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Row(
                                  children: [
                                    // Index
                                    SizedBox(
                                      width: 45,
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),

                                    // Payment Date
                                    Expanded(
                                      child: Text(
                                        _formatDateString(item.paymentDate),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Enquiry Source
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEEF2FF),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: const Color(0xFFC7D2FE),
                                            ),
                                          ),
                                          child: Text(
                                            item.enquirySourceName.isEmpty
                                                ? '-'
                                                : item.enquirySourceName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF4338CA),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Amount Paid
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          _formatCurrency(item.amount),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF059669),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),

                                    // Remark
                                    Expanded(
                                      child: Text(
                                        item.remark.isEmpty ? '-' : item.remark,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: const Color(0xFF334155),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Table Footer (Totals)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          border: Border(
                            top: BorderSide(
                                color: Color(0xFFCBD5E1), width: 1.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 45),
                            Expanded(
                              flex: 2, // spans Payment Date & Enquiry Source
                              child: Text(
                                'TOTALS (${provider.agencyPayments.length} Payments)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _formatCurrency(
                                      provider.totalAgencyPaymentsAmount),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF059669),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobilePaymentsListView(
      SourceCategorySummaryProvider provider) {
    return RefreshIndicator(
      onRefresh: () => provider.getSourceCategorySummary(context),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: provider.agencyPayments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = provider.agencyPayments[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        item.enquirySourceName.isEmpty
                            ? '-'
                            : item.enquirySourceName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    Text(
                      _formatDateString(item.paymentDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount Paid:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      _formatCurrency(item.amount),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                if (item.remark.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Remark: ${item.remark}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF475569),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _exportData(SourceCategorySummaryProvider provider) {
    if (provider.selectedTabIndex == 1) {
      if (provider.agencyPayments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No payment data available to export')),
        );
        return;
      }

      exportToExcel(
        headers: [
          'No',
          'Payment Date',
          'Enquiry Source',
          'Amount Paid',
          'Remark',
        ],
        data: provider.agencyPayments.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return {
            'No': i + 1,
            'Payment Date': item.paymentDate,
            'Enquiry Source': item.enquirySourceName,
            'Amount Paid': item.amount,
            'Remark': item.remark,
          };
        }).toList(),
        fileName: 'Agency_Payments_Report',
      );
      return;
    }

    if (provider.sourceCategoryReport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export')),
      );
      return;
    }

    exportToExcel(
      headers: [
        'No',
        'Parent Source',
        'Enquiry Source',
        'Lead Name',
        'Conversion Date',
        'Project Cost',
        'Commission Percentage',
        'Commission Amount',
      ],
      data: provider.sourceCategoryReport.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return {
          'No': i + 1,
          'Parent Source': item.parentEnquirySource,
          'Enquiry Source': item.enquirySource,
          'Lead Name': item.leadName,
          'Conversion Date': item.conversionDate,
          'Project Cost': item.projectCost,
          'Commission Percentage': item.commissionPercentage,
          'Commission Amount': item.commissionAmount,
        };
      }).toList(),
      fileName: 'Source_Category_Summary_Report',
    );
  }
}
