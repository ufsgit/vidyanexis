import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/lead_check_in_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class LeadCheckInReportProvider extends ChangeNotifier {
  List<LeadCheckIn> _reports = [];
  List<LeadCheckIn> get reports => _reports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedUserId;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedUserId => _selectedUserId;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  bool _isFilter = true;
  String _leadSearch = '';
  int? _selectedDateFilterIndex;

  bool get isFilter => _isFilter;
  String get leadSearch => _leadSearch;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setLeadSearch(String value) {
    _leadSearch = value;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  void setDateFilter(String title) {
    DateTime now = DateTime.now();
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
    }
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      notifyListeners();
    }
  }

  void setDates(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  void setUserId(int? userId) {
    _selectedUserId = userId;
    notifyListeners();
  }

  void formatDate() {
    notifyListeners();
  }

  void setTaskSearchCriteria(
    String search,
    String fromDate,
    String toDate,
    String userId,
  ) {
    _leadSearch = search;
    if (fromDate.isNotEmpty) _fromDate = DateTime.parse(fromDate);
    if (toDate.isNotEmpty) _toDate = DateTime.parse(toDate);
    _selectedUserId = int.tryParse(userId);
    notifyListeners();
  }

  String get fromDateS => formattedFromDate;
  String get toDateS => formattedToDate;

  String get userId => (_selectedUserId ?? 0).toString();
  String get Search => _leadSearch;
  int? get Status => 0; // Not used
  int? get AssignedTo => _selectedUserId;
  int? get TaskType => 0; // Not used

  void removeStatus() {
    notifyListeners();
  }

  Future<void> fetchReports(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();
      Loader.showLoader(context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String loginUserId = preferences.getString('userId') ?? "0";

      // Using parameters as requested: User_Id, From_Date, To_Date
      // Mapping them to the expected API format based on LeadCheckInProvider logic
      final String userIdParam = (_selectedUserId ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.getCheckin}?From_Date=$formattedFromDate&To_Date=$formattedToDate&User_Id=$userIdParam&Lead_Name=$_leadSearch&login_user_id=$loginUserId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final leadResponse = LeadCheckInResponse.fromJson(data);
          _reports = leadResponse.data ?? [];
        } else {
          _reports = [];
        }
      } else {
        _reports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch reports')),
          );
        }
      }
    } catch (e) {
      log('Error fetching lead check-in reports: $e');
      _reports = [];
    } finally {
      _isLoading = false;
      Loader.stopLoader(context);
      notifyListeners();
    }
  }

  String calculateTimeDifference(LeadCheckIn record) {
    if (record.timeDifference != null && record.timeDifference!.isNotEmpty) {
      return record.timeDifference!;
    }

    String? checkin = record.checkinDate;
    String? checkout = record.checkoutDate;

    if (checkin == null ||
        checkout == null ||
        checkin.isEmpty ||
        checkout.isEmpty) {
      return 'N/A';
    }

    try {
      DateTime checkinTime = DateTime.parse(checkin);
      DateTime checkoutTime = DateTime.parse(checkout);

      Duration diff = checkoutTime.difference(checkinTime);

      if (diff.isNegative) return 'Invalid Range';

      int hours = diff.inHours;
      int minutes = diff.inMinutes % 60;

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    } catch (e) {
      log('Error calculating time difference: $e');
      return 'Err';
    }
  }

  void clearFilters() {
    _fromDate = null;
    _toDate = null;
    _selectedUserId = null;
    _leadSearch = '';
    _selectedDateFilterIndex = null;
    _reports = [];
    notifyListeners();
  }
}
