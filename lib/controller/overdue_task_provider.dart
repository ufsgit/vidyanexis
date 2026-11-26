import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/overdue_task_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class OverdueTaskProvider extends ChangeNotifier {
  List<OverdueTaskModel> _allReports = [];
  List<OverdueTaskModel> get allReports => _allReports;

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
  final int _pageSize = 20;

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

  List<OverdueTaskModel> get filteredReports {
    return _allReports.where((item) {
      if (_selectedTaskTypeId != null && _selectedTaskTypeId != 0) {
        if (item.taskTypeId != null && item.taskTypeId != _selectedTaskTypeId) {
          return false;
        }
      }

      if (_selectedToUserId != null && _selectedToUserId != 0) {
        if (item.toUserId != null && item.toUserId != _selectedToUserId) {
          return false;
        }
      }

      if (_selectedDepartmentId != null && _selectedDepartmentId != 0) {
        if (item.departmentId != null &&
            item.departmentId != _selectedDepartmentId) {
          return false;
        }
      }

      if (_searchQuery.isEmpty) return true;

      final customer = (item.customerName ?? '').toLowerCase();
      final phone = (item.phoneNumber ?? '').toLowerCase();
      final taskType = (item.taskTypeName ?? '').toLowerCase();
      final user = (item.toUserName ?? '').toLowerCase();
      final status = (item.taskStatusName ?? '').toLowerCase();
      final taskId = (item.taskId?.toString() ?? '').toLowerCase();
      final taskName = (item.taskName ?? '').toLowerCase();
      final detail = (item.taskDetail ?? '').toLowerCase();

      return customer.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          taskType.contains(_searchQuery) ||
          user.contains(_searchQuery) ||
          status.contains(_searchQuery) ||
          taskId.contains(_searchQuery) ||
          taskName.contains(_searchQuery) ||
          detail.contains(_searchQuery);
    }).toList();
  }

  List<OverdueTaskModel> get paginatedReports {
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

  int get startLimit =>
      totalCount == 0 ? 0 : ((_currentPage - 1) * _pageSize) + 1;

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
      final Map<String, dynamic> queryParams = {};
      if (_selectedTaskTypeId != null && _selectedTaskTypeId != 0) {
        queryParams['Task_Type_Id'] = _selectedTaskTypeId;
      }
      if (_selectedToUserId != null && _selectedToUserId != 0) {
        queryParams['To_User'] = _selectedToUserId;
        queryParams['User_Id'] = _selectedToUserId;
      }
      if (_selectedDepartmentId != null && _selectedDepartmentId != 0) {
        queryParams['Department_Id'] = _selectedDepartmentId;
      }

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getOverdueTasks,
        bodyData: queryParams.isNotEmpty ? queryParams : null,
      );

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
          } else if (data['results'] != null && data['results'] is List) {
            rawList = data['results'] as List<dynamic>;
          } else if (data['tasks'] != null && data['tasks'] is List) {
            rawList = data['tasks'] as List<dynamic>;
          } else if (data['taskList'] != null && data['taskList'] is List) {
            rawList = data['taskList'] as List<dynamic>;
          }
        }

        if (rawList != null) {
          _allReports = rawList
              .map((item) =>
                  OverdueTaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _allReports = [];
        }
      } else {
        _allReports = [];
      }
    } catch (e) {
      debugPrint("Error fetching overdue tasks report: $e");
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
