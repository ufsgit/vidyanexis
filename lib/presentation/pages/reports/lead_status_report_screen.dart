import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_status_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_status_report_model.dart';


import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppStyles.isWebScreen(context) ? null : AppBar(
        title: const Text('Lead Status Report'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<LeadStatusReportProvider>(
        builder: (context, provider, child) {
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
        },
      ),
    );
  }

  Widget _buildContentBody(BuildContext context, LeadStatusReportProvider provider) {
    if (provider.reportData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                    if (widget.fromDashBoard)
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            size: 24, color: Color(0xFF152D70)),
                      ),
                    if (widget.fromDashBoard) const SizedBox(width: 8),
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
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: searchController,
                        onSubmitted: (query) {
                          provider.fetchReportData(context);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                provider.fetchReportData(context);
                              },
                              style: ElevatedButton.styleFrom(
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
                    OutlinedButton.icon(
                      onPressed: () {
                        provider.toggleFilter();
                      },
                      icon: const Icon(Icons.filter_list),
                      label: Text(MediaQuery.of(context).size.width > 860
                          ? 'Filter'
                          : ''),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: provider.isFilter
                            ? Colors.white
                            : AppColors.primaryBlue,
                        backgroundColor: provider.isFilter
                            ? const Color(0xFF5499D9)
                            : Colors.white,
                        side: BorderSide(
                            color: provider.isFilter
                                ? const Color(0xFF5499D9)
                                : AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomElevatedButton(
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
                GestureDetector(
                  onTap: () => onClickTopButton(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: provider.fromDate != null ||
                                  provider.toDate != null
                              ? AppColors.primaryBlue
                              : Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        if (provider.fromDate == null &&
                            provider.toDate == null)
                          const Text('Date: All'),
                        if (provider.fromDate != null &&
                            provider.toDate != null)
                          Text(
                              'Date : ${provider.formattedFromDate} - ${provider.formattedToDate}'),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.black45, size: 20),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (provider.fromDate != null || provider.toDate != null)
                  ElevatedButton(
                    onPressed: () {
                      provider.selectDateFilterOption(null);
                      provider.fetchReportData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textRed,
                      side: BorderSide(color: AppColors.textRed),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Reset'),
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                      children:
                          List<Widget>.generate(dateButtonTitles.length, (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            provider.setDateFilter(title);
                            provider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
                                  borderRadius: BorderRadius.circular(15)),
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
                                  borderRadius: BorderRadius.circular(15)),
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
                        style: ElevatedButton.styleFrom(
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
                        style: ElevatedButton.styleFrom(
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
        borderRadius: BorderRadius.circular(16),
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
        borderRadius: BorderRadius.circular(12),
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[100]),
              columns: const [
                DataColumn(label: Text('Status ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status Name', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Lead Count', style: TextStyle(fontWeight: FontWeight.bold))),
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
