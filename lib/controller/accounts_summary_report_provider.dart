import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/accounts_summary_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class AccountsSummaryReportProvider extends ChangeNotifier {
  List<AccountsSummaryReportModel> _accountsSummaryReport = [];
  List<AccountsSummaryReportModel> get accountsSummaryReport => _accountsSummaryReport;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  DateTime? _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  String _formattedFromDate = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String _formattedToDate = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _fromDateS = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
  String _toDateS = DateFormat('yyyy-MM-dd')
      .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));

  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilter(bool filter) {
    _isFilter = filter;
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
    _formattedFromDate =
        fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '';
    _formattedToDate =
        toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '';
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
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

  void removeFilters() {
    _selectedDateFilterIndex = null;
    _fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
    _fromDateS = _formattedFromDate;
    _toDateS = _formattedToDate;
    _isFilter = false;
    _hasFetched = false;
    notifyListeners();
  }

  void setSearchCriteria(String fromDate, String toDate) {
    _fromDateS = fromDate;
    _toDateS = toDate;
    notifyListeners();
  }

  Future<void> getAccountsSummaryReport(BuildContext context,
      {bool reset = false}) async {
    try {
      Loader.showLoader(context);

      if (_fromDateS.isEmpty) {
        _fromDateS = DateFormat('yyyy-MM-dd')
            .format(DateTime(DateTime.now().year, DateTime.now().month, 1));
      }
      if (_toDateS.isEmpty) {
        _toDateS = DateFormat('yyyy-MM-dd')
            .format(DateTime(DateTime.now().year, DateTime.now().month + 1, 0));
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchAccountsSummaryReport,
        bodyData: {
          'From_Date': _fromDateS,
          'To_Date': _toDateS,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataMap = data is Map ? data['data'] ?? data : data;
          if (dataMap is List) {
            _accountsSummaryReport = dataMap
                .map((item) => AccountsSummaryReportModel.fromJson(item))
                .toList();
          } else {
            _accountsSummaryReport = [];
          }
        } else {
          _accountsSummaryReport = [];
        }
        _hasFetched = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception in getAccountsSummaryReport: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
      notifyListeners();
    }
  }

  Future<List<AccountsSummaryReportModel>> fetchAllForExport(
      BuildContext context) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchAccountsSummaryReport,
        bodyData: {
          'From_Date': _fromDateS,
          'To_Date': _toDateS,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataMap = data is Map ? data['data'] ?? data : data;
          if (dataMap is List) {
            return dataMap
                .map((item) => AccountsSummaryReportModel.fromJson(item))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Exception in fetchAllForExport: $e');
      return [];
    } finally {
      Loader.stopLoader(context);
    }
  }
}
