import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/lead_progress_model.dart';
import 'package:vidyanexis/presentation/pages/dashboard/common_report_widget.dart';
import 'package:vidyanexis/presentation/pages/dashboard/custom_dropdown.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WeeklyReportCard extends StatelessWidget {
  const WeeklyReportCard({
    super.key,
    this.isLeadOverView = false,
    this.data,
    required this.dashboardProvider,
  });
  final bool isLeadOverView;
  final List<LeadProgressReportModel>? data;
  final DashboardProvider dashboardProvider;

  @override
  Widget build(BuildContext context) {
    DashboardProvider dashBoardProvider =
        Provider.of<DashboardProvider>(context);
    return Container(
      decoration: BoxDecoration(
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          color: Colors.white,
          borderRadius: BorderRadius.circular(18)),
      constraints: BoxConstraints(
          minWidth: 100, maxWidth: 440, maxHeight: isLeadOverView ? 500 : 420),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isLeadOverView
                  ? 'Lead Progress Report'
                  : 'Work Report Summary'),
              CustomDropDown(
                  value: isLeadOverView
                      ? dashBoardProvider.selectedeLeadProgressValue
                      : dashBoardProvider.selectedDashboardCountValue,
                  dashboardProvider: dashBoardProvider,
                  onChanged: (v) => isLeadOverView
                      ? dashBoardProvider.getLeadProgressionReport(
                          isFilter: v != "all",
                          filterValue: v == "all" ? null : v)
                      : dashBoardProvider.getDashBoardCount(
                          isFilter: v != "all",
                          filterValue: v == "all" ? null : v)),
            ],
          ),
          const SizedBox(height: 15),
          isLeadOverView
              ? Column(
                  children: [
                    SfCircularChart(series: <CircularSeries<
                        LeadProgressReportModel, String>>[
                      DoughnutSeries<LeadProgressReportModel, String>(
                        // cornerStyle: CornerStyle.bothCurve,

                        explode: true,

                        dataSource: data,
                        xValueMapper: (LeadProgressReportModel data, _) =>
                            data.statusName,
                        yValueMapper: (LeadProgressReportModel data, _) =>
                            num.parse(data.percentage),
                        pointColorMapper: (LeadProgressReportModel data, _) =>
                            AppColors.parseColor(data.colorCode.toString()),
                      )
                    ]),
                    SizedBox(
                      height: 100,
                      child: GridView.builder(
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        itemCount: data!.length,
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 260, mainAxisExtent: 30),
                        itemBuilder: (c, i) => newMethod(
                            data![i].statusName.toString(),
                            data![i].percentage,
                            AppColors.parseColor(
                                data![i].colorCode.toString())),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     newMethod(),
                    //     newMethod(),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     newMethod(),
                    //     newMethod(),
                    //   ],
                    // ),
                  ],
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: ListView(
                      shrinkWrap: true,
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: dashBoardProvider.dashBoardCountModel
                          .asMap()
                          .entries
                          .map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: CommonReportWidget(
                                  index: e.key,
                                  image: 'assets/images/service.png',
                                  count: e.value.dataCount.toString(),
                                  label: e.value.title,
                                  title: e.value.title,
                                  id: e.value.tp),
                            ),
                          )
                          .toList()),
                ),
        ],
      ),
    );
  }

  Row newMethod(String title, String count, Color color) {
    return Row(
      children: [
        Container(
          height: 11,
          width: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
              text: title,
              style: AppStyles.getHeadingTextStyle(
                  fontSize: 12, fontColor: AppColors.textGrey4),
              children: [
                TextSpan(
                  text: "  ($count%)",
                  style: AppStyles.getHeadingTextStyle(fontSize: 14),
                )
              ]),
        ),
      ],
    );
  }
}
