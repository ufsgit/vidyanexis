import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/enquiry_source_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class EnquirySourceSummaryReportScreen extends StatefulWidget {
  const EnquirySourceSummaryReportScreen({super.key});

  @override
  State<EnquirySourceSummaryReportScreen> createState() =>
      _EnquirySourceSummaryReportScreenState();
}

class _EnquirySourceSummaryReportScreenState
    extends State<EnquirySourceSummaryReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<EnquirySourceProvider>(context, listen: false);
      reportsProvider.resetExpandedStates();
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', conversionFromDate: '', conversionToDate: '');
      reportsProvider.getEnquirySummary(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<EnquirySourceProvider>(context);

    // Calculate status totals
    Map<String, int> statusTotals = {};
    int totalLeads = 0;

    for (var item in reportsProvider.enquiryReport) {
      if (item.totalLeads != null) {
        if (item.totalLeads is String) {
          totalLeads += int.tryParse(item.totalLeads.toString()) ?? 0;
        } else if (item.totalLeads is num) {
          totalLeads += (item.totalLeads as num).toInt();
        }
      }

      if (item.summaryStatus != null) {
        for (var status in item.summaryStatus!) {
          if (status.statusName != null) {
            final statusName = status.statusName!;
            int statusCount = 0;
            if (status.count != null) {
              if (status.count is String) {
                statusCount = int.tryParse(status.count.toString()) ?? 0;
              } else if (status.count is num) {
                statusCount = (status.count as num).toInt();
              }
            }
            statusTotals[statusName] =
                (statusTotals[statusName] ?? 0) + statusCount;
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
              title: 'Enquiry Source Summary',
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
                      'Enquiry Source Summary',
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
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 40.0),
                  child: Column(
                    children: [
                      _buildReportTable(reportsProvider),
                      const SizedBox(height: 24),
                      _buildSummaryDashboard(totalLeads, statusTotals),
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
                  heroTag: 'apply_enquiry_summary_filter_fab',
                  onPressed: () {
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.formattedFromDate,
                      reportsProvider.formattedToDate,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      conversionFromDate: reportsProvider.formattedConversionFromDate,
                      conversionToDate: reportsProvider.formattedConversionToDate,
                    );
                    reportsProvider.getEnquirySummary(context);
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
      BuildContext context, EnquirySourceProvider reportsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CustomText(
            'Creation Date (Entry Date)',
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
                  onTap: () => onClickTopButton(context, isConversion: false),
                  label: 'Entry Date',
                ),
              ),
              if (reportsProvider.fromDate != null ||
                  reportsProvider.toDate != null) ...[
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.selectDateFilterOption(null, isConversion: false);
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      '',
                      '',
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      conversionFromDate: reportsProvider.formattedConversionFromDate,
                      conversionToDate: reportsProvider.formattedConversionToDate,
                    );
                    reportsProvider.getEnquirySummary(context);
                  },
                ),
              ]
            ],
          ),
          const SizedBox(height: 24),
          CustomText(
            'Conversion Date (Registered Date)',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textBlack,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CommonReportDateFilter(
                  fromDate: reportsProvider.conversionFromDate?.toString(),
                  toDate: reportsProvider.conversionToDate?.toString(),
                  formattedFromDate: reportsProvider.formattedConversionFromDate,
                  formattedToDate: reportsProvider.formattedToDate,
                  onTap: () => onClickTopButton(context, isConversion: true),
                  label: 'Registered Date',
                ),
              ),
              if (reportsProvider.conversionFromDate != null ||
                  reportsProvider.conversionToDate != null) ...[
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    reportsProvider.selectDateFilterOption(null, isConversion: true);
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.formattedFromDate,
                      reportsProvider.formattedToDate,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      conversionFromDate: '',
                      conversionToDate: '',
                    );
                    reportsProvider.getEnquirySummary(context);
                  },
                ),
              ]
            ],
          ),
          const SizedBox(height: 40),
          if (reportsProvider.fromDate != null ||
              reportsProvider.toDate != null ||
              reportsProvider.conversionFromDate != null ||
              reportsProvider.conversionToDate != null)
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                label: 'Reset All Filters',
                onReset: () {
                  reportsProvider.removeStatus();
                  searchController.clear();
                  reportsProvider.setTaskSearchCriteria('', '', '', '', '', conversionFromDate: '', conversionToDate: '');
                  reportsProvider.getEnquirySummary(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textRed,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.textRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReportTable(EnquirySourceProvider provider) {
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                    'ENQUIRY SOURCE',
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
                      'LEADS',
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
          if (provider.enquiryReport.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.enquiryReport.length,
              itemBuilder: (context, index) {
                final item = provider.enquiryReport[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
                            item.enquirySourceName ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.primaryBlue.withOpacity(0.12),
                              ),
                            ),
                            child: Text(
                              '${item.totalLeads}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
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

  Widget _buildStatusTag(String name, dynamic count) {
    Color textCol = AppColors.primaryBlue;
    Color bgCol = AppColors.primaryBlue.withOpacity(0.08);
    final lowerName = name.toLowerCase();

    if (lowerName.contains('converted')) {
      textCol = const Color(0xFF16A34A); // Vibrant green
      bgCol = const Color(0xFFDCFCE7); // Soft green background
    } else if (lowerName.contains('not interested')) {
      textCol = const Color(0xFFDC2626); // Vibrant red
      bgCol = const Color(0xFFFEE2E2); // Soft red background
    } else if (lowerName.contains('in progress')) {
      textCol = const Color(0xFFD97706); // Vibrant orange
      bgCol = const Color(0xFFFEF3C7); // Soft orange background
    } else if (lowerName.contains('follow up') ||
        lowerName.contains('sitevisit') ||
        lowerName.contains('ready') ||
        lowerName.contains('called')) {
      textCol = const Color(0xFF2563EB); // Vibrant blue/indigo
      bgCol = const Color(0xFFDBEAFE); // Soft blue background
    } else {
      textCol = const Color(0xFF475569); // Charcoal slate
      bgCol = const Color(0xFFF1F5F9); // Soft slate background
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textCol.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: textCol,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155), // Slate-700
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard(int totalLeads, Map<String, int> statusTotals) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'Overall Summary',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A), // Navy Blue
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Total Leads: $totalLeads',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: statusTotals.length,
            itemBuilder: (context, index) {
              final entry = statusTotals.entries.elementAt(index);
              return _buildDashboardItem(entry.key, entry.value);
            },
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
    } else if (lowerName.contains('not interested')) {
      color = const Color(0xFFDC2626);
      bgCol = const Color(0xFFFEE2E2).withOpacity(0.5);
    } else if (lowerName.contains('in progress')) {
      color = const Color(0xFFD97706);
      bgCol = const Color(0xFFFEF3C7).withOpacity(0.5);
    } else if (lowerName.contains('follow up') ||
        lowerName.contains('sitevisit') ||
        lowerName.contains('ready') ||
        lowerName.contains('called')) {
      color = const Color(0xFF2563EB);
      bgCol = const Color(0xFFDBEAFE).withOpacity(0.5);
    } else {
      color = const Color(0xFF475569);
      bgCol = const Color(0xFFF1F5F9).withOpacity(0.5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(4),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
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

  void onClickTopButton(BuildContext context, {bool isConversion = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<EnquirySourceProvider>(
        builder: (contextx, reportsProvider, child) {
          final isSelectedOption = isConversion
              ? reportsProvider.selectedConversionDateFilterIndex
              : reportsProvider.selectedDateFilterIndex;
          
          final currentFromDate = isConversion
              ? reportsProvider.conversionFromDate
              : reportsProvider.fromDate;
          
          final currentToDate = isConversion
              ? reportsProvider.conversionToDate
              : reportsProvider.toDate;

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
                        final bool isSelected = isSelectedOption == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilter(title, isConversion: isConversion);
                            reportsProvider.selectDateFilterOption(index, isConversion: isConversion);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                                reportsProvider.selectDate(context, true, isConversion: isConversion),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: currentFromDate != null
                                  ? '${currentFromDate.toLocal()}'
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
                                reportsProvider.selectDate(context, false, isConversion: isConversion),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: currentToDate != null
                                  ? '${currentToDate.toLocal()}'
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
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          String convFromDate = reportsProvider.formattedConversionFromDate;
                          String convToDate = reportsProvider.formattedConversionToDate;
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo,
                              conversionFromDate: convFromDate,
                              conversionToDate: convToDate);
                          reportsProvider.getEnquirySummary(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                          reportsProvider.selectDateFilterOption(null, isConversion: isConversion);
                          reportsProvider.getEnquirySummary(context);
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

