import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/stock_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class StockReportProvider extends ChangeNotifier {
  List<StockReportModel> _taskReport = [];
  List<StockReportModel> get taskReport => _taskReport;
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
  String _Search = '';
  String _fromDateS = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _toDateS = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
      int itemId = 0;
      if (_selectedStatus != null && _selectedStatus! > 0) {
        itemId = _selectedStatus!;
      } else if (_Status.isNotEmpty && _Status != 'null') {
        itemId = int.tryParse(_Status) ?? 0;
      }

      int categoryId = 0;
      if (_selectedUser != null && _selectedUser! > 0) {
        categoryId = _selectedUser!;
      } else if (_AssignedTo.isNotEmpty && _AssignedTo != 'null') {
        categoryId = int.tryParse(_AssignedTo) ?? 0;
      }

      try {
        final response = await HttpRequest.httpGetRequest(
            endPoint:
                '${HttpUrls.Search_Stock_Report}?Item_Id=$itemId&Category_Id=$categoryId');

        if (response.statusCode == 200 && response.data != null) {
          final resData = response.data;
          List<dynamic> itemsList = [];
          if (resData is Map && resData['data'] != null) {
            final rawData = resData['data'];
            if (rawData is List && rawData.isNotEmpty) {
              if (rawData[0] is List) {
                itemsList = rawData[0] as List<dynamic>;
              } else {
                itemsList = rawData;
              }
            }
          } else if (resData is List && resData.isNotEmpty) {
            if (resData[0] is List) {
              itemsList = resData[0] as List<dynamic>;
            } else {
              itemsList = resData;
            }
          }

          if (itemsList.isNotEmpty) {
            _taskReport = itemsList
                .whereType<Map<String, dynamic>>()
                .map((item) => StockReportModel.fromJson(item))
                .toList();
            Loader.stopLoader(context);
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        print('Search_Stock_Report parsing error or failure: $e');
      }

      // Fallback: Fetch stock data with quantities from getStockDetails or getStockList or getItemListStock
      dynamic fallbackResponseData;
      try {
        final resDetails = await HttpRequest.httpGetRequest(endPoint: HttpUrls.getStockDetails);
        if (resDetails.statusCode == 200 && resDetails.data != null) {
          fallbackResponseData = resDetails.data;
        }
      } catch (e) {
        print('getStockDetails failed: $e');
      }

      if (fallbackResponseData == null) {
        try {
          final resList = await HttpRequest.httpGetRequest(endPoint: HttpUrls.getStockList);
          if (resList.statusCode == 200 && resList.data != null) {
            fallbackResponseData = resList.data;
          }
        } catch (e) {
          print('getStockList failed: $e');
        }
      }

      if (fallbackResponseData == null) {
        try {
          final resItemStock = await HttpRequest.httpGetRequest(endPoint: HttpUrls.getItemListStock);
          if (resItemStock.statusCode == 200 && resItemStock.data != null) {
            fallbackResponseData = resItemStock.data;
          }
        } catch (e) {
          print('getItemListStock failed: $e');
        }
      }

      if (fallbackResponseData != null) {
        List<dynamic> itemsList = [];
        if (fallbackResponseData is List) {
          itemsList = fallbackResponseData;
        } else if (fallbackResponseData is Map && fallbackResponseData['data'] != null) {
          itemsList = fallbackResponseData['data'] as List<dynamic>;
        }

        List<StockReportModel> list = [];
        for (var rawItem in itemsList) {
          if (rawItem is Map<String, dynamic>) {
            int itemVal = int.tryParse(rawItem['Item_Id']?.toString() ?? rawItem['item_id']?.toString() ?? '0') ?? 0;
            int catVal = int.tryParse(rawItem['Category_Id']?.toString() ?? rawItem['category_id']?.toString() ?? '0') ?? 0;

            if (itemId > 0 && itemVal != itemId) {
              continue;
            }
            if (categoryId > 0 && catVal != categoryId) {
              continue;
            }
            list.add(StockReportModel.fromJson(rawItem));
          }
        }
        _taskReport = list;
      }

      Loader.stopLoader(context);
      notifyListeners();
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }
}
