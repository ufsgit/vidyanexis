import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/menu_model.dart';
import 'package:vidyanexis/http/socket_io.dart';
import 'package:vidyanexis/presentation/pages/home/task_page.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/notification_overlay.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_page_phone.dart';
import 'package:vidyanexis/presentation/pages/home/dashboard_page.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/animated_bottom_navbar_widget.dart';

class HomePageMobile extends StatefulWidget {
  const HomePageMobile({super.key});

  @override
  State<HomePageMobile> createState() => _HomePageMobileState();
}

class _HomePageMobileState extends State<HomePageMobile> {
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

      final preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      if (!kIsWeb && userId.isNotEmpty) {
        try {
          print("Subscribing to topic: ${AppStyles.name()}-$userId");
          await FirebaseMessaging.instance
              .subscribeToTopic('${AppStyles.name()}-$userId');
        } catch (e) {
          print(e);
        }
      }
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.getMenuPermissionData(userId, context);
      await settingsProvider.getCompanyDetails();
      logo = AppStyles.logo();
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
    final settingsProvider = Provider.of<SettingsProvider>(context);

    List<Widget> pages = [];
    List<BottomNavigationBarItem> bottomNavItems = [];

    void addPage(int menuKey, String iconPath, String label, Widget page) {
      if (settingsProvider.menuIsViewMap[menuKey].toString() == '1') {
        bottomNavItems.add(
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ImageIcon(AssetImage(iconPath), size: 24),
            ),
            label: label,
          ),
        );
        pages.add(page);
      }
    }

    addPage(12, 'assets/images/home-11.png', 'Home', const DashBoardPage());
    addPage(3, 'assets/images/user-story.png', 'Leads', const LeadPagePhone());
    addPage(4, 'assets/images/user_grouped.png', 'Customers',
        const CustomerPagePhone());
    addPage(35, 'assets/images/task-02.png', 'Tasks', const TaskPage());

    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: bottomNavItems.isEmpty ? AppBar() : null,
      body: bottomNavItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : pages[sideProvider.selectedIndexMobile],
      // bottomNavigationBar: bottomNavItems.isNotEmpty
      //     ? AnimatedBottomBarWidget(
      //         items: bottomNavItems,
      //         currentIndex: sideProvider.selectedIndexMobile,
      //         selectedItemColor: AppColors.primaryBlue,
      //         unselectedItemColor: AppColors.textBlack,
      //         selectedLabelStyle: GoogleFonts.plusJakartaSans(
      //           fontSize: 12,
      //           fontWeight: FontWeight.w700,
      //         ),
      //         onTap: (index) {
      //           sideProvider.setSelectedIndexMobile(index);
      //           sideProvider
      //               .updateSelectedName(bottomNavItems[index].label ?? '');
      //         },
      //       )
      //     : null,
      bottomNavigationBar: bottomNavItems.isNotEmpty
          ? BottomNavigationBar(
              currentIndex: sideProvider.selectedIndexMobile,
              iconSize: 20,
              backgroundColor: AppColors.whiteColor,
              elevation: 1,
              selectedItemColor: AppColors.primaryBlue,
              unselectedItemColor: AppColors.textGrey4,
              selectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              onTap: (index) {
                sideProvider.setSelectedIndexMobile(index);
                sideProvider
                    .updateSelectedName(bottomNavItems[index].label ?? '');
              },
              type: BottomNavigationBarType.fixed,
              items: bottomNavItems,
            )
          : null,
    );
  }
}
