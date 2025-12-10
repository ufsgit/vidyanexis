import 'package:flutter/material.dart';
import 'package:techtify/controller/models/dashboard_count_model.dart';
import 'package:techtify/controller/models/dashboard_info_model.dart';
import 'package:techtify/controller/models/dashboard_task_model.dart';
import 'package:techtify/controller/models/follow_up_summary_model.dart';
import 'package:techtify/controller/models/lead_conversion_model.dart';
import 'package:techtify/controller/models/lead_progress_model.dart';
import 'package:techtify/controller/models/search_leads_model.dart';
import 'package:techtify/controller/models/task_allocation_model.dart';
import 'package:techtify/controller/models/work_report_summary_model.dart';
import 'package:techtify/http/http_requests.dart';
import 'package:techtify/http/http_urls.dart';

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
  bool _isLoading = false;
  List<Department>? _departments;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  List<Department>? get departments => _departments;
  String? get errorMessage => _errorMessage;

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

  getLeadConversionChartData(
      {bool isFilter = false, String? filterValue}) async {
    try {
      selectedeLeadConversionValue = filterValue;
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
          endPoint: HttpUrls.enquirySourceConversionReport,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date_Check": isFilter ? "1" : "0"
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

  getLeadProgressionReport({bool isFilter = false, String? filterValue}) async {
    try {
      notifyListeners();
      selectedeLeadProgressValue = filterValue;
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
          endPoint: HttpUrls.leadProgressReport,
          bodyData: {
            "Fromdate": fromDate,
            "Todate": DateTime.now(),
            "Is_Date_Check": isFilter ? "1" : "0"
          }).then((response) {
        print(response);
        if (response.statusCode == 200) {
          List<dynamic> pieData = response.data;

          leadProgressReport = (pieData)
              .map((item) => LeadProgressReportModel.fromJson(item))
              .toList();
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
  getLeadData() async {
    try {
      isDashBoardLoading = true;
      notifyListeners();
      getLeadConversionChartData();
      getLeadProgressionReport();
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
}
