import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/employee_summary_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class EmployeeSummaryReportScreen extends StatefulWidget {
  const EmployeeSummaryReportScreen({super.key});

  @override
  State<EmployeeSummaryReportScreen> createState() =>
      _EmployeeSummaryReportScreenState();
}

class _EmployeeSummaryReportScreenState
    extends State<EmployeeSummaryReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<EmployeeSummaryProvider>(context, listen: false);
      reportsProvider.clearAllFilters();
      reportsProvider.getEmployeeSummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EmployeeSummaryProvider>(context);

    // Calculate dynamic cumulative totals of clients and statuses
    int totalClientsCount = 0;
    int totalConverted = 0;
    int totalScheduled = 0;
    int totalCold = 0;

    for (var item in reportsProvider.employeeReport) {
      totalClientsCount += item.noOfClients ?? 0;
      if (item.summaryStatus != null) {
        for (var status in item.summaryStatus!) {
          final lower = (status.statusName ?? '').toLowerCase();
          if (lower.contains('converted')) {
            totalConverted += status.count ?? 0;
          } else if (lower.contains('scheduled')) {
            totalScheduled += status.count ?? 0;
          } else if (lower.contains('cold')) {
            totalCold += status.count ?? 0;
          }
        }
      }
    }

    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Employee Summary',
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
                            borderRadius: BorderRadius.circular(12),
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
                      'Employee Summary',
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
                      _buildReportTable(reportsProvider),
                      const SizedBox(height: 20),
                      _buildSummaryDashboard(
                        totalClientsCount,
                        totalConverted,
                        totalScheduled,
                        totalCold,
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
                  heroTag: 'apply_employee_summary_filter_fab',
                  onPressed: () {
                    reportsProvider.setTaskSearchCriteria(searchController.text);
                    reportsProvider.getEmployeeSummary(context);
                    reportsProvider.toggleFilter();
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
      BuildContext context, EmployeeSummaryProvider reportsProvider) {
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
                  label: 'Allocation Date',
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
                    reportsProvider.getEmployeeSummary(context);
                  },
                ),
              ]
            ],
          ),
          const SizedBox(height: 40),
          if (reportsProvider.fromDate != null || reportsProvider.toDate != null || searchController.text.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                label: 'Reset All Filters',
                onReset: () {
                  reportsProvider.selectDateFilterOption(null);
                  searchController.clear();
                  reportsProvider.clearAllFilters();
                  reportsProvider.getEmployeeSummary(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textRed,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.textRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportTable(EmployeeSummaryProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                  flex: 3,
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
                  flex: 2,
                  child: Center(
                    child: Text(
                      'CLIENTS',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'DETAILS',
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
          if (provider.employeeReport.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.employeeReport.length,
              itemBuilder: (context, index) {
                final item = provider.employeeReport[index];
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
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            item.employeeName ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.primaryBlue.withOpacity(0.12)),
                            ),
                            child: Text(
                              '${item.noOfClients ?? 0}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: (item.summaryStatus ?? [])
                              .map((status) => _buildStatusTag(
                                  status.statusName ?? '', status.count ?? 0))
                              .toList(),
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

  Widget _buildStatusTag(String name, int count) {
    Color textCol = AppColors.primaryBlue;
    Color bgCol = AppColors.primaryBlue.withOpacity(0.08);
    final lowerName = name.toLowerCase();

    if (lowerName.contains('converted')) {
      textCol = const Color(0xFF16A34A); // Green
      bgCol = const Color(0xFFDCFCE7);
    } else if (lowerName.contains('scheduled')) {
      textCol = const Color(0xFF2563EB); // Indigo/Blue
      bgCol = const Color(0xFFDBEAFE);
    } else if (lowerName.contains('cold') || lowerName.contains('progress')) {
      textCol = const Color(0xFF64748B); // Slate/Grey
      bgCol = const Color(0xFFF1F5F9);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(20),
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
            '$count',
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

  Widget _buildSummaryDashboard(
    int totalClientsCount,
    int totalConverted,
    int totalScheduled,
    int totalCold,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'Overall Summary',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Navy Blue
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Total Clients: $totalClientsCount',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: [
              _buildDashboardItem('Converted', totalConverted),
              _buildDashboardItem('Interview Scheduled', totalScheduled),
              _buildDashboardItem('Cold', totalCold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(String name, int count) {
    Color color = AppColors.primaryBlue;
    Color bgCol = AppColors.primaryBlue.withOpacity(0.05);
    final lowerName = name.toLowerCase();

    if (lowerName.contains('converted')) {
      color = const Color(0xFF16A34A);
      bgCol = const Color(0xFFDCFCE7).withOpacity(0.5);
    } else if (lowerName.contains('scheduled')) {
      color = const Color(0xFF2563EB);
      bgCol = const Color(0xFFDBEAFE).withOpacity(0.5);
    } else if (lowerName.contains('cold') || lowerName.contains('progress')) {
      color = const Color(0xFF64748B);
      bgCol = const Color(0xFFF1F5F9).withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.search_off_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<EmployeeSummaryProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
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
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
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
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!)),
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
                          reportsProvider.getEmployeeSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
                          reportsProvider.getEmployeeSummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.08),
                          foregroundColor: AppColors.textRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
