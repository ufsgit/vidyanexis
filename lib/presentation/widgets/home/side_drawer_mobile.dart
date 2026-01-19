import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/pages/home/task_page.dart';
import 'package:vidyanexis/presentation/pages/reports/checkin_checkout_page.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_reports.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/staff_location_report_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/inventory_page.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';
import 'package:vidyanexis/presentation/pages/login/login_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/billing_andpayments_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/complaint_page_reports_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/enquiry_source_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/periodic_service_report_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/work_summary_screen_phone.dart';
import 'package:vidyanexis/presentation/pages/settings/settings_page.dart';
import 'package:vidyanexis/presentation/pages/home/employee_tracking.dart';
import 'package:vidyanexis/presentation/pages/reports/amc_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/conversion_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/invoice_reports_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/service_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/staff_attendance_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/time_track_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/work_summary_screen.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';

class SidebarDrawer extends StatefulWidget {
  const SidebarDrawer({super.key});

  @override
  State<SidebarDrawer> createState() => _SidebarDrawerState();
}

class _SidebarDrawerState extends State<SidebarDrawer> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    initDevicePlugin();
  }

  initDevicePlugin() async {
    await PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    Future<String> getUserName() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userName') ?? "Admin";
    }

    // Report items
    final List<Map<String, dynamic>> reportItems = [
      // if (settingsProvider.menuIsViewMap[24].toString() == '1')
      //   {'title': 'Employee Tracking', 'page': const EmployeeTracking()},
      if (settingsProvider.menuIsViewMap[7].toString() == '1')
        {'title': 'Task Reports', 'page': const TaskPageReportMobile()},
      if (settingsProvider.menuIsViewMap[8].toString() == '1')
        {
          'title': 'Complaint Reports',
          'page': const ComplaintPageReportsMobile()
        },
      if (settingsProvider.menuIsViewMap[9].toString() == '1')
        {
          'title': 'Periodic Service Reports',
          'page': const PeriodicServiceReportPageMobile()
        },
      if (settingsProvider.menuIsViewMap[10].toString() == '1')
        {'title': 'Conversion Reports', 'page': const ConversionReportPage()},
      // if (settingsProvider.menuIsViewMap[11].toString() == '1')
      // {'title': 'Invoice Reports', 'page': const InvoiceReportsScreen()},
      // {
      //   'title': 'Billing & Payments Report',
      //   'page': const BillingAndpaymentsReportScreen()
      // },
      if (settingsProvider.menuIsViewMap[25].toString() == '1')
        {'title': 'Work Reports', 'page': const WorkSummaryPhone()},
      if (settingsProvider.menuIsViewMap[24].toString() == '1')
        {'title': 'Time Track Reports', 'page': const TimeTrackReportPage()},

      if (settingsProvider.menuIsViewMap[53].toString() == '1')
        {
          'title': 'Enquiry Source Reports',
          'page': const EnquirySourceSummaryReportScreen()
        },

      if (settingsProvider.menuIsViewMap[26].toString() == '1')
        {'title': 'Attendance Reports', 'page': const CheckInOutScreen()},
      // if (settingsProvider.menuIsViewMap[40].toString() == '1')
      //   {
      //     'title': 'Employee Location Reports',
      //     'page': const EmployeeLocationReportScreen()
      //   },
      if (settingsProvider.menuIsViewMap[54].toString() == '1')
        {'title': 'Followup Reports', 'page': const FollowupReportMobile()},
      if (settingsProvider.menuIsViewMap[55].toString() == '1')
        {'title': 'Quotation Reports', 'page': const QuotationReportMobile()},
      if (settingsProvider.menuIsViewMap[56].toString() == '1')
        {'title': 'Lead Reports', 'page': const LeadReportMobile(false)},
    ];

    return Drawer(
      shape: LinearBorder(),
      backgroundColor: AppColors.whiteColor,
      width: 250,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Inventory option
                const SizedBox(
                  height: 58,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Icon(
                              Icons.account_circle,
                              size: 32,
                              color: AppColors.textGrey4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FutureBuilder<String>(
                              future: getUserName(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text('Error loading username'));
                                } else {
                                  final userName = snapshot.data ?? '';
                                  return Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          userName,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        // CustomText(
                                        //   'Admin',
                                        //   fontSize: 12,
                                        //   fontWeight: FontWeight.w500,
                                        //   color: AppColors.textGrey4,
                                        // ),
                                      ],
                                    ),
                                  );
                                }
                              }),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_outlined),
                            iconSize: 18,
                            onSelected: (String value) {
                              if (value == 'logout') {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                          'Are you sure you want to log out?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dialogContext).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(dialogContext).pop();
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            String userId =
                                                prefs.getString('userId') ??
                                                    "0";
                                            // Unsubscribe from Firebase topic if not web
                                            if (!kIsWeb && userId.isNotEmpty) {
                                              await FirebaseMessaging.instance
                                                  .unsubscribeFromTopic(
                                                      '${AppStyles.name()}-$userId');
                                            }
                                            await prefs.clear();
                                            if (context.mounted) {
                                              context.go(LoginPageMobile.route);
                                            }
                                          },
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'logout',
                                child: Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (settingsProvider.menuIsViewMap[29].toString() == '1')
                  _buildMenuItem(
                    'Inventory',
                    'assets/images/inventory.svg',
                    const InventoryPage(),
                    context,
                  ),
                if (settingsProvider.menuIsViewMap[36].toString() == '1')
                  _buildMenuItem('Process Flow', 'assets/images/flow.svg',
                      const ProcessFlowPage(), context),
                // if (settingsProvider.menuIsViewMap[36].toString() == '1')
                //   _buildMenuItem(
                //       'Tasks', 'assets/images/task.svg', const TaskPage(), context),
                if (reportItems.isNotEmpty)
                  ListTileTheme(
                    dense: true,
                    horizontalTitleGap: 0,
                    child: ExpansionTile(
                      collapsedTextColor: AppColors.textBlack,
                      collapsedIconColor: AppColors.textBlack,
                      iconColor: AppColors.bluebutton,
                      textColor: AppColors.bluebutton,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      leading: SvgPicture.asset(
                        'assets/images/Reports.svg',
                        width: 18,
                        height: 18,
                      ),
                      title: Text(
                        'Reports',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      children: reportItems
                          .map((report) => _buildReportItem(
                                report['title'],
                                report['page'],
                                context,
                              ))
                          .toList(),
                    ),
                  ),

                // Settings option - now after Reports
                if (settingsProvider.menuIsViewMap[2].toString() == '1')
                  _buildMenuItem(
                    'Settings',
                    'assets/images/settings-02.svg',
                    const SettingsPage(),
                    context,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(null != packageInfo
                ? "${packageInfo!.version}.${packageInfo!.buildNumber}"
                : "0.0"),
          ),
        ],
      ),
    );
  }

  // Helper method to build main menu items
  Widget _buildMenuItem(
      String title, String iconPath, Widget page, BuildContext context) {
    return ListTileTheme(
      dense: true,
      horizontalTitleGap: 0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
        leading: SvgPicture.asset(
          iconPath,
          width: 18,
          height: 18,
        ),
        title: Text(title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            )),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
      ),
    );
  }

  // Helper method to build report items
  Widget _buildReportItem(String title, Widget page, BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack),
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }
}
