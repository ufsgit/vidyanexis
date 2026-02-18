import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/http/socket_io.dart';
import 'package:vidyanexis/presentation/pages/forms/form_builder_page.dart';
import 'package:vidyanexis/presentation/pages/home/notifications_page.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_reports.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report.dart';
import 'package:vidyanexis/presentation/pages/reports/staff_location_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/checkin_checkout_page.dart';
import 'package:vidyanexis/presentation/widgets/notification_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/side_bar_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/feedback/feeback.dart';
import 'package:vidyanexis/presentation/pages/home/employee_tracking.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_page.dart';
import 'package:vidyanexis/presentation/pages/home/task_page.dart';
import 'package:vidyanexis/presentation/pages/reports/enquiry_source_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/feddback_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/staff_attendance_screen.dart';
import 'package:vidyanexis/presentation/pages/inventory/inventory_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/expense_management.dart';
import 'package:vidyanexis/presentation/pages/reports/expense_report_screen.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/pages/home/customer_page.dart';
import 'package:vidyanexis/presentation/pages/home/dashboard_page.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page.dart';
import 'package:vidyanexis/presentation/pages/reports/amc_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/conversion_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/invoice_reports_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/service_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/balance_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/payment_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/time_track_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/warrenty_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/out_of_warrenty_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/upcoming_warrenty_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/work_summary_screen.dart';
import 'package:vidyanexis/presentation/pages/settings/settings_page.dart';
import 'package:vidyanexis/presentation/widgets/home/side_bar_widget.dart';

class HomePage extends StatefulWidget {
  static String route = '/home';
  const HomePage({super.key});

