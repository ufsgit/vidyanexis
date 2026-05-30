import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/http_requests.dart';

class CompanyProvider extends ChangeNotifier {
  String _baseUrl = '';
  String _companyCode = '';
  bool _isLoading = false;

  String get baseUrl => _baseUrl;
  String get companyCode => _companyCode;
  bool get isLoading => _isLoading;

  CompanyProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('company_base_url') ?? '';
    _companyCode = prefs.getString('company_code') ?? '';

    if (_baseUrl.isNotEmpty) {
      HttpUrls.updateBaseUrl(_baseUrl);
    }
    notifyListeners();
  }

  Future<bool> validateCompanyCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      // // Hardcoded overrides for testing
      // if (code.toLowerCase() == 'code1') {
      //   _setTargetUrl('https://2jw4dwnj-3512.inc1.devtunnels.ms/', code);
      //   return true;
      // } else if (code.toLowerCase() == 'code2') {
      //   _setTargetUrl('https://demo3api.trackbox.net.in/', code);
      //   return true;
      // }

      // Real API call
      final response = await HttpRequest.httpGetRequest(
        endPoint: "${HttpUrls.getCompanyUrl}?CompanyCode=$code",
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['success'] == true) {
          String? targetUrl;

          // Handle the actual response structure
          if (data['company_url'] != null &&
              data['company_url'] is List &&
              (data['company_url'] as List).isNotEmpty) {
            final companyList = data['company_url'] as List;
            targetUrl = companyList.first['CompanyUrl'] ?? '';
          } else if (data['CompanyUrl'] != null) {
            targetUrl = data['CompanyUrl'].toString();
          }

          if (targetUrl != null && targetUrl.isNotEmpty) {
            await _setTargetUrl(targetUrl, code);
            return true;
          }
        }
      }
    } catch (e) {
      print('Error validating company code: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _setTargetUrl(String targetUrl, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('company_base_url', targetUrl);
    await prefs.setString('company_code', code);

    _baseUrl = targetUrl;
    _companyCode = code;
    HttpUrls.updateBaseUrl(targetUrl);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('company_base_url');
    await prefs.remove('company_code');
    _baseUrl = '';
    _companyCode = '';
    notifyListeners();
  }
}
