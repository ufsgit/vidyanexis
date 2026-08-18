import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/customer_outstanding_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/http/http_urls.dart';

class CustomerOutstandingReportProvider extends ChangeNotifier {
  List<CustomerOutstandingReportModel> _reportData = [];
  List<CustomerOutstandingReportModel> get reportData => _reportData;

  String _totalProjectCost = '0.00';
  String _totalReceived = '0.00';
  String _totalBalance = '0.00';

  String get totalProjectCost => _totalProjectCost;
  String get totalReceived => _totalReceived;
  String get totalBalance => _totalBalance;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  String get search => _search;

  int? _selectedEnquirySourceId;
  int? get selectedEnquirySourceId => _selectedEnquirySourceId;

  DateTime? _fromDate;
  DateTime? _toDate;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  int? _selectedDateFilterIndex = 5;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  CustomerOutstandingReportProvider() {
    _setFinancialYearDates();
  }

  void _setFinancialYearDates() {
    final now = DateTime.now();
    final startYear = now.month >= 4 ? now.year : now.year - 1;
    _fromDate = DateTime(startYear, 4, 1);
    _toDate = DateTime(startYear + 1, 3, 31);
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setEnquirySource(int? id) {
    _selectedEnquirySourceId = id;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = 5; // Default to Financial Year
      _setFinancialYearDates();
    } else {
      _selectedDateFilterIndex = index;
      setDateFilterByIndex(index);
    }
    notifyListeners();
  }

  void setDateFilterByIndex(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0: // Yesterday
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 1: // Today
        _fromDate = now;
        _toDate = now;
        break;
      case 2: // Tomorrow
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 3: // This Week
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 4: // This Month
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 5: // Financial Year
        _setFinancialYearDates();
        break;
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
        _fromDate = pickedDate;
      } else {
        _toDate = pickedDate;
      }
      _selectedDateFilterIndex = -1;
      notifyListeners();
    }
  }

  void resetFilters(BuildContext context) {
    _search = '';
    _selectedEnquirySourceId = null;
    _selectedDateFilterIndex = 5;
    _setFinancialYearDates();
    getReport(context);
  }

  Future<void> getReport(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.customerOutstandingReport}?From_Date=$formattedFromDate&To_Date=$formattedToDate&Customer_Name=$_search&Enquiry_Source_Id=${_selectedEnquirySourceId ?? ''}',
          bodyData: {});

      if (response.statusCode == 200) {
        final rawResponse = response.data;
        if (rawResponse != null) {
          if (rawResponse is Map<String, dynamic>) {
            final data = rawResponse['data'];
            if (data != null && data is List) {
              _reportData = data
                  .map((item) => CustomerOutstandingReportModel.fromJson(item))
                  .toList();
            } else if (rawResponse['list'] != null &&
                rawResponse['list'] is List) {
              _reportData = (rawResponse['list'] as List)
                  .map((item) => CustomerOutstandingReportModel.fromJson(item))
                  .toList();
            }
          } else if (rawResponse is List) {
            _reportData = rawResponse
                .map((item) => CustomerOutstandingReportModel.fromJson(item))
                .toList();
          }

          _calculateTotals();
          if (context.mounted) Loader.stopLoader(context);
          notifyListeners();
        } else {
          if (context.mounted) Loader.stopLoader(context);
          _reportData = [];
          notifyListeners();
        }
      } else {
        if (context.mounted) Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Server Error: ${response.statusCode} - ${response.statusMessage}')),
        );
      }
    } catch (e) {
      if (context.mounted) Loader.stopLoader(context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _calculateTotals() {
    double totalCost = 0.0;
    double totalReceived = 0.0;
    double totalBalance = 0.0;

    for (var item in _reportData) {
      totalCost += double.tryParse(item.projectCost.replaceAll(',', '')) ?? 0.0;
      totalReceived +=
          double.tryParse(item.received.replaceAll(',', '')) ?? 0.0;
      totalBalance += double.tryParse(item.balance.replaceAll(',', '')) ?? 0.0;
    }

    _totalProjectCost = totalCost.toStringAsFixed(2);
    _totalReceived = totalReceived.toStringAsFixed(2);
    _totalBalance = totalBalance.toStringAsFixed(2);
  }
}
