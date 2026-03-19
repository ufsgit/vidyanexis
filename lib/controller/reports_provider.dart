import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/conversion_model.dart';
import 'package:vidyanexis/controller/models/invoice_report_model.dart';
import 'package:vidyanexis/controller/models/serive_report_model.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class ReportsProvider extends ChangeNotifier {
  List<TaskReportModel> _taskReport = [];
  List<TaskReportModel> get taskReport => _taskReport;
  List<ServiceReportModel> _serviceReport = [];
  List<ServiceReportModel> get serviceReport => _serviceReport;
  List<ConversionModel> _conversionReport = [];
  List<ConversionModel> get conversionReport => _conversionReport;
  List<AmcReportModeld> _amcReport = [];
  List<AmcReportModeld> get amcReport => _amcReport;
  List<InvoiceReportModel> _invoiceReport = [];
  List<InvoiceReportModel> get invoiceReport => _invoiceReport;
  bool _isFilter = false;
  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  int? _selectedDateFilterIndex;

  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  bool get isFilter => _isFilter;

  bool _isServiceFilter = false;
  bool get isServiceFilter => _isServiceFilter;
  bool _isAMCFilter = false;
  bool get isAMCFilter => _isAMCFilter;
  bool _isConversionFilter = false;
  bool get isConversionFilter => _isConversionFilter;
  bool _isInvoiceFilter = false;
  bool get isInvoiceFilter => _isInvoiceFilter;

  void toggleFilter() {
    _isFilter = !_isFilter;
    selectDateFilterOption(null);
    removeStatus();
    notifyListeners();
  }

  void toggleServiceFilter() {
    _isServiceFilter = !_isServiceFilter;
    selectDateFilterOption(null);
    removeStatus();
    notifyListeners();
  }

  void toggleAmcFilter() {
    _isAMCFilter = !_isAMCFilter;
    selectDateFilterOption(null);
    removeStatus();
    notifyListeners();
  }

  void toggleConversionFilter() {
    _isConversionFilter = !_isConversionFilter;
    selectDateFilterOption(null);
    removeStatus();
    notifyListeners();
  }

  void toggleInvoiceFilter() {
    _isInvoiceFilter = !_isInvoiceFilter;
    selectDateFilterOption(null);
    removeStatus();
    notifyListeners();
  }

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setAMCStatus(int newStatus) {
    _selectedAMCStatus = newStatus;
    print(_selectedAMCStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      // If the index is null, we are clearing the filter
      _selectedDateFilterIndex = null; // Reset to the default "no filter" state
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
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

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    notifyListeners();
  }

  void removeAMCStatus() {
    _selectedAMCStatus = null;
    _selectedUser = null;
    notifyListeners();
  }

//task report
  Future<void> getSearchTaskReport(String search, String fromDate, String toDate,
      String status, BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (status.isEmpty || status == 'null') {
        status = '0';
      }
      String isDate = "0";
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "2024-11-27";
        }
        if (toDate.isEmpty) {
          toDate = "2024-11-27";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchTaskReport}?Customer_Name=$search&Task_Status_Id=$status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$fromDate&Todate=$toDate');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          if (data is List && data.isNotEmpty) {
            print("================ DEBUG TASK JSON (ReportsProvider) ================");
            print(data[0]);
            print("===================================================================");
          }
          _taskReport = (data as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
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

//service
  Future<void> getSearchServiceReport(String search, String fromDate, String toDate,
      String status, BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (status.isEmpty || status == 'null') {
        status = '0';
      }
      String isDate = "0";
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "";
        }
        if (toDate.isEmpty) {
          toDate = "";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchServiceReport}?service_Name=$search&Service_Status_Id=$status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$fromDate&Todate=$toDate');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _serviceReport = (data as List<dynamic>)
              .map((item) => ServiceReportModel.fromJson(item))
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

  Future<void> getSearchConversionReport(String fromDate, String toDate, String enquiryId,
      String registeredBy, String status, BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (status.isEmpty || status == 'null') {
        status = '0';
      }
      String isDate = "0";
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "";
        }
        if (toDate.isEmpty) {
          toDate = "";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchConversionReport}?Fromdate=$fromDate&Todate=$toDate&Is_Date_Check=$isDate&Enquiry_For_Id=$enquiryId&Registered_By=$registeredBy');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _conversionReport = (data as List<dynamic>)
              .map((item) => ConversionModel.fromJson(item))
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

  Future<void> getSearchAmcReport(
      {required String amcNo,
      required String amcId,
      required String fromDate,
      required String toDate,
      required String toUserId,
      required String status,
      required BuildContext context}) async {
    try {
      Loader.showLoader(context);
      if (status.isEmpty || status == 'null') {
        status = '0';
      }
      String isDate = "0";
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "";
        }
        if (toDate.isEmpty) {
          toDate = "";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();
      String amcStatusId = (_selectedAMCStatus ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchAmcReport}?AMC_No=$amcNo&AMC_Status_Id=$amcStatusId&Is_Date$isDate&Fromdate=$fromDate&Todate=$toDate&To_User_Id=$toUserId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _amcReport = (data as List<dynamic>)
              .map((item) => AmcReportModeld.fromJson(item))
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

  Future<void> getSearchInvoiceReport(
      {required String fromDate,
      required String toDate,
      required String search,
      required BuildContext context}) async {
    try {
      Loader.showLoader(context);
      // if (status.isEmpty || status == 'null') {
      //   status = '0';
      // }
      String isDate = "0";
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "";
        }
        if (toDate.isEmpty) {
          toDate = "";
        }
      } else {
        isDate = "1";
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchInvoiceReport}?Fromdate=$fromDate&Todate=$toDate&Is_Date_Check=$isDate&Customer_Name=$search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _invoiceReport = (data as List<dynamic>)
              .map((item) => InvoiceReportModel.fromJson(item))
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
}
