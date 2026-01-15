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

class DashboardProvider extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  final Map<int, bool> _hoverStates = {};
  bool isDashBoardLoading = false;

  String? selectedeLeadConversionValue;
  String? selectedeLeadProgressValue;
  String? selectedeTaskAllocationValue;
  String? selectedDashboardCountValue;
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
  List<SearchLeadModel> searchCustomer = [];
  List<dynamic> taskCount = [];
  List<dynamic> customersCount = [];
  List<TaskInfoDashboardModel> _taskInfoModel = [];
  List<TaskInfoDashboardModel> get taskInfoModel => _taskInfoModel;
  List<DashBoardTaskModel> _dashBoardTasks = [];
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
  Future<void> fetchDashBoardTaskData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.fetchDashBoardTaskData);

      if (response.statusCode == 200) {
        // Parse the entire response as a DashBoardTaskModel
        final dashboardModel = DashBoardTaskModel.fromJson(response.data);

        if (dashboardModel.success == true) {
          // Get the list of departments
          _departments = dashboardModel.getDepartments();
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
    notifyListeners();
  }

  getTaskInfoDashBoard(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getTaskInfoDashBoard}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataitem = data['data'];
          _taskInfoModel = (dataitem as List<dynamic>)
              .map((item) => TaskInfoDashboardModel.fromJson(item))
              .toList();
          notifyListeners();
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

  Future<void> getLeadConversionChartData() async {
    try {
      notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.enquirySourceConversionReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> chartData = response.data[0];
          List<dynamic> countData = response.data[1];

          conversionData = (chartData)
              .map((item) => LeadCoversionChartModel.fromJson(item))
              .toList();
          conversionCountData = (countData)
              .map((item) => CountLeadCoversionChartModel.fromJson(item))
              .toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> getLeadProgressionReport() async {
    try {
      notifyListeners();

      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.leadProgressReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> pieData = response.data;

          leadProgressReport = (pieData)
              .map((item) => LeadProgressReportModel.fromJson(item))
              .toList();
          // final leadProgress = Provider.of<LeadsProvider>(
          //     navigatorKey.currentContext!,
          //     listen: false);
          // leadProgress.formattedFromDate = _formattedFromDate;
          // leadProgress.formattedToDate = _formattedToDate;
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  getFollowUpSummary() async {
    try {
      notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.followUpSummary,
          bodyData: {
            "User": "",
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> followUpData = response.data;

          followUpSummaryData = (followUpData)
              .map((item) => FollowUpSummaryModel.fromJson(item))
              .toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  getTaskAllocationSummary({bool isFilter = false, String? filterValue}) async {
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
      notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.taskAllocationSummary,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date_Check": isFilter ? "1" : "0"
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> taskAllocationData = response.data[0];
          List<dynamic> taskAllocationSummaryStatus = response.data[1];
          taskCount = response.data[2];
          taskAllocationSummaryData = (taskAllocationData)
              .map((item) => TaskAllocationSummaryModel.fromJson(item))
              .toList();
          taskAllocationSummaryDataStatus = (taskAllocationSummaryStatus)
              .map((item) => TaskAllocationStatusModel.fromJson(item))
              .toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  getDashBoardCount({bool isFilter = false, String? filterValue}) async {
    try {
      notifyListeners();
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
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.dashboardCount,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date": isFilter ? "1" : "0"
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> data = response.data;

          dashBoardCountModel =
              (data).map((item) => DashBoardCountModel.fromJson(item)).toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  getWorkSummary({bool isFilter = false, String? filterValue}) async {
    try {
      notifyListeners();
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
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> data = response.data[0];
          customersCount = response.data[1];

          workSummaryReportModel = (data)
              .map((item) => WorkSummaryReportModel.fromJson(item))
              .toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  getCustomers() async {
    try {
      notifyListeners();

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
        }
      });
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  changeTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setHover(int index, bool isHovered) {
    _hoverStates[index] = isHovered;
    notifyListeners();
  }

  bool isHovered(int index) => _hoverStates[index] ?? false;

  Future<void> getLeadEnquiryReport() async {
    try {
      isLeadEnquiryReportLoading = true;
      notifyListeners();
      await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.leadEnquiryReport,
          bodyData: {
            "Fromdate": _formattedFromDate,
            "Todate": _formattedToDate,
            "Is_Date_Check": _formattedFromDate.isNotEmpty ? "1" : "0",
            "User": _selectedUser
          }).then((response) {
        if (response.statusCode == 200) {
          List<dynamic> pieData = response.data;
          leadEnquiryReport = (pieData)
              .map((item) => LeadEnquiryReportModel.fromJson(item))
              .toList();
        }
      });
    } catch (e) {
      print(e);
    } finally {
      isLeadEnquiryReportLoading = false;
      notifyListeners();
    }
  }

  Future<void> getLeadData({String? filterValue}) async {
    try {
      if (filterValue != null) {
        setCommonDateFilter(filterValue);
      }
      isDashBoardLoading = true;
      notifyListeners();
      await Future.wait<void>([
        getLeadConversionChartData(),
        getLeadProgressionReport(),
        getLeadEnquiryReport(),
      ]);
    } finally {
      isDashBoardLoading = false;
      notifyListeners();
    }
  }

  getWorkData() async {
    try {
      isDashBoardLoading = true;
      notifyListeners();
      getTaskAllocationSummary();
      getDashBoardCount();
      getWorkSummary();
    } finally {
      isDashBoardLoading = false;
      notifyListeners();
    }
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
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
