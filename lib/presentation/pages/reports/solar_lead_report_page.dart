import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/solar_lead_report_provider.dart';

class SolarLeadReportPage extends StatefulWidget {
  const SolarLeadReportPage({super.key});

  @override
  State<SolarLeadReportPage> createState() => _SolarLeadReportPageState();
}

class _SolarLeadReportPageState extends State<SolarLeadReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Initialize with this month's data
       final now = DateTime.now();
       final provider = Provider.of<SolarLeadReportProvider>(context, listen: false);
       provider.setDateRange(DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 0));
       provider.fetchReportData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppStyles.isWebScreen(context) ? null : AppBar(
        title: const Text('Solar Lead Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<SolarLeadReportProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Leads Created Per Day',
                  data: provider.leadsCreatedPerDay,
                  yAxisTitle: 'Lead Count',
                  lineColor: AppColors.primaryBlue,
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Lead Conversion Count Per Day',
                  data: provider.conversionsPerDay,
                  yAxisTitle: 'Conversion Count',
                  lineColor: Colors.green,
                ),
                const SizedBox(height: 24),
                _buildChartCard(
                  title: 'Project Cost by Conversion Date',
                  data: provider.projectCostPerDay,
                  yAxisTitle: 'Total Cost',
                  isCurrency: true,
                  lineColor: Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SolarLeadReportProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (AppStyles.isWebScreen(context))
          const Text(
            'Solar Lead Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => _selectDateRange(context, provider),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(
                provider.fromDate == null 
                  ? 'Select Date Range' 
                  : '${DateFormat('dd MMM').format(provider.fromDate!)} - ${DateFormat('dd MMM yyyy').format(provider.toDate!)}',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context, SolarLeadReportProvider provider) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: provider.fromDate != null && provider.toDate != null
          ? DateTimeRange(start: provider.fromDate!, end: provider.toDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
      provider.fetchReportData(context);
    }
  }

  Widget _buildChartCard({
    required String title,
    required List<ChartData> data,
    required String yAxisTitle,
    required Color lineColor,
    bool isCurrency = false,
  }) {
    if (data.isEmpty) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Center(
              child: Text(
                title.contains('Conversion') 
                    ? 'No converted leads found for the selected period' 
                    : title.contains('Cost')
                        ? 'No project cost data available for converted leads'
                        : 'No data available',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

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
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('dd MMM'),
                majorGridLines: const MajorGridLines(width: 0),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                intervalType: DateTimeIntervalType.days,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: yAxisTitle),
                numberFormat: isCurrency 
                    ? NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0) 
                    : NumberFormat.compact(),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
              ),
              series: <CartesianSeries<ChartData, DateTime>>[
                SplineSeries<ChartData, DateTime>(
                  dataSource: data,
                  xValueMapper: (ChartData d, _) => d.date,
                  yValueMapper: (ChartData d, _) => d.value,
                  name: title,
                  color: lineColor,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    borderWidth: 2,
                    borderColor: Colors.white,
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
