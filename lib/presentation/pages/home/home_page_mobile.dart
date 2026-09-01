import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_page_phone.dart';
import 'package:vidyanexis/presentation/pages/home/dashboard_page.dart';
import 'package:vidyanexis/presentation/pages/home/lead_page_phone.dart';
import 'package:vidyanexis/presentation/pages/home/task_page.dart';
import 'package:vidyanexis/http/socket_io.dart';

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
    print('[PERF-BOOT] HomePage created (Mobile)');
    initDevicePlugin();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MicrotecSocket.initSocket();

      final preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      if (!kIsWeb && userId.isNotEmpty) {
        try {
          String? topicnameLocal =
              preferences.getString('cached_company_notification_topic');
          print("Subscribing to topic12: $topicnameLocal");
          String topicName = topicnameLocal ?? '';
          topicName = '$topicName-$userId';
          print("Subscribing to topic: $topicName");
          await FirebaseMessaging.instance.subscribeToTopic(topicName);
        } catch (e) {
          print(e);
        }
      }
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.getMenuPermissionData(userId, context);
      await settingsProvider.getCompanyDetails();
    });
  }

  Future<void> initDevicePlugin() async {
    await PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[PERF-BOOT] HomePage first build (Mobile)');
    final sideProvider = Provider.of<SidebarProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    List<Widget> pages = [];
    List<BottomNavigationBarItem> bottomNavItems = [];

    void addPage(int menuKey, String iconPath, String label, Widget page) {
      final defaultValue = (menuKey == 12 || menuKey == 3 || menuKey == 4 || menuKey == 35) ? 1 : 0;
      final permStr = (settingsProvider.menuIsViewMap[menuKey] ?? defaultValue).toString();
      if (permStr != '0') {
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

    addPage(3, 'assets/images/leader.png', 'Leads', const LeadPagePhone());
    addPage(12, 'assets/images/home-page.png', 'Home', const DashBoardPage());
    addPage(4, 'assets/images/consumer.png', 'Customers',
        const CustomerPagePhone());
    addPage(35, 'assets/images/checklist.png', 'Tasks', const TaskPage());

    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: bottomNavItems.isEmpty ? AppBar() : null,
      body: sideProvider.reportPage != null
          ? sideProvider.reportPage!
          : (pages.isEmpty
              ? const DashBoardPage()
              : pages[
                  sideProvider.selectedIndexMobile.clamp(0, pages.length - 1)]),
      bottomNavigationBar: bottomNavItems.length >= 2
          ? BottomNavigationBar(
              currentIndex: sideProvider.selectedIndexMobile
                  .clamp(0, bottomNavItems.length - 1),
              iconSize: 20,
              backgroundColor: AppColors.whiteColor,
              elevation: 1,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
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
