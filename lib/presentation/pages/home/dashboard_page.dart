import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/presentation/pages/home/notifications_page.dart';
import 'package:vidyanexis/presentation/pages/home/task_summary_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/task_overview_tab.dart';
import 'package:vidyanexis/presentation/pages/dashboard/custom_tab.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/add_attendance.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_overview_tab.dart';
import 'package:vidyanexis/presentation/pages/dashboard/work_overview_tab.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

// import 'package:vidyanexis/presentation/widgets/home/dashboard_task_count_card.dart';
// import 'package:vidyanexis/presentation/pages/home/task_page.dart';
import 'package:vidyanexis/presentation/pages/dashboard/amc_notification_tab.dart';
import 'package:vidyanexis/presentation/pages/dashboard/payment_reminder_tab.dart';
import 'package:vidyanexis/presentation/pages/dashboard/dashboard_count_tab.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  int userId = 0;
  String userName = "";
  String userType = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      // Essential calls
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getFollowUpStatus(context, "1");
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";

      if (userType != "1") {
        dashBoardProvider.setUserFilterStatus(userId);
      } else {
        // For admins, also ensure flags are cleared so fresh data is fetched
        dashBoardProvider.clearDashboardFlags();
      }

      // Load data for the initial tab only
      final allowedTabs = <int>[
        if ((settingsProvider.menuIsViewMap[84] ?? 1).toString() != '0') 6,
        if ((settingsProvider.menuIsViewMap[49] ?? 1).toString() != '0') 0,
        if ((settingsProvider.menuIsViewMap[50] ?? 1).toString() != '0') 1,
        if ((settingsProvider.menuIsViewMap[76] ?? 1).toString() != '0') 4,
        if ((settingsProvider.menuIsViewMap[77] ?? 1).toString() != '0') 5,
        if ((settingsProvider.menuIsViewMap[51] ?? 1).toString() != '0') 2,
        if ((settingsProvider.menuIsViewMap[52] ?? 1).toString() != '0') 3,
      ];

      if (allowedTabs.isNotEmpty) {
        if (!mounted) return;
        final safeIndex =
            dashBoardProvider.tabIndex.clamp(0, allowedTabs.length - 1);
        final activeTab = allowedTabs[safeIndex];
        await dashBoardProvider.loadDataForTab(activeTab, context);
      }

      if (!mounted) return;
      final attendanceProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);
      if (userId != 0) {
        await attendanceProvider.checkIsCheckedIn(userId);
      }

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    DashboardProvider dashBoardProvider =
        Provider.of<DashboardProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final allowedTabs = <int>[
      if ((settingsProvider.menuIsViewMap[84] ?? 1).toString() != '0') 6,
      if ((settingsProvider.menuIsViewMap[49] ?? 1).toString() != '0') 0,
      if ((settingsProvider.menuIsViewMap[50] ?? 1).toString() != '0') 1,
      if ((settingsProvider.menuIsViewMap[76] ?? 1).toString() != '0') 4,
      if ((settingsProvider.menuIsViewMap[77] ?? 1).toString() != '0') 5,
      if ((settingsProvider.menuIsViewMap[51] ?? 1).toString() != '0') 2,
      if ((settingsProvider.menuIsViewMap[52] ?? 1).toString() != '0') 3,
    ];

    Widget dateFilterBtn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onClickTopButton(context, allowedTabs[dashBoardProvider.tabIndex.clamp(0, allowedTabs.length - 1)]),
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: AppStyles.isWebScreen(context) ? 38 : 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.secondaryBlue),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  dashBoardProvider.fromDate == null &&
                          dashBoardProvider.toDate == null
                      ? 'All Dates'
                      : dashBoardProvider.formattedFromDate ==
                              dashBoardProvider.formattedToDate
                          ? dashBoardProvider.formattedFromDate
                          : '${dashBoardProvider.formattedFromDate} - ${dashBoardProvider.formattedToDate}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Widget staffFilterBtn = Material(
      color: Colors.transparent,
      child: Ink(
        height: AppStyles.isWebScreen(context) ? 38 : 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: _buildAssignedStaffFilter(dashBoardProvider, allowedTabs[dashBoardProvider.tabIndex.clamp(0, allowedTabs.length - 1)]),
      ),
    );

    Widget attendanceBtn = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 140),
      child: Consumer<AttendanceReportProvider>(
        builder: (context, attendanceProvider, child) {
          if (settingsProvider.menuIsViewMap[26].toString() != '1') {
            return const SizedBox.shrink();
          }

          final isWeb = AppStyles.isWebScreen(context);
          final btnHeight = isWeb ? 38.0 : 74.0;

          if (attendanceProvider.isCompletedToday) {
            return Container(
              height: btnHeight,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: isWeb 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Done',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF16A34A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                        const SizedBox(height: 2),
                        Text(
                          'Done',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF16A34A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            );
          }

          return Container(
            height: btnHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.secondaryBlue,
                  AppColors.secondaryBlue.withOpacity(0.85),
                ],
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return const AddAttendanceWidget(
                        editId: '0',
                        isEdit: false,
                        user: '',
                        userId: 0);
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isWeb 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Attendance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 20),
                        const SizedBox(height: 2),
                        Text(
                          'Attendance',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );

    return Scaffold(
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      backgroundColor: AppColors.scaffoldColor,
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              backgroundColor: AppColors.whiteColor,
              leadingWidth: 56,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sort,
                          size: 20, color: AppColors.textBlue800),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              title: Text(
                'Dashboard',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              actions: [
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    final count = notificationProvider.totalCount;

                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            size: 26,
                            color: Colors.black.withOpacity(0.7),
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
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '!' : count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
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
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => dashBoardProvider.refreshDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero, // Remove padding here, add inside containers

          children: [
            // Premium Header Section
            Container(
              padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AppStyles.isWebScreen(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 4,
                          child: CustomTab(dashBoardProvider: dashBoardProvider),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: dateFilterBtn),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: staffFilterBtn),
                        const SizedBox(width: 12),
                        attendanceBtn,
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTab(dashBoardProvider: dashBoardProvider),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  dateFilterBtn,
                                  const SizedBox(height: 6),
                                  staffFilterBtn,
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            attendanceBtn,
                          ],
                        ),
                      ],
                    ),
            ),




            const SizedBox(height: 16),
            
            // Tab Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Builder(builder: (context) {
                final safeIndex =
                    dashBoardProvider.tabIndex.clamp(0, allowedTabs.length - 1);
                final activeTab = allowedTabs[safeIndex];


              switch (activeTab) {
                case 6:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: safeIndex == allowedTabs.indexOf(6)
                        ? const Alignment(0, 0)
                        : const Alignment(-100, 0),
                    child: DashboardCountTab(
                      dashBoardProvider: dashBoardProvider,
                    ),
                  );
                case 0:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: safeIndex == allowedTabs.indexOf(0)
                        ? const Alignment(0, 0)
                        : const Alignment(-100, 0),
                    child: LeadsOverViewTab(
                      dashBoardProvider: dashBoardProvider,
                      taskAllocationData:
                          dashBoardProvider.taskAllocationSummaryData,
                      followUpLeadData:
                          dashBoardProvider.followUpSummaryData,
                      leadConversionData: dashBoardProvider.conversionData,
                      countLeadData: dashBoardProvider.conversionCountData,
                      pieData: dashBoardProvider.leadProgressReport,
                    ),
                  );

                case 1:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: safeIndex == 1
                        ? const Alignment(0, 0)
                        : const Alignment(0, -100),
                    child: WorkOverViewTab(
                      dashboardProvider: dashBoardProvider,
                      taskData: dashBoardProvider.taskAllocationSummaryData,
                      data: dashBoardProvider.conversionData,
                      countLeadData: dashBoardProvider.conversionCountData,
                    ),
                  );
                case 4:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: const Alignment(0, 0),
                    child: const AmcNotificationTab(),
                  );
                case 5:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: const Alignment(0, 0),
                    child: const PaymentReminderTab(),
                  );
                case 2:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: const Alignment(0, 0),
                    child: const TaskOverviewTab(),
                  );
                case 3:
                  return AnimatedAlign(
                    duration: const Duration(milliseconds: 600),
                    alignment: const Alignment(0, 0),
                    child: const TaskSummaryPage(),
                  );
                }
                return const SizedBox.shrink();
              }),

            ),
          ],
        ),
      ),
    );

  }

  void onClickTopButton(BuildContext context, int activeTab) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<DashboardProvider>(
        builder: (contextx, dashBoardProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            dashBoardProvider.setDateFilter(title);
                            dashBoardProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              dashBoardProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: dashBoardProvider.selectedDateFilterIndex ==
                                    index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: dashBoardProvider.fromDate ??
                                    DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                dashBoardProvider.setFromDate(pickedDate);
                                dashBoardProvider.setToDate(pickedDate);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: dashBoardProvider.fromDate != null
                                  ? '${dashBoardProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'Select Date',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);

                          dashBoardProvider.formatDate();

                          dashBoardProvider.loadDataForTab(activeTab, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          dashBoardProvider.selectDateFilterOption(null);
                          dashBoardProvider.loadDataForTab(activeTab, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> dateButtonTitles = [
    // 'Yesterday',
    'Today',
    'Tomorrow',
    // 'This Week',
    // 'This Month',
  ];

  // Filters (no date): User, Client, Project Type, Expense Type
  Widget _buildAssignedStaffFilter(
      DashboardProvider dashBoardProvider, int activeTab) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        bool isAdmin = userType == "1" || userType == "0";
        int dropdownValue;
        List<DropdownMenuItem<int>> dropdownItems;

        if (isAdmin) {
          dropdownItems = [
                DropdownMenuItem<int>(
                  value: 0,
                  child: Text(
                    'All Staff',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                ),
              ] +
              dropDownProvider.searchUserDetails
                  .map((user) => DropdownMenuItem<int>(
                        value: user.userDetailsId,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            user.userDetailsName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryBlue,
                            ),
                          ),
                        ),
                      ))
                  .toList();
          dropdownValue = dashBoardProvider.selectedUser ?? 0;
        } else {
          dropdownItems = [
            DropdownMenuItem<int>(
              value: userId,
                child: Text(
                  userName.isNotEmpty ? userName : 'Current User',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryBlue,
                  ),
                ),
            ),
          ];
          dropdownValue = userId;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.person_search_rounded, size: 13, color: AppColors.secondaryBlue),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: dropdownItems.any((item) => item.value == dropdownValue)
                      ? dropdownValue
                      : 0,
                  underline: Container(),
                  isDense: true,
                  isExpanded: true,
                  alignment: Alignment.centerLeft,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.secondaryBlue.withOpacity(0.5)),
                  items: dropdownItems,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryBlue,
                  ),
                  onChanged: isAdmin
                      ? (int? newValue) {
                          if (newValue != null) {
                            dashBoardProvider.setUserFilterStatus(newValue);
                            dashBoardProvider.loadDataForTab(activeTab, context);
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        );



      },
    );
  }

  Widget filterWidget(
      {required DashboardProvider dashBoardProvider, required int activeTab}) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onClickTopButton(context, activeTab),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: dashBoardProvider.fromDate != null ||
                              dashBoardProvider.toDate != null
                          ? AppColors.secondaryBlue.withOpacity(0.5)
                          : Colors.grey[200]!,
                      width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.black.withOpacity(0.5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        dashBoardProvider.fromDate == null &&
                                dashBoardProvider.toDate == null
                            ? 'All Dates'
                            : dashBoardProvider.formattedFromDate ==
                                    dashBoardProvider.formattedToDate
                                ? dashBoardProvider.formattedFromDate
                                : '${dashBoardProvider.formattedFromDate} - ${dashBoardProvider.formattedToDate}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.black45),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildAssignedStaffFilter(dashBoardProvider, activeTab),
          ),
          if (dashBoardProvider.fromDate != null ||
              dashBoardProvider.toDate != null ||
              dashBoardProvider.selectedUser != 0) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: () {
                dashBoardProvider.selectDateFilterOption(null);
                dashBoardProvider.selectedLeadCountKeyword = null;
                if (userType != "1") {
                  dashBoardProvider.setUserFilterStatus(userId);
                } else {
                  dashBoardProvider.setUserFilterStatus(0);
                }
                dashBoardProvider.loadDataForTab(activeTab, context);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(36, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ]
        ],
      ),
    );
  }




  /*
  Widget _buildTaskReports(
      BuildContext context, DashboardProvider dashBoardProvider) {
    // Access DropDownProvider to map names to IDs for navigation
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    // Calculate Counts
    int pendingCount = 0;
    int currentCount = 0;

    for (var status in dashBoardProvider.taskAllocationSummaryDataStatus) {
      final name = status.taskStatusName.toLowerCase();
      if (name.contains('pending') || name.contains('not started')) {
        pendingCount += status.count;
      } else if (name.contains('in progress')) {
        currentCount += status.count;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // final isMobile = !AppStyles.isWebScreen(context); // This variable is no longer needed

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DashboardTaskCountCard(
                    isLoading: dashBoardProvider.isDashBoardLoading,
                    title: 'Pending Tasks',
                    count: pendingCount,
                    baseColor: const Color(0xFFEAB308), // Yellow/Warning
                    onTap: () {
                      // Find ID for Pending/Not Started
                      int? pendingId;
                      try {
                        pendingId = dropDownProvider.followUpData.firstWhere(
                          (element) {
                            final name =
                                element.statusName?.toLowerCase() ?? '';
                            return name.contains('pending') ||
                                name.contains('not started');
                          },
                        ).statusId;
                      } catch (_) {}

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TaskPage(initialStatusFilter: pendingId),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                    width: 16), // Fixed spacing for both mobile and web
                Expanded(
                  child: DashboardTaskCountCard(
                    isLoading: dashBoardProvider.isDashBoardLoading,
                    title: 'Current Tasks',
                    count: currentCount,
                    baseColor: const Color(0xFF3B82F6), // Blue/Info
                    onTap: () {
                      // Find ID for In Progress
                      int? currentId;
                      try {
                        currentId = dropDownProvider.followUpData.firstWhere(
                          (element) {
                            final name =
                                element.statusName?.toLowerCase() ?? '';
                            return name.contains('in progress');
                          },
                        ).statusId;
                      } catch (_) {}

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TaskPage(initialStatusFilter: currentId),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  */
}
