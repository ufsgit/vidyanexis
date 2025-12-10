import 'package:flutter/material.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/dashboard_provider.dart';
import 'package:techtify/controller/models/lead_conversion_model.dart';
import 'package:techtify/controller/models/task_allocation_model.dart';
import 'package:techtify/presentation/pages/dashboard/count_widget.dart';
import 'package:techtify/presentation/pages/dashboard/custom_dropdown.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.leadData,
    this.isLeadOverView = false,
    required this.countLeadData,
    required this.taskData,
    required this.dashboardProvider,
  });

  final bool isLeadOverView;
  final List<LeadCoversionChartModel> leadData;
  final List<TaskAllocationSummaryModel> taskData;
  final List<CountLeadCoversionChartModel> countLeadData;
  final DashboardProvider dashboardProvider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      constraints: BoxConstraints(
        minWidth: 399,
        maxWidth: 1800,
        maxHeight: isLeadOverView ? 500 : 420,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLeadOverView
                    ? 'Lead Conversion by Source'
                    : 'Task Allocation Overview',
                style: AppStyles.getBodyTextStyle(
                    fontSize: 14, fontColor: AppColors.textGrey3),
              ),
              CustomDropDown(
                value: isLeadOverView
                    ? dashboardProvider.selectedeLeadConversionValue
                    : dashboardProvider.selectedeTaskAllocationValue,
                onChanged: (v) => isLeadOverView
                    ? dashboardProvider.getLeadConversionChartData(
                        isFilter: v != "all",
                        filterValue: v == "all" ? null : v)
                    : dashboardProvider.getTaskAllocationSummary(
                        isFilter: v != "all",
                        filterValue: v == "all" ? null : v),
                dashboardProvider: dashboardProvider,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Count Row
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: isLeadOverView
                      ? (countLeadData.isNotEmpty
                          ? '${countLeadData[0].totalLeadCount ?? "0"}'
                          : "0")
                      : (dashboardProvider.taskCount.isNotEmpty
                          ? dashboardProvider.taskCount[0]['totalTaskCount']
                              .toString()
                          : "0"),
                  style: AppStyles.getHeadingTextStyle(fontSize: 16),
                  children: [
                    TextSpan(
                      text: '    ${isLeadOverView ? 'Leads' : 'Tasks'}',
                      style: AppStyles.getHeadingTextStyle(
                          fontSize: 16, fontColor: AppColors.textGrey4),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (isLeadOverView) ...[
                CountWidget(
                  count: countLeadData.isNotEmpty
                      ? countLeadData[0].totalLeadCount ?? 0
                      : 0,
                  title: 'Leads',
                  color: AppColors.primaryBlue,
                ),
                CountWidget(
                  count: countLeadData.isNotEmpty
                      ? int.parse(countLeadData[0].totalConvertedCount ?? "0")
                      : 0,
                  title: 'Conversions',
                  color: AppColors.secondaryBlue,
                ),
              ] else
                ...dashboardProvider.taskAllocationSummaryDataStatus
                    .asMap()
                    .entries
                    .map((e) => CountWidget(
                          count: e.value.count ?? 0,
                          title: e.value.taskStatusName,
                          color: e.key == 0
                              ? AppColors.textGreen
                              : e.key == 1
                                  ? AppColors.textYellow
                                  : AppColors.textRed,
                        )),
            ],
          ),

          const SizedBox(height: 10),

          // Chart
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
                    maximumLabels: leadData.length, // Show all labels
                    labelAlignment: LabelAlignment.center,
                  ),
            borderColor: Colors.white,
            tooltipBehavior: TooltipBehavior(enable: true, header: ''),
            series: isLeadOverView
                ? <CartesianSeries<LeadCoversionChartModel, String>>[
                    StackedColumn100Series<LeadCoversionChartModel, String>(
                      dataSource: leadData,
                      enableTooltip: true,
                      color: AppColors.primaryBlue,
                      width: 0.3,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18)),
                      xValueMapper: (LeadCoversionChartModel lead, _) =>
                          lead.enquirySource.toString(),
                      yValueMapper: (LeadCoversionChartModel lead, _) =>
                          lead.leadCount ?? 0,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                    StackedColumn100Series<LeadCoversionChartModel, String>(
                      dataSource: leadData,
                      enableTooltip: true,
                      color: AppColors.secondaryBlue,
                      width: 0.3,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18)),
                      xValueMapper: (LeadCoversionChartModel lead, _) =>
                          lead.enquirySource.toString(),
                      yValueMapper: (LeadCoversionChartModel lead, _) =>
                          int.tryParse(lead.convertedCount ?? "0") ?? 0,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ]
                : <CartesianSeries<TaskAllocationSummaryModel, String>>[
                    ColumnSeries<TaskAllocationSummaryModel, String>(
                      dataSource: taskData,
                      color: AppColors.primaryBlue,
                      width: 0.5,
                      borderRadius: BorderRadius.circular(18),
                      xValueMapper: (TaskAllocationSummaryModel data, _) =>
                          data.userDetailsName ?? '',
                      yValueMapper: (TaskAllocationSummaryModel data, _) =>
                          num.tryParse(data.totalTasks ?? "0") ?? 0,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:techtify/constants/app_colors.dart';
// import 'package:techtify/constants/app_styles.dart';
// import 'package:techtify/controller/dashboard_provider.dart';
// import 'package:techtify/controller/models/lead_conversion_model.dart';
// import 'package:techtify/controller/models/task_allocation_model.dart';
// import 'package:techtify/presentation/pages/dashboard/count_widget.dart';
// import 'package:techtify/presentation/pages/dashboard/custom_dropdown.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class Chart extends StatelessWidget {
//   const Chart({
//     super.key,
//     required this.leadData,
//     this.isLeadOverView = false,
//     required this.countLeadData,
//     required this.taskData,
//     required this.dashboardProvider,
//   });

//   final bool isLeadOverView;
//   final List<LeadCoversionChartModel> leadData;
//   final List<TaskAllocationSummaryModel> taskData;
//   final List<CountLeadCoversionChartModel> countLeadData;
//   final DashboardProvider dashboardProvider;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       constraints: BoxConstraints(
//         minWidth: 399,
//         maxWidth: 1800,
//         maxHeight: isLeadOverView ? 500 : 420,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 isLeadOverView
//                     ? 'Lead Conversion by Source'
//                     : 'Task Allocation Overview',
//                 style: AppStyles.getBodyTextStyle(
//                     fontSize: 14, fontColor: AppColors.textGrey3),
//               ),
//               CustomDropDown(
//                 value: isLeadOverView
//                     ? dashboardProvider.selectedeLeadConversionValue
//                     : dashboardProvider.selectedeTaskAllocationValue,
//                 onChanged: (v) => isLeadOverView
//                     ? dashboardProvider.getLeadConversionChartData(
//                         isFilter: true, filterValue: v)
//                     : dashboardProvider.getTaskAllocationSummary(
//                         isFilter: true, filterValue: v),
//                 dashboardProvider: dashboardProvider,
//               ),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // Count Row
//           Row(
//             children: [
//               RichText(
//                 text: TextSpan(
//                   text: isLeadOverView
//                       ? (countLeadData.isNotEmpty
//                           ? '${countLeadData[0].totalLeadCount ?? "0"}'
//                           : "0")
//                       : (dashboardProvider.taskCount != null &&
//                               dashboardProvider.taskCount.isNotEmpty)
//                           ? dashboardProvider.taskCount[0]['totalTaskCount']
//                               .toString()
//                           : "0",
//                   style: AppStyles.getHeadingTextStyle(fontSize: 16),
//                   children: [
//                     TextSpan(
//                       text: '    ${isLeadOverView ? 'Leads' : 'Tasks'}',
//                       style: AppStyles.getHeadingTextStyle(
//                           fontSize: 16, fontColor: AppColors.textGrey4),
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               if (isLeadOverView) ...[
//                 CountWidget(
//                   count: countLeadData.isNotEmpty
//                       ? countLeadData[0].totalLeadCount ?? 0
//                       : 0,
//                   title: 'Leads',
//                   color: AppColors.primaryBlue,
//                 ),
//                 CountWidget(
//                   count: countLeadData.isNotEmpty
//                       ? int.parse(countLeadData[0].totalConvertedCount ?? "0")
//                       : 0,
//                   title: 'Conversions',
//                   color: AppColors.secondaryBlue,
//                 ),
//               ] else if (dashboardProvider.taskAllocationSummaryDataStatus !=
//                       null &&
//                   dashboardProvider.taskAllocationSummaryDataStatus.isNotEmpty)
//                 ...dashboardProvider.taskAllocationSummaryDataStatus
//                     .map((status) => CountWidget(
//                           count: status.count,
//                           title: status.taskStatusName,
//                           color: _getStatusColor(status.taskStatusName),
//                         )),
//             ],
//           ),

//           const SizedBox(height: 10),

//           // Chart
//           isLeadOverView ? _buildLeadChart() : _buildTaskChart(),
//         ],
//       ),
//     );
//   }

//   Widget _buildLeadChart() {
//     return SfCartesianChart(
//       primaryXAxis: const CategoryAxis(),
//       borderColor: Colors.white,
//       tooltipBehavior: TooltipBehavior(enable: true, header: ''),
//       series: <CartesianSeries>[
//         StackedColumn100Series<LeadCoversionChartModel, String>(
//           dataSource: leadData,
//           enableTooltip: true,
//           color: AppColors.primaryBlue,
//           width: 0.3,
//           borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(18),
//               bottomRight: Radius.circular(18)),
//           xValueMapper: (LeadCoversionChartModel lead, _) =>
//               lead.enquirySource.toString(),
//           yValueMapper: (LeadCoversionChartModel lead, _) =>
//               lead.leadCount ?? 0,
//           dataLabelSettings: const DataLabelSettings(isVisible: true),
//         ),
//         StackedColumn100Series<LeadCoversionChartModel, String>(
//           dataSource: leadData,
//           enableTooltip: true,
//           color: AppColors.secondaryBlue,
//           width: 0.3,
//           borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(18), topRight: Radius.circular(18)),
//           xValueMapper: (LeadCoversionChartModel lead, _) =>
//               lead.enquirySource.toString(),
//           yValueMapper: (LeadCoversionChartModel lead, _) =>
//               int.tryParse(lead.convertedCount ?? "0") ?? 0,
//           dataLabelSettings: const DataLabelSettings(isVisible: true),
//         ),
//       ],
//     );
//   }

//   Widget _buildTaskChart() {
//     return FutureBuilder<List<_TaskChartData>>(
//       future: Future.microtask(() => _processTaskData()),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No data available'));
//         }

//         final groupedData = snapshot.data!;
//         print(groupedData);
//         return SfCartesianChart(
//           primaryXAxis: const CategoryAxis(),
//           borderColor: Colors.white,
//           tooltipBehavior: TooltipBehavior(enable: true, header: ''),
//           legend: Legend(
//             isVisible: true,
//             position: LegendPosition.bottom,
//             overflowMode: LegendItemOverflowMode.wrap,
//             textStyle: AppStyles.getBodyTextStyle(fontSize: 12),
//           ),
//           series: <CartesianSeries>[
//             // Not Started Series - Red
//             StackedColumnSeries<_TaskChartData, String>(
//               dataSource: groupedData,
//               color: AppColors.textRed,
//               width: 0.5,
//               name: 'Not Started',
//               xValueMapper: (_TaskChartData data, _) => data.userName,
//               yValueMapper: (_TaskChartData data, _) => data.notStartedCount,
//               dataLabelSettings: const DataLabelSettings(isVisible: true),
//             ),
//             // In Progress Series - Yellow
//             StackedColumnSeries<_TaskChartData, String>(
//               dataSource: groupedData,
//               color: AppColors.textYellow,
//               width: 0.5,
//               name: 'In Progress',
//               xValueMapper: (_TaskChartData data, _) => data.userName,
//               yValueMapper: (_TaskChartData data, _) => data.inProgressCount,
//               dataLabelSettings: const DataLabelSettings(isVisible: true),
//             ),
//             // Completed Series - Green
//             StackedColumnSeries<_TaskChartData, String>(
//               dataSource: groupedData,
//               color: AppColors.textGreen,
//               width: 0.5,
//               name: 'Completed',
//               xValueMapper: (_TaskChartData data, _) => data.userName,
//               yValueMapper: (_TaskChartData data, _) => data.completedCount,
//               dataLabelSettings: const DataLabelSettings(isVisible: true),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   List<_TaskChartData> _processTaskData() {
//     List<_TaskChartData> processedData = [];

//     if (taskData.isEmpty) {
//       return processedData;
//     }

//     for (var task in taskData) {
//       processedData.add(_TaskChartData(
//         userName: task.userDetailsName,
//         completedCount: task.statusBreakdown.completed ?? 0,
//         inProgressCount: task.statusBreakdown.inProgress ?? 0,
//         notStartedCount: task.statusBreakdown.notStarted,
//       ));
//     }

//     return processedData;
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'Completed':
//         return AppColors.textGreen;
//       case 'In Progress':
//         return AppColors.textYellow;
//       case 'Not Started':
//         return AppColors.textRed;
//       default:
//         return Colors.grey;
//     }
//   }
// }

// class _TaskChartData {
//   final String userName;
//   final int completedCount;
//   final int inProgressCount;
//   final int notStartedCount;

//   _TaskChartData({
//     required this.userName,
//     required this.completedCount,
//     required this.inProgressCount,
//     required this.notStartedCount,
//   });
// }
