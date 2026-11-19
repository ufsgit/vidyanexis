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

  static final Dio _dioInstance = _createDio();

  static String? _cachedToken;

  static Future<String> _getToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken!;
    }
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString('token') ?? "";
    return _cachedToken!;
  }

  static Future<String> getToken() => _getToken();

  static void setCachedToken(String token) {
    _cachedToken = token;
  }

  static void updateCachedToken(String token) {
    _cachedToken = token;
  }

  static void clearCachedToken() {
    _cachedToken = null;
  }

  static Dio _createDio() {
    final Dio dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 25),
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

  static Dio _getDio() => _dioInstance;

  static Future<Response> httpGetRequest(
      {Map<String, dynamic>? bodyData,
      String endPoint = '',
      bool returnBytes = false,
      int? menuId}) async {
    if (kDebugMode) {
      print('get request ====> $endPoint $bodyData ');
    }

    final Dio dio = _getDio();

    final String token = await _getToken();


    try {
      final String url = endPoint.startsWith('http')
          ? endPoint
          : '${HttpUrls.baseUrl}$endPoint';
      final response = await dio.get(
        url,
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
          "menuId": menuId ?? sideBarProvider.menuId
        }, responseType: returnBytes ? ResponseType.bytes : ResponseType.json),
        queryParameters: bodyData,
      );

      if (kDebugMode) {
        final str = response.data?.toString() ?? '';
        print('get result $endPoint ====> ${str.length > 200 ? '${str.substring(0, 200)}... (length: ${str.length})' : str}');
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
      {Map<String, dynamic>? bodyData, String endPoint = '', int? menuId}) async {
    if (kDebugMode) {
      print('post request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();

    final String token = await _getToken();


    try {
      final Response response = await dio.post(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
          "menuId": menuId ?? sideBarProvider.menuId
        }),
        data: bodyData,
      );
      if (kDebugMode) {
        final str = response.data?.toString() ?? '';
        print('post result  $endPoint ====> ${str.length > 200 ? '${str.substring(0, 200)}... (length: ${str.length})' : str}');
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
      {Map<String, dynamic>? bodyData, String endPoint = '', int? menuId}) async {
    if (kDebugMode) {
      print('delete request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();

    final String token = await _getToken();


    try {
      final Response response = await dio.delete(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
          "menuId": menuId ?? sideBarProvider.menuId
        }),
        data: bodyData,
      );
      if (kDebugMode) {
        final str = response.data?.toString() ?? '';
        print('delete result $endPoint ====> ${str.length > 200 ? '${str.substring(0, 200)}... (length: ${str.length})' : str}');
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
      {Map<String, dynamic>? bodyData, String endPoint = '', int? menuId}) async {
    if (kDebugMode) {
      print('put request ====> $endPoint $bodyData');
    }
    final Dio dio = _getDio();

    final String token = await _getToken();


    try {
      final Response response = await dio.put(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
          "menuId": menuId ?? sideBarProvider.menuId
        }),
        data: bodyData, // data remains the same
      );
      if (kDebugMode) {
        final str = response.data?.toString() ?? '';
        print('put result  $endPoint ====> ${str.length > 200 ? '${str.substring(0, 200)}... (length: ${str.length})' : str}');
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

    final String token = await _getToken();


    try {
      final Response response = await dio.put(
        '${HttpUrls.baseUrl}$endPoint',
        options: Options(headers: {
          'ngrok-skip-browser-warning': 'true',
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
          "menuId": sideBarProvider.menuId
        }),
        queryParameters: bodyData,
      );
      if (kDebugMode) {
        final str = response.data?.toString() ?? '';
        print('put result  $endPoint ====> ${str.length > 200 ? '${str.substring(0, 200)}... (length: ${str.length})' : str}');
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
