import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/conversion_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class ConversionReportProvider extends ChangeNotifier {
  List<ConversionModel> _conversionReport = [];
  List<ConversionModel> get conversionReport => _conversionReport;
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
  String _leadId = '0';
  String _fromDateS = '';
  String _toDateS = '';
  String _Status = '';
  String _AssignedTo = '';

  String get Search => _Search;
  String get leadId => _leadId;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;
  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedToUserId;
  int? _selectedByUserId;
  int? selectedFollowUpStatusId;
  int? _selectedEnquirySourceId;
  int? get selectedEnquirySourceId => _selectedEnquirySourceId;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  int? get selectedToUserId => _selectedToUserId;
  int? get selectedByUserId => _selectedByUserId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
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
    _fromDateS = _formattedFromDate;
    _toDateS = _formattedToDate;
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
    formatDate();
    _fromDateS = _formattedFromDate;
    _toDateS = _formattedToDate;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    _fromDateS = _formattedFromDate;
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    _toDateS = _formattedToDate;
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
    _Status = newStatus.toString();
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setEnquirySource(int newSource) {
    _selectedEnquirySourceId = newSource;
    notifyListeners();
  }

  void setUserFilterStatus(int? value) {
    _selectedUser = value;
    _selectedByUserId = value;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setToUserFilterStatus(int? value) {
    _selectedToUserId = value;
    notifyListeners();
  }

  void setByUserFilterStatus(int? value) {
    _selectedByUserId = value;
    _selectedUser = value;
    notifyListeners();
  }

  void setLeadId(String value) {
    _leadId = value.isEmpty ? '0' : value;
    notifyListeners();
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedEnquirySourceId = null;
    _selectedUser = null;
    _selectedToUserId = null;
    _selectedByUserId = null;
    _selectedDateFilterIndex = null;
    selectedFollowUpStatusId = null;
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _fromDateS = '';
    _toDateS = '';
    _leadId = '0';
    _Status = '0';
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo,
      {String leadId = '0'}) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _leadId = leadId.isEmpty ? '0' : leadId;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  //conversion report
  Future<void> getSearchConversionReport(BuildContext context) async {
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

      String toUserIdStr = (_selectedToUserId ?? 0).toString();
      String byUserIdStr = (_selectedByUserId ?? 0).toString();
      String registeredByStr = (_selectedByUserId ?? _selectedUser ?? 0).toString();
      String enquirySourceIdStr = (_selectedEnquirySourceId ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchConversionReport}?Customer_Name=$_Search&Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Enquiry_For_Id=$_Status&Registered_By=$registeredByStr&Status_Id=${selectedFollowUpStatusId ?? 0}&Enquiry_Source_Id=$enquirySourceIdStr&Lead_Id=$_leadId&To_User_Id=$toUserIdStr&By_User_Id=$byUserIdStr');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _conversionReport = (data as List<dynamic>)
              .map((item) => ConversionModel.fromJson(item))
              .toList();
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
      notifyListeners();
    }
  }

  Future<void> getSearchConversionReportNoContext() async {
    try {
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

      String toUserIdStr = (_selectedToUserId ?? 0).toString();
      String byUserIdStr = (_selectedByUserId ?? 0).toString();
      String registeredByStr = (_selectedByUserId ?? _selectedUser ?? 0).toString();
      String enquirySourceIdStr = (_selectedEnquirySourceId ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchConversionReport}?Customer_Name=$_Search&Fromdate=$_fromDateS&Todate=$_toDateS&Is_Date_Check=$isDate&Enquiry_For_Id=$_Status&Registered_By=$registeredByStr&Status_Id=${selectedFollowUpStatusId ?? 0}&Enquiry_Source_Id=$enquirySourceIdStr&Lead_Id=$_leadId&To_User_Id=$toUserIdStr&By_User_Id=$byUserIdStr');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _conversionReport = (data as List<dynamic>)
              .map((item) => ConversionModel.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }
}
