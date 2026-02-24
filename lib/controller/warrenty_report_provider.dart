import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/warrenty_model.dart';
import 'package:vidyanexis/controller/models/amc_notification_model.dart';
import 'package:vidyanexis/controller/models/payment_reminder_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class WarrentyReportProvider extends ChangeNotifier {
  List<WarrentyModel> _amcReport = [];
  List<WarrentyModel> get amcReport => _amcReport;
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
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;

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
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  //amc report
  getSearchAmcReport(BuildContext context) async {
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
              '${HttpUrls.warrentyReport}?Customer_Name=$_Search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());
          final newData = data['data'];
          _amcReport = (newData as List<dynamic>)
              .map((item) => WarrentyModel.fromJson(item))
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

  // getSearchAmcReportNoContext() async {
  //   try {
  //     if (_Status.isEmpty || _Status == 'null') {
  //       _Status = '0';
  //     }
  //     print(_fromDateS);
  //     print(_toDateS);
  //     String isDate = "0";
  //     if (_fromDateS.isEmpty && _toDateS.isEmpty) {
  //       isDate = "0";
  //       if (_fromDateS.isEmpty) {
  //         _fromDateS = "";
  //       }
  //       if (_toDateS.isEmpty) {
  //         _toDateS = "";
  //       }
  //     } else {
  //       isDate = "1";
  //     }
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String userId = preferences.getString('userId') ?? "";

  //     String toUserId = (_selectedUser ?? 0).toString();

  //     final response = await HttpRequest.httpGetRequest(
  //         endPoint:
  //             '${HttpUrls.searchAmcReport}?Customer_Name=&AMC_Status_Id=$_Status&Is_Date$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=$toUserId');

  //     if (response.statusCode == 200) {
  //       final data = response.data;

  //       if (data != null) {
  //         // log(data.toString());

  //         _amcReport = (data as List<dynamic>)
  //             .map((item) => AmcReportModeld.fromJson(item))
  //             .toList();

  //         notifyListeners();
  //       }
  //     } else {}
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //   }
  // }
  // Out of Warranty Report
  List<WarrentyModel> _outOfWarrentyReport = [];
  List<WarrentyModel> get outOfWarrentyReport => _outOfWarrentyReport;

  Future<void> getSearchOutOfWarrentyReport(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        if (_fromDateS.isEmpty) _fromDateS = "";
        if (_toDateS.isEmpty) _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchOutofwarrentyReport}?Customer_Name=$_Search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          if (data is List) {
            _outOfWarrentyReport =
                data.map((item) => WarrentyModel.fromJson(item)).toList();
          } else {
            final newData = data['data'];
            if (newData != null) {
              _outOfWarrentyReport = (newData as List<dynamic>)
                  .map((item) => WarrentyModel.fromJson(item))
                  .toList();
            } else {
              _outOfWarrentyReport = [];
            }
          }

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

  // Upcoming Warranty Report
  List<WarrentyModel> _upcomingWarrantyReport = [];
  List<WarrentyModel> get upcomingWarrantyReport => _upcomingWarrantyReport;

  Future<void> getSearchUpcomingWarrantyReport(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        if (_fromDateS.isEmpty) _fromDateS = "";
        if (_toDateS.isEmpty) _toDateS = "";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchUpcomingWarrantyReport}?Customer_Name=$_Search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          if (data is List) {
            _upcomingWarrantyReport =
                data.map((item) => WarrentyModel.fromJson(item)).toList();
          } else {
            final newData = data['data'];
            if (newData != null) {
              _upcomingWarrantyReport = (newData as List<dynamic>)
                  .map((item) => WarrentyModel.fromJson(item))
                  .toList();
            } else {
              _upcomingWarrantyReport = [];
            }
          }

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

  // Amc Notification Report
  List<AmcNotificationModel> _amcNotificationList = [];
  List<AmcNotificationModel> get amcNotificationList => _amcNotificationList;
  bool isAmcNotificationLoading = false;

  Future<void> getAmcNotification(BuildContext context) async {
    isAmcNotificationLoading = true;
    notifyListeners();

    // Default dates if null
    if (fromDate == null) {
      _selectedDateFilterIndex = null;
    }
    formatDate();

    String isDate = "0";
    if (_formattedFromDate.isNotEmpty && _formattedToDate.isNotEmpty) {
      isDate = "1";
    }

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.amcNotification}?From_Date=$formattedFromDate&To_Date=$formattedToDate&Is_Date_Check=$isDate&User_Id=${_selectedUser ?? 0}');

      if (response.statusCode == 200) {
        final data = response.data;
        // print('Amc Notification Response: $data');

        if (data != null && data['list'] != null) {
          if (data['list'] is List) {
            _amcNotificationList = (data['list'] as List)
                .map((e) => AmcNotificationModel.fromJson(e))
                .toList();
          } else {
            _amcNotificationList = [];
          }
        } else {
          _amcNotificationList = [];
        }
      } else {
        _amcNotificationList = [];
        // print('Failed to load amc notification: ${response.statusCode}');
      }
    } catch (e) {
      _amcNotificationList = [];
      print('Error fetching amc notification: $e');
    } finally {
      isAmcNotificationLoading = false;
      notifyListeners();
    }
  }

  // Payment Reminder Report
  List<PaymentReminderModel> _paymentReminderList = [];
  List<PaymentReminderModel> get paymentReminderList => _paymentReminderList;
  bool isPaymentReminderLoading = false;

  Future<void> getPaymentReminders(BuildContext context) async {
    isPaymentReminderLoading = true;
    notifyListeners();

    // Default dates if null
    if (fromDate == null) {
      _selectedDateFilterIndex = null;
    }
    formatDate();

    String isDate = "0";
    if (_formattedFromDate.isNotEmpty && _formattedToDate.isNotEmpty) {
      isDate = "1";
    }

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getPaymentReminders}?From_Date=$formattedFromDate&To_Date=$formattedToDate&Is_Date_Check=$isDate&User_Id=${_selectedUser ?? 0}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['data'] != null) {
          if (data['data'] is List) {
            _paymentReminderList = (data['data'] as List)
                .map((e) => PaymentReminderModel.fromJson(e))
                .toList();
          } else {
            _paymentReminderList = [];
          }
        } else {
          _paymentReminderList = [];
        }
      } else {
        _paymentReminderList = [];
      }
    } catch (e) {
      _paymentReminderList = [];
      print('Error fetching payment reminders: $e');
    } finally {
      isPaymentReminderLoading = false;
      notifyListeners();
    }
  }
}
