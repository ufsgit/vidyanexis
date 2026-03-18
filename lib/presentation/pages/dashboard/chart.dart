import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/lead_conversion_model.dart';
import 'package:vidyanexis/controller/models/task_allocation_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/leads_report_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_page_report.dart';

class LeadGraphBarChart extends StatelessWidget {
  const LeadGraphBarChart({
    super.key,
    required this.leadData,
  });

  final List<LeadCoversionChartModel> leadData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lead Graph',
                  style: AppStyles.getBodyTextStyle(
                      fontSize: 14, fontColor: AppColors.textGrey3),
                ),
              ),
              // CustomDropDown(
              //   value: dashboardProvider.selectedeLeadConversionValue,
              //   onChanged: (v) => dashboardProvider.getLeadData(
              //       filterValue: v == "all" ? null : v),
              //   dashboardProvider: dashboardProvider,
              // ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250, // Fixed height for the bar chart
            child: SfCartesianChart(
              primaryXAxis: AppStyles.isWebScreen(context)
                  ? const CategoryAxis(labelRotation: 270)
                  : CategoryAxis(
                      labelRotation: 90,
                      labelIntersectAction: AxisLabelIntersectAction.none,
                      labelStyle: const TextStyle(fontSize: 7),
                      interval: 1,
                      maximumLabels: leadData.length,
                      labelAlignment: LabelAlignment.center,
                    ),
              borderColor: Colors.white,
              tooltipBehavior: TooltipBehavior(enable: true, header: ''),
              series: <CartesianSeries<LeadCoversionChartModel, String>>[
                ColumnSeries<LeadCoversionChartModel, String>(
                  dataSource: leadData,
                  enableTooltip: true,
                  color: AppColors.primaryBlue,
                  width: 0.5,
                  borderRadius: BorderRadius.circular(18),
                  xValueMapper: (LeadCoversionChartModel lead, _) =>
                      lead.enquirySource.toString(),
                  yValueMapper: (LeadCoversionChartModel lead, _) =>
                      lead.leadCount ?? 0,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  onPointTap: (ChartPointDetails details) async {
                    if (details.pointIndex != null) {
                      final item = leadData[details.pointIndex!];
                      final leadReportProvider =
                          Provider.of<LeadReportProvider>(context,
                              listen: false);
                      final dashBoardProvider = Provider.of<DashboardProvider>(
                          context,
                          listen: false);

                      leadReportProvider.setStatus(0);
                      leadReportProvider
                          .setEnquirySourceFilter(item.enquirySourceId);
                      leadReportProvider
                          .setUserFilterStatus(dashBoardProvider.selectedUser);
                      leadReportProvider.setEnquiryForFilter(0);
                      leadReportProvider.setFromandToDate(
                          dashBoardProvider.formattedFromDate,
                          dashBoardProvider.formattedToDate);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LeadPageReport(
                            fromDashBoard: true,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ConversionGraphBarChart extends StatelessWidget {
  const ConversionGraphBarChart({
    super.key,
    required this.leadData,
  });

  final List<LeadCoversionChartModel> leadData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Conversion Graph',
              style: AppStyles.getBodyTextStyle(
                  fontSize: 14, fontColor: AppColors.textGrey3),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250, // Fixed height for the bar chart
            child: SfCartesianChart(
              primaryXAxis: AppStyles.isWebScreen(context)
                  ? const CategoryAxis(labelRotation: 270)
                  : CategoryAxis(
                      labelRotation: 90,
                      labelIntersectAction: AxisLabelIntersectAction.none,
                      labelStyle: const TextStyle(fontSize: 7),
                      interval: 1,
                      maximumLabels: leadData.length,
                      labelAlignment: LabelAlignment.center,
                    ),
              borderColor: Colors.white,
              tooltipBehavior: TooltipBehavior(enable: true, header: ''),
              series: <CartesianSeries<LeadCoversionChartModel, String>>[
                ColumnSeries<LeadCoversionChartModel, String>(
                  dataSource: leadData,
                  enableTooltip: true,
                  color: AppColors.secondaryBlue,
                  width: 0.5,
                  borderRadius: BorderRadius.circular(18),
                  xValueMapper: (LeadCoversionChartModel lead, _) =>
                      lead.enquirySource.toString(),
                  yValueMapper: (LeadCoversionChartModel lead, _) =>
                      int.tryParse(lead.convertedCount ?? "0") ?? 0,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  onPointTap: (ChartPointDetails details) async {
                    if (details.pointIndex != null) {
                      final item = leadData[details.pointIndex!];
                      final leadReportProvider =
                          Provider.of<LeadReportProvider>(context,
                              listen: false);
                      final dashBoardProvider = Provider.of<DashboardProvider>(
                          context,
                          listen: false);

                      leadReportProvider.setStatus(0);
                      leadReportProvider
                          .setEnquirySourceFilter(item.enquirySourceId);
                      leadReportProvider
                          .setUserFilterStatus(dashBoardProvider.selectedUser);
                      leadReportProvider.setEnquiryForFilter(0);
                      leadReportProvider.setFromandToDate(
                          dashBoardProvider.formattedFromDate,
                          dashBoardProvider.formattedToDate);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LeadPageReport(
                            fromDashBoard: true,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeadDistributionPieChart extends StatelessWidget {
  const LeadDistributionPieChart({
    super.key,
    required this.leadData,
  });

  final List<LeadCoversionChartModel> leadData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Lead Graph',
              style: AppStyles.getBodyTextStyle(
                  fontSize: 14, fontColor: AppColors.textGrey3),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300, // Fixed height for the pie chart
            child: SfCircularChart(
              tooltipBehavior: TooltipBehavior(enable: true),
              legend: Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
              ),
              series: <CircularSeries<LeadCoversionChartModel, String>>[
                PieSeries<LeadCoversionChartModel, String>(
                  dataSource: leadData,
                  xValueMapper: (LeadCoversionChartModel lead, _) =>
                      lead.enquirySource.toString(),
                  yValueMapper: (LeadCoversionChartModel lead, _) =>
                      lead.leadCount ?? 0,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
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

class TaskAllocationBarChart extends StatelessWidget {
  const TaskAllocationBarChart({
    super.key,
    required this.taskData,
  });

  final List<TaskAllocationSummaryModel> taskData;

  @override
  Widget build(BuildContext context) {
    // final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Column(
        children: [
          // CustomDropDown(
          //   value: dashboardProvider.selectedeTaskAllocationValue,
          //   onChanged: (v) => dashboardProvider.getTaskAllocationSummary(
          //       isFilter: v != "all", filterValue: v == "all" ? null : v),
          //   dashboardProvider: dashboardProvider,
          // ),
          SfCartesianChart(
            primaryXAxis: AppStyles.isWebScreen(context)
                ? const CategoryAxis(
                    labelRotation: 270, // Less steep rotation
                  )
                : CategoryAxis(
                    labelRotation: 90, // Less steep rotation
                    labelIntersectAction:
                        AxisLabelIntersectAction.none, // Don't hide any labels
                    labelStyle: const TextStyle(fontSize: 7),
                    interval: 1, // Force interval of 1 to show all
                    maximumLabels: taskData.length, // Show all labels
                    labelAlignment: LabelAlignment.center,
                  ),
            borderColor: Colors.white,
            tooltipBehavior: TooltipBehavior(enable: true, header: ''),
            series: <CartesianSeries<TaskAllocationSummaryModel, String>>[
              ColumnSeries<TaskAllocationSummaryModel, String>(
                dataSource: taskData,
                color: AppColors.primaryBlue,
                width: 0.5,
                borderRadius: BorderRadius.circular(18),
                xValueMapper: (TaskAllocationSummaryModel data, _) =>
                    data.userDetailsName ?? '',
                yValueMapper: (TaskAllocationSummaryModel data, _) =>
                    num.tryParse(data.totalTasks ?? "0") ?? 0,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Update the Chart widget methods to use the new classes
/*
  Widget _buildLeadCharts(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LeadGraphBarChart(leadData: leadData),
          ConversionGraphBarChart(leadData: leadData),
          LeadDistributionPieChart(leadData: leadData),
        ],
      ),
    );
  }

  Widget _buildTaskChart(BuildContext context) {
    return TaskAllocationBarChart(taskData: taskData);
  }
*/
