import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_status_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_status_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class LeadStatusReportScreen extends StatefulWidget {
  final bool fromDashBoard;
  static const String route = '/leadStatusReport';
  const LeadStatusReportScreen({super.key, this.fromDashBoard = false});

  @override
  State<LeadStatusReportScreen> createState() => _LeadStatusReportScreenState();
}

class _LeadStatusReportScreenState extends State<LeadStatusReportScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<LeadStatusReportProvider>(context, listen: false);

      provider.fetchReportData(context);
    });
  }

  String formatDateStr(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('dd MMM yyyy').format(date);
    }
    if (date is String && date.isNotEmpty) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
      } catch (e) {
        return date;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeadStatusReportProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: AppStyles.isWebScreen(context)
          ? null
          : CustomAppBar(
              title: 'Lead Status Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onFilterTap: () => provider.toggleFilter(),
              onSearch: (query) {},
              showSearch: false,
            ),
      body: Consumer<LeadStatusReportProvider>(
        builder: (context, provider, child) {
          if (AppStyles.isWebScreen(context)) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  const SizedBox(height: 24),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildContentBody(context, provider),
                ],
              ),
            );
          }
          return _buildMobileLayout(context, provider);
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, LeadStatusReportProvider provider) {
    return Column(
      children: [
        if (provider.isFilter) _buildFilterPanel(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.reportData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.reportData.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildChartCard('Lead Status Funnel', provider.reportData),
                              const SizedBox(height: 24),
                              CustomText('Status Summary',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlack),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                        final totalLeads = provider.reportData.fold(0, (sum, item) => sum + (item.leadCount ?? 0));
                        final report = provider.reportData[index - 1];
                        final percentage = totalLeads > 0 
                            ? ((report.leadCount ?? 0) / totalLeads * 100) 
                            : 0.0;
                            
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReportListItem(
                            title: report.statusName ?? 'Unknown',
                            subtitle: '${percentage.toStringAsFixed(1)}%',
                            description: 'Total Leads: ${report.leadCount ?? 0}',
                            statusColor: AppColors.primaryBlue,
                            trailingText: (report.leadCount ?? 0).toString(),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(
      BuildContext context, LeadStatusReportProvider provider) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: provider.fromDate?.toString(),
              toDate: provider.toDate?.toString(),
              formattedFromDate: provider.formattedFromDate,
              formattedToDate: provider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.fetchReportData(context);
                      provider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    provider.removeStatus();
                    provider.fetchReportData(context);
                  },
                ),
              ],
            ),
          ],
        ),
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
          Text(
            'No report data found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(
      BuildContext context, LeadStatusReportProvider provider) {
    if (provider.reportData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No data available',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildChartCard('Lead Status Funnel', provider.reportData),
        const SizedBox(height: 24),
        _buildTableCard('Lead Status Counts', provider.reportData),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, LeadStatusReportProvider provider) {
    return Column(
      children: [
        AppStyles.isWebScreen(context)
            ? Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    if (widget.fromDashBoard) ...[
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            size: 24, color: Color(0xFF152D70)),
                      ),
                      const SizedBox(width: 8),
                    ] else ...[
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
                    ],
                    const Text(
                      'Sales Pipeline',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (query) {
                          provider.fetchReportData(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                              hintStyle: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF64748B),
                                size: 18,
                              ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                provider.fetchReportData(context);
                              },
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                                backgroundColor: AppColors.textGrey4,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              child: const Text('Search'),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomFilterButton(
                      onPressed: () {
                        provider.toggleFilter();
                      },
                      isFilter: provider.isFilter,
                    ),
                    const SizedBox(width: 16),
                    CustomElevatedButton(
                          radius: 4,
                      onPressed: () {
                        exportToExcel(
                          headers: ['Status ID', 'Status Name', 'Lead Count'],
                          data: provider.reportData.map((item) {
                            return {
                              'Status ID': item.statusId.toString(),
                              'Status Name': item.statusName,
                              'Lead Count': item.leadCount.toString(),
                            };
                          }).toList(),
                          fileName: 'Sales_Pipeline_Report',
                        );
                      },
                      buttonText: 'Export to Excel',
                      textColor: AppColors.whiteColor,
                      borderColor: const Color(0xFFCD9C11),
                      backgroundColor: const Color(0xFFCD9C11),
                    )
                  ],
                ),
              )
            : Container(),
        if (provider.isFilter)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                CommonReportDateFilter(
                  fromDate: provider.fromDate?.toString(),
                  toDate: provider.toDate?.toString(),
                  formattedFromDate: provider.formattedFromDate,
                  formattedToDate: provider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                ),
                const Spacer(),
                CommonReportResetButton(
                  onReset: () {
                    provider.selectDateFilterOption(null);
                    provider.fetchReportData(context);
                  },
                  label: 'Reset',
                ),
              ],
            ),
          ),
      ],
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<LeadStatusReportProvider>(
        builder: (contextx, provider, child) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text('Choose Date',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            provider.setDateFilter(title);
                            provider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          label: Text(title),
                          backgroundColor:
                              provider.selectedDateFilterIndex == index
                                  ? const Color(0xFFF1B418)
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: provider.selectedDateFilterIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text('Pick a date',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              hintText: provider.fromDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(provider.fromDate!)
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              hintText: provider.toDate != null
                                  ? DateFormat('yyyy-MM-dd')
                                      .format(provider.toDate!)
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.fetchReportData(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                          backgroundColor: const Color(0xFFCD9C11),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          provider.selectDateFilterOption(null);
                          provider.fetchReportData(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                        ),
                        child: const Text('Clear'),
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

  Widget _buildChartCard(String title, List<LeadStatusReportModel> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 400,
            child: SfFunnelChart(
              palette: const [
                Color(0xFF152654), // Deep Blue
                Color(0xFF1E3A8A), // Blue
                Color(0xFF3B82F6), // Bright Blue
                Color(0xFF60A5FA), // Light Blue
                Color(0xFF93C5FD), // Sky Blue
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: 'Lead Status',
                canShowMarker: true,
                format: 'point.x : point.y Leads',
              ),
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
                offset: const Offset(0, 10),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              series: FunnelSeries<LeadStatusReportModel, String>(
                dataSource: data,
                xValueMapper: (LeadStatusReportModel model, _) =>
                    model.statusName,
                yValueMapper: (LeadStatusReportModel model, _) =>
                    model.leadCount,
                gapRatio: 0.05,
                neckWidth: '20%',
                neckHeight: '15%',
                explode: true,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.inside,
                  useSeriesColor: false,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(String title, List<LeadStatusReportModel> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor:
                  WidgetStateProperty.resolveWith((states) => Colors.grey[100]),
              columns: const [
                DataColumn(
                    label: Text('Status ID',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Status Name',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Lead Count',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: data.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.statusId?.toString() ?? '-')),
                    DataCell(Text(item.statusName ?? '-')),
                    DataCell(Text(item.leadCount?.toString() ?? '0')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
