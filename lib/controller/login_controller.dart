import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';
import 'package:vidyanexis/controller/location_tracking_provider.dart';
import 'package:vidyanexis/helpers/location_tracking_service.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:vidyanexis/main.dart';

class LoginController extends ChangeNotifier {
  String _userName = '';
  bool _loggedIn = false;
  bool _passwordVisible = false;

  final TextEditingController passWordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  String get userNamee => _userName;
  bool get loggedIn => _loggedIn;
  bool get passwordVisible => _passwordVisible;

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void login({
    required BuildContext context,
    required String userName,
    required String passWord,
  }) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.loginCheck,
          bodyData: {"userName": userName, "password": passWord});

      final BuildContext safeContext = navigatorKey.currentContext ?? context;
      if (!safeContext.mounted) return;

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (!AppStyles.isWebScreen(safeContext)) {
          final allowAppLogin = data['Allow_App_Login']?.toString() ?? '0';
          if (allowAppLogin == '0' || allowAppLogin == 'false') {
            navigatorKey.currentState?.showSnackBar(
              SnackBar(
                content: const Center(
                    child: Text('App access is disabled for your account')),
                backgroundColor: Colors.red.shade400,
                duration: const Duration(seconds: 3),
              ),
            );
            Loader.stopLoader(safeContext);
            return;
          }
        }

        preferences.setString('token', data['token'].toString());
        preferences.setString('userName', data['User_Details_Name'].toString());
        preferences.setString('userId', data['User_Details_Id'].toString());
        preferences.setString('userType', data['User_Type_Id'].toString());
        preferences.setString(
            'userTypeName', data['User_Type_Name']?.toString() ?? '');
        preferences.setString('branchId', data['Branch_Id'].toString());
        preferences.setString('branchName', data['Branch_Name'].toString());
        preferences.setString('departmentId', data['Department_Id'].toString());
        preferences.setString(
            'departmentName', data['Department_Name'].toString());

        passWordController.clear();
        userNameController.clear();
        _userName = userName;

        if (data['User_Details_Id'] != null) {
          _loggedIn = true;
          preferences.setBool('IsLoggedIn', loggedIn);
          final provider = Provider.of<SidebarProvider>(safeContext, listen: false);
          provider.setMenuId(0, 0);

          // Initiate location tracking for the newly authenticated employee session
          try {
            final locationProvider =
                Provider.of<LocationTrackingProvider>(safeContext, listen: false);
            locationProvider.startTracking(safeContext);
          } catch (e) {
            if (kDebugMode) {
              print('Location tracking auto-start note on login: $e');
            }
          }

          context.go(HomePage.route);
          log('Login Success');
        } else {
          navigatorKey.currentState?.showSnackBar(
            SnackBar(
              content: const Center(child: Text('Invalid Login')),
              backgroundColor: Colors.red.shade400,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        Loader.stopLoader(safeContext);
        notifyListeners();
        print(data);
      } else {
        showErrorSnackBar(safeContext,
            response?.statusCode == 0 ? response?.statusMessage : response);
        Loader.stopLoader(safeContext);
      }
    } catch (e) {
      print('Exception occurred: $e');
      final BuildContext safeContext = navigatorKey.currentContext ?? context;
      if (safeContext.mounted) {
        showErrorSnackBar(safeContext, e);
        Loader.stopLoader(safeContext);
      }
    }
  }

  Future<void> logout({required int userId}) async {
    try {
      final locationService = LocationTrackingService();
      await locationService.stopTracking();
    } catch (e) {
      if (kDebugMode) {
        print('Exception stopping location tracking during logout: $e');
      }
    }
  }
}
