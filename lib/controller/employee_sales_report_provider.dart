import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/employee_sales_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class EmployeeSalesReportProvider extends ChangeNotifier {
  List<EmployeeSalesReportModel> _salesReport = [];
  List<EmployeeSalesReportModel> get salesReport => _salesReport;

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

  /// Fetches data from /lead/Employee_Sales_Report, with no dummy data fallback.
  Future<void> getEmployeeSalesReport(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final String fromDateParam = _formattedFromDate;
      final String toDateParam = _formattedToDate;

      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final String userId = preferences.getString('userId') ?? "0";

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.employeeSalesReport}?Fromdate=$fromDateParam&Todate=$toDateParam&User_Details_Id=$userId',
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> listData = [];
        if (response.data is Map && response.data['data'] != null) {
          listData = response.data['data'] is List ? response.data['data'] : [];
        } else if (response.data is List) {
          listData = response.data;
        }

        List<EmployeeSalesReportModel> parsedList = listData
            .map((item) => EmployeeSalesReportModel.fromJson(item))
            .toList();

        // Perform client-side keyword search if keyword is typed
        if (_search.isNotEmpty) {
          parsedList = parsedList
              .where((item) => (item.username ?? '')
                  .toLowerCase()
                  .contains(_search.toLowerCase()))
              .toList();
        }

        _salesReport = parsedList;
      } else {
        _salesReport = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch sales report')),
          );
        }
      }

      Loader.stopLoader(context);
      notifyListeners();
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception in getEmployeeSalesReport: $e');
      _salesReport = [];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch sales report')),
        );
      }
      notifyListeners();
    }
  }
}
