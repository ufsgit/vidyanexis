import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/dashboard_provider.dart';
import 'package:techtify/controller/models/lead_conversion_model.dart';
import 'package:techtify/controller/models/task_allocation_model.dart';
import 'package:techtify/presentation/pages/dashboard/chart.dart';
import 'package:techtify/presentation/pages/dashboard/custom_table_widget.dart';
import 'package:techtify/presentation/pages/dashboard/customer_work_summary.dart';
import 'package:techtify/presentation/pages/dashboard/financial_report_graph.dart';
import 'package:techtify/presentation/pages/dashboard/weekly_report_card.dart';

class WorkOverViewTab extends StatefulWidget {
  const WorkOverViewTab({
    super.key,
    required this.data,
    required this.countLeadData,
    required this.taskData,
    required this.dashboardProvider,
  });

  final List<LeadCoversionChartModel> data;
  final List<CountLeadCoversionChartModel> countLeadData;
  final List<TaskAllocationSummaryModel> taskData;
  final DashboardProvider dashboardProvider;

  @override
  State<WorkOverViewTab> createState() => _WorkOverViewTabState();
}

class _WorkOverViewTabState extends State<WorkOverViewTab> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DashboardProvider dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      dashBoardProvider.getWorkData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [
        Chart(
          dashboardProvider: widget.dashboardProvider,
          leadData: widget.data,
          countLeadData: widget.countLeadData,
          taskData: widget.taskData,
        ),
        WeeklyReportCard(
          dashboardProvider: widget.dashboardProvider,
        ),
        CustomerWorkSummary(
          dashBoardProvider: widget.dashboardProvider,
        ),
        // FinancialSummaryChart(
        //   dashboardProvider: widget.dashboardProvider,
        // ),
      ],
    );
  }
}
