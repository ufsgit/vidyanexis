// import 'package:flutter/material.dart';
// import 'package:vidyanexis/constants/app_colors.dart';
// import 'package:vidyanexis/constants/app_styles.dart';
// import 'package:vidyanexis/controller/dashboard_provider.dart';

// class CustomTab extends StatelessWidget {
//   const CustomTab({
//     super.key,
//     required DashboardProvider dashBoardProvider,
//   }) : _dashBoardProvider = dashBoardProvider;

//   final DashboardProvider _dashBoardProvider;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           height: 36,
//           width: 450, // Increased width to accommodate three tabs
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4),
//             color: Colors.grey.shade100,
//           ),
//           child: Stack(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     child: Text(
//                       'Leads Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(0),
//                   ),
//                   TextButton(
//                     child: Text(
//                       'Work Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(1),
//                   ),
//                   TextButton(
//                     child: Text(
//                       'Task Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(2),
//                   ),
//                 ],
//               ),
//               AnimatedAlign(
//                 duration: const Duration(milliseconds: 600),
//                 alignment: _dashBoardProvider.tabIndex == 0
//                     ? Alignment.centerLeft
//                     : _dashBoardProvider.tabIndex == 1
//                         ? Alignment.center
//                         : Alignment.centerRight,
//                 child: Container(
//                   width: 140,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Text(
//                       _dashBoardProvider.tabIndex == 0
//                           ? "Leads Overview"
//                           : _dashBoardProvider.tabIndex == 1
//                               ? "Work Overview"
//                               : "Task Overview",
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.primaryBlue),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:thrissur_ventures/constants/app_colors.dart';
// import 'package:thrissur_ventures/constants/app_styles.dart';
// import 'package:thrissur_ventures/controller/dashboard_provider.dart';

// class CustomTab extends StatelessWidget {
//   const CustomTab({
//     super.key,
//     required DashboardProvider dashBoardProvider,
//   }) : _dashBoardProvider = dashBoardProvider;

//   final DashboardProvider _dashBoardProvider;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           height: 36,
//           width: 450, // Increased width to accommodate three tabs
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(4),
//             color: Colors.grey.shade100,
//           ),
//           child: Stack(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextButton(
//                     child: Text(
//                       'Leads Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(0),
//                   ),
//                   TextButton(
//                     child: Text(
//                       'Work Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(1),
//                   ),
//                   TextButton(
//                     child: Text(
//                       'Task Overview',
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.textGrey3),
//                     ),
//                     onPressed: () => _dashBoardProvider.changeTab(2),
//                   ),
//                 ],
//               ),
//               AnimatedAlign(
//                 duration: const Duration(milliseconds: 600),
//                 alignment: _dashBoardProvider.tabIndex == 0
//                     ? Alignment.centerLeft
//                     : _dashBoardProvider.tabIndex == 1
//                         ? Alignment.center
//                         : Alignment.centerRight,
//                 child: Container(
//                   width: 140,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(4),
//                     color: Colors.white,
//                   ),
//                   child: Center(
//                     child: Text(
//                       _dashBoardProvider.tabIndex == 0
//                           ? "Leads Overview"
//                           : _dashBoardProvider.tabIndex == 1
//                               ? "Work Overview"
//                               : "Task Overview",
//                       style: AppStyles.getBodyTextStyle(
//                           fontSize: 13, fontColor: AppColors.primaryBlue),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:provider/provider.dart';

class CustomTab extends StatefulWidget {
  const CustomTab({
    super.key,
    required this.dashBoardProvider,
    this.userType = "",
  });

  final DashboardProvider dashBoardProvider;
  final String userType;

  @override
  State<CustomTab> createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  final List<GlobalKey> _tabKeys = [];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Accurate available width calculation
    final containerWidth = screenWidth < 800
        ? screenWidth - 32 // screenWidth minus horizontal padding (16*2)
        : 900.0;

