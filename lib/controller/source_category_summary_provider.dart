import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/source_category_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class SourceCategorySummaryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  // Search keyword
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Selected dropdown filters
  String? _selectedParentCategory;
  String? get selectedParentCategory => _selectedParentCategory;

  String? _selectedEnquirySource;
  String? get selectedEnquirySource => _selectedEnquirySource;

  // Selected date range options
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  DateTime? _fromDate;
  DateTime? get fromDate => _fromDate;

  DateTime? _toDate;
  DateTime? get toDate => _toDate;

  String _formattedFromDate = '';
  String get formattedFromDate => _formattedFromDate;

  String _formattedToDate = '';
  String get formattedToDate => _formattedToDate;

  // Live and filtered data lists
  List<SourceCategorySummaryModel> _rawList = [];
  List<SourceCategorySummaryModel> _filteredList = [];

  List<SourceCategorySummaryModel> get sourceCategoryReport => _filteredList;

  // KPI Totals
  int get totalLeadsCount => _filteredList.length;

  double get totalProjectCost {
    return _filteredList.fold(0.0, (sum, item) => sum + item.projectCost);
  }

  double get totalCommissionAmount {
    return _filteredList.fold(0.0, (sum, item) => sum + item.commissionAmount);
  }

  double get avgCommissionPercentage {
    if (_filteredList.isEmpty) return 0.0;
    final totalPercentage =
        _filteredList.fold(0.0, (sum, item) => sum + item.commissionPercentage);
    return totalPercentage / _filteredList.length;
  }

  // Unique lists for dropdowns
  List<String> get uniqueParentCategories {
    final set = <String>{};
    for (var item in _rawList) {
      if (item.parentEnquirySource.trim().isNotEmpty) {
        set.add(item.parentEnquirySource.trim());
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> get uniqueEnquirySources {
    final set = <String>{};
    for (var item in _rawList) {
      if (item.enquirySource.trim().isNotEmpty) {
        set.add(item.enquirySource.trim());
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  SourceCategorySummaryProvider() {
    _initDefaultDates();
  }

  void _initDefaultDates() {
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
    _formatDates();
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setParentCategoryFilter(String? parentCategory) {
    _selectedParentCategory = parentCategory;
    _applyFilters();
  }

  void setEnquirySourceFilter(String? enquirySource) {
    _selectedEnquirySource = enquirySource;
    _applyFilters();
  }

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    if (index != null) {
      setDateFilterByIndex(index);
    }
    notifyListeners();
  }

  void setDateFilterByIndex(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0: // Yesterday
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 1: // Today
        _fromDate = now;
        _toDate = now;
        break;
      case 2: // Tomorrow
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 3: // This Week
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 4: // This Month
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        break;
    }
    _formatDates();
  }

  void _formatDates() {
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    } else {
      _formattedFromDate = '';
    }
    if (_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
    } else {
      _formattedToDate = '';
    }
  }

  String get displayFromDate {
    if (_fromDate != null) {
      return DateFormat('dd-MM-yyyy').format(_fromDate!);
    }
    return '';
  }

  String get displayToDate {
    if (_toDate != null) {
      return DateFormat('dd-MM-yyyy').format(_toDate!);
    }
    return '';
  }

  Future<void> selectCustomDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isFromDate) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      _selectedDateFilterIndex = null;
      _formatDates();
      notifyListeners();
    }
  }

  void clearAllFilters() {
    _searchQuery = '';
    _selectedParentCategory = null;
    _selectedEnquirySource = null;
    _selectedDateFilterIndex = null;
    _initDefaultDates();
    _applyFilters();
  }

  void resetFilters(BuildContext context) {
    clearAllFilters();
    getSourceCategorySummary(context);
  }

  List<dynamic> _extractList(dynamic resData) {
    if (resData == null) return [];
    if (resData is String) {
      try {
        resData = jsonDecode(resData);
      } catch (_) {
        return [];
      }
    }
    if (resData is Map) {
      if (resData['data'] != null && resData['data'] is List) {
        return resData['data'] as List<dynamic>;
      } else if (resData['Data'] != null && resData['Data'] is List) {
        return resData['Data'] as List<dynamic>;
      }
    } else if (resData is List) {
      return resData;
    }
    return [];
  }

  // Fetch Source Category Summary Report from API
  Future<void> getSourceCategorySummary(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      Loader.showLoader(context);
    } catch (_) {}

    _formatDates();
    final fromDateParam = _formattedFromDate;
    final toDateParam = _formattedToDate;

    try {
      String queryParams = '';
      if (fromDateParam.isNotEmpty && toDateParam.isNotEmpty) {
        queryParams =
            '?From_Date=$fromDateParam&To_Date=$toDateParam&from_date=$fromDateParam&to_date=$toDateParam';
      }

      // 1. Try primary endpoint Source_Category_Summary with menuId: 218
      var response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.sourceCategorySummary}$queryParams',
        menuId: 218,
      );

      List<dynamic> list = _extractList(response.data);

      // 2. If empty or failed, try Source_Category_Summary without query parameters
      if (list.isEmpty && queryParams.isNotEmpty) {
        final fallbackResponse = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.sourceCategorySummary,
          menuId: 218,
        );
        final fallbackList = _extractList(fallbackResponse.data);
        if (fallbackList.isNotEmpty) {
          response = fallbackResponse;
          list = fallbackList;
        }
      }

      // 3. If still empty, try lead/Source_Category_Summary fallback
      if (list.isEmpty) {
        final leadResponse = await HttpRequest.httpGetRequest(
          endPoint: 'lead/${HttpUrls.sourceCategorySummary}$queryParams',
          menuId: 218,
        );
        final leadList = _extractList(leadResponse.data);
        if (leadList.isNotEmpty) {
          response = leadResponse;
          list = leadList;
        } else if (queryParams.isNotEmpty) {
          final leadNoQueryResponse = await HttpRequest.httpGetRequest(
            endPoint: 'lead/${HttpUrls.sourceCategorySummary}',
            menuId: 218,
          );
          final leadNoQueryList = _extractList(leadNoQueryResponse.data);
          if (leadNoQueryList.isNotEmpty) {
            response = leadNoQueryResponse;
            list = leadNoQueryList;
          }
        }
      }

      if (list.isNotEmpty) {
        _rawList = list
            .map((item) => SourceCategorySummaryModel.fromJson(
                item as Map<String, dynamic>))
            .toList();
      } else {
        _rawList = [];
        if (response.statusCode != 200 && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Server response: ${response.statusCode} - ${response.statusMessage ?? "No data"}'),
            ),
          );
        }
      }
    } catch (e) {
      print('Exception in getSourceCategorySummary: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report: $e')),
        );
      }
    } finally {
      try {
        Loader.stopLoader(context);
      } catch (_) {}
      _isLoading = false;
      _applyFilters();
    }
  }

  void _applyFilters() {
    _filteredList = _rawList.where((item) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchLead = item.leadName.toLowerCase().contains(q);
        final matchSource = item.enquirySource.toLowerCase().contains(q);
        final matchParent = item.parentEnquirySource.toLowerCase().contains(q);
        if (!matchLead && !matchSource && !matchParent) {
          return false;
        }
      }

      // Parent category filter
      if (_selectedParentCategory != null &&
          _selectedParentCategory!.isNotEmpty) {
        if (item.parentEnquirySource != _selectedParentCategory) {
          return false;
        }
      }

      // Enquiry source filter
      if (_selectedEnquirySource != null &&
          _selectedEnquirySource!.isNotEmpty) {
        if (item.enquirySource != _selectedEnquirySource) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }
}
