import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/home/task_summary_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/task_overview_tab.dart';
import 'package:vidyanexis/presentation/pages/reports/staff_attendance_screen.dart';
import 'package:vidyanexis/presentation/pages/dashboard/custom_tab.dart';
import 'package:vidyanexis/presentation/widgets/home/add_attendance.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_overview_tab.dart';
import 'package:vidyanexis/presentation/pages/dashboard/work_overview_tab.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

import '../../widgets/home/custom_textfield_widget_mobile.dart';

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
                  return Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset(
                        'assets/images/menu.png',
                        height: 24,
                        width: 24,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (settingsProvider.menuIsViewMap[26].toString() == '1')
                ElevatedButton.icon(
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
                ),
            ],
          ),
          const SizedBox(height: 20),
          CustomTab(dashBoardProvider: dashBoardProvider),
          const SizedBox(height: 24),
          // Render tab body only if permitted
          Builder(builder: (context) {
            final allowedTabs = <int>[
              if ((settingsProvider.menuIsViewMap[49] ?? 0).toString() == '1')
                0, // Leads Overview
              if ((settingsProvider.menuIsViewMap[50] ?? 0).toString() == '1')
                1, // Work Overview
              if ((settingsProvider.menuIsViewMap[51] ?? 0).toString() == '1')
                2, // Task Overview
              if ((settingsProvider.menuIsViewMap[52] ?? 0).toString() == '1')
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
              case 0:
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 600),
                  alignment: safeIndex == 0
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
              case 2:
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 600),
                  alignment: safeIndex == 2
                      ? const Alignment(0, 0)
                      : const Alignment(50, 0),
                  child: const TaskOverviewTab(),
                );
              case 3:
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 600),
                  alignment: safeIndex == 3
                      ? const Alignment(0, 0)
                      : const Alignment(50, 0),
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
                value: dropdownValue,
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
}
