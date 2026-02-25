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
    _Status = newStatus.toString();
    notifyListeners();
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    _AssignedTo = newStatus.toString();
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

      String itemId = (_selectedStatus ?? 0).toString();
      String categoryId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.stockReport}?s_Item_Id=$itemId&s_Category_Id=$categoryId');

      print('=== STOCK REPORT RAW RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Data type: ${response.data.runtimeType}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<dynamic> listData = [];

          if (data is Map && data['data'] != null) {
            final dataArray = data['data'];
            print('data[data] type: ${dataArray.runtimeType}');
            print('data[data]: $dataArray');

            if (dataArray is List && dataArray.isNotEmpty) {
              // Handle nested list structure: data['data'] = [[item1, item2], ...]
              if (dataArray[0] is List) {
                listData = dataArray[0] as List<dynamic>;
                print('Parsed from nested list: ${listData.length} items');
              } else {
                listData = dataArray;
                print('Parsed from flat list: ${listData.length} items');
              }
            }
          } else if (data is List) {
            listData = data;
            print('Data is direct list: ${listData.length} items');
          }

          if (listData.isNotEmpty) {
            print('First item keys: ${(listData[0] as Map).keys.toList()}');
            print('First item data: ${listData[0]}');
          } else {
            print('=== STOCK REPORT: No data returned from API ===');
          }

          _taskReport =
              listData.map((item) => StockReportModel.fromJson(item)).toList();
          print('Parsed ${_taskReport.length} stock report items');
          if (_taskReport.isNotEmpty) {
            print(
                'First item: name=${_taskReport[0].itemName}, cat=${_taskReport[0].categoryName}, qty=${_taskReport[0].quantity}');
          }
        }
        Loader.stopLoader(context);
        notifyListeners();
      } else {
        Loader.stopLoader(context);
        print('Stock report API error: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception occurred in getSearchWorkSummary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }
}
