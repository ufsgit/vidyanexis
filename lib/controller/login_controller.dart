import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/pages/home/homepage.dart';

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

      if (response!.statusCode == 200) {
        final data = response.data;
        preferences.setString('token', data['token'].toString());
        preferences.setString('userName', data['User_Details_Name'].toString());
        preferences.setString('userId', data['User_Details_Id'].toString());
        preferences.setString('userType', data['User_Type'].toString());
        passWordController.clear();
        userNameController.clear();
        _userName = userName;

        if (data['User_Details_Id'] != null) {
          _loggedIn = true;
          preferences.setBool('IsLoggedIn', loggedIn);
          final provider = Provider.of<SidebarProvider>(context, listen: false);
          provider.setMenuId(0, 0);
          context.go(HomePage.route);
          log('Login Success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Center(child: Text('Invalid Login')),
              backgroundColor: Colors.red.shade400,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        Loader.stopLoader(context);
        notifyListeners();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }
}
