import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/stock_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class StockReportProvider extends ChangeNotifier {
  List<StockReportModel> _taskReport = [];
  List<StockReportModel> get taskReport => _taskReport;
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
  String _Search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _Status = '';
  String _AssignedTo = '';

  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;

  int? _selectedStatus;
  int? _selectedUser;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedUser => _selectedUser;

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

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    notifyListeners();
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    notifyListeners();
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _fromDateS = '';
    _toDateS = '';
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    notifyListeners();
  }

  Future<void> getSearchWorkSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null' || _Status == '0') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      String toUserId = (_selectedUser ?? 0).toString();

      // Using searchWorkReport endpoint as it seems most relevant for a generic report that might be stock related
      // or we can use getStockList if we want actual stock data.
      // However, the snippet suggests it expects a filtered search.
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchWorkReport}?Item_Id=$_Status&Category_Id=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          _taskReport = (data as List<dynamic>)
              .map((item) => StockReportModel.fromJson(item))
              .toList();
        }
        Loader.stopLoader(context);
        notifyListeners();
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }
}
