import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/dashboard_count_model.dart';
import 'package:vidyanexis/controller/models/dashboard_info_model.dart';
import 'package:vidyanexis/controller/models/dashboard_task_model.dart';
import 'package:vidyanexis/controller/models/follow_up_summary_model.dart';
import 'package:vidyanexis/controller/models/lead_conversion_model.dart';
import 'package:vidyanexis/controller/models/lead_progress_model.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/models/task_allocation_model.dart';
import 'package:vidyanexis/controller/models/work_report_summary_model.dart';
import 'package:vidyanexis/controller/models/lead_enquiry_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

// Top-level parsing functions for compute()
List<TaskInfoDashboardModel> _parseTaskInfo(List<dynamic> data) {
  return data.map((item) => TaskInfoDashboardModel.fromJson(item)).toList();
}

DashBoardTaskModel _parseDashBoardTask(Map<String, dynamic> data) {
  return DashBoardTaskModel.fromJson(data);
}

List<DashBoardCountModel> _parseDashBoardCount(List<dynamic> data) {
  return data.map((item) => DashBoardCountModel.fromJson(item)).toList();
}

List<LeadCoversionChartModel> _parseLeadConversion(List<dynamic> data) {
  return data.map((item) => LeadCoversionChartModel.fromJson(item)).toList();
}

List<CountLeadCoversionChartModel> _parseLeadConversionCount(
    List<dynamic> data) {
  return data
      .map((item) => CountLeadCoversionChartModel.fromJson(item))
      .toList();
}

List<LeadProgressReportModel> _parseLeadProgress(List<dynamic> data) {
  return data.map((item) => LeadProgressReportModel.fromJson(item)).toList();
}

List<LeadEnquiryReportModel> _parseLeadEnquiry(List<dynamic> data) {
  return data.map((item) => LeadEnquiryReportModel.fromJson(item)).toList();
}

List<FollowUpSummaryModel> _parseFollowUpSummary(List<dynamic> data) {
  return data.map((item) => FollowUpSummaryModel.fromJson(item)).toList();
}

List<TaskAllocationSummaryModel> _parseTaskAllocationSummary(
    List<dynamic> data) {
  return data.map((item) => TaskAllocationSummaryModel.fromJson(item)).toList();
}

List<TaskAllocationStatusModel> _parseTaskAllocationStatus(List<dynamic> data) {
  return data.map((item) => TaskAllocationStatusModel.fromJson(item)).toList();
}

List<WorkSummaryReportModel> _parseWorkSummary(List<dynamic> data) {
  return data.map((item) => WorkSummaryReportModel.fromJson(item)).toList();
}

