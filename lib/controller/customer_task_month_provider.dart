import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/customer_task_month_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:intl/intl.dart';

class CustomerTaskMonthProvider extends ChangeNotifier {
  List<CustomerTaskMonthModel> _taskData = [];
  List<CustomerTaskMonthModel> get taskData => _taskData;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilter(bool value) {
    _isFilter = value;
    notifyListeners();
  }

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  int _selectedDateFilterIndex = -1;
  int get selectedDateFilterIndex => _selectedDateFilterIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setSelectedMonth(DateTime date) {
    _selectedMonth = date;
    _fromDate = DateTime(date.year, date.month, 1);
    _toDate = DateTime(date.year, date.month + 1, 0);
    notifyListeners();
  }

  void selectDateFilterOption(int index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  void setDateFilter(String filter) {
    DateTime now = DateTime.now();
    switch (filter) {
      case 'Today':
        _fromDate = DateTime(now.year, now.month, now.day);
        _toDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Yesterday':
        DateTime yesterday = now.subtract(const Duration(days: 1));
        _fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        _toDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        break;
      case 'Tomorrow':
        DateTime tomorrow = now.add(const Duration(days: 1));
        _fromDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        _toDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
    }
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      _selectedDateFilterIndex = -1;
      notifyListeners();
    }
  }

  Future<void> getCustomerTaskMonth(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Use fromDate and toDate if available, otherwise fallback to selectedMonth
      DateTime firstDay =
          _fromDate ?? DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      DateTime lastDay =
          _toDate ?? DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

      String fromDateStr = DateFormat('yyyy-MM-dd').format(firstDay);
      String toDateStr = DateFormat('yyyy-MM-dd').format(lastDay);

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getCustomerTaskMonth}?Fromdate_=$fromDateStr&Todate_=$toDateStr');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _taskData = data
              .map((json) => CustomerTaskMonthModel.fromJson(json))
              .toList();
        } else {
          _taskData = [];
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load report data')),
        );
      }
    } catch (e) {
      print('Error fetching customer task month: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching report')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to group data by customer and date for the UI
  Map<String, Map<String, List<CustomerTaskMonthModel>>> groupedDataInRange(
      List<DateTime> range) {
    Map<String, Map<String, List<CustomerTaskMonthModel>>> grouped = {};
    for (var item in _taskData) {
      if (item.customerName == null || item.taskDate == null) continue;

      // Extract only the date part for comparison
      String itemDateStr = item.taskDate!.split(' ')[0];

      if (!grouped.containsKey(item.customerName)) {
        grouped[item.customerName!] = {};
      }

      if (!grouped[item.customerName]!.containsKey(itemDateStr)) {
        grouped[item.customerName]![itemDateStr] = [];
      }

      grouped[item.customerName]![itemDateStr]!.add(item);
    }
    return grouped;
  }
}
