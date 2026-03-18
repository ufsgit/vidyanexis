import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/mandatory_status_model.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/models/task_history_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';

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
  int? _expandedIndex;
  int? get expandedIndex => _expandedIndex;

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

  void clearDescription() {
    descriptionController.clear();
    followUpDateController.clear();
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
      await searchTaskByCustomer(context);
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
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _selectedTaskType = null;
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
    _isFilter = false;
    _pageIndex = 1;
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

      String toUserId = (_selectedUser ?? 0).toString();

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchTaskByCustomer}?Customer_Name=$_Search&Task_Status_Id=$_Status&To_User=$toUserId&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&Task_Type_Id=$_TaskType&Page_Index=$_pageIndex&PageSize=$_pageSize');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'] ?? [];
          final metaData = data['metadata'] ?? {};

          // Convert new data to TaskReportModel list
          final newTasks = (newData as List<dynamic>)
              .map((item) => TaskReportModel.fromJson(item))
              .toList();

          // Update metadata
          _totalSize = metaData['Total_Items'] ?? 1;
          _totalPages = metaData['Total_Pages'] ?? 1;

          // Check if it's mobile screen
          final isMobile = MediaQuery.of(context).size.width < 768;

          if (isMobile && _pageIndex > 1) {
            // For mobile scroll pagination, append new tasks to existing list
            _taskReport.addAll(newTasks);
          } else {
            // For web or first page load, replace the entire list
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

  Future<bool> changeTaskStatus(
      BuildContext context,
      TaskTypeStatusModel statusModel,
      int taskId,
      Map<String, dynamic>? locationData) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Extract location data
      String location = locationData?['address'] ?? "";
      double latitude = locationData?['latitude'] ?? 0.0;
      double longitude = locationData?['longitude'] ?? 0.0;

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
            "Next_FollowUp_Date": followUpDateController.text.toyyyymmdd(),
            "Tasks": _selectedTaskTypeIds.join(",")
          });

      if (response?.statusCode == 200) {
        final data = response?.data;

        if (data != null) {
          bool isSuccess = data["success"];
          if (isSuccess) {
            descriptionController.clear();
            _pageIndex = 1;
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

  Future<void> fetchTaskHistory(int userDetailsId) async {
    try {
      _isHistoryLoading = true;
      notifyListeners();

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.getTaskHistory}?User_Details_Id=$userDetailsId&Is_Date=0&Fromdate=&Todate=',
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

          debugPrint("DEBUG: fetchTaskTypes received ${formsData.length} forms");

          _taskTypeModel = (newData as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();

          initializeSelectedTaskTypes(); // deafult checkbox

          _documentTypeModel = (documentData as List<dynamic>)
              .map((item) => DocumentTypeModel.fromJson(item))
              .toList();
          _statusData = (statusData as List<dynamic>)
              .map((item) => MandatoryStatusModel.fromJson(item))
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
}
