import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/enquiry_source_report_model.dart';
import 'package:vidyanexis/controller/models/work_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class EnquirySourceProvider extends ChangeNotifier {
  List<WorkSummaryModel> _taskReport = [];
  List<WorkSummaryModel> get taskReport => _taskReport;

  List<EnquirySourceReportModel> _enquiryReport = [];
  List<EnquirySourceReportModel> get enquiryReport => _enquiryReport;

  // Creation Date variables
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  // Conversion Date variables
  DateTime? _conversionFromDate;
  DateTime? _conversionToDate;
  String _formattedConversionFromDate = '';
  String _formattedConversionToDate = '';
  String get formattedConversionFromDate => _formattedConversionFromDate;
  String get formattedConversionToDate => _formattedConversionToDate;
  DateTime? get conversionFromDate => _conversionFromDate;
  DateTime? get conversionToDate => _conversionToDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;
  String _Search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _conversionFromDateS = '';
  String _conversionToDateS = '';
  String _Status = '';
  String _AssignedTo = '';

  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get conversionFromDateS => _conversionFromDateS;
  String get conversionToDateS => _conversionToDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;

  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedDateFilterIndex;
  int? _selectedConversionDateFilterIndex;

  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedConversionDateFilterIndex =>
      _selectedConversionDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  Map<int, bool> expandedRows = {};

  void toggleRowExpansion(int index) {
    expandedRows[index] = !(expandedRows[index] ?? false);
    notifyListeners();
  }

  void resetExpandedStates() {
    expandedRows.clear();
    notifyListeners();
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index, {bool isConversion = false}) {
    if (isConversion) {
      if (index == null) {
        _selectedConversionDateFilterIndex = null;
        _conversionFromDate = null;
        _conversionToDate = null;
        _formattedConversionFromDate = '';
        _formattedConversionToDate = '';
      } else {
        _selectedConversionDateFilterIndex = index;
        formatDate();
      }
    } else {
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
    }
    notifyListeners();
  }

  void setDateFilter(String title, {bool isConversion = false}) {
    final now = DateTime.now();
    DateTime? from;
    DateTime? to;

    switch (title) {
      case 'Yesterday':
        from = now.subtract(const Duration(days: 1));
        to = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        from = now;
        to = now;
        break;
      case 'Tomorrow':
        from = now.add(const Duration(days: 1));
        to = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        from = now.subtract(Duration(days: now.weekday - 1));
        to = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        from = null;
        to = null;
        break;
    }

    if (isConversion) {
      _conversionFromDate = from;
      _conversionToDate = to;
    } else {
      _fromDate = from;
      _toDate = to;
    }

    notifyListeners();
  }

  void setFromDate(DateTime date, {bool isConversion = false}) {
    if (isConversion) {
      _conversionFromDate = date;
      _selectedConversionDateFilterIndex = -1;
    } else {
      _fromDate = date;
      _selectedDateFilterIndex = -1;
    }
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date, {bool isConversion = false}) {
    if (isConversion) {
      _conversionToDate = date;
      _selectedConversionDateFilterIndex = -1;
    } else {
      _toDate = date;
      _selectedDateFilterIndex = -1;
    }
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

    if (conversionFromDate != null) {
      _formattedConversionFromDate =
          DateFormat('yyyy-MM-dd').format(conversionFromDate!);
    } else {
      _formattedConversionFromDate = '';
    }

    if (conversionToDate != null) {
      _formattedConversionToDate =
          DateFormat('yyyy-MM-dd').format(conversionToDate!);
    } else {
      _formattedConversionToDate = '';
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate,
      {bool isConversion = false}) async {
    DateTime? initialDate;
    if (isConversion) {
      initialDate = isFromDate
          ? (_conversionFromDate ?? DateTime.now())
          : (_conversionToDate ?? DateTime.now());
    } else {
      initialDate = isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now());
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setFromDate(pickedDate, isConversion: isConversion);
      } else {
        setToDate(pickedDate, isConversion: isConversion);
      }
    }
    notifyListeners();
  }

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    print(_selectedStatus.toString());
    notifyListeners();
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners();
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _selectedConversionDateFilterIndex = null;
    _fromDateS = '';
    _toDateS = '';
    _conversionFromDateS = '';
    _conversionToDateS = '';
    _fromDate = null;
    _toDate = null;
    _conversionFromDate = null;
    _conversionToDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _formattedConversionFromDate = '';
    _formattedConversionToDate = '';
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo,
      {String conversionFromDate = '', String conversionToDate = ''}) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _conversionFromDateS = conversionFromDate;
    _conversionToDateS = conversionToDate;
    notifyListeners();
  }

  //work report
  Future<void> getSearchWorkSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      print(_fromDateS);
      print(_toDateS);
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        if (_fromDateS.isEmpty) {
          _fromDateS = "";
        }
        if (_toDateS.isEmpty) {
          _toDateS = "";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchWorkSummary}?Fromdate=$_fromDateS&Todate=$_toDateS&By_User=$toUserId&look_In_Date_Value=$isDate');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _taskReport = (data as List<dynamic>)
              .map((item) => WorkSummaryModel.fromJson(item))
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

  Future<void> getEnquirySummary(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      print(_fromDateS);
      print(_toDateS);
      print(_conversionFromDateS);
      print(_conversionToDateS);

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getLeadReportByEnquirySource}?from_date=$_fromDateS&to_date=$_toDateS&conversion_from_date=$_conversionFromDateS&conversion_to_date=$_conversionToDateS');
      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _enquiryReport = (data as List<dynamic>)
              .map((item) => EnquirySourceReportModel.fromJson(item))
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

  Future<void> getSearchWorkSummaryNoContext() async {
    try {
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        if (_fromDateS.isEmpty) {
          _fromDateS = "2024-01-01";
        }
        if (_toDateS.isEmpty) {
          _toDateS = "2024-01-01";
        }
      } else {
        isDate = "1";
      }
      print(_fromDateS);
      print(_toDateS);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchWorkSummary}?Customer_Name=$_Search&Task_Status_Id=$_Status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _taskReport = (data as List<dynamic>)
              .map((item) => WorkSummaryModel.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
