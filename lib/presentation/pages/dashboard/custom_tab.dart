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
//             borderRadius: BorderRadius.circular(15),
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
//                     borderRadius: BorderRadius.circular(15),
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
//             borderRadius: BorderRadius.circular(15),
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
//                     borderRadius: BorderRadius.circular(15),
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
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:provider/provider.dart';

class CustomTab extends StatelessWidget {
  const CustomTab({
    super.key,
    required DashboardProvider dashBoardProvider,
  }) : _dashBoardProvider = dashBoardProvider;

  final DashboardProvider _dashBoardProvider;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Better responsive breakpoints
    final containerWidth = screenWidth < 400
        ? screenWidth * 0.95
        : screenWidth < 800
            ? screenWidth * 0.95
            : 900.0;

    final tabOptions = [
      if (settingsProvider.menuIsViewMap[49].toString() != '0')
        'Leads Overview',
      if (settingsProvider.menuIsViewMap[50].toString() != '0') 'Work Overview',
      if (settingsProvider.menuIsViewMap[76].toString() != '0')
        'Amc Notification',
      if (settingsProvider.menuIsViewMap[77].toString() != '0')
        'Payment Reminders',
      if (settingsProvider.menuIsViewMap[51].toString() != '0') 'Task Overview',
      if (settingsProvider.menuIsViewMap[52].toString() != '0') 'Task Summary',
    ];
    //change permissions id in dashBoardPage also ----------------

    if (tabOptions.isEmpty) {
      return Container();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 36,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade100,
          ),
          child: Stack(
            children: [
              // Buttons Row
              Row(
                children: List.generate(tabOptions.length, (index) {
                  return Expanded(
                    child: InkWell(
                      onTap: () => _dashBoardProvider.changeTab(index),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        height: 36,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          screenWidth < 1000
                              ? _getShortTabName(tabOptions[index])
                              : tabOptions[index],
                          style: AppStyles.getBodyTextStyle(
                              fontSize: screenWidth < 400 ? 11 : 13,
                              fontColor: AppColors.textGrey3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Animated Selection Indicator
              Builder(
                builder: (_) {
                  final currentIndex = _dashBoardProvider.tabIndex
                      .clamp(0, tabOptions.length - 1);
                  final dynamicButtonWidth = containerWidth / tabOptions.length;
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    left: currentIndex * dynamicButtonWidth,
                    top: 2,
                    child: Container(
                      width: dynamicButtonWidth,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            screenWidth < 1000
                                ? _getShortTabName(tabOptions[currentIndex])
                                : tabOptions[currentIndex],
                            style: AppStyles.getBodyTextStyle(
                                fontSize: screenWidth < 400 ? 11 : 13,
                                fontColor: AppColors.primaryBlue),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getShortTabName(String fullName) {
    switch (fullName) {
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
      default:
        return fullName;
    }
  }
}
