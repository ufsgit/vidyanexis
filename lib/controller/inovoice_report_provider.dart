import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/invoice_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class InvoiceReportProvider extends ChangeNotifier {
  List<InvoiceReportModel> _taskReport = [];
  List<InvoiceReportModel> get taskReport => _taskReport;
  List<InvoiceReportModel> _tempData = [];
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
  String _enquirySource = '';
  String _enquiryFor = '';
  bool _hasFetched = false;
  bool _isLoading = false;
  bool get hasFetched => _hasFetched;
  bool get isLoading => _isLoading;
  String get enquirySource => _enquirySource;
  String get enquiryFor => _enquiryFor;
  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;
  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  String _invoiceTotal = '';
  String get invoiceTotal => _invoiceTotal;
  String _recieptTotal = '';
  String get recieptTotal => _recieptTotal;
  String _balanceTotal = '';
  String get balanceTotal => _balanceTotal;
  bool _isChecked = false;

  bool get isChecked => _isChecked;

  void toggleCheckbox() {
    _isChecked = !_isChecked;
    notifyListeners();
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      // If the index is null, we are clearing the filter
      _selectedDateFilterIndex = 1; // Default to Today
      _fromDate = DateTime.now();
      _toDate = DateTime.now();
      formatDate();
    } else {
      _selectedDateFilterIndex = index; // Set the new selected filter index
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

    notifyListeners(); // Notify listeners to rebuild the UI
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
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2101), // Maximum date
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setFromDate(pickedDate); // Set the 'from' date in provider
      } else {
        setToDate(pickedDate); // Set the 'to' date in provider
      }
    }
    notifyListeners();
  }

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _enquiryFor = '';
    _enquirySource = "";
    _fromDate = null;
    _toDate = null;
    formatDate();
    _fromDateS = '';
    _toDateS = '';
    _hasFetched = false;
    notifyListeners();
  }

  void setTaskSearchCriteria(
      String search,
      String fromDate,
      String toDate,
      String status,
      String assignedTo,
      String enquiryFor,
      String enquirySource) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _enquiryFor = enquiryFor;
    _enquirySource = enquirySource;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

//bill and payments report
  Future<void> getBillandPaymentsReport(BuildContext context) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();

      var response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.billPayementReport}?Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Customer_Name=$_Search');

      // Fallback strategy if first endpoint returns 404, 0 or any non-200 status code
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print(
              "Billing_Payment_Report returned ${response.statusCode}, falling back to Search_Invoice_Report...");
        }
        response = await HttpRequest.httpGetRequest(
            endPoint:
                '${HttpUrls.searchInvoiceReport}?Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Customer_Name=$_Search');
      }

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _tempData = (data as List<dynamic>)
              .map((item) => InvoiceReportModel.fromJson(item))
              .toList();

          for (var item in _tempData) {
            if (item.tp == 2) {
              _recieptTotal = item.recieptAmount.toString();
              _invoiceTotal = item.invoiceAmount.toString();
              _balanceTotal = item.balanceAmount.toString();
            }
          }

          if (_tempData.isNotEmpty) {
            _tempData.removeLast();
          }
          _taskReport = List.from(_tempData);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
      _isLoading = false;
      _hasFetched = true;
      notifyListeners();
    }
  }

  //task report
  Future<void> getSearchTaskReport(BuildContext context) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String isCheck = _isChecked ? "1" : "0";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchInvoiceReport}?Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Customer_Name=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _tempData = (data as List<dynamic>)
              .map((item) => InvoiceReportModel.fromJson(item))
              .toList();

          for (var item in _tempData) {
            if (item.tp == 2) {
              _recieptTotal = item.recieptAmount.toString();
              _invoiceTotal = item.invoiceAmount.toString();
              _balanceTotal = item.balanceAmount.toString();
            }
          }

          if (_tempData.isNotEmpty) {
            _tempData.removeLast();
          }
          _taskReport = List.from(_tempData);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
      _hasFetched = true;
      notifyListeners();
    }
  }

  Future<void> getSearchTaskReportNoContext() async {
    try {
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        _fromDateS = "";
        _toDateS = "";
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
              '${HttpUrls.searchInvoiceReport}?Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Customer_Name=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _taskReport = (data as List<dynamic>)
              .map((item) => InvoiceReportModel.fromJson(item))
              .toList();

          _hasFetched = true;

          _hasFetched = true;
          notifyListeners();
        }
      } else {
        _hasFetched = true;
      }
    } catch (e) {
      _hasFetched = true;
      print('Exception occurred: $e');
    }
  }
}
