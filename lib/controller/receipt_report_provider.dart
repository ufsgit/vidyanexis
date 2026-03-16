import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/receipt_report_model.dart';
import 'package:vidyanexis/http/http_urls.dart';

class ReceiptReportProvider with ChangeNotifier {
  List<ReceiptReportModel> receiptReportList = [];
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

  Future<void> getReceiptReport(BuildContext context) async {
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
        '${HttpUrls.baseUrl}${HttpUrls.searchReceiptReport}?Fromdate=$formattedFromDate&Todate=$formattedToDate&Is_Date_Check=1&Customer_Name=$searchText');

    print('Receipt Report Request: $url');

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? "";

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Receipt Report Response: $data');
        
        List<dynamic> listData = [];
        if (data is List) {
          listData = data;
        } else if (data is Map) {
          if (data['list'] is List) {
            listData = data['list'];
          } else if (data['total'] is Map) {
             listData = [data['total']];
          } else if (data['data'] is List) {
            listData = data['data'];
          }
        }

        receiptReportList = listData.map((e) => ReceiptReportModel.fromJson(e)).toList();
      } else {
        receiptReportList = [];
        print('Failed to load receipt report: ${response.statusCode}');
      }
    } catch (e) {
      receiptReportList = [];
      print('Error fetching receipt report: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    searchText = query;
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
