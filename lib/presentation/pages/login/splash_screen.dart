import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String logo = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.getCompanyDetails();
      logo = HttpUrls.imgBaseUrl + settingsProvider.logo;
      _checkLoginStatus();
      print(logo);
    });
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('IsLoggedIn') ?? false;
    print('Is Logged $isLoggedIn');
    if (isLoggedIn) {
      context.go(HomePage.route);
    } else {
      context.go(LoginPage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.textBlue800,
                  AppColors.secondaryBlue,
                  const Color.fromARGB(255, 0, 19, 68),
                ],
              ),
            ),
          ),
          Center(
              child: Image.network(
            logo,
            errorBuilder: (context, error, stackTrace) {
              return Container();
            },
          )),
        ],
      ),
    );
  }
}
