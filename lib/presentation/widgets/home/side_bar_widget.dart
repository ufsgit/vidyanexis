import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/side_bar_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';

class CustomSidebar extends StatefulWidget {
  final List<SidebarOption> options;
  final String title;
  final String userName;
  final String logo;
  final double? width;
  final bool isDrawer;
  final String? appVersion;
  final void Function()? onPressed;

  const CustomSidebar({
    super.key,
    required this.options,
    this.title = 'vidyanexis',
    this.width,
    this.isDrawer = false,
    required this.userName,
    this.onPressed,
    this.appVersion,
    required this.logo,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  bool isReportsExpanded = false;

  List<SidebarOption> getNonReportOptions() {
    return widget.options
        .where((option) => !option.title.contains('Reports'))
        .toList();
  }

  List<SidebarOption> getReportOptions() {
    return widget.options
        .where((option) => option.title.contains('Reports'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final nonReportOptions = getNonReportOptions();
    final reportOptions = getReportOptions();

    return Container(
      width: widget.width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Section
          SizedBox(
            height: 64,
            child: Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Image(
                          image: NetworkImage(widget.logo),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isDrawer)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
          // Main Menu Items
          Expanded(
            child: Consumer<SidebarProvider>(
              builder: (context, provider, child) {
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Regular menu items
                    ...List.generate(nonReportOptions.length, (index) {
                      return _buildMenuItem(
                          context, provider, nonReportOptions[index], index);
                    }),

                    // Reports Section
                    if (reportOptions.isNotEmpty)
                      Container(
                        // decoration: BoxDecoration(
                        //   color: isReportsExpanded
                        //       ? AppColors.lightBlueColor
                        //       : AppColors.whiteColor,
                        //   borderRadius: BorderRadius.circular(8),
                        // ),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              isReportsExpanded = expanded;
                            });
                          },
                          leading: SvgPicture.asset(
                            'assets/images/Reports.svg',
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              isReportsExpanded
                                  ? AppColors.primaryBlue
                                  : AppColors.textGrey4,
                              BlendMode.srcIn,
                            ),
                          ),
                          title: Text(
                            'Reports',
                            style: GoogleFonts.plusJakartaSans(
                              color: isReportsExpanded
                                  ? AppColors.primaryBlue
                                  : AppColors.textGrey4,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          children: reportOptions.map((option) {
                            return _buildSubmenuItem(
                                context,
                                provider,
                                option,
                                nonReportOptions.length +
                                    reportOptions.indexOf(option));
                          }).toList(),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // User Profile Section
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
            child: Container(
              height: 40,
              color: AppColors.surfaceGrey,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/profile_icon.svg',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.userName,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
          // Version Number
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Version ${widget.appVersion ?? ""}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, SidebarProvider provider,
      SidebarOption option, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 35,
        decoration: BoxDecoration(
          color: provider.selectedIndex == index
              ? AppColors.lightBlueColor
              : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: () {
            provider.updateSelectedName(option.title);
            provider.replaceWidget(true, '');
            provider.replaceWidgetCustomer(true, '');
            context.go(HomePage.route);
            provider.setSelectedIndex(index);
            if (widget.isDrawer) {
              Navigator.of(context).pop();
            }
          },
          child: Row(
            children: [
              const SizedBox(width: 8),
              SvgPicture.asset(
                option.iconPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  provider.selectedIndex == index
                      ? AppColors.primaryBlue
                      : AppColors.textGrey4,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                option.title,
                style: GoogleFonts.plusJakartaSans(
                  color: provider.selectedIndex == index
                      ? AppColors.primaryBlue
                      : AppColors.textGrey4,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmenuItem(BuildContext context, SidebarProvider provider,
      SidebarOption option, int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, right: 8, top: 4, bottom: 4),
      child: InkWell(
        onTap: () {
          provider.replaceWidget(true, '');
          provider.replaceWidgetCustomer(true, '');
          context.go(HomePage.route);
          provider.setSelectedIndex(index);
          if (widget.isDrawer) {
            Navigator.of(context).pop();
          }
        },
        child: Container(
          height: 35,
          decoration: BoxDecoration(
            color: provider.selectedIndex == index
                ? AppColors.lightBlueColor
                : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              option.title,
              style: GoogleFonts.plusJakartaSans(
                color: provider.selectedIndex == index
                    ? AppColors.primaryBlue
                    : AppColors.textGrey4,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_outlined),
      iconSize: 18,
      onSelected: (String value) {
        if (value == 'logout') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
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
                      }

                      await prefs.clear();

                      // Restore attendance state
                      if (userId != null) {
                        if (isCheckedIn != null) {
                          await prefs.setBool(
                              'is_checked_in_$userId', isCheckedIn);
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
                          await prefs.setInt(
                              'attendance_id_$userId', attendanceId);
                        }
                      }

                      context.go(LoginPage.route);
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text(
            'Logout',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
