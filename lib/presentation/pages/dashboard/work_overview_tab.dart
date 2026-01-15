import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/lead_conversion_model.dart';
import 'package:vidyanexis/controller/models/task_allocation_model.dart';
import 'package:vidyanexis/presentation/pages/dashboard/chart.dart';
import 'package:vidyanexis/presentation/pages/dashboard/customer_work_summary.dart';
import 'package:vidyanexis/presentation/pages/dashboard/weekly_report_card.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [
        TaskAllocationBarChart(
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
