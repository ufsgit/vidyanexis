import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/notification_provider.dart';
import 'package:vidyanexis/presentation/pages/home/notifications_page.dart';
import 'package:vidyanexis/presentation/pages/home/task_summary_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
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

import 'package:vidyanexis/presentation/widgets/home/dashboard_task_count_card.dart';
import 'package:vidyanexis/presentation/pages/home/task_page.dart';
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
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getData();
      final dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      await dashBoardProvider.getTaskInfoDashBoard(context);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getFollowUpStatus(context, "3");
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";
      //not admin type assign user filter
      if (userType != "1") {
        dashBoardProvider.setUserFilterStatus(userId);
      }

      // Load initial data
      await dashBoardProvider.getLeadData();
      await dashBoardProvider.getWorkData();
      await dashBoardProvider.getCustomers();

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
    GlobalKey<FormState> formKey = GlobalKey();
    DashboardProvider dashBoardProvider =
        Provider.of<DashboardProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              leadingWidth: 40,
              leading: Builder(
                builder: (context) {
                  return InkWell(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.menu,
                            size: 20, color: Colors.black87),
                      ),
                    ),
                  );
                },
              ),
              title: const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            )
          : null,
      drawer: const SidebarDrawer(),
      body: ListView(
        padding: AppStyles.isWebScreen(context)
            ? const EdgeInsets.symmetric(vertical: 18, horizontal: 130)
            : const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        children: [
          // TextButton(onPressed: (){
          //   if (formKey.currentState!.validate()) {

          //   }
          // }, child: Text("data")),
          if (AppStyles.isWebScreen(context))
            Text(
              'Dashboard',
              style: AppStyles.getHeadingTextStyle(
                  fontSize: 24, fontColor: AppColors.primaryViolet),
            ),
          const SizedBox(height: 20),
          _buildTaskReports(context, dashBoardProvider),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Consumer<AttendanceReportProvider>(
                builder: (context, attendanceProvider, child) {
                  if (settingsProvider.menuIsViewMap[26].toString() != '1') {
                    return const SizedBox.shrink();
                  }

                  if (attendanceProvider.isCompletedToday) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Attendance Completed',
                        style: AppStyles.getBoldTextStyle(
                          fontColor: AppColors.btnRed,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return const AddAttendanceWidget(
                              editId: '0', isEdit: false, user: '', userId: 0);
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Mark Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTab(dashBoardProvider: dashBoardProvider),
          const SizedBox(height: 24),
          // Render tab body only if permitted
          Builder(builder: (context) {
            final allowedTabs = <int>[
              if ((settingsProvider.menuIsViewMap[84] ?? 1).toString() != '0')
                6, // Dashboard count
              if ((settingsProvider.menuIsViewMap[49] ?? 1).toString() != '0')
                0, // Leads Overview
              if ((settingsProvider.menuIsViewMap[50] ?? 1).toString() != '0')
                1, // Work Overview
              if ((settingsProvider.menuIsViewMap[76] ?? 1).toString() != '0')
                4, // Amc Notification
              if ((settingsProvider.menuIsViewMap[77] ?? 1).toString() != '0')
                5, // Payment Reminders
              if ((settingsProvider.menuIsViewMap[51] ?? 1).toString() != '0')
                2, // Task Overview
              if ((settingsProvider.menuIsViewMap[52] ?? 1).toString() != '0')
                3, // Task Summary
            ];
            //change permissions id in CustomTab also ----------------

            if (allowedTabs.isEmpty) {
              return Container();
            }

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
                  child: Column(
                    children: [
                      filterWidget(dashBoardProvider: dashBoardProvider),
                      const SizedBox(height: 20),
                      DashboardCountTab(
                        dashBoardProvider: dashBoardProvider,
                      ),
                    ],
                  ),
                );
              case 0:
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 600),
                  alignment: safeIndex == allowedTabs.indexOf(0)
                      ? const Alignment(0, 0)
                      : const Alignment(-100, 0),
                  child: Column(
                    children: [
                      filterWidget(dashBoardProvider: dashBoardProvider),
                      const SizedBox(height: 20),
                      LeadsOverViewTab(
                        dashBoardProvider: dashBoardProvider,
                        taskAllocationData:
                            dashBoardProvider.taskAllocationSummaryData,
                        followUpLeadData: dashBoardProvider.followUpSummaryData,
                        leadConversionData: dashBoardProvider.conversionData,
                        countLeadData: dashBoardProvider.conversionCountData,
                        pieData: dashBoardProvider.leadProgressReport,
                      ),
                    ],
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
              default:
                return Container();
            }
          }),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
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
                            onTap: () =>
                                dashBoardProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: dashBoardProvider.fromDate != null
                                  ? '${dashBoardProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                dashBoardProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: dashBoardProvider.toDate != null
                                  ? '${dashBoardProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
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

                          print(dashBoardProvider.formattedFromDate);
                          print(dashBoardProvider.formattedToDate);
                          dashBoardProvider.getLeadData();
                          dashBoardProvider.getWorkData();
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
                          dashBoardProvider.getLeadData();
                          dashBoardProvider.getWorkData();
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
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  // Filters (no date): User, Client, Project Type, Expense Type
  Widget _buildAssignedStaffFilter(DashboardProvider dashBoardProvider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        bool isAdmin = true; // Enabled for all as per request
        int dropdownValue;
        List<DropdownMenuItem<int>> dropdownItems;

        if (isAdmin) {
          // Admin: Show all users with "All" option
          dropdownItems = [
                const DropdownMenuItem<int>(
                  value: 0,
                  child: Text(
                    'All',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ] +
              dropDownProvider.searchUserDetails
                  .map((user) => DropdownMenuItem<int>(
                        value: user.userDetailsId!,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            user.userDetailsName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ))
                  .toList();
          dropdownValue = dashBoardProvider.selectedUser ?? 0;
        } else {
          // Non-admin staff: Show only their own name
          dropdownItems = [
            DropdownMenuItem<int>(
              value: userId, // Use userId from state
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  userName.isNotEmpty ? userName : 'Current User',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ];
          dropdownValue = userId;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (dashBoardProvider.selectedUser != null &&
                      dashBoardProvider.selectedUser != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Assigned Staff: '),
              DropdownButton<int>(
                value: dropdownItems.any((item) => item.value == dropdownValue)
                    ? dropdownValue
                    : 0,
                hint: const Text('All'),
                items: dropdownItems,
                onChanged: isAdmin
                    ? (int? newValue) {
                        if (newValue != null) {
                          dashBoardProvider.setUserFilterStatus(newValue);
                          dashBoardProvider.getLeadData();
                        }
                      }
                    : null,
                underline: Container(),
                isDense: true,
                iconSize: 18,
                disabledHint: Text(
                  userName.isNotEmpty ? userName : 'Current User',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget filterWidget({required DashboardProvider dashBoardProvider}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 0.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          GestureDetector(
            onTap: () {
              onClickTopButton(context);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: dashBoardProvider.fromDate != null ||
                            dashBoardProvider.toDate != null
                        ? AppColors.primaryBlue
                        : Colors.grey[300]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dashBoardProvider.fromDate == null &&
                      dashBoardProvider.toDate == null)
                    const Text('Follow-Up Date: All'),
                  if (dashBoardProvider.fromDate != null &&
                      dashBoardProvider.toDate != null)
                    Text(
                        'Date : ${dashBoardProvider.formattedFromDate} - ${dashBoardProvider.formattedToDate}'),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.black45,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          _buildAssignedStaffFilter(dashBoardProvider),
          // const Spacer(),
          if (dashBoardProvider.fromDate != null ||
              dashBoardProvider.toDate != null ||
              dashBoardProvider.selectedUser != 0)
            ElevatedButton(
              onPressed: () {
                dashBoardProvider.selectDateFilterOption(null);
                // clear keyword filter as well
                dashBoardProvider.selectedLeadCountKeyword = null;
                if (userType != "1") {
                  dashBoardProvider.setUserFilterStatus(userId);
                } else {
                  dashBoardProvider.setUserFilterStatus(0);
                }
                dashBoardProvider.getLeadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                side: BorderSide(color: AppColors.textRed),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Reset'),
            ),
        ],
      ),
    );
  }

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
}
