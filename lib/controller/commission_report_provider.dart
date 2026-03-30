import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/commission_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/loader.dart';

class CommissionReportProvider extends ChangeNotifier {
  List<CommissionReportModel> _commissionReport = [];
  List<CommissionReportModel> get commissionReport => _commissionReport;

  DateTime? _fromDate = DateTime(2025, 1, 1);
  DateTime? _toDate = DateTime(2025, 12, 31);
  String _formattedFromDate = '2025-01-01';
  String _formattedToDate = '2025-12-31';
  String _totalProjectCost = '0.00';
  String _totalCommission = '0.00';

  String get totalProjectCost => _totalProjectCost;
  String get totalCommission => _totalCommission;

  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  String _fromDateS = '2025-01-01';
  String _toDateS = '2025-12-31';

  String get search => _search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;

  int? _selectedEnquiryFor = 10;
  int? _selectedEnquirySource = 0;
  int? _selectedDateFilterIndex = -1;
  bool _isDateCheck = false;

  bool get isDateCheck => _isDateCheck;

  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedEnquiryFor => _selectedEnquiryFor;
  int? get selectedEnquirySource => _selectedEnquirySource;

  CommissionReportProvider() {
    _formattedFromDate = _fromDateS;
    _formattedToDate = _toDateS;
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilter(bool value) {
    _isFilter = value;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = 1; // Default to Today
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
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
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
      _fromDateS = _formattedFromDate;
    } else {
      _formattedFromDate = '';
      _fromDateS = '';
    }

    if (_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
      _toDateS = _formattedToDate;
    } else {
      _formattedToDate = '';
      _toDateS = '';
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

  void setEnquiryForFilter(int? value) {
    _selectedEnquiryFor = value;
    _isDateCheck = true; // Trigger date check if filter applied? Or maybe not. 
    // Usually reports show data for the selected period.
    notifyListeners();
  }

  void setEnquirySourceFilter(int? value) {
    _selectedEnquirySource = value;
    _isDateCheck = true;
    notifyListeners();
  }

  void resetFilters(BuildContext context) {
    _selectedEnquiryFor = 0;
    _selectedEnquirySource = 0;
    _selectedDateFilterIndex = -1;
    _isDateCheck = false;
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    formatDate();
    getCommissionReport(context);
  }

  Future<void> getCommissionReport(BuildContext context) async {
    try {
      Loader.showLoader(context);
      
      // Use the exact parameters from the snippet for testing
      final response = await HttpRequest.httpGetRequest(
          endPoint: 'lead/Get_Commission_Report?From_Date=2025-01-01&To_Date=2025-12-31&Is_Date_Check=0&Enquiry_Source_Id&Enquiry_For_Id=10',
          bodyData: {});

      if (response.statusCode == 200) {
        final rawResponse = response.data;
        if (rawResponse != null && rawResponse is Map<String, dynamic>) {
          final data = rawResponse['data'];
          if (data != null && data is List) {
            _commissionReport = data
                .map((item) => CommissionReportModel.fromJson(item))
                .toList();
          }

          final totals = rawResponse['totals'];
          if (totals != null && totals is Map<String, dynamic>) {
            _totalProjectCost = totals['Total_Project_Cost']?.toString() ?? '0.00';
            _totalCommission = totals['Total_Commission']?.toString() ?? '0.00';
          }
          
          if (context.mounted) Loader.stopLoader(context);
          notifyListeners();
        } else {
          if (context.mounted) Loader.stopLoader(context);
          _commissionReport = [];
          notifyListeners();
          print('Response is not the expected Map: $rawResponse');
        }
      } else {
        if (context.mounted) Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode} - ${response.statusMessage}')),
        );
      }
    } catch (e) {
      if (context.mounted) Loader.stopLoader(context);
      print('Exception occurred in getCommissionReport: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
