import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class ChartData {
  final DateTime date;
  final double value;

  ChartData(this.date, this.value);
}

class SolarLeadReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SearchLeadModel> _allLeads = [];
  
  List<ChartData> _leadsCreatedPerDay = [];
  List<ChartData> _conversionsPerDay = [];
  List<ChartData> _projectCostPerDay = [];

  List<ChartData> get leadsCreatedPerDay => _leadsCreatedPerDay;
  List<ChartData> get conversionsPerDay => _conversionsPerDay;
  List<ChartData> get projectCostPerDay => _projectCostPerDay;

  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;

  set formattedFromDate(String value) {
    _formattedFromDate = value;
    notifyListeners();
  }

  set formattedToDate(String value) {
    _formattedToDate = value;
    notifyListeners();
  }

  bool _isFilter = false;
  bool get isFilter => _isFilter;
  String _search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _status = '';
  String _assignedTo = '';

  String get Search => _search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _status;
  String get AssignedTo => _assignedTo;

  int _selectedStatus = 0;
  int _selectedUser = 0;
  int? _selectedDateFilterIndex;

  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int get selectedStatus => _selectedStatus;
  int get selectedUser => _selectedUser;

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
    final from = _fromDate;
    if (from != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(from);
    } else {
      _formattedFromDate = '';
    }
    final to = _toDate;
    if (to != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(to);
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

  void setUserFilterStatus(int newUser) {
    _selectedUser = newUser;
    notifyListeners();
  }

  void removeStatus() {
    _selectedStatus = 0;
    _selectedUser = 0;
    _selectedDateFilterIndex = null;
    _search = '';
    _fromDateS = '';
    _toDateS = '';
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo) {
    _search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _status = status;
    _assignedTo = assignedTo;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    formatDate();
    notifyListeners();
  }

  Future<void> getSolarLeadReport(BuildContext context, String search, String fromDate, String toDate,
      String status, String assignedTo) async {
    setTaskSearchCriteria(search, fromDate, toDate, status, assignedTo);
    _isLoading = true;
    notifyListeners();

    try {
      const int poolLimit = 2000;
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.searchLead}?lead_Name=&Is_Date=0&Fromdate=&Todate=&Page_Index1=1&Page_Index2=$poolLimit'
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _allLeads = data
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();
          
          if (_allLeads.isNotEmpty && _allLeads.last.customerId == 0) {
             _allLeads.removeLast();
          }

          debugPrint("Total leads fetched for processing: ${_allLeads.length}");
          _processData();
        }
      }
    } catch (e) {
      debugPrint('Error fetching solar lead report data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == "null") return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        if (dateStr.contains('/')) {
          return DateFormat('dd/MM/yyyy').parse(dateStr);
        } else if (dateStr.contains('-') && dateStr.split('-')[0].length == 2) {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        }
      } catch (_) {}
    }
    return null;
  }

  void _processData() {
    Map<String, int> leadsCreatedGrouped = {};
    Map<String, int> conversionsGrouped = {};
    Map<String, double> projectCostGrouped = {};

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    DateTime rangeStart = _fromDate ?? DateTime(2000);
    DateTime rangeEnd = _toDate ?? DateTime.now().add(const Duration(days: 1));
    rangeEnd = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 23, 59, 59);

    for (var lead in _allLeads) {
      // Apply Search Filter locally
      if (_search.isNotEmpty) {
        if (!lead.customerName.toLowerCase().contains(_search.toLowerCase())) {
          continue;
        }
      }

      // Apply Status Filter locally
      if (_selectedStatus != 0) {
        if (lead.statusId != _selectedStatus) {
          continue;
        }
      }

      // Apply User Filter locally
      if (_selectedUser != 0) {
        if (lead.toUserId != _selectedUser) {
          continue;
        }
      }

      DateTime? createdDate = _parseDate(lead.entryDate);
      if (createdDate != null) {
        if (createdDate.isAfter(rangeStart.subtract(const Duration(seconds: 1))) && 
            createdDate.isBefore(rangeEnd.add(const Duration(seconds: 1)))) {
          String key = formatter.format(createdDate);
          leadsCreatedGrouped[key] = (leadsCreatedGrouped[key] ?? 0) + 1;
        }
      }

      DateTime? conversionDate = _parseDate(lead.registeredDate);
      if (conversionDate != null) {
        if (conversionDate.isAfter(rangeStart.subtract(const Duration(seconds: 1))) && 
            conversionDate.isBefore(rangeEnd.add(const Duration(seconds: 1)))) {
          String key = formatter.format(conversionDate);
          conversionsGrouped[key] = (conversionsGrouped[key] ?? 0) + 1;
          
          String cleanCost = lead.totalProjectCost.replaceAll(RegExp(r'[^0-9.]'), '');
          double cost = double.tryParse(cleanCost) ?? 0.0;
          projectCostGrouped[key] = (projectCostGrouped[key] ?? 0.0) + cost;
        }
      }
    }

    _leadsCreatedPerDay = leadsCreatedGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _conversionsPerDay = conversionsGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _projectCostPerDay = projectCostGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    debugPrint("Conversion chart data points: ${_conversionsPerDay.length}");
    debugPrint("Project cost chart data points: ${_projectCostPerDay.length}");
  }
}

