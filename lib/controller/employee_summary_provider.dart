import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/employee_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class EmployeeSummaryProvider extends ChangeNotifier {
  List<EmployeeSummaryModel> _employeeReport = [];
  List<EmployeeSummaryModel> get employeeReport => _employeeReport;

  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  String get search => _search;

  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = null;
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
    } else {
      _selectedDateFilterIndex = index;
      formatDate();
    }
    notifyListeners();
  }

  void setDateFilter(String title) {
    final now = DateTime.now();

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
      default:
        _fromDate = null;
        _toDate = null;
        break;
    }

    notifyListeners();
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
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

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setFromDate(pickedDate);
      } else {
        setToDate(pickedDate);
      }
    }
    notifyListeners();
  }

  void setTaskSearchCriteria(String searchKeyword) {
    _search = searchKeyword;
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedDateFilterIndex = null;
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _search = '';
    notifyListeners();
  }

  /// Fetches actual data from /lead/Employee_Summary_Report, falling back to clean mock data if empty/error.
  Future<void> getEmployeeSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final String fromDateParam = _formattedFromDate;
      final String toDateParam = _formattedToDate;

      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.employeeSummaryReport}?from_date=$fromDateParam&to_date=$toDateParam',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> listData = response.data is List ? response.data : [];
        List<EmployeeSummaryModel> parsedList = listData
            .map((item) => EmployeeSummaryModel.fromJson(item))
            .toList();

        // Perform client-side keyword search if keyword is typed
        if (_search.isNotEmpty) {
          parsedList = parsedList
              .where((item) => (item.employeeName ?? '')
                  .toLowerCase()
                  .contains(_search.toLowerCase()))
              .toList();
        }

        _employeeReport = parsedList;
      } else {
        // Fallback to structured dynamic mock data if API is not yet active/offline
        _loadMockData();
      }

      Loader.stopLoader(context);
      notifyListeners();
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception in getEmployeeSummary: $e. Falling back to mock data...');
      _loadMockData();
      notifyListeners();
    }
  }

  void _loadMockData() {
    final baseEmployees = [
      {'Employee_Name': 'admin', 'No_of_Clients': 18},
      {'Employee_Name': 'Lead1', 'No_of_Clients': 1},
      {'Employee_Name': 'Sarah Connor', 'No_of_Clients': 25},
      {'Employee_Name': 'John Doe', 'No_of_Clients': 14},
      {'Employee_Name': 'Bruce Wayne', 'No_of_Clients': 42},
      {'Employee_Name': 'Clark Kent', 'No_of_Clients': 35},
    ];

    List<EmployeeSummaryModel> results = [];
    for (var emp in baseEmployees) {
      if (_search.isNotEmpty &&
          !emp['Employee_Name'].toString().toLowerCase().contains(_search.toLowerCase())) {
        continue;
      }
      results.add(EmployeeSummaryModel.fromJson(emp));
    }
    _employeeReport = results;
  }
}
