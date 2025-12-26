import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_reports.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report_mobile.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page_phone.dart';
import 'package:vidyanexis/presentation/pages/reports/amc_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/complaint_page_reports_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/conversion_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/periodic_service_report_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/service_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report_mobile.dart';

class CommonReportWidget extends StatefulWidget {
  const CommonReportWidget({
    super.key,
    required this.title,
    required this.count,
    required this.label,
    required this.image,
    required this.index,
    required this.id,
  });
  final String title;
  final String count;
  final String label;
  final int index;
  final int id;
  final String image;

  @override
  State<CommonReportWidget> createState() => _CommonReportWidgetState();
}

class _CommonReportWidgetState extends State<CommonReportWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SidebarProvider>(context);
    final dp = Provider.of<DashboardProvider>(context);

    return InkWell(
      onHover: (widget.id == 11 || widget.id == 12)
          ? null
          : (hovering) {
              setState(() {
                isHovered = hovering;
              });
            },
      onTap: (widget.id == 11 || widget.id == 12)
          ? null
          : () {
              print(widget.id);
              if (widget.id == 1) {
                // provider.setSelectedIndex(1);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const LeadPageReport(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const LeadReportMobile(false);
                        },
                      ));
              }
              //followup
              if (widget.id == 2) {
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const FollowupReports(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const FollowupReportMobile();
                        },
                      ));
              }
              //conversion
              if (widget.id == 3) {
                // provider.setSelectedIndex(3);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const ConversionReportPage(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const ConversionReportPage(
                            fromDashBoard: true,
                          );
                        },
                      ));
              }
              //task
              if (widget.id == 4) {
                // provider.setSelectedIndex(4);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const TaskPageReport(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const TaskPageReportMobile();
                        },
                      ));
              }
              //service
              if (widget.id == 5) {
                // provider.setSelectedIndex(5);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const ServicePageReport(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const ComplaintPageReportsMobile();
                        },
                      ));
              }
              //amc
              if (widget.id == 6) {
                // provider.setSelectedIndex(6);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const AmcReportScreen(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const PeriodicServiceReportPageMobile();
                        },
                      ));
              }
              //quotation
              if (widget.id == 7) {
                // provider.setSelectedIndex(6);
                AppStyles.isWebScreen(context)
                    ? Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const QuotationReport(
                            fromDashBoard: true,
                          );
                        },
                      ))
                    : Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const QuotationReportMobile();
                        },
                      ));
              }
            },
      child: Container(
        padding: const EdgeInsets.all(10),
        // height: 100,
        decoration: BoxDecoration(
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
            color: isHovered ? AppColors.buttonBackgroundColor : Colors.white,
            borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          leading: Image.asset(widget.image),
          title: Text(widget.title),
          subtitle: RichText(
            text: TextSpan(
                text: widget.count,
                style: AppStyles.getHeadingTextStyle(fontSize: 16),
                children: [
                  TextSpan(
                      text: "  ${widget.label}",
                      style: AppStyles.getHeadingTextStyle(
                          fontSize: 16, fontColor: AppColors.textGrey4))
                ]),
          ),
          trailing: (widget.id == 10 || widget.id == 11)
              ? null
              : const Icon(Icons.arrow_outward_rounded),
        ),
      ),
    );
  }
}
