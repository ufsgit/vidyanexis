import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/leads_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_enquiry_report_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_page_report.dart';

class LeadEnquiryForReportCard extends StatelessWidget {
  const LeadEnquiryForReportCard({
    super.key,
    required this.dashboardProvider,
  });

  final DashboardProvider dashboardProvider;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLeadEnquiryReportLoading) {
          return Container(
            height: 400,
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 5)
            ], color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = provider.leadEnquiryReport;

        return Container(
          decoration: BoxDecoration(boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 5)
          ], color: Colors.white, borderRadius: BorderRadius.circular(18)),
          constraints: BoxConstraints(
              minWidth: 100,
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: 500),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lead Enquiry For Report'),
                  // CustomDropDown(
                  //     value: provider.selectedLeadEnquiryReportValue,
                  //     dashboardProvider: provider,
                  //     onChanged: (v) => provider.getLeadData(
                  //         filterValue: v == "all" ? null : v)),
                ],
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(),
                      series: <CartesianSeries<LeadEnquiryReportModel, String>>[
                        ColumnSeries<LeadEnquiryReportModel, String>(
                          dataSource: data,
                          xValueMapper: (LeadEnquiryReportModel data, _) =>
                              data.enquiryForName,
                          yValueMapper: (LeadEnquiryReportModel data, _) =>
                              data.count,
                          pointColorMapper: (LeadEnquiryReportModel data, _) =>
                              AppColors.parseColor(data.colorCode),
                          dataLabelSettings:
                              const DataLabelSettings(isVisible: true),
                          onPointTap: (ChartPointDetails details) async {
                            final statusId =
                                data[details.pointIndex!].enquiryForId;
                            final leadReportProvider =
                                Provider.of<LeadReportProvider>(context,
                                    listen: false);
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            int userId = int.tryParse(
                                    preferences.getString('userId') ?? "0") ??
                                0;
                            leadReportProvider.setStatus(statusId);
                            leadReportProvider.setUserFilterStatus(userId);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const LeadPageReport(
                                  fromDashBoard: true,
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260, mainAxisExtent: 30),
                      itemBuilder: (c, i) => _buildLegendItem(
                          data[i].enquiryForName,
                          data[i].count.toString(),
                          AppColors.parseColor(data[i].colorCode)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Row _buildLegendItem(String title, String count, Color color) {
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
                  text: "  ($count)",
                  style: AppStyles.getHeadingTextStyle(fontSize: 14),
                )
              ]),
        ),
      ],
    );
  }
}