class DashboardProvider extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  final Map<int, bool> _hoverStates = {};
  bool isDashBoardLoading = false;
  bool isLeadLoaded = false;
  bool isWorkLoaded = false;
  bool isCustomerLoaded = false;
  bool isTaskInfoLoaded = false;
  bool isDashboardCountLoaded = false;
  bool isTaskOverviewLoaded = false;
  bool isAmcLoaded = false;
  bool isPaymentLoaded = false;

  String? selectedeLeadConversionValue;
  String? selectedeLeadProgressValue;
  String? selectedeTaskAllocationValue;
  String? selectedDashboardCountValue;

  /// keyword for lead dashboard count (New_Leads, Missed_Leads, Pending_Followups, Transferred_Leads etc)
  String? selectedLeadCountKeyword;
  String? selectedWorkSummaryValue;
  String? selectedLeadEnquiryReportValue;
  List<LeadCoversionChartModel> conversionData = [];
  List<WorkSummaryReportModel> workSummaryReportModel = [];
  List<CountLeadCoversionChartModel> conversionCountData = [];
  List<LeadProgressReportModel> leadProgressReport = [];
  List<FollowUpSummaryModel> followUpSummaryData = [];
  List<TaskAllocationSummaryModel> taskAllocationSummaryData = [];
  List<TaskAllocationStatusModel> taskAllocationSummaryDataStatus = [];
  List<DashBoardCountModel> dashBoardCountModel = [];
  List<DashBoardCountModel> leadDashboardCountData = [];

  /// map from keyword string to count returned by Get_Lead_Dashboard
  final Map<String, int> leadCountMap = {};
  List<SearchLeadModel> searchCustomer = [];
  List<dynamic> taskCount = [];
  List<dynamic> customersCount = [];
  List<TaskInfoDashboardModel> _taskInfoModel = [];
  List<TaskInfoDashboardModel> get taskInfoModel => _taskInfoModel;
  final List<DashBoardTaskModel> _dashBoardTasks = [];
  List<DashBoardTaskModel>? get dashBoardTasks => _dashBoardTasks;
  List<LeadEnquiryReportModel> leadEnquiryReport = [];
  bool isLeadEnquiryReportLoading = false;
  bool _isLoading = false;
  List<Department>? _departments;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  List<Department>? get departments => _departments;
  String? get errorMessage => _errorMessage;
  int _selectedUser = 0;
  int get selectedUser => _selectedUser;

  // Pagination for Task Summary (Frontend only)
  int _taskCurrentPage = 0;
  final int _taskItemsPerPage = 50;
  int get taskCurrentPage => _taskCurrentPage;

  int get taskItemsPerPage => _taskItemsPerPage;

  // Total items = actual list length (not the backend marker)
  int get taskTotalCount => _taskInfoModel.length;

  int get taskStartLimit {
    if (_taskInfoModel.isEmpty) return 0;
    return (_taskCurrentPage * _taskItemsPerPage) + 1;
  }

  int get taskEndLimit {
    int end = (_taskCurrentPage + 1) * _taskItemsPerPage;
    return end > _taskInfoModel.length ? _taskInfoModel.length : end;
  }

  List<TaskInfoDashboardModel> get pagedTaskInfoModel {
    if (_taskInfoModel.isEmpty) return [];
    int start = _taskCurrentPage * _taskItemsPerPage;
    int end = start + _taskItemsPerPage;
    if (start >= _taskInfoModel.length) {
      // Page out of range, reset to last valid page
      _taskCurrentPage =
          ((_taskInfoModel.length - 1) / _taskItemsPerPage).floor();
      start = _taskCurrentPage * _taskItemsPerPage;
      end = start + _taskItemsPerPage;
    }
    return _taskInfoModel.sublist(
        start, end > _taskInfoModel.length ? _taskInfoModel.length : end);
  }

  // Date filter properties
  int? _selectedDateFilterIndex;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';

  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;

  // Fetch dashboard task data
  Future<void> fetchDashBoardTaskData({bool shouldNotify = true}) async {
    if (isTaskOverviewLoaded) return;
    _isLoading = true;
    _errorMessage = null;
    if (shouldNotify) notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.fetchDashBoardTaskData);

      if (response.statusCode == 200) {
        // Use compute for parsing heavy JSON
        final dashboardModel = await compute(
            _parseDashBoardTask, response.data as Map<String, dynamic>);

        if (dashboardModel.success == true) {
          _departments = dashboardModel.getDepartments();
          isTaskOverviewLoaded = true;
          _errorMessage = null;
        } else {
          _errorMessage = dashboardModel.message ?? 'Unknown error occurred';
          _departments = [];
        }
      } else {
        _errorMessage = 'Failed to load dashboard data: ${response.statusCode}';
        _departments = [];
      }
    } catch (error) {
      _errorMessage = 'Exception occurred: $error';
      _departments = [];
    }

    _isLoading = false;
    if (shouldNotify) notifyListeners();
  }

  Future<void> getTaskInfoDashBoard(BuildContext context,
      {bool shouldNotify = true}) async {
    if (isTaskInfoLoaded) return;
    try {
      isDashBoardLoading = true;
      if (shouldNotify) notifyListeners();
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getTaskInfoDashBoard,
          bodyData: {
            "Page_Index1": 1,
            "Page_Index2": 1000,
          });
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataitem = data['data'];

          // Use compute for heavy JSON parsing
          List<TaskInfoDashboardModel> tempData =
              await compute(_parseTaskInfo, dataitem as List<dynamic>);

          if (tempData.isNotEmpty) {
            tempData.removeLast();
            _taskInfoModel = tempData;
            _taskCurrentPage = 0;
            isTaskInfoLoaded = true;
          } else {
            _taskInfoModel = [];
            _taskCurrentPage = 0;
          }
        }
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        });
      }
    } catch (e) {
      print('Exception occurred: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      });
    } finally {
      isDashBoardLoading = false;
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> fetchNextPageTasks(BuildContext context,
      {bool shouldNotify = true}) async {
    if ((_taskCurrentPage + 1) * _taskItemsPerPage < _taskInfoModel.length) {
      _taskCurrentPage++;
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> fetchPreviousPageTasks(BuildContext context,
      {bool shouldNotify = true}) async {
    if (_taskCurrentPage > 0) {
      _taskCurrentPage--;
      if (shouldNotify) notifyListeners();
    }
  }

  void setCommonDateFilter(String? filterValue) {
    if (filterValue == null || filterValue == "all") {
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
      selectedeLeadConversionValue = null;
      selectedeLeadProgressValue = null;
      selectedLeadEnquiryReportValue = null;
    } else {
      selectedeLeadConversionValue = filterValue;
      selectedeLeadProgressValue = filterValue;
      selectedLeadEnquiryReportValue = filterValue;
      DateTime from;
      switch (filterValue) {
        case 'tdy':
          from = DateTime.now();
          break;
        case 'th_wk':
          from = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'th_mnt':
          from = DateTime.now().subtract(const Duration(days: 30));
          break;
        default:
          from = DateTime.now();
      }
      _fromDate = from;
      _toDate = DateTime.now();
      formatDate();
    }
    notifyListeners();
  }

  Future<void> getLeadConversionChartData({bool shouldNotify = true}) async {
    try {
      if (shouldNotify) notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.enquirySourceConversionReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> chartData = response.data[0];
          List<dynamic> countData = response.data[1];

          conversionData = await compute(_parseLeadConversion, chartData);
          conversionCountData =
              await compute(_parseLeadConversionCount, countData);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getLeadProgressionReport({bool shouldNotify = true}) async {
    try {
      if (shouldNotify) notifyListeners();

      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.leadProgressReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> pieData = response.data;
          leadProgressReport = await compute(_parseLeadProgress, pieData);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getFollowUpSummary({bool shouldNotify = true}) async {
    try {
      if (shouldNotify) notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.followUpSummary,
          bodyData: {
            "User": "",
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> followUpData = response.data;
          followUpSummaryData =
              await compute(_parseFollowUpSummary, followUpData);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getTaskAllocationSummary(
      {bool isFilter = false,
      String? filterValue,
      bool shouldNotify = true}) async {
    try {
      selectedeTaskAllocationValue = filterValue;
      late DateTime fromDate;

      switch (filterValue) {
        case 'tdy':
          fromDate = DateTime.now();

          break;
        case 'th_wk':
          fromDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'th_mnt':
          fromDate = DateTime.now().subtract(const Duration(days: 30));
        default:
          fromDate = DateTime.now();
      }
      if (shouldNotify) notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.taskAllocationSummary,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date_Check": isFilter ? "1" : "0"
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> taskAllocationData = response.data[0];
          List<dynamic> taskAllocationSummaryStatus = response.data[1];
          taskCount = response.data[2];

          taskAllocationSummaryData =
              await compute(_parseTaskAllocationSummary, taskAllocationData);
          taskAllocationSummaryDataStatus = await compute(
              _parseTaskAllocationStatus, taskAllocationSummaryStatus);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  /// Generic dashboard count (work summary) - also supports an optional
  /// keyword parameter that will be forwarded to the server. The backend may
  /// ignore the value if it only understands lead-related keywords.
  Future<void> getDashBoardCount(
      {bool isFilter = false,
      String? filterValue,
      String? keyword,
      bool shouldNotify = true}) async {
    if (isDashboardCountLoaded && !isFilter) return;
    try {
      if (shouldNotify) notifyListeners();
      selectedDashboardCountValue = filterValue;
      late DateTime fromDate;

      switch (filterValue) {
        case 'tdy':
          fromDate = DateTime.now();

          break;
        case 'th_wk':
          fromDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'th_mnt':
          fromDate = DateTime.now().subtract(const Duration(days: 30));
        default:
          fromDate = DateTime.now();
      }

      final body = {
        "Fromdate": fromDate,
        "Todate": DateTime.now(),
        "Is_Date": isFilter ? "1" : "0"
      };
      if (keyword != null && keyword.isNotEmpty) {
        body["Keyword"] = keyword;
      }

      await HttpRequest.httpGetRequest(
              endPoint: HttpUrls.dashboardCount, bodyData: body)
          .then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> data = response.data;
          dashBoardCountModel = await compute(_parseDashBoardCount, data);
          isDashboardCountLoaded = true;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getWorkSummary(
      {bool isFilter = false,
      String? filterValue,
      bool shouldNotify = true}) async {
    try {
      if (shouldNotify) notifyListeners();
      selectedWorkSummaryValue = filterValue;
      late DateTime fromDate;

      switch (filterValue) {
        case 'tdy':
          fromDate = DateTime.now();

          break;
        case 'th_wk':
          fromDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case 'th_mnt':
          fromDate = DateTime.now().subtract(const Duration(days: 30));
        default:
          fromDate = DateTime.now();
      }
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.workSummary,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date_Check": isFilter ? "1" : "0"
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> data = response.data[0];
          customersCount = response.data[1];

          workSummaryReportModel = await compute(_parseWorkSummary, data);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getCustomers({bool shouldNotify = true}) async {
    if (isCustomerLoaded) return;
    try {
      if (shouldNotify) notifyListeners();

      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchCustomer,
          bodyData: {
            "Customer_Name": "",
            "Is_Date": 0,
            "Fromdate": '',
            "Todate": '',
            "To_User_Id": 0,
            "Status_Id": 0,
            "Page_Index1": 1,
            "Page_Index2": 10,
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> data = response.data;

          // searchCustomer =
          //     (data).map((item) => SearchLeadModel.fromJson(item)).toList();
          List tempData =
              (data).map((item) => SearchLeadModel.fromJson(item)).toList();
          tempData.removeLast();

          searchCustomer = List.from(tempData);
          isCustomerLoaded = true;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  void changeTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> loadDataForTab(int activeTab, BuildContext context) async {
    switch (activeTab) {
      case 0: // Leads Overview
        await getLeadData();
        break;
      case 1: // Work Overview
        await getWorkData();
        break;
      case 2: // Task Overview
        await fetchDashBoardTaskData();
        break;
      case 3: // Task Summary
        await getTaskInfoDashBoard(context);
        break;
      case 4: // Amc Notification
        await Provider.of<WarrentyReportProvider>(context, listen: false)
            .getAmcNotification(context);
        isAmcLoaded = true;
        break;
      case 5: // Payment Reminders
        await Provider.of<WarrentyReportProvider>(context, listen: false)
            .getPaymentReminders(context);
        isPaymentLoaded = true;
        break;
      case 6: // Dashboard count
        await getLeadDashboardCount();
        break;
    }
  }

  void setHover(int index, bool isHovered) {
    _hoverStates[index] = isHovered;
    notifyListeners();
  }

  bool isHovered(int index) => _hoverStates[index] ?? false;

  Future<void> getLeadEnquiryReport({bool shouldNotify = true}) async {
    try {
      isLeadEnquiryReportLoading = true;
      if (shouldNotify) notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.leadEnquiryReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> pieData = response.data;
          leadEnquiryReport = await compute(_parseLeadEnquiry, pieData);
        }
      });
    } catch (e) {
      print(e);
    } finally {
      isLeadEnquiryReportLoading = false;
      if (shouldNotify) notifyListeners();
    }
  }

  /// like: [{"New_Leads": 1, "Missed_Leads": 117, ...}]
  Future<void> getLeadDashboardCount({bool shouldNotify = true}) async {
    if (isDashboardCountLoaded) return;
    try {
      if (shouldNotify) notifyListeners();

      final body = {
        "Fromdate": _formattedFromDate,
        "Todate": _formattedToDate,
        "Is_Date": _formattedFromDate.isNotEmpty ? "1" : "0",
        "User": _selectedUser
      };

      await HttpRequest.httpGetRequest(
              endPoint: HttpUrls.getLeadDashboard, bodyData: body)
          .then((response) async {
        if (response.statusCode == 200) {
          List<dynamic> data = response.data;
          if (data.isNotEmpty && data.first is Map) {
            Map<String, dynamic> counts = data.first;
            leadCountMap.clear();
            counts.forEach((key, value) {
              if (value is int) {
                leadCountMap[key] = value;
              }
            });
          }
          isDashboardCountLoaded = true;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getLeadData(
      {String? filterValue, bool shouldNotify = true}) async {
    if (isLeadLoaded && filterValue == null) return;
    try {
      if (filterValue != null) {
        setCommonDateFilter(filterValue);
      }
      isDashBoardLoading = true;
      if (shouldNotify) notifyListeners();
      // Batch API calls and notify only once at the end
      await Future.wait<void>([
        getLeadConversionChartData(shouldNotify: false),
        getLeadProgressionReport(shouldNotify: false),
        getLeadEnquiryReport(shouldNotify: false),
        getLeadDashboardCount(shouldNotify: false),
      ]);
      isLeadLoaded = true;
    } finally {
      isDashBoardLoading = false;
      if (shouldNotify) notifyListeners();
    }
  }

  Future<void> getWorkData({bool shouldNotify = true}) async {
    if (isWorkLoaded) return;
    try {
      isDashBoardLoading = true;
      if (shouldNotify) notifyListeners();
      // Batch updates
      await Future.wait([
        getTaskAllocationSummary(shouldNotify: false),
        getDashBoardCount(shouldNotify: false),
        getWorkSummary(shouldNotify: false),
      ]);
      isWorkLoaded = true;
    } finally {
      isDashBoardLoading = false;
      if (shouldNotify) notifyListeners();
    }
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  // updateAllLeadKeywords removed as getLeadDashboardCount fetch all counts in one go

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
}
