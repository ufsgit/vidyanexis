import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/payment_report_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';

class PaymentReportProvider with ChangeNotifier {
  List<PaymentReportModel> paymentReportList = [];
  bool isLoading = false;
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

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    int branchId = settingsProvider.selectedBranchId ?? 1;

    // Default dates if null
    if (fromDate == null) {
      var now = DateTime.now();
      fromDate = DateTime(now.year, now.month, 1);
      toDate = DateTime(now.year, now.month + 1, 0);
    }

    final url = Uri.parse(HttpUrls.baseUrl + HttpUrls.getPaymentReport);
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "From_Date": formattedFromDate,
      "To_Date": formattedToDate,
      "Customer_Id": selectedCustomerId ?? 0,
      "Branch_Id": branchId,
      "Payment_Mode_Id": 0,
      "Search_Text": searchText,
      "Page_No": pageNo,
      "Page_Size": pageSize
    });

    print('Payment Report Request: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Payment Report Response: $data');
        if (data['list'] is List) {
          paymentReportList = (data['list'] as List)
              .map((e) => PaymentReportModel.fromJson(e))
              .toList();
        } else {
          paymentReportList = [];
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
