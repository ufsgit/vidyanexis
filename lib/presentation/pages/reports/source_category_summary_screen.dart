import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
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

            // Content Table / List
            Expanded(
              child: provider.sourceCategoryReport.isEmpty
                  ? const CommonEmptyState(
                      message: 'No source category records found',
                    )
                  : (isWeb
                      ? _buildWebTableView(provider)
                      : _buildMobileListView(provider)),
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

              // Parent Category Dropdown
              if (provider.uniqueParentCategories.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: provider.selectedParentCategory != null
                          ? AppColors.primaryBlue
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedParentCategory,
                      hint: Text(
                        'All Parent Categories',
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
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Parent Categories',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        ...provider.uniqueParentCategories.map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          provider.setParentCategoryFilter(val),
                    ),
                  ),
                ),

              // Enquiry Source Dropdown
              if (provider.uniqueEnquirySources.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: provider.selectedEnquirySource != null
                          ? AppColors.primaryBlue
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: provider.selectedEnquirySource,
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
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Enquiry Sources',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        ...provider.uniqueEnquirySources.map(
                          (src) => DropdownMenuItem<String>(
                            value: src,
                            child: Text(src),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          provider.setEnquirySourceFilter(val),
                    ),
                  ),
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
              value: _formatCurrency(provider.totalCommissionAmount),
              subtitle: 'Calculated commission',
              icon: Icons.verified_outlined,
              iconColor: const Color(0xFF7C3AED),
              bgColor: const Color(0xFFF5F3FF),
              accentColor: const Color(0xFF8B5CF6),
            ),
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
    const double tableMinWidth = 1270;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
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
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: tableMinWidth),
              child: SizedBox(
                width: tableMinWidth,
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
                          _buildColumnHeader('#', width: 50),
                          _buildColumnHeader('PARENT SOURCE', width: 170),
                          _buildColumnHeader('ENQUIRY SOURCE', width: 160),
                          _buildColumnHeader('LEAD NAME', width: 220),
                          _buildColumnHeader('CONVERSION DATE', width: 180),
                          _buildColumnHeader('PROJECT COST',
                              width: 150, alignment: Alignment.centerRight),
                          _buildColumnHeader('COMMISSION %',
                              width: 120, alignment: Alignment.center),
                          _buildColumnHeader('COMMISSION AMOUNT',
                              width: 170, alignment: Alignment.centerRight),
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
                                    width: 50,
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
                                  SizedBox(
                                    width: 170,
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
                                  SizedBox(
                                    width: 160,
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
                                  SizedBox(
                                    width: 220,
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
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      _formatDateString(item.conversionDate),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),

                                  // Project Cost
                                  SizedBox(
                                    width: 150,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatCurrency(item.projectCost),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Commission %
                                  SizedBox(
                                    width: 120,
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
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Commission Amount
                                  SizedBox(
                                    width: 170,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _formatCurrency(item.commissionAmount),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF059669),
                                        ),
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
                          const SizedBox(width: 50),
                          SizedBox(
                            width: 170 + 160 + 220 + 180,
                            child: Text(
                              'TOTALS (${provider.sourceCategoryReport.length} Entries)',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatCurrency(provider.totalProjectCost),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: Center(
                              child: Text(
                                '${provider.avgCommissionPercentage.toStringAsFixed(1)}% avg',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 170,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatCurrency(provider.totalCommissionAmount),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
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
        ),
      ),
    );
  }

  Widget _buildColumnHeader(String title,
      {required double width, Alignment alignment = Alignment.centerLeft}) {
    return SizedBox(
      width: width,
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

  void _exportData(SourceCategorySummaryProvider provider) {
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
