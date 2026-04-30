import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/sub_contract_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/http/http_urls.dart';

class SubContractReportProvider extends ChangeNotifier {
  List<SubContractReportModel> _subContractReport = [];
  List<SubContractReportModel> get subContractReport => _subContractReport;

  DateTime? _fromDate = DateTime(DateTime.now().year, 1, 1);
  DateTime? _toDate = DateTime(DateTime.now().year, 12, 31);
  String _formattedFromDate = '';
  String _formattedToDate = '';
  String _totalCommission = '0.00';

  String get totalCommission => _totalCommission;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  int? _selectedDateFilterIndex = 4;
  bool _isDateCheck = true;

  bool get isDateCheck => _isDateCheck;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  String get search => _search;

  int _selectedUserId = 0;
  int _selectedEnquiryForId = 0;

  int get selectedUserId => _selectedUserId;
  int get selectedEnquiryForId => _selectedEnquiryForId;

  void setUserId(int id) {
    _selectedUserId = id;
    notifyListeners();
  }

  void setEnquiryForId(int id) {
    _selectedEnquiryForId = id;
    notifyListeners();
  }

  SubContractReportProvider() {
    _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = -1;
      _isDateCheck = false;
    } else {
      _selectedDateFilterIndex = index;
      setDateFilterByIndex(index);
      _isDateCheck = true;
    }
    formatDate();
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
    }
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    _isDateCheck = true;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _isDateCheck = true;
    formatDate();
    notifyListeners();
  }

  void formatDate() {
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    }
    if (_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
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
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void resetFilters(BuildContext context) {
    _selectedDateFilterIndex = -1;
    _isDateCheck = false;
    _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
    _search = '';
    _selectedUserId = 0;
    _selectedEnquiryForId = 0;
    formatDate();
    getSubContractReport(context);
  }

  Future<void> getSubContractReport(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final String url =
          "${HttpUrls.subContractsReport}?From_Date=$_formattedFromDate&To_Date=$_formattedToDate&Is_Date_Check=${_isDateCheck ? 1 : 0}&Search=$_search&User_Id=$_selectedUserId&Enquiry_For_Id=$_selectedEnquiryForId";

      final response =
          await HttpRequest.httpGetRequest(endPoint: url, bodyData: {});

      if (response.statusCode == 200) {
        final rawResponse = response.data;
        if (rawResponse != null &&
            rawResponse is List &&
            rawResponse.isNotEmpty) {
          final data = rawResponse[0];
          if (data != null && data is List) {
            _subContractReport = data
                .map((item) => SubContractReportModel.fromJson(item))
                .toList();

            // Calculate total commission manually as backend doesn't provide it in this structure
            double total = 0;
            for (var item in _subContractReport) {
              total += double.tryParse(item.commission) ?? 0;
            }
            _totalCommission = total.toStringAsFixed(2);
          } else {
            _subContractReport = [];
            _totalCommission = '0.00';
          }

          if (context.mounted) Loader.stopLoader(context);
          notifyListeners();
        } else if (rawResponse != null && rawResponse is Map<String, dynamic>) {
          // Fallback to standard structure if returned
          final data = rawResponse['data'];
          if (data != null && data is List) {
            _subContractReport = data
                .map((item) => SubContractReportModel.fromJson(item))
                .toList();
          } else {
            _subContractReport = [];
          }

          final totals = rawResponse['totals'];
          if (totals != null && totals is Map<String, dynamic>) {
            _totalCommission = totals['Total_Commission']?.toString() ?? '0.00';
          } else if (_subContractReport.isNotEmpty) {
            double total = 0;
            for (var item in _subContractReport) {
              total += double.tryParse(item.commission) ?? 0;
            }
            _totalCommission = total.toStringAsFixed(2);
          }

          if (context.mounted) Loader.stopLoader(context);
          notifyListeners();
        } else {
          if (context.mounted) Loader.stopLoader(context);
          _subContractReport = [];
          _totalCommission = '0.00';
          notifyListeners();
        }
      } else {
        if (context.mounted) Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (context.mounted) Loader.stopLoader(context);
      print('Exception in getSubContractReport: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
