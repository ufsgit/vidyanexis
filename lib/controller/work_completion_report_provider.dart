import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/work_completion_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class WorkCompletionReportProvider extends ChangeNotifier {
  List<WorkCompletionReportModel> _reports = [];
  List<WorkCompletionReportModel> _filteredReports = [];

  List<WorkCompletionReportModel> get reports => _filteredReports;
  List<WorkCompletionReportModel> get rawReports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? _toDate = DateTime.now();

  String _customerName = '';
  String _phoneNumber = '';
  String _searchQuery = '';
  bool _isFilter = false;
  bool _isSearch = false;
  int? _selectedDateFilterIndex = 4; // This Month

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get customerName => _customerName;
  String get phoneNumber => _phoneNumber;
  String get searchQuery => _searchQuery;
  bool get isFilter => _isFilter;
  bool get isSearch => _isSearch;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void toggleSearch() {
    _isSearch = !_isSearch;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredReports = List.from(_reports);
    } else {
      final q = _searchQuery.toLowerCase().trim();
      _filteredReports = _reports.where((item) {
        final dataStr = item.rawData.values.join(' ').toLowerCase();
        return dataStr.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  void setDateFilter(String title) {
    DateTime now = DateTime.now();
    switch (title) {
      case 'Yesterday':
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        _selectedDateFilterIndex = 0;
        break;
      case 'Today':
        _fromDate = now;
        _toDate = now;
        _selectedDateFilterIndex = 1;
        break;
      case 'Tomorrow':
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        _selectedDateFilterIndex = 2;
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        _selectedDateFilterIndex = 3;
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        _selectedDateFilterIndex = 4;
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
      _selectedDateFilterIndex = null;
      notifyListeners();
    }
  }

  void setDates(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      Loader.showLoader(context);

      final cName = Uri.encodeComponent(_customerName);
      final pNumber = Uri.encodeComponent(_phoneNumber);
      final url = '${HttpUrls.workCompletionReport}?Customer_Name=$cName&Phone_Number=$pNumber&Fromdate=$formattedFromDate&Todate=$formattedToDate';

      log('Fetching Work Completion Report URL: $url');

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          if (data.isNotEmpty && data.first is List) {
            _reports = (data.first as List)
                .map((item) => WorkCompletionReportModel.fromJson(item))
                .toList();
          } else {
            _reports =
                data.map((item) => WorkCompletionReportModel.fromJson(item)).toList();
          }
        } else if (data != null && data['data'] != null && data['data'] is List) {
          _reports = (data['data'] as List)
              .map((item) => WorkCompletionReportModel.fromJson(item))
              .toList();
        } else {
          _reports = [];
        }
      } else {
        _reports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch work completion report')),
          );
        }
      }
    } catch (e) {
      log('Error fetching work completion report: $e');
      _reports = [];
    } finally {
      _applySearch();
      _isLoading = false;
      Loader.stopLoader(context);
      notifyListeners();
    }
  }

  void clearFilters(BuildContext context) {
    _fromDate = null;
    _toDate = null;
    _customerName = '';
    _phoneNumber = '';
    _searchQuery = '';
    _selectedDateFilterIndex = null;
    fetchReports(context);
  }
}
