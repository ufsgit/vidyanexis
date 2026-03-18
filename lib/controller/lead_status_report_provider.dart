import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/lead_status_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class LeadStatusReportProvider extends ChangeNotifier {
  List<LeadStatusReportModel> _reportData = [];
  List<LeadStatusReportModel> get reportData => _reportData;

  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  int? _selectedDateFilterIndex;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

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
  }

  void setDateRange(DateTime start, DateTime end) {
    _fromDate = start;
    _toDate = end;
    formatDate();
    notifyListeners();
  }

  void formatDate() {
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

  void removeStatus() {
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _selectedDateFilterIndex = null;
    notifyListeners();
  }

  Future<void> fetchReportData(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      formatDate();

      String isDate = "0";
      if (_formattedFromDate.isEmpty && _formattedToDate.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getLeadStatusReport}?From_Date=$_formattedFromDate&To_Date=$_formattedToDate&Is_Date_Check=$isDate');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['success'] == true && data['data'] != null) {
          _reportData = (data['data'] as List<dynamic>)
              .map((item) => LeadStatusReportModel.fromJson(item))
              .toList();
        } else {
          _reportData = [];
        }
      } else {
        _reportData = [];
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      _reportData = [];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
