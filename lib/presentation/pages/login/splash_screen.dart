import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/company_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/presentation/pages/login/company_code_page.dart';
import 'package:vidyanexis/presentation/pages/login/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isCompanyCode) {
        final companyProvider =
            Provider.of<CompanyProvider>(context, listen: false);

        // Load settings first (this is already done in constructor, but double check)
        await companyProvider.loadSettings();

        if (companyProvider.baseUrl.isEmpty) {
          if (mounted) {
            context.go(CompanyCodePage.route);
          }
          return;
        }
      }

      // final settingsProvider =
      //     Provider.of<SettingsProvider>(context, listen: false);
      // await settingsProvider.getCompanyDetails();
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    print('[PERF-BOOT] auth/session started');

    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('IsLoggedIn') ?? false;
    final sessionRestoredTime = DateTime.now().millisecondsSinceEpoch - startTime;
    print('[PERF-BOOT] auth/session completed: $sessionRestoredTime ms (isLoggedIn=$isLoggedIn)');

    print('[PERF-BOOT] route resolution started');
    if (isLoggedIn) {
      if (mounted) {
        context.go(HomePage.route);
        print('[PERF-BOOT] route resolution completed: ${DateTime.now().millisecondsSinceEpoch - startTime} ms');
      }
    } else {
      if (mounted) {
        context.go(LoginPage.route);
        print('[PERF-BOOT] route resolution completed: ${DateTime.now().millisecondsSinceEpoch - startTime} ms');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final displayLogo = settingsProvider.displayLogo;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: displayLogo.startsWith('http')
                          ? Image.network(
                              displayLogo,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppStyles.logo(),
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.contain,
                                );
                              },
                            )
                          : Image.asset(
                              displayLogo,
                              height: 150,
                              width: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container();
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  settingsProvider.displayTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
