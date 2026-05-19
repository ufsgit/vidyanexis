import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/task_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:intl/intl.dart';

class TaskSummaryProvider extends ChangeNotifier {
  List<TaskSummaryModel> _taskSummaries = [];
  List<TaskSummaryModel> get taskSummaries => _taskSummaries;

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isDateCheck = false;
  bool _isFilter = false;
  int? _selectedDateFilterIndex;
  String _formattedFromDate = '';
  String _formattedToDate = '';

  DateTime? get fromDate => _fromDate;
  DateTime? get to_toDate => _toDate;
  bool get isDateCheck => _isDateCheck;
  bool get isFilter => _isFilter;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;

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
      _isDateCheck = false;
    } else {
      _selectedDateFilterIndex = index;
      _isDateCheck = true;
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
    _isDateCheck = true;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _selectedDateFilterIndex = -1;
    _isDateCheck = true;
    formatDate();
    notifyListeners();
  }

  void formatDate() {
    if (fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    } else {
      _formattedFromDate = '';
    }

    if (to_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(to_toDate!);
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

  void setIsDateCheck(bool value) {
    _isDateCheck = value;
    notifyListeners();
  }

  Future<void> getTaskSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String fromDateStr =
          _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
      String toDateStr =
          _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';
      int isDateCheckInt = _isDateCheck ? 1 : 0;

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.taskSummary}?Fromdate_=$fromDateStr&Todate_=$toDateStr&Is_Date_Check_=$isDateCheckInt&Login_User_Id_=$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _taskSummaries =
              data.map((json) => TaskSummaryModel.fromJson(json)).toList();
        } else {
          _taskSummaries = [];
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load task summary')),
        );
      }
    } catch (e) {
      print('Error fetching task summary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching task summary')),
      );
    } finally {
      Loader.stopLoader(context);
    }
  }

  void resetFilters() {
    _fromDate = null;
    _toDate = null;
    _isDateCheck = false;
    _selectedDateFilterIndex = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    notifyListeners();
  }
}
