import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/duplicate_entry_attempts_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class DuplicateEntryAttemptsProvider extends ChangeNotifier {
  List<DuplicateEntryAttemptsModel> _reports = [];

  List<DuplicateEntryAttemptsModel> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Date filter
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedDateFilterIndex = 1; // Today default

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  // Filter panel visibility
  bool _isFilter = true;
  bool get isFilter => _isFilter;

  // Selected user (User_Id)
  int? _selectedUserId;
  int? get selectedUserId => _selectedUserId;

  // Selected duplicate type filter
  String _selectedDuplicateType = '';
  String get selectedDuplicateType => _selectedDuplicateType;

  // Search query (now sent to API)
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ─── Pagination ───────────────────────────────────────────────────────────
  static const int pageSize = 10;

  int _startLimit = 1;
  int _endLimit = pageSize;
  int _totalCount = 0;
  int currentPage = 1;

  int get startLimit => _startLimit;
  int get endLimit => _endLimit;
  int get totalCount => _totalCount;

  int get totalPages =>
      _totalCount == 0 ? 1 : ((_totalCount - 1) ~/ pageSize) + 1;

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  void _updateLimitsFromPage() {
    _startLimit = ((currentPage - 1) * pageSize) + 1;
    _endLimit = currentPage * pageSize;
  }

  Future<void> fetchNextPage(BuildContext context) async {
    if (!hasNextPage) return;

    currentPage++;
    _updateLimitsFromPage();
    await fetchReports(context, isWebPagination: true);
  }

  Future<void> fetchPreviousPage(BuildContext context) async {
    if (!hasPreviousPage) return;

    currentPage--;
    _updateLimitsFromPage();
    await fetchReports(context, isWebPagination: true);
  }

  void resetPagination() {
    currentPage = 1;
    _updateLimitsFromPage();
  }

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'This Week',
    'This Month',
  ];

  final List<String> duplicateTypeOptions = [
    'All',
    'Phone',
    'Consumer',
    'Aadhaar',
  ];

  // ─── Filter Toggles ───────────────────────────────────────────────────────

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  /// Search is now sent to the API. Debounce on the UI side if needed.
  void setSearchQuery(String query, BuildContext context) {
    _searchQuery = query.trim();
    // Reset to page 1 and fetch from API
    resetPagination();
    fetchReports(context);
  }

  void setUserId(int? userId) {
    _selectedUserId = userId;
    notifyListeners();
  }

  void setDuplicateType(String type) {
    _selectedDuplicateType = type == 'All' ? '' : type;
    notifyListeners();
  }

  // ─── Date Filters ─────────────────────────────────────────────────────────

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  void setDateFilter(String title) {
    final now = DateTime.now();
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
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        _selectedDateFilterIndex = 2;
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        _selectedDateFilterIndex = 3;
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

  // ─── API Fetch ─────────────────────────────────────────────────────────────

  Future<void> fetchReports(BuildContext context,
      {bool isWebPagination = false}) async {
    try {
      if (!isWebPagination) {
        resetPagination();
      }

      _isLoading = true;
      notifyListeners();

      final url = '${HttpUrls.duplicateEntryAttemptsReport}'
          '?From_Date=$formattedFromDate'
          '&To_Date=$formattedToDate'
          '&User_Id=${int.tryParse(_selectedUserId?.toString() ?? "0") ?? 0}'
          '&Duplicate_Type=$_selectedDuplicateType'
          '&Page_Index1=$_startLimit'
          '&Page_Index2=$_endLimit'
          '&Search=$_searchQuery';

      log('Fetching Duplicate Entry Attempts Report URL: $url');

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map) {
          if (data['Total_Count'] != null) {
            _totalCount =
                int.tryParse(data['Total_Count']?.toString() ?? '0') ?? 0;
          }

          if (data['Data'] != null && data['Data'] is List) {
            _reports = (data['Data'] as List)
                .map((item) => DuplicateEntryAttemptsModel.fromJson(item))
                .toList();
          } else {
            _reports = [];
          }
        } else if (data != null && data is List) {
          _reports = data
              .map((item) => DuplicateEntryAttemptsModel.fromJson(item))
              .toList();
          if (_reports.length < pageSize) {
            _totalCount = ((currentPage - 1) * pageSize) + _reports.length;
          }
        } else {
          _reports = [];
        }
      } else {
        _reports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch duplicate entry attempts report'),
            ),
          );
        }
      }
    } catch (e) {
      log('Error fetching duplicate entry attempts report: $e');
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────

  void clearFilters(BuildContext context) {
    _fromDate = null;
    _toDate = null;
    _selectedUserId = null;
    _selectedDuplicateType = '';
    _searchQuery = '';
    _selectedDateFilterIndex = null;
    resetPagination();
    fetchReports(context);
  }
}
