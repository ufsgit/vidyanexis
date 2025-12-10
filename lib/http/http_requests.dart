import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/http/http_urls.dart';

class HttpRequest {
  static final sideBarProvider = Provider.of<SidebarProvider>(
      navigatorKey.currentState!.context,
      listen: false);

  static Future<Response> httpGetRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('get request ====> $endPoint $bodyData ');
    }

    final Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    print(token);

    final response = await dio.get(
      '${HttpUrls.baseUrl}$endPoint',
      options: Options(headers: {
        'ngrok-skip-browser-warning': 'true',
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        "menuId": sideBarProvider.menuId
      }),
      queryParameters: bodyData,
    );

    if (kDebugMode) {
      print('get result $endPoint ====> $response  ');
    }

    return response;
  }

  static Future<Response?> httpPostRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('post request ====> $endPoint $bodyData');
    }
    final Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    try {
      final Response response = await dio.post(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }),
        data: bodyData,
      );
      if (kDebugMode) {
        print('post result  $endPoint ====> ${response.data}  ');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
      return null;
    }
  }

  static Future<Response?> httpDeleteRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('delete request ====> $endPoint $bodyData');
    }
    final Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    try {
      final Response response = await dio.delete(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }),
        data: bodyData,
      );
      if (kDebugMode) {
        print('delete result $endPoint ====> ${response.data}  ');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
      return null;
    }
  }

  static Future<Response?> httpPutRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('put request ====> $endPoint $bodyData');
    }
    final Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    try {
      final Response response = await dio.put(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }),
        data: bodyData, // data remains the same
      );
      if (kDebugMode) {
        print('put result  $endPoint ====> ${response.data}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
      return null;
    }
  }

  static Future<Response?> httpPutParamRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('put request ====> $endPoint $bodyData');
    }
    final Dio dio = Dio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";

    try {
      final Response response = await dio.put(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }),
        queryParameters: bodyData,
      );
      if (kDebugMode) {
        print('put result  $endPoint ====> ${response.data}');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
      return null;
    }
  }
}