  static const double _breakpoint = 768;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? "Admin";
  }

  PackageInfo? packageInfo;
  String logo = '';

  @override
  void initState() {
    super.initState();
    initDevicePlugin();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MicrotecSocket.initSocket();
      // Permission.notification.request();

      final preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.getMenuPermissionData(userId, context);
      await settingsProvider.getCompanyDetails();
      logo = HttpUrls.imgBaseUrl + settingsProvider.logo;
    });
  }

  initDevicePlugin() async {
    await PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final sideProvider = Provider.of<SidebarProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final List<SidebarOption> sidebarOptions = [
      if (settingsProvider.menuIsViewMap[12].toString() == '1')
        SidebarOption(
          title: 'DashBoard',
          iconPath: 'assets/images/dashboard_icon.svg',
          baseContent: const DashBoardPage(),
        ),
      if (settingsProvider.menuIsViewMap[3].toString() == '1')
        SidebarOption(
          title: 'Leads',
          iconPath: 'assets/images/Leads.svg',
          baseContent: const LeadPage(),
        ),
      if (settingsProvider.menuIsViewMap[4].toString() == '1')
        SidebarOption(
            title: 'Customers',
            iconPath: 'assets/images/user-group-03.svg',
            baseContent: const CustomerPage(),
            overlayContent: sideProvider.replaceCustomer
                ? null
                : CustomerDetailsScreen(
                    customerId: sideProvider.customerId,
                    report: 'false',
                  )),
      if (settingsProvider.menuIsViewMap[35].toString() == '1')
        SidebarOption(
          title: 'Task',
          iconPath: 'assets/images/task.svg',
          baseContent: const TaskPage(),
        ),

      if (settingsProvider.menuIsViewMap[29].toString() == '1')
        SidebarOption(
          title: 'Inventory',
          iconPath: 'assets/images/inventory.svg',
          baseContent: const InventoryPage(),
        ),
      // if (settingsProvider.menuIsViewMap[40].toString() == '1')
      // SidebarOption(
      //   title: 'Forms',
      //   iconPath: 'assets/images/Reports.svg',
      //   baseContent: const Center(child: FormBuilderPage()),
      // ),
      // SidebarOption(
      //   title: 'Workers',
      //   iconPath: 'assets/images/Workers.svg',
      //   content: const Center(
      //     child: Text(
      //       'Workers',
      //       style: TextStyle(fontSize: 24),
      //     ),
      //   ),
      // ),
      // SidebarOption(
      //   title: 'Chats',
      //   iconPath: 'assets/images/comment-01.svg',
      //   content: const Center(
      //     child: Text(
      //       'Chats Content',
      //       style: TextStyle(fontSize: 24),
      //     ),
      //   ),
      // ),
      if (settingsProvider.menuIsViewMap[2].toString() == '1')
        SidebarOption(
            title: 'Settings',
            iconPath: 'assets/images/settings-02.svg',
            baseContent: const SettingsPage()),
      if (settingsProvider.menuIsViewMap[36].toString() == '1')
        SidebarOption(
          title: 'Process Flow',
          iconPath: 'assets/images/flow.svg',
          baseContent: const ProcessFlowPage(),
        ),
      if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
        SidebarOption(
          title: 'Expense Management',
          iconPath: 'assets/images/inventory.svg',
          baseContent: const ExpenseManagement(),
        ),
      // Expense Report - linking to the same permission as Expense Management for now
      if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
        SidebarOption(
          title: 'Expense Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: ExpenseReportScreen()),
        ),
      if (settingsProvider.menuIsViewMap[7].toString() == '1')
        SidebarOption(
          title: 'Task Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: TaskPageReport()),
        ),

      if (settingsProvider.menuIsViewMap[8].toString() == '1')
        SidebarOption(
          title: 'Complaint Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: ServicePageReport()),
        ),

      if (settingsProvider.menuIsViewMap[9].toString() == '1')
        SidebarOption(
          title: 'Periodic service Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: AmcReportScreen()),
        ),
      if (settingsProvider.menuIsViewMap[9].toString() == '1')
        SidebarOption(
          title: 'Out Of Warranty Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: OutOfWarrentyReportScreen()),
        ),
      if (settingsProvider.menuIsViewMap[9].toString() == '1')
        SidebarOption(
          title: 'Upcoming Warranty Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: UpcomingWarrentyReportScreen()),
        ),
      if (settingsProvider.menuIsViewMap[10].toString() == '1')
        SidebarOption(
          title: 'Conversion Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: ConversionReportPage()),
        ),
      if (settingsProvider.menuIsViewMap[25].toString() == '1')
        SidebarOption(
          title: 'Work Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: WorkSummaryScreen()),
        ),

      if (settingsProvider.menuIsViewMap[24].toString() == '1')
        SidebarOption(
          title: 'Time Track Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: TimeTrackReportPage()),
        ),

      if (settingsProvider.menuIsViewMap[53].toString() == '1')
        SidebarOption(
          title: 'Enquiry Source Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: EnquirySourceSummaryReportScreen()),
        ),
      if (settingsProvider.menuIsViewMap[26].toString() == '1')
        SidebarOption(
          title: 'Attendance Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: CheckInOutScreen()),
        ),
      if (settingsProvider.menuIsViewMap[54].toString() == '1')
        SidebarOption(
          title: 'Followup Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: FollowupReports()),
        ),
      if (settingsProvider.menuIsViewMap[55].toString() == '1')
        SidebarOption(
          title: 'Quotation Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: QuotationReport()),
        ),
      if (settingsProvider.menuIsViewMap[56].toString() == '1')
        SidebarOption(
          title: 'Lead Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: LeadPageReport()),
        ),
      if (settingsProvider.menuIsViewMap[72].toString() == '1')
        SidebarOption(
          title: 'Balance Reports',
          iconPath: 'assets/images/Reports.svg',
          baseContent: const Center(child: BalanceReportPage()),
        ),
      SidebarOption(
        title: 'Payment Reports',
        iconPath: 'assets/images/Reports.svg',
        baseContent: const Center(child: PaymentReportPage()),
      ),
      // SidebarOption(
      //   title: 'Feedback Reports',
      //   iconPath: 'assets/images/Reports.svg',
      //   baseContent: const Center(child: FeedbackReportScreen()),
      // ),
      // if (settingsProvider.menuIsViewMap[40].toString() == '1')
      //   SidebarOption(
      //     title: 'Employee Location Reports',
      //     iconPath: 'assets/images/location.svg',
      //     baseContent: const Center(child: EmployeeLocationReportScreen()),
      //   ),
    ];

    bool isCustomerDetailsVisible =
        (sideProvider.selectedName == 'Leads' && !sideProvider.replaceLead) ||
            (sideProvider.selectedName == 'Customers' &&
                !sideProvider.replaceCustomer);
    return Scaffold(
      appBar: isCustomerDetailsVisible
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: Image.network(
                logo,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return Container();
                },
              ),
              centerTitle: false,
              actions: [
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    final count = notificationProvider.totalCount;

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_active_outlined,
                            size: 28,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const NotificationsPage();
                              },
                            ));
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),

      // drawer: screenWidth < _breakpoint
      //     ?
      drawer: Drawer(
        child: FutureBuilder<String>(
          future: getUserName(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading username'));
            } else {
              final userName = snapshot.data ?? '';
              return CustomSidebar(
                userName: userName,
                options: sidebarOptions,
                isDrawer: true,
                logo: logo,
                width: screenWidth * 0.85,
                appVersion: (null != packageInfo
                    ? "${packageInfo!.version}.${packageInfo!.buildNumber}"
                    : "0.0"),
              );
            }
          },
        ),
      ),
      body: Row(
        children: [
          // if (screenWidth >= _breakpoint)
          //   FutureBuilder<String>(
          //     future: getUserName(),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasError) {
          //         return const Text('Error loading username');
          //       } else {
          //         final userName = snapshot.data ?? '';
          //         return CustomSidebar(
          //           onPressed: () {
          //             // leadsProvider.getSearchLeads(context);
          //             // leadsProvider.saveLead(context);
          //           },
          //           options: sidebarOptions,
          //           width: 200,
          //           isDrawer: false,
          //           userName: userName,
          //         );
          //       }
          //     },
          //   ),
          Expanded(
            child: Consumer<SidebarProvider>(
              builder: (context, provider, child) {
                // Ensure sidebarOptions is not empty before accessing it
                if (sidebarOptions.isEmpty ||
                    provider.selectedIndex >= sidebarOptions.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Safely find the selected option with error handling
                SidebarOption? selectedOption;
                try {
                  // First try to find by name
                  var matchingOptions = sidebarOptions
                      .where((option) => option.title == provider.selectedName)
                      .toList();

                  if (matchingOptions.isEmpty) {
                    // If no matching option found, show empty container
                    return Center(
                        child: Container(child: CircularProgressIndicator()));
                  } else {
                    // Use the first matching option
                    selectedOption = matchingOptions.first;
                  }
                } catch (e) {
                  // If any error occurs, show empty container
                  return Container(
                    color: Colors.grey.shade50,
                    child: Center(
                      child: Text(
                        "No content to display",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }
                // Get the base content for the selected index
                final baseContent =
                    sidebarOptions[provider.selectedIndex].baseContent;

                // Determine the overlay content based on the selected index and state flags
                final overlayContent =
                    selectedOption.title == "Leads" // For 'Leads' section
                        ? (provider.replaceLead
                            ? null // No overlay if replaceLead is true
                            : CustomerDetailsScreen(
                                customerId: provider.customerId,
                                report: 'false',
                              )) // Overlay for 'Leads'
                        : selectedOption.title ==
                                "Customers" // For 'Customers' section
                            ? (provider.replaceCustomer
                                ? null // No overlay if replaceCustomer is true
                                : CustomerDetailsScreen(
                                    customerId: provider.customerId,
                                    report: 'false',
                                  )) // Overlay for 'Customers'
                            : null; // Default case, no overlay

                return Container(
                  color: Colors.grey.shade50,
                  child: Stack(
                    children: [
                      baseContent, // The main content displayed at the bottom
                      if (overlayContent !=
                          null) // Show overlay content if it's not null
                        Positioned.fill(
                          child: Material(
                            color: Colors
                                .black54, // Optional dim background behind overlay
                            child: overlayContent,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
