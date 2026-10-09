import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/task_deadline_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class TaskDeadlineReportProvider extends ChangeNotifier {
  List<TaskDeadlineReportModel> _allReports = [];
  List<TaskDeadlineReportModel> get allReports => _allReports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  int? _selectedTaskTypeId = 0;
  int? get selectedTaskTypeId => _selectedTaskTypeId;

  int? _selectedToUserId = 0;
  int? get selectedToUserId => _selectedToUserId;

  int? _selectedDepartmentId = 0;
  int? get selectedDepartmentId => _selectedDepartmentId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Pagination
  int _currentPage = 1;
  int _pageSize = 20;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setTaskTypeId(int? id, BuildContext context) {
    _selectedTaskTypeId = id ?? 0;
    _currentPage = 1;
    notifyListeners();
    fetchReports(context);
  }

  void setToUserId(int? id, BuildContext context) {
    _selectedToUserId = id ?? 0;
    _currentPage = 1;
    notifyListeners();
    fetchReports(context);
  }

  void setDepartmentId(int? id, BuildContext context) {
    _selectedDepartmentId = id ?? 0;
    _currentPage = 1;
    notifyListeners();
    fetchReports(context);
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _currentPage = 1;
    notifyListeners();
  }

  List<TaskDeadlineReportModel> get filteredReports {
    if (_searchQuery.isEmpty) {
      return _allReports;
    }
    return _allReports.where((item) {
      final customer = (item.customerName ?? '').toLowerCase();
      final phone = (item.phoneNumber ?? '').toLowerCase();
      final taskType = (item.taskTypeName ?? '').toLowerCase();
      final user = (item.toUserName ?? '').toLowerCase();
      final status = (item.taskStatusName ?? '').toLowerCase();
      final taskId = (item.taskId?.toString() ?? '').toLowerCase();

      return customer.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          taskType.contains(_searchQuery) ||
          user.contains(_searchQuery) ||
          status.contains(_searchQuery) ||
          taskId.contains(_searchQuery);
    }).toList();
  }

  List<TaskDeadlineReportModel> get paginatedReports {
    final filtered = filteredReports;
    final startIndex = (_currentPage - 1) * _pageSize;
    if (startIndex >= filtered.length) {
      return [];
    }
    final endIndex = (startIndex + _pageSize > filtered.length)
        ? filtered.length
        : startIndex + _pageSize;
    return filtered.sublist(startIndex, endIndex);
  }

  int get totalCount => filteredReports.length;

  int get startLimit => totalCount == 0 ? 0 : ((_currentPage - 1) * _pageSize) + 1;

  int get endLimit {
    final computed = _currentPage * _pageSize;
    return (computed < totalCount) ? computed : totalCount;
  }

  bool get hasNextPage => (_currentPage * _pageSize) < totalCount;
  bool get hasPreviousPage => _currentPage > 1;

  void fetchNextPage() {
    if (hasNextPage) {
      _currentPage++;
      notifyListeners();
    }
  }

  void fetchPreviousPage() {
    if (hasPreviousPage) {
      _currentPage--;
      notifyListeners();
    }
  }

  Future<void> fetchReports(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final taskTypeId = _selectedTaskTypeId ?? 0;
      final toUser = _selectedToUserId ?? 0;
      final deptId = _selectedDepartmentId ?? 0;

      final url =
          '${HttpUrls.taskDeadlineReport}?Task_Type_Id=$taskTypeId&To_User=$toUser&Department_Id=$deptId';

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic>? rawList;

        if (data is List) {
          rawList = data;
        } else if (data is Map) {
          if (data['data'] != null && data['data'] is List) {
            rawList = data['data'] as List<dynamic>;
          } else if (data['Data'] != null && data['Data'] is List) {
            rawList = data['Data'] as List<dynamic>;
          } else if (data['success'] == true && data['data'] is List) {
            rawList = data['data'] as List<dynamic>;
          }
        }

        if (rawList != null) {
          _allReports = rawList
              .map((item) =>
                  TaskDeadlineReportModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _allReports = [];
        }
      } else {
        _allReports = [];
      }
    } catch (e) {
      debugPrint("Error fetching task deadline report: $e");
      _allReports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters(BuildContext context) {
    _selectedTaskTypeId = 0;
    _selectedToUserId = 0;
    _selectedDepartmentId = 0;
    _searchQuery = '';
    _currentPage = 1;
    notifyListeners();
    fetchReports(context);
  }
}
