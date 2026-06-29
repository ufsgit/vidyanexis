import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/mandatory_status_model.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
import 'package:vidyanexis/controller/models/task_history_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class TaskPageProvider extends ChangeNotifier {
  List<TaskReportModel> _taskReport = [];
  List<TaskReportModel> get taskReport => _taskReport;
  List<TaskTypeModel> _taskTypeModel = [];
  List<TaskTypeModel> get taskTypeModel => _taskTypeModel;
  List<DocumentTypeModel> _documentTypeModel = [];
  List<DocumentTypeModel> get documentTypeModel => _documentTypeModel;
  List<MandatoryStatusModel> _statusData = [];
  List<MandatoryStatusModel> get statusData => _statusData;
  List<TaskReportModel> _taskData = [];
  List<TaskReportModel> get taskData => _taskData;

  List<TaskHistoryModel> _taskHistoryList = [];
  List<TaskHistoryModel> get taskHistoryList => _taskHistoryList;

  List<CustomFieldByStatusId> _showCustomFields = [];
  List<CustomFieldByStatusId> get showCustomFields => _showCustomFields;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;
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
  String _TaskType = '';
  String _enquiryForS = '';

  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;
  String get TaskType => _TaskType;
  String get enquiryForS => _enquiryForS;

  String _entryType = 'myown';
  String get entryType => _entryType;
  void setEntryType(String value) {
    _entryType = value;
    notifyListeners();
  }

  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedTaskType;
  int? _selectedEnquiryFor;
  int _selectedSortOption = 0;
  int get selectedSortOption => _selectedSortOption;

  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  int? get selectedTaskType => _selectedTaskType;
  int? get selectedEnquiryFor => _selectedEnquiryFor;

  List<int> _selectedStatusIds = [0];
  List<int> _selectedUserIds = [0];
  List<int> _selectedTaskTypeFilterIds = [0];
  List<int> _selectedEnquiryForIds = [0];

  String _lastFetchPayload = "";

  List<int> get selectedStatusIds => _selectedStatusIds;
  List<int> get selectedUserIds => _selectedUserIds;
  List<int> get selectedTaskTypeFilterIds => _selectedTaskTypeFilterIds;
  List<int> get selectedEnquiryForIds => _selectedEnquiryForIds;
  int? _expandedIndex;
  int? get expandedIndex => _expandedIndex;
  int _flowId = 0;

  Map<String, int> _taskTypeToUserMap = {};
  Map<String, int> get taskTypeToUserMap => _taskTypeToUserMap;

  void setTaskUser(String taskTypeId, int? userId) {
    if (userId != null && userId > 0) {
      _taskTypeToUserMap[taskTypeId] = userId;
    } else {
      _taskTypeToUserMap.remove(taskTypeId);
    }
    notifyListeners();
  }

  void clearTaskUserAssignments() {
    _taskTypeToUserMap.clear();
    notifyListeners();
  }

  void toggleExpansion(int index) {
    if (_expandedIndex == index) {
      _expandedIndex = null;
    } else {
      _expandedIndex = index;
    }
    notifyListeners();
  }

  void resetExpansion() {
    _expandedIndex = null;
    notifyListeners();
  }

  bool get hasMorePages => _pageIndex < _totalPages;

  final List<String> _selectedTaskTypeIds = [];
  List<String> get selectedTaskTypeIds => _selectedTaskTypeIds;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController followUpDateController = TextEditingController();
  final TextEditingController followUpTimeController = TextEditingController();

  void clearDescription() {
    descriptionController.clear();
    followUpDateController.clear();
    followUpTimeController.clear();
    notifyListeners();
  }

  int _pageIndex = 1;
  int _pageSize = 20;
  int _totalSize = 0;
  int _totalPages = 1;

  int get pageIndex => _pageIndex;
  int get pageSize => _pageSize;
  int get totalSize => _totalSize;
  int get totalPages => _totalPages;

  void setPageSize(int newSize) {
    if (newSize < 1) return;
    _pageSize = newSize;
    // _pageIndex = 1; // Reset to first page
    notifyListeners();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages) {
      _pageIndex = page;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Location services are disabled");
        return {};
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          print("Location permissions are denied");
          return {};
        }
      }

      print("Getting current position...");
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("Position obtained: ${position.latitude}, ${position.longitude}");
      String address = "";

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String? locality = place.locality;
          String? adminArea = place.administrativeArea;

          address = [
            if (locality != null && locality.isNotEmpty) locality,
            if (adminArea != null && adminArea.isNotEmpty) adminArea,
          ].join(', ');

          print("Resolved Address: $address");
        } else {
          print("No placemarks found.");
        }
      } catch (geoError) {
        print("Error in geocoding: $geoError");
      }

      return {
        "latitude": position.latitude,
        "longitude": position.longitude,
        "address": address.isNotEmpty
            ? address
            : "${position.latitude},${position.longitude}"
      };
    } catch (e) {
      print("General error in getCurrentLocation: $e");
      return {};
    }
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setFilterState(bool value) {
    _isFilter = value;
    notifyListeners();
  }

  void nextPage() {
    if (_pageIndex < _totalPages) {
      _pageIndex++;
      notifyListeners();
    }
  }

  // Go to previous page
  void previousPage() {
    if (_pageIndex > 1) {
      _pageIndex--;
      notifyListeners();
    }
  }

  Future<void> loadMoreData(BuildContext context) async {
    if (hasMorePages) {
      nextPage();
      await searchTaskByCustomer(context, isShowLoader: false);
    }
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
    _selectedStatusIds = [newStatus];
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    _selectedUserIds = [newStatus];
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setTaskType(int newStatus) {
    _selectedTaskType = newStatus;
    _selectedTaskTypeFilterIds = [newStatus];
    print(_selectedTaskType.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setEnquiryFor(int newId) {
    _selectedEnquiryFor = newId;
    _selectedEnquiryForIds = [newId];
    print(_selectedEnquiryFor.toString());
    notifyListeners();
  }

  void toggleStatus(int value) {
    if (value == 0) {
      _selectedStatusIds = [0];
    } else {
      _selectedStatusIds.remove(0);
      if (_selectedStatusIds.contains(value)) {
        _selectedStatusIds.remove(value);
      } else {
        _selectedStatusIds.add(value);
      }
      if (_selectedStatusIds.isEmpty) {
        _selectedStatusIds = [0];
      }
    }
    _selectedStatus =
        _selectedStatusIds.isNotEmpty ? _selectedStatusIds.first : null;
    notifyListeners();
  }

  void toggleUserFilter(int value) {
    if (value == 0) {
      _selectedUserIds = [0];
    } else {
      _selectedUserIds.remove(0);
      if (_selectedUserIds.contains(value)) {
        _selectedUserIds.remove(value);
      } else {
        _selectedUserIds.add(value);
      }
      if (_selectedUserIds.isEmpty) {
        _selectedUserIds = [0];
      }
    }
    _selectedUser = _selectedUserIds.isNotEmpty ? _selectedUserIds.first : null;
    notifyListeners();
  }

  void toggleTaskTypeFilter(int value) {
    if (value == 0) {
      _selectedTaskTypeFilterIds = [0];
    } else {
      _selectedTaskTypeFilterIds.remove(0);
      if (_selectedTaskTypeFilterIds.contains(value)) {
        _selectedTaskTypeFilterIds.remove(value);
      } else {
        _selectedTaskTypeFilterIds.add(value);
      }
      if (_selectedTaskTypeFilterIds.isEmpty) {
        _selectedTaskTypeFilterIds = [0];
      }
    }
    _selectedTaskType = _selectedTaskTypeFilterIds.isNotEmpty
        ? _selectedTaskTypeFilterIds.first
        : null;
    notifyListeners();
  }

  void toggleEnquiryForFilter(int value) {
    if (value == 0) {
      _selectedEnquiryForIds = [0];
    } else {
      _selectedEnquiryForIds.remove(0);
      if (_selectedEnquiryForIds.contains(value)) {
        _selectedEnquiryForIds.remove(value);
      } else {
        _selectedEnquiryForIds.add(value);
      }
      if (_selectedEnquiryForIds.isEmpty) {
        _selectedEnquiryForIds = [0];
      }
    }
    _selectedEnquiryFor =
        _selectedEnquiryForIds.isNotEmpty ? _selectedEnquiryForIds.first : null;
    notifyListeners();
  }

  void setSortOption(int option, BuildContext context) {
    _selectedSortOption = option;
    _pageIndex = 1;
    searchTaskByCustomer(context);
    notifyListeners();
  }

  String _sortOrder = 'DESC'; // ASC or DESC
  String get sortOrder => _sortOrder;

  void toggleSortOrder(BuildContext context) {
    _sortOrder = _sortOrder == 'ASC' ? 'DESC' : 'ASC';
    _pageIndex = 1;
    searchTaskByCustomer(context);
    notifyListeners();
  }

  void removeStatus() {
    clearAllFilters();
  }

  void clearAllFilters() {
    _selectedTaskType = null;
    _selectedEnquiryFor = null;
    _selectedStatusIds = [0];
    _selectedUserIds = [0];
    _selectedTaskTypeFilterIds = [0];
    _selectedEnquiryForIds = [0];
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _fromDateS = '';
    _toDateS = '';
    _Search = '';
    _Status = '';
    _AssignedTo = '';
    _TaskType = '';
    _enquiryForS = '';
    _entryType = 'myown';
    _isFilter = false;
    _pageIndex = 1;
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo, String taskType, String enquiryFor) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _TaskType = taskType;
    _enquiryForS = enquiryFor;
    _pageIndex = 1;
    _pageSize = 20;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  //task report
  //task report
  Future<void> searchTaskByCustomer(BuildContext context,
      {bool isShowLoader = true}) async {
    try {
      if (isShowLoader) Loader.showLoader(context);
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
      String userId = preferences.getString('userId') ?? "";

      String toUserId = _selectedUserIds.join(',');
      _Status = _selectedStatusIds.join(',');
      _TaskType = _selectedTaskTypeFilterIds.join(',');
      _enquiryForS = _selectedEnquiryForIds.join(',');

      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      if (_enquiryForS.isEmpty || _enquiryForS == 'null') {
        _enquiryForS = '0';
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchTaskByCustomer}?Customer_Name=$_Search&Task_Status_Id=$_Status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&Task_Type_Id=$_TaskType&Enquiry_For_Id=$_enquiryForS&Page_Index=$_pageIndex&PageSize=$_pageSize&Order_By_=$_selectedSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'] ?? [];
          final metaData = data['metadata'] ?? {};

          // Convert new data to TaskReportModel list
          if (newData.isNotEmpty) {
            print(
                "================ DEBUG TASK JSON (searchTaskByCustomer) ================");
            print(newData[0]);
            print(
                "=========================================================================");
          }
          final newTasks = (newData as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
              .toList();

          // Update metadata
          _totalSize = metaData['Total_Items'] ?? 1;
          _totalPages = metaData['Total_Pages'] ?? 1;

          // Check if it's mobile screen using app-wide threshold
          final isMobile = !AppStyles.isWebScreen(context);

          if (isMobile && _pageIndex > 1) {
            // For mobile scroll pagination, append new tasks to existing list
            _taskReport.addAll(newTasks);
          } else {
            // For web or first page load (e.g. filter change), replace the entire list
            _taskReport = newTasks;
          }
        }
        if (isShowLoader) Loader.stopLoader(context);
        notifyListeners();
      } else {
        if (isShowLoader) Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      if (isShowLoader) Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> fetchTasksForExport(BuildContext context) async {
    try {
      Loader.showLoader(context);

      if (_Status.isEmpty || _Status == 'null') _Status = '0';
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      String toUserId = _selectedUserIds.join(',');
      _Status = _selectedStatusIds.join(',');
      _TaskType = _selectedTaskTypeFilterIds.join(',');
      _enquiryForS = _selectedEnquiryForIds.join(',');

      if (_Status.isEmpty || _Status == 'null') _Status = '0';
      if (_TaskType.isEmpty || _TaskType == 'null') _TaskType = '0';
      if (_enquiryForS.isEmpty || _enquiryForS == 'null') _enquiryForS = '0';

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.exportTaskByCustomer}?Customer_Name=$_Search&Task_Status_Id=$_Status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&Task_Type_Id=$_TaskType&Enquiry_For_Id=$_enquiryForS&Entry_Type_=$_entryType',
          returnBytes: true);

      Loader.stopLoader(context);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List<int>) {
          await saveBytesAsExcel(bytes: data, fileName: 'Task');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to load format or empty bytes')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load export data')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception occurred during export: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during export')),
      );
    }
  }

  Future<bool> changeTaskStatus(
      BuildContext context,
      TaskTypeStatusModel statusModel,
      int taskId,
      Map<String, dynamic>? locationData,
      {SubStatus? subStatus}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Extract location data
      String location = locationData?['address'] ?? "";
      double latitude = locationData?['latitude'] ?? 0.0;
      double longitude = locationData?['longitude'] ?? 0.0;

      // Build TaskUsers list - ONLY where user is selected
      List<Map<String, dynamic>> taskUsers = _taskTypeToUserMap.entries
          .where((entry) => _selectedTaskTypeIds.contains(entry.key))
          .map((entry) => {
                "task_type_id": int.tryParse(entry.key) ?? 0,
                "to_user_id": entry.value,
              })
          .toList();

      List<Map<String, dynamic>> customFieldsData = [];
      if (customFieldTaskStatusKey.currentState != null) {
        final fieldValues =
            customFieldTaskStatusKey.currentState!.getFieldValues();

        final checkedFieldIds = _showCustomFields
            .where((cf) => cf.isChecked == 1 || cf.isChecked == null)
            .map((cf) => cf.customFieldId)
            .toSet();

        customFieldsData = fieldValues
            .where((field) => checkedFieldIds.contains(field.customFieldId))
            .map((field) => field.toJson())
            .toList();
      }

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.changeTaskStatus,
          bodyData: {
            "Task_Id": taskId,
            "Location": location,
            "Latitude": latitude,
            "Longitude": longitude,
            "Status_Id": statusModel.statusId,
            "Status_Name": statusModel.statusName,
            "By_User_Id": userId,
            "Description": descriptionController.text,
            // "Next_FollowUp_Date":
            //     DateFormat('yyyy-MM-dd').format(DateTime.now()),
            "Next_FollowUp_Date": statusModel.followup == 1
                ? followUpDateController.text.toyyyymmdd()
                : "",
            "Followup_Time":
                statusModel.isTime == 1 ? followUpTimeController.text : "",
            "Tasks": _selectedTaskTypeIds.join(","),
            "CustomFields": customFieldsData,
            "flow_id": _flowId,
            "Sub_Status_Id": subStatus?.subStatusId,
            "Sub_Status_Name": subStatus?.subStatusName,
            "sub_status_id": subStatus?.subStatusId,
            "sub_status_name": subStatus?.subStatusName,
            "Sub_Status": subStatus != null ? [subStatus.toJson()] : null,
            "TaskUsers": taskUsers,
          });

      if (response?.statusCode == 200) {
        final data = response?.data;

        if (data != null) {
          bool isSuccess = data["success"];
          if (isSuccess) {
            descriptionController.clear();
            _pageIndex = 1;
            clearTaskUserAssignments();
            try {
              final dbProvider =
                  Provider.of<DashboardProvider>(context, listen: false);
              dbProvider.clearDashboardFlags();
              dbProvider.getTaskInfoDashBoard(context,
                  isSilent: true, shouldNotify: true);
            } catch (_) {}
          }
          return isSuccess;
        } else {
          return false;
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
      return false;
    } catch (e) {
      print('Exception occurred: $e');
      if (e.toString().contains("Server timeout")) {
        rethrow;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
      return false;
    }
  }

  Future<bool> saveTaskData(
      BuildContext context,
      int userId,
      int taskId,
      String taskName,
      bool isRepeating,
      TextEditingController durationController,
      TextEditingController endDateController) async {
    try {
      final bodyData = {
        "Task_Id": taskId,
        "Task_name": taskName,
        "User_Id": userId,
        "Task_date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "Is_Repeating_Task": isRepeating,
        "Duration": durationController.text,
        "End_Date": endDateController.text,
      };
      print('=== TaskPageProvider: HTTP POST Request Body ===');
      print(bodyData);
      print('================================================');
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveTaskData, bodyData: bodyData);

      if (response?.statusCode == 200) {
        final data = response?.data;

        if (data != null) {
          bool isSuccess = data["success"];
          return isSuccess;
        } else {
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
      return false;
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return false;
    }
  }

  Future<void> getTaskData(String taskId, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getTaskData}/$taskId');

      if (response.statusCode == 200) {
        final data = response.data;
        _taskData = (data as List<dynamic>)
            .map((item) => TaskReportModel.fromJson(item))
            .toList();
        notifyListeners();
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

  Future<void> fetchTaskHistory(int userDetailsId, int taskId) async {
    try {
      _isHistoryLoading = true;
      notifyListeners();

      String isDate =
          (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.getTaskHistory}?User_Details_Id=$userDetailsId&Task_Id=$taskId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final list = data['data'] ?? [];

        _taskHistoryList =
            (list as List).map((e) => TaskHistoryModel.fromJson(e)).toList();
      } else {
        _taskHistoryList = [];
      }
    } catch (e) {
      _taskHistoryList = [];
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  //Status Dialogue
  Future<bool> updateTaskData(
    BuildContext context,
    String statusName,
  ) async {
    try {
      final bodyData = {
        "Task_status": statusName,
      };
      print('=== TaskPageProvider: HTTP POST Request Body ===');
      print(bodyData);
      print('================================================');
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.updateTaskData, bodyData: bodyData);

      if (response?.statusCode == 200) {
        final data = response?.data;

        if (data != null) {
          bool isSuccess = data["success"];
          return isSuccess;
        } else {
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
      return false;
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return false;
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
          endPoint:
              '${HttpUrls.searchTaskReport}?Customer_Name=$_Search&Task_Status_Id=$_Status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&Task_Type_Id=$_TaskType');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          _taskReport = (data as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  void toggleTaskTypeSelection(String taskTypeId) {
    if (_selectedTaskTypeIds.contains(taskTypeId)) {
      _selectedTaskTypeIds.remove(taskTypeId);
    } else {
      _selectedTaskTypeIds.add(taskTypeId);
      try {
        final selectedType = _taskTypeModel.firstWhere(
          (t) => t.taskTypeId.toString() == taskTypeId,
        );
        followUpDateController.text = DateFormat('dd MMM yyyy')
            .format(DateTime.now().add(Duration(days: selectedType.duration)));
      } catch (e) {
        debugPrint("Error updating follow-up date in toggle: $e");
      }
    }
    print(_selectedTaskTypeIds);
    notifyListeners();
  }

  void initializeSelectedTaskTypes() {
    // Clear any existing selections
    _selectedTaskTypeIds.clear();

    // Add all task type IDs to the selected list
    for (var task in _taskTypeModel) {
      _selectedTaskTypeIds.add(task.taskTypeId.toString());
    }

    notifyListeners();
  }

  //
  Future<void> fetchTaskTypes(int tasktypeId, int statusId, int customerId,
      int enquiryForId, BuildContext context) async {
    print(statusId);
    print(tasktypeId);
    _lastFetchPayload = "";
    try {
      Loader.showLoader(context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final Map<String, dynamic> queryParams = {
        "Task_Type_Id": tasktypeId,
        "Status_Id": statusId,
        "Customer_Id": customerId,
        "Login_User_Id": userId,
        "Enquiry_For_Id": enquiryForId,
      };

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getTaskTypesOfProcessFlow,
        bodyData: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());
          _selectedTaskTypeIds.clear();
          final newData = data['data'] ?? [];
          final documentData = data['document_types'] ?? [];
          final statusData = data['mandatory_status'] ?? [];
          final formsData = data['forms'] ?? [];
          final customFieldData = data['show_custom_field'] ?? [];
          final enquiry = data['enquiry'] ?? [];
          if (enquiry.isNotEmpty) {
            _flowId = enquiry.first['FlowId'] ?? 0;
            print("FlowId: ${_flowId.toString()}");
          }

          debugPrint(
              "DEBUG: fetchTaskTypes received ${formsData.length} forms");

          _taskTypeModel = (newData as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();

          initializeSelectedTaskTypes(); // deafult checkbox

          if (_taskTypeModel.isNotEmpty) {
            followUpDateController.text = DateFormat('dd MMM yyyy').format(
                DateTime.now()
                    .add(Duration(days: _taskTypeModel.first.duration)));
          }

          _documentTypeModel = (documentData as List<dynamic>)
              .map((item) => DocumentTypeModel.fromJson(item))
              .toList();
          _statusData = (statusData as List<dynamic>)
              .map((item) => MandatoryStatusModel.fromJson(item))
              .toList();

          _showCustomFields = (customFieldData as List)
              .map((e) => CustomFieldByStatusId.fromJson(e))
              .toList();

          // Update forms in FormProvider if present
          final formProvider =
              Provider.of<FormProvider>(context, listen: false);
          formProvider.setCustomerForms(data);

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

  Future<void> fetchTaskTypesWithCustomFields(int tasktypeId, int statusId,
      int customerId, int enquiryForId, BuildContext context) async {
    print(statusId);
    print(tasktypeId);
    List<Map<String, dynamic>> customFieldsData = [];
    if (customFieldTaskStatusKey.currentState != null) {
      final fieldValues =
          customFieldTaskStatusKey.currentState!.getFieldValues();

      final checkedFieldIds = _showCustomFields
          .where((cf) => cf.isChecked == 1 || cf.isChecked == null)
          .map((cf) => cf.customFieldId)
          .toSet();

      customFieldsData = fieldValues
          .where((field) => checkedFieldIds.contains(field.customFieldId))
          .map((field) => field.toJson())
          .toList();
    }

    if (customFieldsData.isEmpty) {
      return; // No need to call the API if there are no active custom fields to pass
    }

    final payloadJson = jsonEncode(customFieldsData);
    if (payloadJson == _lastFetchPayload) {
      // Payload hasn't changed (e.g., interacted with unchecked fields)
      return;
    }
    _lastFetchPayload = payloadJson;

    try {
      Loader.showLoader(context);

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final Map<String, dynamic> queryParams = {
        "Task_Type_Id": tasktypeId,
        "Status_Id": statusId,
        "Customer_Id": customerId,
        "Login_User_Id": userId,
        "Enquiry_For_Id": enquiryForId,
        "Custom_Fields": customFieldsData,
      };

      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getTaskTypesOfProcessFlowWithCustomFields,
        bodyData: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());
          final newData = data['data'] ?? [];
          _selectedTaskTypeIds.clear();
          final documentData = data['document_types'] ?? [];
          final statusData = data['mandatory_status'] ?? [];
          final formsData = data['forms'] ?? [];
          // final customFieldData = data['show_custom_field'] ?? [];
          final enquiry = data['enquiry'] ?? [];
          if (enquiry.isNotEmpty) {
            _flowId = enquiry.first['FlowId'] ?? 0;
            print("FlowId: ${_flowId.toString()}");
          }

          debugPrint(
              "DEBUG: fetchTaskTypes received ${formsData.length} forms");

          _taskTypeModel = (newData as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();

          initializeSelectedTaskTypes(); // deafult checkbox

          if (_taskTypeModel.isNotEmpty) {
            followUpDateController.text = DateFormat('dd MMM yyyy').format(
                DateTime.now()
                    .add(Duration(days: _taskTypeModel.first.duration)));
          }

          _documentTypeModel = (documentData as List<dynamic>)
              .map((item) => DocumentTypeModel.fromJson(item))
              .toList();
          _statusData = (statusData as List<dynamic>)
              .map((item) => MandatoryStatusModel.fromJson(item))
              .toList();

          // _showCustomFields = (customFieldData as List)
          //     .map((e) => CustomFieldByStatusId.fromJson(e))
          //     .toList();

          // Update forms in FormProvider if present
          final formProvider =
              Provider.of<FormProvider>(context, listen: false);
          formProvider.setCustomerForms(data);

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
}
