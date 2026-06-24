import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class TaskReportProvider extends ChangeNotifier {
  List<TaskReportModel> _taskReport = [];
  List<TaskReportModel> get taskReport => _taskReport;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  int _selectedSortOption =
      0; // 0: Default, 1: ID, 2: Creation Date, 3: Followup Date
  int get selectedSortOption => _selectedSortOption;

  void setSortOption(int option, BuildContext context) {
    _selectedSortOption = option;
    notifyListeners();
    getSearchTaskReport(context);
  }

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
  String _TaskType = '';

  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;
  String get TaskType => _TaskType;
  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedTaskType;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  int? get selectedTaskType => _selectedTaskType;

  List<int> _selectedStatusIds = [0];
  List<int> get selectedStatusIds => _selectedStatusIds;

  void toggleStatus(int value) {
    if (value == 0) {
      _selectedStatusIds = [0];
    } else {
      if (_selectedStatusIds.contains(0)) {
        _selectedStatusIds.remove(0);
      }
      if (_selectedStatusIds.contains(value)) {
        _selectedStatusIds.remove(value);
        if (_selectedStatusIds.isEmpty) {
          _selectedStatusIds = [0];
        }
      } else {
        _selectedStatusIds.add(value);
      }
    }
    _Status = _selectedStatusIds.join(',');
    notifyListeners();
  }

  int _pageIndex = 1;
  final int _pageSize = 20;
  int _totalSize = 0;
  int _totalPages = 1;

  int get pageIndex => _pageIndex;
  int get pageSize => _pageSize;
  int get totalSize => _totalSize;
  int get totalPages => _totalPages;

  void nextPage() {
    _pageIndex++;
    notifyListeners();
  }

  void previousPage() {
    if (_pageIndex > 1) {
      _pageIndex--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pageIndex = page;
      notifyListeners();
    }
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilter(bool filter) {
    _isFilter = filter;
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
    toggleStatus(
        newStatus); // Use toggleStatus for consistency or update directly
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setTaskType(int newStatus) {
    _selectedTaskType = newStatus;
    print(_selectedTaskType.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedStatusIds = [0]; // Reset multi-select status
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _selectedTaskType = null;
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _fromDateS = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _toDateS = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    _formattedFromDate = _fromDateS;
    _formattedToDate = _toDateS;
    _Status = '0'; // Default to "All"
    _AssignedTo = '';
    _TaskType = '';
    _isFilter = false;
    _pageIndex = 1;
    _hasFetched = false;
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo, String taskType) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _TaskType = taskType;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  //task report
  Future<bool> getSearchTaskReport(BuildContext context,
      {bool isLoadMore = false, bool resetPage = false}) async {
    bool result = false;
    try {
      print("DEBUG: getSearchTaskReport started. resetPage: $resetPage");
      if (resetPage) {
        _pageIndex = 1;
      }
      if (!isLoadMore && _pageIndex == 1 && !resetPage) {
        _taskReport = [];
      }
      if (!isLoadMore) {
        print("DEBUG: showing loader");
        Loader.showLoader(context);
        if (resetPage) {
          _taskReport = [];
        }
      }

      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      String toUserId = (_selectedUser ?? 0).toString();

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      int startLimit = (_pageIndex - 1) * _pageSize + 1;
      int endLimit = _pageIndex * _pageSize;

      print(
          "DEBUG: calling API with Page_Index1: $startLimit, Page_Index2: $endLimit");
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchTaskReport,
          bodyData: {
            'Customer_Name': _Search,
            'Task_Status_Id': _Status,
            'To_User': toUserId,
            'Is_Date': isDate,
            'Fromdate': _fromDateS,
            'Todate': _toDateS,
            'Task_Type_Id': _TaskType,
            'Page_Index': _pageIndex,
            'PageSize': _pageSize,
            'Order_By_': _selectedSortOption,
          });

      if (response.statusCode == 200) {
        final data = response.data;
        print("DEBUG: API success, status 200");

        if (data != null) {
          final dataMap = data is Map ? data['data'] ?? data : data;

          if (dataMap is List) {
            final allTasks =
                dataMap.map((item) => TaskReportModel.fromJson(item)).toList();

            print("DEBUG: Total items received from API: ${allTasks.length}");

            if (allTasks.isNotEmpty) {
              // Check if the last item is a metadata row (pattern in Leads/Customer Reports)
              bool likelyMetadataRow = allTasks.length > 1 &&
                  allTasks.last.taskId == 0 &&
                  allTasks.last.customerId > 0;

              if (likelyMetadataRow) {
                _totalSize = allTasks.last.customerId;
                allTasks.removeLast();
              }

              // Fallback: If server returns more than pageSize (e.g. 100 instead of 20),
              // perform client-side slicing to ensure the user sees exactly what they asked for.
              if (allTasks.length > _pageSize) {
                print(
                    "DEBUG: Server returned unpaginated list. Slicing for page $_pageIndex.");
                int start = (_pageIndex - 1) * _pageSize;
                int end = _pageIndex * _pageSize;

                if (start < allTasks.length) {
                  _taskReport = allTasks.sublist(
                      start, end > allTasks.length ? allTasks.length : end);
                } else {
                  _taskReport = [];
                }

                if (!likelyMetadataRow) {
                  _totalSize = allTasks.length;
                }
              } else {
                // Server seems to have paginated the results
                _taskReport = allTasks;

                if (!likelyMetadataRow) {
                  if (allTasks.length == _pageSize) {
                    _totalSize =
                        _pageIndex * _pageSize + 1; // Assume more pages
                  } else {
                    _totalSize = (_pageIndex - 1) * _pageSize + allTasks.length;
                  }
                }
              }
            } else {
              _taskReport = [];
              _totalSize = 0;
            }

            _totalPages = (_totalSize / _pageSize).ceil();
            if (_totalPages == 0) _totalPages = 1;

            print(
                "DEBUG: Final taskReport count: ${_taskReport.length}, Total Size: $_totalSize, Total Pages: $_totalPages");
            _hasFetched = true;
            result = true;
          } else {
            print("DEBUG: dataMap is not a List: $dataMap");
            _hasFetched = true;
          }
        } else {
          print("DEBUG: response data is null");
          _hasFetched = true;
        }
      } else {
        print("DEBUG: API error, status: ${response.statusCode}");
        if (!isLoadMore) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Exception in getSearchTaskReport: $e');
      if (!isLoadMore) {
        _hasFetched = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      if (!isLoadMore) {
        print("DEBUG: stopping loader");
        Loader.stopLoader(context);
      }
      notifyListeners();
    }
    return result;
  }

  Future<void> getFollowupReports(BuildContext context) async {
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

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchFollowupReports,
          bodyData: {
            'Customer_Name': _Search,
            'Task_Status_Id': _Status,
            'To_User': toUserId,
            'Is_Date': isDate,
            'Fromdate': _fromDateS,
            'Todate': _toDateS,
            'Task_Type_Id': _TaskType,
          });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _taskReport = (data as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
              .toList();
        }
        Loader.stopLoader(context);
        notifyListeners();
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      _hasFetched = true;
      Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
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
          endPoint: HttpUrls.searchTaskReport,
          bodyData: {
            'Customer_Name': _Search,
            'Task_Status_Id': _Status,
            'To_User': toUserId,
            'Is_Date': isDate,
            'Fromdate': _fromDateS,
            'Todate': _toDateS,
            'Task_Type_Id': _TaskType,
          });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _taskReport = (data as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
              .toList();

          _hasFetched = true;
          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<List<TaskReportModel>> fetchAllTasksForExport(
      BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      String toUserId = (_selectedUser ?? 0).toString();

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchTaskReport,
          bodyData: {
            'Customer_Name': _Search,
            'Task_Status_Id': _Status,
            'To_User': toUserId,
            'Is_Date': isDate,
            'Fromdate': _fromDateS,
            'Todate': _toDateS,
            'Task_Type_Id': _TaskType,
            'Page_Index': 1,
            'PageSize': 10000, // Fetch a large number for export
          });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataMap = data is Map ? data['data'] ?? data : data;
          if (dataMap is List) {
            final allTasks =
                dataMap.map((item) => TaskReportModel.fromJson(item)).toList();

            // Remove metadata row if present
            if (allTasks.isNotEmpty &&
                allTasks.last.taskId == 0 &&
                allTasks.last.customerId > 0) {
              allTasks.removeLast();
            }
            return allTasks;
          }
        }
      }
      return [];
    } catch (e) {
      print('DEBUG: Exception in fetchAllTasksForExport: $e');
      return [];
    } finally {
      Loader.stopLoader(context);
    }
  }
}
