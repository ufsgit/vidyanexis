import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';

class FinancialSummaryChart extends StatelessWidget {
  final DashboardProvider dashboardProvider;

  const FinancialSummaryChart({
    super.key,
    required this.dashboardProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with year dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF505050),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Text(
                      '2024',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary amounts
          Row(
            children: [
              // Invoiced amount
              _buildSummaryItem(
                color: Colors.blue,
                amount: '₹22,45,000',
                label: 'invoiced',
              ),
              const SizedBox(width: 24),

              // Paid amount
              _buildSummaryItem(
                color: Colors.green,
                amount: '₹18,50,000',
                label: 'paid',
              ),
              const SizedBox(width: 24),

              // Pending amount
              _buildSummaryItem(
                color: Colors.orange,
                amount: '₹3,95,000',
                label: 'pending',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart section
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              margin: const EdgeInsets.all(0),
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF606060),
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 150000,
                interval: 50000,
                labelFormat: '{value}',
                axisLabelFormatter: (axisLabelRenderArgs) {
                  if (axisLabelRenderArgs.value == 0) {
                    return ChartAxisLabel('0', axisLabelRenderArgs.textStyle);
                  } else if (axisLabelRenderArgs.value == 50000) {
                    return ChartAxisLabel(
                        '₹50K', axisLabelRenderArgs.textStyle);
                  } else if (axisLabelRenderArgs.value == 100000) {
                    return ChartAxisLabel(
                        '₹100K', axisLabelRenderArgs.textStyle);
                  } else if (axisLabelRenderArgs.value == 150000) {
                    return ChartAxisLabel(
                        '₹150K', axisLabelRenderArgs.textStyle);
                  }
                  return ChartAxisLabel('', axisLabelRenderArgs.textStyle);
                },
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: Colors.grey.shade200,
                  dashArray: const <double>[5, 5],
                ),
                majorTickLines: const MajorTickLines(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF606060),
                ),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: Colors.white,
                borderColor: Colors.grey.shade300,
                borderWidth: 1,
                textStyle: const TextStyle(color: Colors.black),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                alignment: ChartAlignment.far,
                legendItemBuilder:
                    (String name, dynamic series, dynamic point, int index) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          color:
                              name == 'Invoiced' ? Colors.blue : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              series: <CartesianSeries<FinancialData, String>>[
                // Invoiced line
                SplineSeries<FinancialData, String>(
                  name: 'Invoiced',
                  dataSource: getFinancialData(),
                  xValueMapper: (FinancialData data, _) => data.month,
                  yValueMapper: (FinancialData data, _) => data.invoiced,
                  color: Colors.blue,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),

                // Paid line
                SplineSeries<FinancialData, String>(
                  name: 'Paid',
                  dataSource: getFinancialData(),
                  xValueMapper: (FinancialData data, _) => data.month,
                  yValueMapper: (FinancialData data, _) => data.paid,
                  color: Colors.green,
                  width: 2,
                  markerSettings: const MarkerSettings(isVisible: false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required Color color,
    required String amount,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  List<FinancialData> getFinancialData() {
    return [
      FinancialData('Jan', 40000, 60000),
      FinancialData('Feb', 80000, 75000),
      FinancialData('Mar', 75000, 40000),
      FinancialData('Apr', 90000, 85000),
      FinancialData('May', 85000, 110000),
      FinancialData('Jun', 70000, 75000),
      FinancialData('Jul', 110000, 60000),
      FinancialData('Aug', 80000, 50000),
      FinancialData('Sep', 65000, 70000),
      FinancialData('Oct', 100000, 80000),
      FinancialData('Nov', 60000, 90000),
      FinancialData('Dec', 85000, 95000),
    ];
  }
}

class FinancialData {
  final String month;
  final double invoiced;
  final double paid;

  FinancialData(this.month, this.invoiced, this.paid);
}
