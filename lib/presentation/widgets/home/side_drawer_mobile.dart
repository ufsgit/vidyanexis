import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/controller/login_controller.dart';
import 'package:vidyanexis/presentation/pages/reports/attendance_report.dart';
import 'package:vidyanexis/presentation/pages/reports/ta_report_screen.dart';
import 'package:vidyanexis/presentation/pages/travel_allowance/travel_allowance_page.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/followup_amount_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_check_in_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/deleted_lead_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/quotation_report_mobile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/pages/home/process_flow_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/expense_management.dart';
import 'package:vidyanexis/presentation/pages/inventory/inventory_page.dart';
import 'package:vidyanexis/presentation/pages/location/location_tracking_page.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';
import 'package:vidyanexis/presentation/pages/reports/complaint_page_reports_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/enquiry_source_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/employee_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/employee_sales_customer_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/enquiry_for_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/periodic_service_report_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_return_report.dart';
import 'package:vidyanexis/presentation/pages/reports/target_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/accounts_summary_page_report.dart';
import 'package:vidyanexis/presentation/pages/reports/task_page_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/work_summary_screen_phone.dart';
import 'package:vidyanexis/presentation/pages/settings/settings_page.dart';
import 'package:vidyanexis/presentation/pages/reports/conversion_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/expense_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/out_of_warrenty_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/upcoming_warrenty_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/time_track_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/balance_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/upcoming_payment_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/payment_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/total_outstanding_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/outstanding_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/invoice_reports_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/task_summary_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/solar_lead_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_status_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_report.dart';
import 'package:vidyanexis/presentation/pages/reports/work_completion_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/commission_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/sub_contract_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/receipt_report_page.dart';
import 'package:vidyanexis/presentation/pages/reports/customer_outstanding_report_mobile.dart';
import 'package:vidyanexis/presentation/pages/reports/stock_use_report.dart';
import 'package:vidyanexis/presentation/pages/reports/sales_report_screen_phone.dart';
import 'package:vidyanexis/presentation/pages/reports/customer_task_month_report_screen.dart';
import 'package:vidyanexis/presentation/pages/reports/duplicate_entry_attempts_report_screen.dart';

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

  Future<void> initDevicePlugin() async {
    await PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context, listen: false);

    // Report items
    final List<Map<String, dynamic>> reportItems = [
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
      if (settingsProvider.menuIsViewMap[112].toString() == '1')
        {
          'title': 'Out Of Warranty Reports',
          'page': const OutOfWarrentyReportScreen()
        },
      if (settingsProvider.menuIsViewMap[117].toString() == '1')
        {
          'title': 'Upcoming Warranty Reports',
          'page': const UpcomingWarrentyReportScreen()
        },
      if (settingsProvider.menuIsViewMap[10].toString() == '1')
        {'title': 'Conversion Reports', 'page': const ConversionReportPage()},
      if (settingsProvider.menuIsViewMap[11].toString() == '1')
        {'title': 'Invoice Reports', 'page': const InvoiceReportsScreen()},
      if (settingsProvider.menuIsViewMap[25].toString() == '1')
        {'title': 'Work Reports', 'page': const WorkSummaryPhone()},
      if (settingsProvider.menuIsViewMap[24].toString() == '1')
        {'title': 'Time Track Reports', 'page': const TimeTrackReportPage()},
      if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
        {'title': 'Expense Reports', 'page': const ExpenseReportScreen()},
      if (settingsProvider.menuIsViewMap[119].toString() == '1')
        {
          'title': 'Enquiry Source Reports',
          'page': const EnquirySourceSummaryReportScreen()
        },
      if (settingsProvider.menuIsViewMap[119].toString() == '1' ||
          settingsProvider.menuIsViewMap[89].toString() == '1')
        {
          'title': 'Employee Summary Reports',
          'page': const EmployeeSummaryReportScreen()
        },
      if (settingsProvider.menuIsViewMap[119].toString() == '1' ||
          settingsProvider.menuIsViewMap[89].toString() == '1')
        {
          'title': 'Employee Sales Customer Reports',
          'page': const EmployeeSalesCustomerReportScreen()
        },
      if (settingsProvider.menuIsViewMap[119].toString() == '1' ||
          settingsProvider.menuIsViewMap[89].toString() == '1')
        {
          'title': 'Enquiry For Summary Reports',
          'page': const EnquiryForSummaryReportScreen()
        },
      if (settingsProvider.menuIsViewMap[26].toString() == '1')
        {'title': 'Attendance Reports', 'page': const AttendanceReport()},
      if (settingsProvider.hasTravelAllowancePermission)
        {'title': 'Travel Allowance', 'page': const TravelAllowancePage()},
      if ((settingsProvider.menuIsViewMap[26] ?? 0).toString() == '1' ||
          (settingsProvider.menuIsViewMap[201] ?? 0).toString() == '1')
        {'title': 'TA Reports', 'page': const TAReportScreen()},
      if (settingsProvider.menuIsViewMap[96].toString() == '1')
        {'title': 'Check-in Reports', 'page': const LeadCheckInReportScreen()},
      if (settingsProvider.menuIsViewMap[115].toString() == '1')
        {'title': 'Followup Reports', 'page': const FollowupReportMobile()},
      if (settingsProvider.menuIsViewMap[153].toString() == '1')
        {
          'title': 'Followup Amount Report',
          'page': const FollowupAmountReportPage()
        },
      if (settingsProvider.menuIsViewMap[118].toString() == '1')
        {'title': 'Quotation Reports', 'page': const QuotationReportMobile()},
      if (settingsProvider.menuIsViewMap[56].toString() == '1')
        {'title': 'Lead Reports', 'page': const LeadReportMobile(false)},
      if (settingsProvider.menuIsViewMap[56].toString() == '1' ||
          settingsProvider.menuIsViewMap[168].toString() == '1')
        {
          'title': 'Deleted Lead Reports',
          'page': const DeletedLeadReportScreen()
        },
      if (settingsProvider.menuIsViewMap[163].toString() == '1')
        {
          'title': 'Work Completion Report',
          'page': const WorkCompletionReportScreen()
        },
      if (settingsProvider.menuIsViewMap[97].toString() == '1')
        {'title': 'Solar Lead Reports', 'page': const SolarLeadReportPage()},
      if (settingsProvider.menuIsViewMap[98].toString() == '1')
        {'title': 'Sales Pipeline', 'page': const LeadStatusReportScreen()},
      if (settingsProvider.menuIsViewMap[99].toString() == '1')
        {'title': 'Balance Reports', 'page': const BalanceReportPage()},
      if (settingsProvider.menuIsViewMap[72].toString() == '1')
        {'title': 'Payment Reports', 'page': const PaymentReportPage()},
      if (settingsProvider.menuIsViewMap[73].toString() == '1')
        {
          'title': 'Upcoming Payment Reports',
          'page': const UpcomingPaymentReportPage()
        },
      if (settingsProvider.menuIsViewMap[74].toString() == '1')
        {
          'title': 'Total Outstanding Reports',
          'page': const TotalOutstandingReportPage()
        },
      if (settingsProvider.menuIsViewMap[75].toString() == '1')
        {'title': 'Outstanding Reports', 'page': const OutstandingReportPage()},
      if (settingsProvider.menuIsViewMap[89].toString() == '1')
        {
          'title': 'Task Summary Reports',
          'page': const TaskSummaryReportScreen()
        },
      if (settingsProvider.menuIsViewMap[80].toString() == '1')
        {'title': 'Stock Reports', 'page': const StockReport()},
      if (settingsProvider.menuIsViewMap[121].toString() == '1')
        {'title': 'Check list Reports', 'page': const StockUseReport()},
      if (settingsProvider.menuIsViewMap[122].toString() == '1')
        {'title': 'Stock Return Reports', 'page': const StockReturnReport()},
      if (settingsProvider.menuIsViewMap[113].toString() == '1')
        {'title': 'Commission Reports', 'page': const CommissionReportMobile()},
      if (settingsProvider.menuIsViewMap[114].toString() == '1')
        {
          'title': 'Sub Contract Reports',
          'page': const SubContractReportMobile()
        },
      if (settingsProvider.menuIsViewMap[88].toString() == '1')
        {'title': 'Receipt Reports', 'page': const ReceiptReportPage()},
      if (settingsProvider.menuIsViewMap[123].toString() == '1')
        {
          'title': 'Customer Task Month Report',
          'page': const CustomerTaskMonthReportScreen()
        },
      if (settingsProvider.menuIsViewMap[144].toString() == '1')
        {'title': 'Sales Reports', 'page': const SalesReportScreenPhone()},
      if (settingsProvider.menuIsViewMap[152].toString() == '1')
        {
          'title': 'Customer Outstanding Reports',
          'page': const CustomerOutstandingReportMobile()
        },
      if (settingsProvider.menuIsViewMap[172].toString() == '1')
        {'title': 'Target Reports', 'page': const TargetPageReport()},
      if (settingsProvider.menuIsViewMap[172].toString() == '1')
        {
          'title': 'Accounts Summary Reports',
          'page': const AccountsSummaryPageReport()
        },
      {
        'title': 'Duplicate Entry Reports',
        'page': const DuplicateEntryAttemptsReportScreen()
      },
    ];

    Future<String> getUserName() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userName') ?? "Admin";
    }

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      width: 280,
      child: Column(
        children: [
          // Premium Header Section
          _buildHeader(settingsProvider, getUserName),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                if (settingsProvider.menuIsViewMap[29].toString() == '1')
                  _buildModernMenuItem(
                    context: context,
                    title: 'Inventory',
                    iconPath: 'assets/images/inventory.svg',
                    page: const InventoryPage(),
                    sideProvider: sideProvider,
                    activeColor: const Color(0xFF7B61FF), // Purple
                    lightColor: const Color(0xFFE9EAFB),
                  ),
                if (settingsProvider.menuIsViewMap[36].toString() == '1')
                  _buildModernMenuItem(
                    context: context,
                    title: 'Process Flow',
                    iconPath: 'assets/images/flow.svg',
                    page: const ProcessFlowPage(),
                    sideProvider: sideProvider,
                    activeColor: const Color(0xFF63B3ED), // Blue
                    lightColor: const Color(0xFFE6F5FF),
                  ),
                if ((settingsProvider.menuIsViewMap[48] ?? 0).toString() == '1')
                  _buildModernMenuItem(
                    context: context,
                    title: 'Expenses',
                    iconPath: 'assets/images/inventory.svg',
                    page: const ExpenseManagement(),
                    sideProvider: sideProvider,
                    activeColor: const Color(0xFFFF9D6E), // Orange
                    lightColor: const Color(0xFFFFF1E8),
                  ),
                if (reportItems.isNotEmpty)
                  _buildReportsExpansionTile(
                    context: context,
                    reportItems: reportItems,
                    sideProvider: sideProvider,
                  ),
                _buildModernMenuItem(
                  context: context,
                  title: 'Location Tracking',
                  iconData: Icons.my_location_rounded,
                  page: const LocationTrackingPage(),
                  sideProvider: sideProvider,
                  activeColor: const Color(0xFF005A45),
                  lightColor: const Color(0xFFE0F2F1),
                ),
                if (settingsProvider.menuIsViewMap[2].toString() == '1')
                  _buildModernMenuItem(
                    context: context,
                    title: 'Settings',
                    iconPath: 'assets/images/settings-02.svg',
                    page: const SettingsPage(),
                    sideProvider: sideProvider,
                    activeColor: const Color(0xFF48BB78), // Green
                    lightColor: const Color(0xFFEDF7ED),
                  ),
                const SizedBox(height: 8),
                _buildLogoutButton(context),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Footer Section
          _buildFooter(context, packageInfo),
        ],
      ),
    );
  }

  Widget _buildHeader(SettingsProvider settingsProvider,
      Future<String> Function() getUserName) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: settingsProvider.displayLogo.startsWith('http')
                ? Image.network(
                    settingsProvider.displayLogo,
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      AppStyles.logo(),
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                    ),
                  )
                : Image.asset(
                    settingsProvider.displayLogo,
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      AppStyles.logo(),
                      height: 40,
                      width: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<String>(
                  future: getUserName(),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Admin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF172230),
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required String title,
    String? iconPath,
    IconData? iconData,
    required Widget page,
    required SidebarProvider sideProvider,
    required Color activeColor,
    required Color lightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            sideProvider.setReportPage(page);
          },
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: iconPath != null
                      ? SvgPicture.asset(
                          iconPath,
                          width: 18,
                          height: 18,
                          colorFilter:
                              ColorFilter.mode(activeColor, BlendMode.srcIn),
                        )
                      : Icon(
                          iconData ?? Icons.circle,
                          size: 18,
                          color: activeColor,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF172230),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsExpansionTile({
    required BuildContext context,
    required List<Map<String, dynamic>> reportItems,
    required SidebarProvider sideProvider,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EAFB),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              'assets/images/Reports.svg',
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(Color(0xFF7B61FF), BlendMode.srcIn),
            ),
          ),
          title: Text(
            'Reports',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF172230),
            ),
          ),
          iconColor: const Color(0xFF7B61FF),
          collapsedIconColor: Colors.grey[400],
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: reportItems.map((report) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              dense: true,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              title: Text(
                report['title'],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                sideProvider.setReportPage(report['page']);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.2)),
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFFFF3B30).withOpacity(0.05),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded,
                  color: Color(0xFFFF3B30), size: 20),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF3B30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, PackageInfo? packageInfo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Center(
        child: Text(
          packageInfo != null
              ? "v${packageInfo.version} (${packageInfo.buildNumber})"
              : "v1.0.0",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'Logout',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Are you sure you want to log out from Vidyanexis?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () async {
                  final loginController =
                      Provider.of<LoginController>(context, listen: false);
                  final router = GoRouter.of(context);

                  Navigator.of(context).pop();

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  // Backup attendance state
                  String? userId = prefs.getString('userId');
                  bool? isCheckedIn;
                  String? checkInDate;
                  String? checkInTime;
                  int? attendanceId;

                  if (userId != null) {
                    isCheckedIn = prefs.getBool('is_checked_in_$userId');
                    checkInDate = prefs.getString('check_in_date_$userId');
                    checkInTime = prefs.getString('check_in_time_$userId');
                    attendanceId = prefs.getInt('attendance_id_$userId');
                    await loginController.logout(
                        userId: int.tryParse(userId) ?? 0);

                    try {
                      if (!kIsWeb && userId.isNotEmpty) {
                        final String topicName = '${AppStyles.name()}-$userId';
                        await FirebaseMessaging.instance
                            .unsubscribeFromTopic(topicName);
                      }
                    } catch (e) {
                      if (kDebugMode) print(e);
                    }
                  }

                  // Backup branding state
                  String? cachedLogo = prefs.getString('cached_company_logo');
                  String? cachedTitle = prefs.getString('cached_company_title');
                  String? baseUrl = prefs.getString('company_base_url');

                  await prefs.clear();

                  // Restore attendance state
                  if (userId != null) {
                    if (isCheckedIn != null) {
                      await prefs.setBool('is_checked_in_$userId', isCheckedIn);
                    }
                    if (checkInDate != null) {
                      await prefs.setString(
                          'check_in_date_$userId', checkInDate);
                    }
                    if (checkInTime != null) {
                      await prefs.setString(
                          'check_in_time_$userId', checkInTime);
                    }
                    if (attendanceId != null) {
                      await prefs.setInt('attendance_id_$userId', attendanceId);
                    }
                  }

                  // Restore branding state
                  if (cachedLogo != null) {
                    await prefs.setString('cached_company_logo', cachedLogo);
                  }
                  if (cachedTitle != null) {
                    await prefs.setString('cached_company_title', cachedTitle);
                  }
                  if (baseUrl != null) {
                    await prefs.setString('company_base_url', baseUrl);
                  }

                  if (context.mounted) {
                    router.go(LoginPage.route);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF3B30),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  'Logout',
                  style:
                      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
