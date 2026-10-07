import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/employee_lead_summary_model.dart';
import 'package:vidyanexis/controller/models/lead_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class EmployeeLeadSummaryProvider extends ChangeNotifier {
  EmployeeLeadSummaryModel? _employeeLeadSummary;
  EmployeeLeadSummaryModel? get employeeLeadSummary => _employeeLeadSummary;

  List<LeadReportModel>? _selectedEmployeeLeads;
  List<LeadReportModel>? get selectedEmployeeLeads => _selectedEmployeeLeads;

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
    _selectedEmployeeLeads = null;
    notifyListeners();
  }

  void clearSelectedLeads() {
    _selectedEmployeeLeads = null;
    notifyListeners();
  }

  Future<void> getEmployeeLeadSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final String fromDateParam = _formattedFromDate;
      final String toDateParam = _formattedToDate;

      String url = '${HttpUrls.employeeLeadSummary}?User_Id=0';
      if (fromDateParam.isNotEmpty && toDateParam.isNotEmpty) {
          url += '&From_Date=$fromDateParam&To_Date=$toDateParam&Is_Date=true';
      } else {
          url += '&From_Date=&To_Date=&Is_Date=';
      }

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200 && response.data != null) {
        _employeeLeadSummary = EmployeeLeadSummaryModel.fromJson(response.data);
        
        if (_search.isNotEmpty && _employeeLeadSummary?.employeeReport != null) {
             _employeeLeadSummary!.employeeReport = _employeeLeadSummary!.employeeReport!
                 .where((item) => (item.userDetailsName ?? '').toLowerCase().contains(_search.toLowerCase()))
                 .toList();
        }
      }

      Loader.stopLoader(context);
      notifyListeners();
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception in getEmployeeLeadSummary: $e');
      notifyListeners();
    }
  }

  Future<void> getEmployeeLeadList(BuildContext context, int userId, String filterType) async {
    try {
      Loader.showLoader(context);

      final String fromDateParam = _formattedFromDate;
      final String toDateParam = _formattedToDate;

      String url = 'lead/Get_Employee_Lead_List?User_Id=$userId&Filter_Type=$filterType';
      if (fromDateParam.isNotEmpty && toDateParam.isNotEmpty) {
          url += '&From_Date=$fromDateParam&To_Date=$toDateParam&Is_Date=true';
      } else {
          url += '&From_Date=&To_Date=&Is_Date=';
      }

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> jsonList = [];
        if (response.data is Map<String, dynamic> && response.data['Data'] != null) {
          final data = response.data['Data'];
          if (data is List && data.isNotEmpty && data.first is List) {
            jsonList = data.first;
          }
        } else if (response.data is List) {
          jsonList = response.data;
        }
        _selectedEmployeeLeads = jsonList.map((e) => LeadReportModel.fromJson(e)).toList();
      } else {
        _selectedEmployeeLeads = [];
      }

      Loader.stopLoader(context);
      notifyListeners();
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception in getEmployeeLeadList: $e');
      _selectedEmployeeLeads = [];
      notifyListeners();
    }
  }
}