    final tabOptions = [
      if (settingsProvider.menuIsViewMap[84].toString() != '0')
        'Dashboard count',
      if (settingsProvider.menuIsViewMap[49].toString() != '0')
        'Leads Overview',
      if (settingsProvider.menuIsViewMap[50].toString() != '0') 'Work Overview',
      if (settingsProvider.menuIsViewMap[76].toString() != '0')
        'Amc Notification',
      if (settingsProvider.menuIsViewMap[77].toString() != '0')
        'Payment Reminders',
      if (settingsProvider.menuIsViewMap[51].toString() != '0') 'Task Overview',
      if (settingsProvider.menuIsViewMap[52].toString() != '0') 'Task Summary',
      if (settingsProvider.menuIsViewMap[152].toString() != '0')
        'Customer Outstanding Summary',
      if (widget.userType == '1') 'User Activity',
      if (widget.userType == '1') 'Attendance Dashboard',
      if (settingsProvider.hasTravelAllowancePermission)
        'Travel Allowance',
    ];

    if (_tabKeys.length != tabOptions.length) {
      _tabKeys.clear();
      for (int i = 0; i < tabOptions.length; i++) {
        _tabKeys.add(GlobalKey());
      }
    }

    //change permissions id in dashBoardPage also ----------------

    if (tabOptions.isEmpty) {
      return Container();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tabOptions.length, (index) {
                final isSelected = widget.dashBoardProvider.tabIndex == index;
                return GestureDetector(
                  key: _tabKeys[index],
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    widget.dashBoardProvider.changeTab(index);
                    final allowedTabIds = [
                      if (settingsProvider.menuIsViewMap[84].toString() != '0')
                        6,
                      if (settingsProvider.menuIsViewMap[49].toString() != '0')
                        0,
                      if (settingsProvider.menuIsViewMap[50].toString() != '0')
                        1,
                      if (settingsProvider.menuIsViewMap[76].toString() != '0')
                        4,
                      if (settingsProvider.menuIsViewMap[77].toString() != '0')
                        5,
                      if (settingsProvider.menuIsViewMap[51].toString() != '0')
                        2,
                      if (settingsProvider.menuIsViewMap[52].toString() != '0')
                        3,
                      if (settingsProvider.menuIsViewMap[152].toString() != '0')
                        7,
                      if (widget.userType == '1') 8,
                      if (widget.userType == '1') 9,
                      if (settingsProvider.hasTravelAllowancePermission)
                        10,
                    ];

                    if (index >= 0 && index < allowedTabIds.length) {
                      widget.dashBoardProvider.loadDataForTab(
                          allowedTabIds[index], context);
                    }
                    
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_tabKeys[index].currentContext != null) {
                        Scrollable.ensureVisible(
                          _tabKeys[index].currentContext!,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          alignment: 0.5,
                        );
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: isSelected
                        ? const EdgeInsets.symmetric(vertical: 4, horizontal: 2)
                        : const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected ? Colors.white : Colors.transparent,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tabOptions[index] == 'Travel Allowance') ...[
                          //   Icon(
                          //     Icons.directions_car_rounded,
                          //     size: 14,
                          //     color: isSelected
                          //         ? AppColors.secondaryBlue
                          //         : const Color(0xFF64748B),
                          //   ),
                          //   const SizedBox(width: 6),
                        ],
                        Text(
                          _getShortTabName(tabOptions[index]),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.secondaryBlue
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  String _getShortTabName(String fullName) {
    switch (fullName) {
      case 'Dashboard count':
        return 'Dashboard';
      case 'Leads Overview':
        return 'Leads';
      case 'Work Overview':
        return 'Work';
      case 'Amc Notification':
        return 'Amc';
      case 'Payment Reminders':
        return 'Payment';
      case 'Task Overview':
        return 'Tasks';
      case 'Task Summary':
        return 'Summary';
      case 'Customer Outstanding Summary':
        return 'Outstanding';
      case 'User Activity':
        return 'Activity';
      case 'Attendance Dashboard':
        return 'Attendance';
      case 'Travel Allowance':
        return 'Travel Allowance';
      default:
        return fullName;
    }
  }
}

