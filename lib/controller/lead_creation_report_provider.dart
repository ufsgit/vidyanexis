import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/lead_creation_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class LeadCreationReportProvider extends ChangeNotifier {
  List<LeadCreationSummaryModel> _reports = [];
  List<LeadCreationSummaryModel> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  bool _isFilter = true;
  int? _selectedDateFilterIndex;

  bool get isFilter => _isFilter;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = 1; // Default to Today
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
    } else {
      _selectedDateFilterIndex = index;
    }
    notifyListeners();
  }

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  void setDateFilter(String title) {
    DateTime now = DateTime.now();
    switch (title) {
      case 'Yesterday':
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        _fromDate = now;
        _toDate = now;
        break;
      case 'Tomorrow':
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
    }
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      notifyListeners();
    }
  }

  void setDates(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void formatDate() {
    notifyListeners();
  }

  String get fromDateS => formattedFromDate;
  String get toDateS => formattedToDate;

  void clearFilters() {
    _fromDate = null;
    _toDate = null;
    _selectedDateFilterIndex = null;
    _reports = [];
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      Loader.showLoader(context);

      String isDate = "0";
      if (formattedFromDate.isNotEmpty || formattedToDate.isNotEmpty) {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.searchLeadCreatedReport}?Is_Date=$isDate&Fromdate=$formattedFromDate&Todate=$formattedToDate',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        log('Raw API Response Data: $data');
        if (data != null) {
          if (data is List) {
            _reports = data.map((item) => LeadCreationSummaryModel.fromJson(item)).toList();
          } else if (data is Map && data['Data'] is List) {
            _reports = (data['Data'] as List)
                .map((item) => LeadCreationSummaryModel.fromJson(item))
                .toList();
          } else {
            _reports = [];
          }
        } else {
          _reports = [];
        }
      } else {
        _reports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch lead creation reports')),
          );
        }
      }
    } catch (e) {
      log('Error fetching lead creation reports: $e');
      _reports = [];
    } finally {
      _isLoading = false;
      Loader.stopLoader(context);
      notifyListeners();
    }
  }
}
