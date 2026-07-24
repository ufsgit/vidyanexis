import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/deleted_lead_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class DeletedLeadReportProvider extends ChangeNotifier {
  List<DeletedLeadReportModel> _reports = [];
  List<DeletedLeadReportModel> _filteredReports = [];

  List<DeletedLeadReportModel> get reports => _filteredReports;
  List<DeletedLeadReportModel> get rawReports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();

  String? _selectedUserName;
  String _searchQuery = '';
  bool _isFilter = true;
  int? _selectedDateFilterIndex = 1; // Today default

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String? get selectedUserName => _selectedUserName;
  String get searchQuery => _searchQuery;
  bool get isFilter => _isFilter;
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
        final leadId = item.leadId?.toString() ?? '';
        final custName = item.customerName?.toLowerCase() ?? '';
        final uName = item.userName?.toLowerCase() ?? '';
        return leadId.contains(q) || custName.contains(q) || uName.contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void setUserName(String? userName) {
    _selectedUserName = userName;
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

      final userNameParam = _selectedUserName ?? '';
      final url =
          '${HttpUrls.deletedLeadReport}?User_Name=${Uri.encodeComponent(userNameParam)}&Fromdate=$formattedFromDate&Todate=$formattedToDate';

      log('Fetching Deleted Lead Report URL: $url');

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _reports =
              data.map((item) => DeletedLeadReportModel.fromJson(item)).toList();
        } else if (data != null && data['data'] != null && data['data'] is List) {
          _reports = (data['data'] as List)
              .map((item) => DeletedLeadReportModel.fromJson(item))
              .toList();
        } else {
          _reports = [];
        }
      } else {
        _reports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch deleted lead report')),
          );
        }
      }
    } catch (e) {
      log('Error fetching deleted lead report: $e');
      _reports = [];
    } finally {
      _applySearch();
      _isLoading = false;
      Loader.stopLoader(context);
      notifyListeners();
    }
  }

  void clearFilters(BuildContext context) {
    final now = DateTime.now();
    _fromDate = now;
    _toDate = now;
    _selectedUserName = null;
    _searchQuery = '';
    _selectedDateFilterIndex = 1;
    fetchReports(context);
  }
}
