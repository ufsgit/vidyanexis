import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/count_widget.dart';
import 'package:vidyanexis/presentation/pages/dashboard/custom_dropdown.dart';

class CustomerWorkSummary extends StatelessWidget {
  const CustomerWorkSummary({super.key, required this.dashBoardProvider});
  final DashboardProvider dashBoardProvider;

  // List of colors to use for different statuses
  final List<Color> statusColors = const [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.amber,
    Colors.pink,
  ];

  // Get a color based on index or status name
  Color getStatusColor(int index, String statusName) {
    // Use index to get a color from the list (with wrapping)
    return statusColors[index % statusColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final hasCustomerData = dashBoardProvider.customersCount.isNotEmpty;
    final hasWorkSummary = dashBoardProvider.workSummaryReportModel.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Customer Work Summary'),
              CustomDropDown(
                dashboardProvider: dashBoardProvider,
                onChanged: (v) => dashBoardProvider.getWorkSummary(
                    isFilter: v != "all", filterValue: v == "all" ? null : v),
                value: dashBoardProvider.selectedWorkSummaryValue,
              ),
            ],
          ),
          const SizedBox(height: 15),
          RichText(
            text: TextSpan(
              text: hasCustomerData
                  ? dashBoardProvider.customersCount[0]['total'].toString()
                  : "0",
              style: AppStyles.getHeadingTextStyle(fontSize: 16),
              children: [
                TextSpan(
                  text: "  customers",
                  style: AppStyles.getHeadingTextStyle(
                      fontSize: 16, fontColor: AppColors.textGrey4),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),

          /// Progress bar with colored sections
          Align(
            alignment: Alignment.center,
            child: hasWorkSummary
                ? Container(
                    width: 200, // Fixed width for the circle
                    height: 200, // Fixed height for the circle
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        // Create segments for the circle
                        ...dashBoardProvider.workSummaryReportModel
                            .asMap()
                            .entries
                            .map((e) {
                          // Calculate segment angle based on percentage
                          final percentage =
                              (num.tryParse(e.value.percentage.toString()) ??
                                      0) /
                                  100;
                          final startAngle = e.key == 0
                              ? 0
                              : dashBoardProvider.workSummaryReportModel
                                  .sublist(0, e.key)
                                  .fold(
                                      0.0,
                                      (sum, item) =>
                                          sum +
                                          (num.tryParse(item.percentage
                                                      .toString()) ??
                                                  0) /
                                              100);

                          return CustomPaint(
                            size: const Size(200, 200),
                            painter: CircleSegmentPainter(
                              startAngle: startAngle * 2 * 3.14159,
                              sweepAngle: percentage * 2 * 3.14159,
                              color: getStatusColor(
                                  e.key, e.value.taskStatusName ?? ""),
                            ),
                          );
                        }).toList(),

                        // Center circle for contrast/showing as donut
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Text("No Work Summary Available"),
          ),
          const SizedBox(height: 8),

          /// Work summary details
          hasWorkSummary
              ? Column(
                  children: dashBoardProvider.workSummaryReportModel
                      .asMap()
                      .entries
                      .map(
                        (entry) => CountWidget2(
                          count: entry.value.customerCount.toString(),
                          indicatorColor: getStatusColor(
                              entry.key, entry.value.taskStatusName ?? ''),
                          label: "customers",
                          title: entry.value.taskStatusName.toString(),
                          progress: "(${entry.value.percentage}%)",
                        ),
                      )
                      .toList(),
                )
              : const Text("No Work Summary Data", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class CircleSegmentPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  CircleSegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

List<Color> colors = [
  Colors.green,
  Colors.red,
  Colors.orange,
];
