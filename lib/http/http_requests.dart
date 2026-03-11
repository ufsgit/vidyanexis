import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/http/http_urls.dart';

class HttpRequest {
  static SidebarProvider get sideBarProvider =>
      Provider.of<SidebarProvider>(navigatorKey.currentState!.context,
          listen: false);

  static Dio _getDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    if (!kIsWeb) {
      try {
        (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };
      } catch (e) {
        if (kDebugMode) {
          print("Error configuring Dio adapter: $e");
        }
      }
    }
    return dio;
  }

  static Future<Response> httpGetRequest(
      {Map<String, dynamic>? bodyData,
      String endPoint = '',
      bool returnBytes = false}) async {
    if (kDebugMode) {
      print('get request ====> $endPoint $bodyData ');
    }

    final Dio dio = _getDio();
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token') ?? "";
    print(token);

    try {
      final response = await dio.get(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }, responseType: returnBytes ? ResponseType.bytes : ResponseType.json),
        queryParameters: bodyData,
      );

      if (kDebugMode) {
        print('get result $endPoint ====> $response  ');
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Request failed: $e');
      }
      return Response(
        requestOptions: RequestOptions(path: endPoint),
        statusCode: 0,
        statusMessage: e.toString(),
      );
    }
  }

  static Future<Response?> httpPostRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('post request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();
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
      if (e is DioException) {
        if (e.response?.statusCode == 504 ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          throw Exception("Server timeout");
        }
      }
      if (kDebugMode) {
        print('Request failed: $e');
      }
      rethrow;
    }
  }

  static Future<Response?> httpDeleteRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('delete request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();
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
      return Response(
        requestOptions: RequestOptions(path: endPoint),
        statusCode: 0,
        statusMessage: e.toString(),
      );
    }
  }

  static Future<Response?> httpPutRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('put request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();
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
      return Response(
        requestOptions: RequestOptions(path: endPoint),
        statusCode: 0,
        statusMessage: e.toString(),
      );
    }
  }

  static Future<Response?> httpPutParamRequest(
      {Map<String, dynamic>? bodyData, String endPoint = ''}) async {
    if (kDebugMode) {
      print('put request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();
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
