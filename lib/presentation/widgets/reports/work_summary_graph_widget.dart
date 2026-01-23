import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/work_summary_model.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/work_summary_provider.dart';

class WorkSummaryGraphWidget extends StatefulWidget {
  const WorkSummaryGraphWidget({super.key});

  @override
  State<WorkSummaryGraphWidget> createState() => _WorkSummaryGraphWidgetState();
}

class _WorkSummaryGraphWidgetState extends State<WorkSummaryGraphWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final summaryReport =
        context.select<WorkSummaryProvider, List<WorkSummaryModel>>((provider) => provider.taskReport);

    if (summaryReport.isEmpty) {
      return const Center(
        child: Text(
          'No data available to display',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    double maxY = 18000;
    if (summaryReport.isNotEmpty) {
      double maxData = 0;
      for (var item in summaryReport) {
        if (item.noOfFollowUp > maxData) {
          maxData = item.noOfFollowUp.toDouble();
        }
      }
      if (maxData > 18000) {
        maxY = (maxData / 500).ceil() * 500;
      }
    }

    // Wrap in RepaintBoundary to separate chart rendering from parent updates
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(16),
          child: SfCartesianChart(
            primaryXAxis: const CategoryAxis(
              title: AxisTitle(text: 'User Name'),
              labelIntersectAction: AxisLabelIntersectAction.rotate45,
              labelPlacement: LabelPlacement.betweenTicks,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: const AxisTitle(text: 'No of Follow up'),
              minimum: 0,
              maximum: maxY,
              interval: 500,
              majorGridLines: const MajorGridLines(width: 0.5),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<WorkSummaryModel, String>>[
              ColumnSeries<WorkSummaryModel, String>(
                dataSource: summaryReport,
                xValueMapper: (WorkSummaryModel data, _) => data.toStaff,
                yValueMapper: (WorkSummaryModel data, _) => data.noOfFollowUp,
                name: 'Follow Ups',
                color: AppColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelAlignment: ChartDataLabelAlignment.outer,
                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                width: 0.5,
                spacing: 0.2,
                animationDuration: 300, // Reduced to 300ms for better performance
              )
            ],
          ),
        ),
      ),
    );
  }
}
