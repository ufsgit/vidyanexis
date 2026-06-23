import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/followup_amount_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class FollowupAmountReportProvider extends ChangeNotifier {
  List<FollowupAmountReportModel> _reportList = [];
  List<FollowupAmountReportModel> get reportList => _reportList;

  DateTime? _fromDate = DateTime.now();
  DateTime? _toDate = DateTime.now();
  String _formattedFromDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _formattedToDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  String get search => _search;

  int? _selectedUser;
  int? get selectedUser => _selectedUser;

  int? _selectedDateFilterIndex = 1; // Default to Today
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilter(bool filter) {
    _isFilter = filter;
    notifyListeners();
  }

  void setSearch(String query) {
    _search = query;
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

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = 1;
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      formatDate();
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

  void setUserFilter(int? userId) {
    _selectedUser = userId;
    notifyListeners();
  }

  void resetFilters() {
    _selectedUser = null;
    _selectedDateFilterIndex = 1;
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    _search = '';
    formatDate();
    notifyListeners();
  }

  List<FollowupAmountReportModel> get filteredReportList {
    if (_search.isEmpty) {
      return _reportList;
    }
    return _reportList.where((item) {
      return item.customerName.toLowerCase().contains(_search.toLowerCase()) ||
          item.statusName.toLowerCase().contains(_search.toLowerCase()) ||
          item.toUserName.toLowerCase().contains(_search.toLowerCase());
    }).toList();
  }

  Future<void> getReport(BuildContext context) async {
    try {
      Loader.showLoader(context);

      String fromStr = _formattedFromDate;
      String toStr = _formattedToDate;
      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.followupAmountReport}?From_Date_=$fromStr&To_Date_=$toStr&To_User_Id_=$toUserId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          _reportList = (data as List<dynamic>)
              .map((item) => FollowupAmountReportModel.fromJson(item))
              .toList();
          Loader.stopLoader(context);
          notifyListeners();
        }
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
