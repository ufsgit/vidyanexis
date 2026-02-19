import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/payment_report_model.dart';
import 'package:vidyanexis/controller/models/upcoming_payment_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class PaymentReportProvider with ChangeNotifier {
  List<PaymentReportModel> paymentReportList = [];
  List<UpcomingPaymentReportModel> upcomingPaymentReportList = [];
  bool isLoading = false;
  bool isUpcomingLoading = false;
  String searchText = '';

  // Filters
  DateTime? fromDate;
  DateTime? toDate;
  int? selectedCustomerId;
  String? selectedCustomerName;
  bool isFilter = false;

  int pageNo = 1;
  int pageSize = 1000;

  Future<void> getPaymentReport(BuildContext context) async {
    isLoading = true;
    notifyListeners();

    // Default dates if null
    if (fromDate == null) {
      var now = DateTime.now();
      fromDate = DateTime(now.year, now.month, 1);
      toDate = DateTime(now.year, now.month + 1, 0);
    }
    formatDate();

    final url = Uri.parse(
        '${HttpUrls.baseUrl}${HttpUrls.getPaymentReport}?From_Date=$formattedFromDate&To_Date=$formattedToDate&Is_Date_Check=1&Customer_Name=$searchText');

    print('Payment Report Request: $url');

    try {
      // Check token first as 401 indicates unauthorized
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? "";
      print('Using Token: $token');

      // Note: http.get uses the HttpRequest class which handles headers including Authorization
      // Make sure the token is being passed correctly in HttpRequest.httpGetRequest if using that helper,
      // but here we are using http.get directly? No, we previously used http.get(url).
      // Wait, the previous code imported 'package:http/http.dart' as http;
      // BUT there is a HttpRequest helper class in the project at 'package:vidyanexis/http/http_requests.dart'.
      // If we use standard http.get, we must manually add headers.
      // If we use HttpRequest.httpGetRequest, it adds headers for us.

      // The current code uses: import 'package:http/http.dart' as http;
      // And calls: final response = await http.get(url);
      // This DOES NOT add the Authorization header, hence the 401 error!

      // I need to use the project's helper class HttpRequest or add headers manually.
      // Given the file imports, I should probably switch to using the helper class or add headers manually.
      // Adding headers manually is safer if I don't want to change imports too much,
      // but using the helper is more consistent with the project.

      // Let's add headers manually first to fix the immediate 401.
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Payment Report Response: $data');
        if (data['total'] is Map) {
          // Wrap single object in list if response structure changed to single object as per user request example
          // But usually list is expected. The user example showed "total": {...} which looks like summary or single item.
          // Assuming the list is somewhere or modifying based on user provided JSON:
          /*
            User provided JSON:
            {
              "total": {
                "Customer_Name": "neww test ",
                "Payment_Date": "2026-02-18",
                "Payment_Mode_Name": "Cash",
                "Paying_Amount": "6789.000"
              }
            }
           */
          // It seems the user wants to handle this specific structure.
          // If 'total' is the list wrapper (unlikely name for list) or just a single summary object?
          // The user said "this is the json fix the error".
          // If the API returns a list under a key, we need that key.
          // If the API returns a single object under "total", we might need to treat it as a list of 1 or look for the actual list key.
          // However, usually 'total' implies summary.
          // Let's check if there is a 'list' key or if we should parse 'total' as the data.
          // Given the ambiguity, I will try to handle both or the specific structure provided.

          if (data['list'] != null && data['list'] is List) {
            paymentReportList = (data['list'] as List)
                .map((e) => PaymentReportModel.fromJson(e))
                .toList();
          } else if (data['total'] != null) {
            // Fallback to usage of 'total' as a single item list if 'list' is missing,
            // OR maybe the user meant the response contains a 'total' field AND a list?
            // Let's assume standard list processing but if emptiness, check for this specific structure.
            // Actually, the user request says "changed api post to get ... thise is the json fix the error".
            // It implies the response format might have changed or they are seeing this specific response.
            // If the API now returns `{"total": {...}}`, it might just be the summary or a single record.
            // I'll stick to robust parsing: check for 'list', if not found, check if root or 'total' can be parsed.

            // BUT, typically 'total' is a summary object.
            // Let's try to find a list. If not, maybe the 'total' IS the data (weird naming).

            // Let's implement a robust check.
            List<dynamic> listData = [];
            if (data['list'] is List) {
              listData = data['list'];
            } else if (data['total'] is Map) {
              // Treat as single item list for now if that's what's returned
              listData = [data['total']];
            }

            paymentReportList =
                listData.map((e) => PaymentReportModel.fromJson(e)).toList();
          } else {
            paymentReportList = [];
          }
        } else if (data is List) {
          paymentReportList =
              (data).map((e) => PaymentReportModel.fromJson(e)).toList();
        } else {
          // Try to parse 'list' from root if it exists
          if (data['list'] is List) {
            paymentReportList = (data['list'] as List)
                .map((e) => PaymentReportModel.fromJson(e))
                .toList();
          } else {
            paymentReportList = [];
          }
        }
      } else {
        paymentReportList = [];
        print('Failed to load payment report: ${response.statusCode}');
      }
    } catch (e) {
      paymentReportList = [];
      print('Error fetching payment report: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getUpcomingPaymentReport(BuildContext context) async {
    isUpcomingLoading = true;
    notifyListeners();

    // Default dates if null
    if (fromDate == null) {
      var now = DateTime.now();
      fromDate = DateTime(now.year, now.month, 1);
      toDate = DateTime(now.year, now.month + 1, 0);
    }
    formatDate();

    String isDate = "1"; // Default to check date as per standard logic

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.upcomingPaymentReport}?Is_Date_Check=$isDate&Fromdate=$formattedFromDate&Todate=$formattedToDate&Customer_Name=$searchText');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Upcoming Payment Report Response: $data');

        if (data != null) {
          if (data is List) {
            upcomingPaymentReportList = data
                .map((e) => UpcomingPaymentReportModel.fromJson(e))
                .toList();
          } else if (data is Map && data['data'] is List) {
            upcomingPaymentReportList = (data['data'] as List)
                .map((e) => UpcomingPaymentReportModel.fromJson(e))
                .toList();
          } else {
            upcomingPaymentReportList = [];
          }
        } else {
          upcomingPaymentReportList = [];
        }
      } else {
        upcomingPaymentReportList = [];
        print('Failed to load upcoming payment report: ${response.statusCode}');
      }
    } catch (e) {
      upcomingPaymentReportList = [];
      print('Error fetching upcoming payment report: $e');
    } finally {
      isUpcomingLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    searchText = query;
    notifyListeners();
  }

  void setDateRange(DateTime start, DateTime end) {
    fromDate = start;
    toDate = end;
    notifyListeners();
  }

  void setCustomer(int? id, String? name) {
    selectedCustomerId = id;
    selectedCustomerName = name;
    notifyListeners();
  }

  void toggleFilter() {
    isFilter = !isFilter;
    notifyListeners();
  }

  int? selectedDateFilterIndex;
  String _formattedFromDate = '';
  String _formattedToDate = '';

  String get formattedFromDate => _formattedFromDate.isNotEmpty
      ? _formattedFromDate
      : (fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '');

  String get formattedToDate => _formattedToDate.isNotEmpty
      ? _formattedToDate
      : (toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '');

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFromDate) {
        fromDate = picked;
      } else {
        toDate = picked;
      }
      formatDate();
      notifyListeners();
    }
  }

  void selectDateFilterOption(int? index) {
    selectedDateFilterIndex = index;
    if (index == null) {
      fromDate = null;
      toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
    } else {
      formatDate();
    }
    notifyListeners();
  }

  void formatDate() {
    if (fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    } else {
      _formattedFromDate = '';
    }

    if (toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      _formattedToDate = '';
    }
  }

  void setDateFilter(String title) {
    final now = DateTime.now();
    switch (title) {
      case 'Yesterday':
        fromDate = now.subtract(const Duration(days: 1));
        toDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        fromDate = now;
        toDate = now;
        break;
      case 'Tomorrow':
        fromDate = now.add(const Duration(days: 1));
        toDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        fromDate = now.subtract(Duration(days: now.weekday - 1));
        toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        fromDate = DateTime(now.year, now.month, 1);
        toDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        fromDate = null;
        toDate = null;
    }
    formatDate();
    notifyListeners();
  }
}
