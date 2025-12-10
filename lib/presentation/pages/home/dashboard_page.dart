import 'package:flutter/material.dart';
import 'package:techtify/presentation/pages/home/task_summary_page.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/dashboard_provider.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/pages/dashboard/task_overview_tab.dart';
import 'package:techtify/presentation/pages/reports/staff_attendance_screen.dart';
import 'package:techtify/presentation/pages/dashboard/custom_tab.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/pages/dashboard/lead_overview_tab.dart';
import 'package:techtify/presentation/pages/dashboard/work_overview_tab.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
import 'package:techtify/presentation/widgets/home/side_drawer_mobile.dart';

import '../../widgets/home/custom_textfield_widget_mobile.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // getData();
      final dashBoardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      await dashBoardProvider.getTaskInfoDashBoard(context);
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
              title: Text(
                'Dashboard',
                style: const TextStyle(
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
                CustomElevatedButton(
                  buttonText: 'View Attendance',
                  onPressed: () async {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return const StaffAttendanceScreen();
                      },
                    );
                  },
                  backgroundColor: AppColors.whiteColor,
                  borderColor: AppColors.appViolet,
                  textColor: AppColors.appViolet,
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
                return dashBoardProvider.isDashBoardLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AnimatedAlign(
                        duration: const Duration(milliseconds: 600),
                        alignment: safeIndex == 0
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
                return dashBoardProvider.isDashBoardLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AnimatedAlign(
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
}
