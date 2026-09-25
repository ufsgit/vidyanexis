import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/day_wise_count_model.dart';

class LeadFlowTab extends StatefulWidget {
  const LeadFlowTab({super.key});

  @override
  State<LeadFlowTab> createState() => _LeadFlowTabState();
}

class _LeadFlowTabState extends State<LeadFlowTab> {

  List<_ChartData> _mapToChartData(List<DayWiseCountModel> apiData) {
    return apiData.map((e) {
      // Use toLocal() to prevent timezone shifts from UTC
      final date = e.date?.toLocal() ?? DateTime.now();
      return _ChartData(date, e.leadCount ?? 0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    bool isWide = MediaQuery.of(context).size.width > 900;

    return Container(
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
      padding: const EdgeInsets.all(24),
      child: provider.isDashBoardLoading 
          ? const Center(child: CircularProgressIndicator())
          : isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeadCountChart(provider)),
                const SizedBox(width: 24),
                Expanded(child: _buildConversionChart(provider)),
              ],
            )
          : Column(
              children: [
                _buildLeadCountChart(provider),
                const SizedBox(height: 24),
                _buildConversionChart(provider),
              ],
            ),
    );
  }

  Widget _buildLeadCountChart(DashboardProvider provider) {
    final leadData = _mapToChartData(provider.leadCountDayWise);
    return _buildChartCard(
      title: 'Lead Conversions Count (Day-wise)',
      child: leadData.isEmpty ? const Center(child: Text("No Data")) : _buildAreaChart(
        data: leadData,
        gradientColors: [
          AppColors.primaryBlue.withOpacity(0.6),
          AppColors.primaryBlue.withOpacity(0.0),
        ],
        lineColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildConversionChart(DashboardProvider provider) {
    final conversionData = _mapToChartData(provider.conversionCountDayWise);
    return _buildChartCard(
      title: 'Conversion Count (Day-wise)',
      child: conversionData.isEmpty ? const Center(child: Text("No Data")) : _buildAreaChart(
        data: conversionData,
        gradientColors: [
          const Color(0xFF14A46B).withOpacity(0.6),
          const Color(0xFF14A46B).withOpacity(0.0),
        ],
        lineColor: const Color(0xFF14A46B),
      ),
    );
  }

  Widget _buildChartCard(
      {required String title, required Widget child, Widget? action}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart({
    required List<_ChartData> data,
    required List<Color> gradientColors,
    required Color lineColor,
  }) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      margin: EdgeInsets.zero,
      primaryXAxis: DateTimeAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        dateFormat: DateFormat('MMM dd'),
        intervalType: DateTimeIntervalType.days,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: Colors.grey.shade200,
          dashArray: const <double>[5, 5],
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: Colors.grey.shade600,
        ),
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: true,
        textStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
      ),
      series: <CartesianSeries<_ChartData, DateTime>>[
        AreaSeries<_ChartData, DateTime>(
          dataSource: data,
          xValueMapper: (_ChartData data, _) => data.date,
          yValueMapper: (_ChartData data, _) => data.count,
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderDrawMode: BorderDrawMode.top,
          borderColor: lineColor,
          borderWidth: 2,
          animationDuration: 1000,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: Colors.white,
            borderColor: lineColor,
            borderWidth: 2,
            shape: DataMarkerType.circle,
          ),
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.date, this.count);
  final DateTime date;
  final int count;
}
