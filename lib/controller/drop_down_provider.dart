import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/amc_status_model.dart';
import 'package:vidyanexis/controller/models/district_model.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/duration_model.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/user_enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/user_enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/follow_up_status_model.dart';
import 'package:vidyanexis/controller/models/interval_model.dart';
import 'package:vidyanexis/controller/models/location_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/task_type_status_model.dart';
import 'package:vidyanexis/controller/models/user_task_type_model.dart';
import 'package:vidyanexis/http/http_requests.dart';

import '../http/http_urls.dart';

class DropDownProvider extends ChangeNotifier {
  List<Enquirysourcemodel> _enquiryData = [];
  List<EnquiryForModel> _enquiryForList = [];
  List<FollowUpStatusModel> _followUpStatusList = [];

  List<SearchUserDetails> _searchUserDetails = [];
  List<SearchLeadStatusModel> _followUpstatus = [];
  List<TaskTypeModel> _taskType = [];
  List<AMCStatusModel> _amcStatus = [];
  List<DocumentTypeModel> _documentType = [];
  List<LocationModel> _locationList = [];

  List<Enquirysourcemodel> get enquiryData => _enquiryData;
  List<EnquiryForModel> get enquiryForList => _enquiryForList;
  List<FollowUpStatusModel> get followUpStatusList => _followUpStatusList;

  List<SearchUserDetails> get searchUserDetails => _searchUserDetails;
  List<SearchLeadStatusModel> get followUpData => _followUpstatus;
  List<TaskTypeModel> get taskType => _taskType;
  List<DocumentTypeModel> get documentType => _documentType;
  List<AMCStatusModel> get amcStatus => _amcStatus;
  List<LocationModel> get locationList => _locationList;

  String getEnquiryForNameById(int id, String fallback) {
    if (id <= 0) return fallback;
    try {
      final item = _enquiryForList.firstWhere(
        (element) => element.enquiryForId == id,
      );
      return item.enquiryForName.isNotEmpty ? item.enquiryForName : fallback;
    } catch (_) {
      return fallback;
    }
  }

  String getEnquirySourceNameById(int id, String fallback) {
    if (id <= 0) return fallback;
    try {
      final item = _enquiryData.firstWhere(
        (element) => element.enquirySourceId == id,
      );
      return item.enquirySourceName.isNotEmpty
          ? item.enquirySourceName
          : fallback;
    } catch (_) {
      return fallback;
    }
  }

  // List<Enquirysourcemodel> filteredEnquiryData = []; // New filtered list
  List<EnquiryForModel> filteredEnquiryForData = []; // New filtered list

  // // Optimized Task Filtering logic (Requirement 1, 2, 5)
  // List<TaskTypeModel> getFilteredTaskTypes() {
  //   return _taskType.where((taskType) {
  //     // 1. Check if the task type itself is enabled
  //     if (!taskType.isEnabled) return false;

  //     // 2. Check if there are active users for this task type's department
  //     // Requirement 2: Remove parent if all children (users) are disabled/missing
  //     final hasActiveUsers = _searchUserDetails.any((user) =>
  //         user.workingStatus == "1" &&
  //         user.departmentId.toString() == taskType.departmentIds.toString());

  //     return hasActiveUsers;
  //   }).toList();
  // }

  // // Get filtered users for a task type (Requirement 2)
  // List<SearchUserDetails> getActiveUsersForTask(TaskTypeModel taskType) {
  //   return _searchUserDetails
  //       .where((user) =>
  //           user.workingStatus == "1" &&
  //           user.departmentId.toString() == taskType.departmentIds.toString())
  //       .toList();
  // }

  int? selectedSourceId;
  int? selectedEnquirySourceId;
  bool showValidation = false;
  List<SearchUserDetails> filteredStaffData = []; // Filtered staff data
  List<DistrictModel> _districtList = [];
  List<DistrictModel> get districtList => _districtList;
  int? _selectedDistrictId;
  int? get selectedDistrictId => _selectedDistrictId;
  String _selectedDistrictName = '';
  String get selectedDistrictName => _selectedDistrictName;
  int? _amcPeriodIntervalId;
  int? get amcPeriodIntervalId => _amcPeriodIntervalId;
  int? _amcTotalDurationId;
  int? get amcTotalDurationlId => _amcTotalDurationId;
  List<DurationModel> _amcDuration = [];
  List<DurationModel> get amcDuration => _amcDuration;
  List<IntervalModel> _amcInterval = [];
  List<IntervalModel> get amcInterval => _amcInterval;

  int? _currentBranchId;
  int? _currentDepartmentId;

  int? _selectedLocationId;
  int? get selectedLocationId => _selectedLocationId;
  set selectedLocationId(int? value) {
    _selectedLocationId = value;
    notifyListeners();
  }

  // Method to set source category ID and filter enquiry sources
  void setSourceCategoryId(int? categoryId) {
    selectedSourceId = categoryId;
    notifyListeners();
  }

  // Method to set selected enquiry source ID
  void setSelectedEnquirySourceId(int? enquirySourceId) {
    selectedEnquirySourceId = enquirySourceId;
    notifyListeners();
  }

  void updateDistrict(int? value, String districtName) {
    _selectedDistrictId = value;
    _selectedDistrictName = districtName;
    notifyListeners();
  }

  // Method to filter enquiry sources based on selected source category
  // void filterEnquirySourcesByCategory(int sourceCategoryId) {
  //   filteredEnquiryData = enquiryData
  //       .where((enquiry) => enquiry.sourceCategoryId == sourceCategoryId)
  //       .toList();
  //   notifyListeners();
  // }

  void filterEnquiryForByCategory(int sourceCategoryId) {
    filteredEnquiryForData = enquiryForList
        .where((enquiry) => enquiry.sourceCategoryId == sourceCategoryId)
        .toList();
    notifyListeners();
  }

  void filterStaffByBranchAndDepartment({
    required int? branchId,
    required int? departmentId,
  }) {
    _currentBranchId = branchId;
    _currentDepartmentId = departmentId;

    if (branchId == null || departmentId == null) {
      filteredStaffData = [];
    } else {
      filteredStaffData = searchUserDetails
          .where((staff) =>
              staff.branchId == branchId.toString() &&
              staff.departmentId == departmentId.toString() &&
              staff.workingStatus == "1")
          .toList();
    }
    // Print the full list with all fields as maps for clarity
    print(
        "filteredStaffData: ${filteredStaffData.map((staff) => staff.toJson()).toList()}");
    notifyListeners();
  }

  void filterStaff(String query) {
    if (_currentBranchId == null || _currentDepartmentId == null) {
      filteredStaffData = [];
      notifyListeners();
      return;
    }

    final lowerQuery = query.trim().toLowerCase();

    filteredStaffData = searchUserDetails.where((staff) {
      if (staff.branchId != _currentBranchId.toString() ||
          staff.departmentId != _currentDepartmentId.toString() ||
          staff.workingStatus != "1") {
        return false;
      }

      if (lowerQuery.isEmpty) {
        return true; // show all
      }

      return (staff.userDetailsName ?? '').toLowerCase().contains(lowerQuery);
    }).toList();

    notifyListeners();
  }

  void getDistricts(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getDistricts);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null) {
          // Check if the response has the expected structure
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('success') &&
              responseData.containsKey('data')) {
            // Check if the request was successful
            if (responseData['success'] == true) {
              final data = responseData['data'];

              // Ensure data is a List
              if (data is List<dynamic>) {
                _districtList =
                    data.map((item) => DistrictModel.fromJson(item)).toList();
                notifyListeners();
              } else {
                print('Data is not a List: ${data.runtimeType}');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid data format')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request failed')),
              );
            }
          } else {
            // Handle case where response doesn't have expected structure
            // Maybe the API returns data directly as a List
            if (responseData is List<dynamic>) {
              _districtList = responseData
                  .map((item) => DistrictModel.fromJson(item))
                  .toList();
              notifyListeners();
            } else {
              print(
                  'Unexpected response structure: ${responseData.runtimeType}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Unexpected response format')),
              );
            }
          }
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

  // Method to reset dropdowns
  void resetDropdowns() {
    selectedSourceId = null;
    selectedEnquirySourceId = null;
    filteredEnquiryForData = [];
    notifyListeners();
  }

  // For edit mode - set initial values and filter accordingly
  void setInitialValuues(int? sourceCategoryId, int? enquirySourceId) {
    selectedSourceId = sourceCategoryId;
    selectedEnquirySourceId = enquirySourceId;

    if (sourceCategoryId != null) {
      filterEnquiryForByCategory(sourceCategoryId);
    }

    notifyListeners();
  }

  int? _selectedEnquirySourceId;
  int? _selectedSourceId;

  int? _selectedUserId;
  int? _selectedpeUserId;
  int? _selectedcreUserId;
  int? _selectedleadtypeUserId;
  int? _selectedStatusId;
  int? _selectedTransferStatusId;
  int? _selectedFollowUpId;
  int? _selectedDepartmentId;

  int? get selectedUserId => _selectedUserId;
  int? get selectedpeUserId => _selectedpeUserId;
  String _selectedPEName = '';
  String get selectedPEName => _selectedPEName;
  int? get selectedcreUserId => _selectedcreUserId;
  int? get selectedleadtypeUserId => _selectedleadtypeUserId;
  int? get selectedStatusId => _selectedStatusId;
  int? get selectedTransferStatusId => _selectedTransferStatusId;
  int? get selectedFollowUpId => _selectedFollowUpId;
  bool _showValidation = false;
  int? _selectedEnquiryForId;
  int? get selectedEnquiryForId => _selectedEnquiryForId;
  String _selectedEnquiryForName = '';
  String get selectedEnquiryForName => _selectedEnquiryForName;
  int? get selectedDepartmentId => _selectedDepartmentId;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController invoiceNoController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();

  final TextEditingController unitController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController netValueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController cgstController = TextEditingController();
  final TextEditingController sgstController = TextEditingController();

  final TextEditingController gstController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final double cgstRate = 5.0;
  final double sgstRate = 5.0;

  @override
  void dispose() {
    unitController.dispose();
    quantityController.dispose();
    priceController.dispose();
    amountController.dispose();
    discountController.dispose();
    netValueController.dispose();
    cgstController.dispose();
    sgstController.dispose();
    gstController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  void resetValues() {
    addressController.clear();
    invoiceNoController.clear();
    invoiceDateController.clear();
    categoryController.clear();
    unitController.clear();
    quantityController.clear();
    priceController.clear();
    amountController.clear();
    discountController.clear();
    netValueController.clear();
    cgstController.clear();
    sgstController.clear();
    gstController.clear();
    totalAmountController.clear();
    notifyListeners(); // If you're using ChangeNotifier/Provider
  }

  set selectedStatusId(int? value) {
    // You can add logic here if needed (e.g., validation, state changes, etc.)
    if (_selectedStatusId != value) {
      _selectedStatusId = value;
      // Optionally, trigger a state change, call a method, or notify listeners if using providers
      notifyListeners();
    }
  }

  set selectedUserId(int? value) {
    // You can add logic here if needed (e.g., validation, state changes, etc.)
    if (_selectedUserId != value) {
      _selectedUserId = value;
      // Optionally, trigger a state change, call a method, or notify listeners if using providers
      notifyListeners();
    }
  }

  set selectedpeUserId(int? selectedpeUserId) {
    _selectedpeUserId = selectedpeUserId;
    notifyListeners();
  }

  set selectedcreUserId(int? selectedcreUserId) {
    _selectedcreUserId = selectedcreUserId;
    notifyListeners();
  }

  set selectedleadtypeUserId(int? id) {
    _selectedleadtypeUserId = id;
    notifyListeners();
  }

  set selectedFollowUPId(int? id) {
    _selectedFollowUpId = id;
    notifyListeners();
  }

  set selectedDepartmentId(int? id) {
    _selectedDepartmentId = id;
    notifyListeners();
  }

  void setSelectedAmcPeriodicIntervalId(int id) {
    _amcPeriodIntervalId = id;
    notifyListeners();
  }

  void setSelectedAmcTotalDurationId(int id) {
    _amcTotalDurationId = id;
    notifyListeners();
  }

  void updateEnquiryForName(int? value, String enquiryForName) {
    _selectedEnquiryForId = value;
    _selectedEnquiryForName = enquiryForName;
    print(_selectedEnquiryForName);
    print(_selectedEnquiryForId);
    notifyListeners();
  }

  void updatePEName(int? value, String userDetailsName) {
    _selectedpeUserId = value;
    _selectedPEName = userDetailsName;
    print(_selectedPEName);
    print(_selectedpeUserId);
    notifyListeners();
  }

  void setShowValidation(bool value) {
    _showValidation = value;
    notifyListeners();
  }

  void resetFields() {
    _showValidation = false;
    _selectedFollowUpId = null;
    _selectedUserId = null;
    _selectedEnquiryForId = null;
    _selectedEnquiryForName = '';
    _selectedEnquirySourceId = null;
    _selectedSourceId = null;
    _selectedDepartmentId = null;
    _selectedLocationId = null;
    notifyListeners();
  }

  bool isFormValid(
      String leadName,
      String enquirySource,
      String contactNo,
      String address,
      String city,
      String state,
      String followUpStatus,
      String assignTo) {
    return leadName.isNotEmpty &&
        enquirySource.isNotEmpty &&
        contactNo.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        followUpStatus.isNotEmpty &&
        assignTo.isNotEmpty;
  }

  void setSelectedUserId(int? id) {
    _selectedUserId = id;
    notifyListeners();
  }

  void setSelectedpeUserId(int id) {
    _selectedpeUserId = id;
    notifyListeners();
  }

  void setSelectedcreUserId(int id) {
    _selectedcreUserId = id;
    notifyListeners();
  }

  void setSelectedleadtypeUserId(int id) {
    _selectedleadtypeUserId = id;
    notifyListeners();
  }

  void setSelectedStatusId(int? id) {
    _selectedStatusId = id;
    notifyListeners();
  }

  void setSelectedTransferStatusId(int? id) {
    _selectedTransferStatusId = id;
    notifyListeners();
  }

  void setSelectedFollowUPId(int? id) {
    _selectedFollowUpId = id;
    notifyListeners();
  }

  bool isFollowupRequired() {
    if (_selectedFollowUpId != null) {
      final selectedStatus = _followUpstatus.firstWhere(
        (status) => status.statusId == _selectedFollowUpId,
        orElse: () => SearchLeadStatusModel(
          statusId: -1,
        ),
      );
      print(selectedStatus.isShowFollowupDate == 1);
      return selectedStatus.isShowFollowupDate == 1;
    }
    return false;
  }

  bool isFollowupRequiredNew() {
    if (_selectedStatusId != null) {
      final selectedStatus = _followUpstatus.firstWhere(
        (status) => status.statusId == _selectedStatusId,
        orElse: () => SearchLeadStatusModel(
          statusId: -1,
        ),
      );
      print(selectedStatus.isShowFollowupDate == 1);
      return selectedStatus.isShowFollowupDate == 1;
    }
    return false;
  }

  void getDuration(BuildContext context) async {
    try {
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.amcDuration);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataItem = data['data'] ?? [];

          _amcDuration = (dataItem as List<dynamic>)
              .map((item) => DurationModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('Exception occurred in getDuration: $e');
    }
    // Fallback hardcoded values if API fails or returns empty
    if (_amcDuration.isEmpty) {
      _amcDuration = [
        DurationModel(durationId: 1, durationName: '1 Year', durationNo: 1),
        DurationModel(durationId: 2, durationName: '2 Years', durationNo: 2),
        DurationModel(durationId: 3, durationName: '3 Years', durationNo: 3),
        DurationModel(durationId: 4, durationName: '4 Years', durationNo: 4),
        DurationModel(durationId: 5, durationName: '5 Years', durationNo: 5),
      ];
    }
    notifyListeners();
  }

  void getIntervals(BuildContext context) async {
    try {
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.amcInterval);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final dataItem = data['data'] ?? [];

          _amcInterval = (dataItem as List<dynamic>)
              .map((item) => IntervalModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('Exception occurred in getIntervals: $e');
    }
    // Fallback hardcoded values if API fails or returns empty
    if (_amcInterval.isEmpty) {
      _amcInterval = [
        IntervalModel(intervalsId: 1, intervalsName: 'Monthly', intervalsNo: 1),
        IntervalModel(
            intervalsId: 2, intervalsName: 'Quarterly', intervalsNo: 3),
        IntervalModel(
            intervalsId: 3, intervalsName: 'Half Yearly', intervalsNo: 6),
        IntervalModel(intervalsId: 4, intervalsName: 'Yearly', intervalsNo: 12),
      ];
    }
    notifyListeners();
  }

  Future<void> getEnquirySource(BuildContext context,
      {bool fetchUserSpecific = false}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.enquirySource}?Enquiry_Source_Name=');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          List<Enquirysourcemodel> allSources = (data as List<dynamic>)
              .map((item) => Enquirysourcemodel.fromJson(item))
              .toList();

          if (fetchUserSpecific && userId.isNotEmpty) {
            try {
              final userResponse = await HttpRequest.httpGetRequest(
                endPoint: '${HttpUrls.getUserEnquirySource}/$userId',
              );
              if (userResponse.statusCode == 200 &&
                  userResponse.data != null &&
                  userResponse.data['data'] != null) {
                final responseData = userResponse.data['data'];
                List<dynamic> dataList;
                if (responseData is Map &&
                    responseData['enquiry_source_list'] != null) {
                  dataList =
                      responseData['enquiry_source_list'] as List<dynamic>;
                } else if (responseData is List) {
                  dataList = responseData;
                } else {
                  dataList = [];
                }
                final userSources = dataList
                    .map((item) => UserEnquirySourceModel.fromJson(item))
                    .toList();

                allSources = allSources.where((source) {
                  final matched = userSources.firstWhere(
                    (u) => u.enquirySourceId == source.enquirySourceId,
                    orElse: () => UserEnquirySourceModel(isview: 0),
                  );
                  return matched.isview == 1;
                }).toList();
              } else {
                allSources = [];
              }
            } catch (e) {
              print(
                  'Exception occurred while fetching user enquiry sources: $e');
              allSources = [];
            }
          }

          _enquiryData = allSources;
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

  void getAllFollowUpStatus(BuildContext context, String viewId) async {
    try {
      // Build endpoint and add pagination parameters. Only include ViewIn_Id when provided.
      String endPoint =
          '${HttpUrls.searchStatus}?status_Name=&Page_Index=1&PageSize=1000';
      if (viewId.isNotEmpty) {
        endPoint =
            "${HttpUrls.searchStatus}?status_Name=&ViewIn_Id=$viewId&Page_Index=1&PageSize=1000";
      }
      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;
        print('DEBUG getAllFollowUpStatus: Data type=${data.runtimeType}');

        if (data != null) {
          // Handle both list and map responses
          if (data is List<dynamic>) {
            _followUpStatusList =
                data.map((item) => FollowUpStatusModel.fromJson(item)).toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _followUpStatusList = (data['data'] as List<dynamic>)
                .map((item) => FollowUpStatusModel.fromJson(item))
                .toList();
          } else {
            _followUpStatusList = [];
          }
          print(
              'DEBUG getAllFollowUpStatus: Loaded ${_followUpStatusList.length} statuses');
          notifyListeners();
        }
      } else {
        print(
            'DEBUG getAllFollowUpStatus: Server error ${response.statusCode}');
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

  Future<void> getEnquiryFor(BuildContext context,
      {bool fetchUserSpecific = false}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.enquiryFor}?Enquiry_For_Name=');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          List<EnquiryForModel> allEnquiryFor = (data as List<dynamic>)
              .map((item) => EnquiryForModel.fromJson(item))
              .toList();

          if (fetchUserSpecific && userId.isNotEmpty) {
            try {
              final userResponse = await HttpRequest.httpGetRequest(
                endPoint: '${HttpUrls.getUserEnquiryFor}/$userId',
              );
              if (userResponse.statusCode == 200 &&
                  userResponse.data != null &&
                  userResponse.data['data'] != null) {
                final responseData = userResponse.data['data'];
                List<dynamic> dataList;
                if (responseData is Map &&
                    responseData['enquiry_for_list'] != null) {
                  dataList = responseData['enquiry_for_list'] as List<dynamic>;
                } else if (responseData is List) {
                  dataList = responseData;
                } else {
                  dataList = [];
                }
                final userEnquiryFor = dataList
                    .map((item) => UserEnquiryForModel.fromJson(item))
                    .toList();

                allEnquiryFor = allEnquiryFor.where((enquiry) {
                  final matched = userEnquiryFor.firstWhere(
                    (u) => u.enquiryForId == enquiry.enquiryForId,
                    orElse: () => UserEnquiryForModel(isview: 0),
                  );
                  return matched.isview == 1;
                }).toList();
              } else {
                allEnquiryFor = [];
              }
            } catch (e) {
              print('Exception occurred while fetching user enquiry for: $e');
              allEnquiryFor = [];
            }
          }

          _enquiryForList = allEnquiryFor;
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

  void getUserDetails(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchUserDetails}?user_details_Name=');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchUserDetails = (data as List<dynamic>)
              .map((item) => SearchUserDetails.fromJson(item))
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

  Future<void> getFollowUpStatus(BuildContext context, String viewId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Build endpoint and add pagination parameters. Only include ViewIn_Id when provided.
      String endPoint =
          '${HttpUrls.searchStatus}?status_Name=&Page_Index=1&PageSize=1000';
      if (viewId.isNotEmpty) {
        endPoint =
            '${HttpUrls.searchStatus}?status_Name=&ViewIn_Id=$viewId&Page_Index=1&PageSize=1000';
      }
      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;
        print(
            'DEBUG getFollowUpStatus: Data type=${data.runtimeType}, Value=$data');

        if (data != null) {
          // Handle both list and map responses
          if (data is List<dynamic>) {
            _followUpstatus = data
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _followUpstatus = (data['data'] as List<dynamic>)
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else {
            _followUpstatus = [];
          }
          print(
              'DEBUG getFollowUpStatus: Loaded ${_followUpstatus.length} statuses');
          notifyListeners();
        }
      } else {
        print('DEBUG getFollowUpStatus: Server error ${response.statusCode}');
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

  Future<void> getFollowUpStatusCustomer(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Build endpoint and add pagination parameters. Only include ViewIn_Id when provided.
      String endPoint =
          '${HttpUrls.getFollowUpStatusCustomer}?status_Name=&Page_Index=1&PageSize=1000';

      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;
        print(
            'DEBUG getFollowUpStatus: Data type=${data.runtimeType}, Value=$data');

        if (data != null) {
          // Handle both list and map responses
          if (data is List<dynamic>) {
            _followUpstatus = data
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _followUpstatus = (data['data'] as List<dynamic>)
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else {
            _followUpstatus = [];
          }
          print(
              'DEBUG getFollowUpStatus: Loaded ${_followUpstatus.length} statuses');
          notifyListeners();
        }
      } else {
        print('DEBUG getFollowUpStatus: Server error ${response.statusCode}');
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

  void getTaskType(BuildContext context,
      {String enquiryForId = '0', bool fetchUserSpecific = true}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchTaskType,
          bodyData: {
            'Task_Type_Name': '',
            'Enquiry_For_Id': enquiryForId,
          });

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          List<TaskTypeModel> allTaskTypes = (data as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();

          if (fetchUserSpecific && userId.isNotEmpty) {
            try {
              final userResponse = await HttpRequest.httpGetRequest(
                endPoint: '${HttpUrls.getUserTaskType}/$userId',
              );
              if (userResponse.statusCode == 200 &&
                  userResponse.data != null &&
                  userResponse.data['data'] != null) {
                final responseData = userResponse.data['data'];
                List<dynamic> dataList;
                if (responseData is Map &&
                    responseData['task_type_list'] != null) {
                  dataList = responseData['task_type_list'] as List<dynamic>;
                } else if (responseData is List) {
                  dataList = responseData;
                } else {
                  dataList = [];
                }
                final userTaskTypes = dataList
                    .map((item) => UserTaskTypeModel.fromJson(item))
                    .toList();

                allTaskTypes = allTaskTypes.where((taskType) {
                  final matched = userTaskTypes.firstWhere(
                    (u) => u.taskTypeId == taskType.taskTypeId,
                    orElse: () => UserTaskTypeModel(isview: 0),
                  );
                  return matched.isview == 1;
                }).toList();
              } else {
                allTaskTypes = [];
              }
            } catch (e) {
              print('Exception occurred while fetching user task types: $e');
              allTaskTypes = [];
            }
          }

          _taskType = allTaskTypes;
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

  void getAMCStatus(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchAMCStatus,
          bodyData: {'amc_status_Name': ''});

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _amcStatus = (data as List<dynamic>)
              .map((item) => AMCStatusModel.fromJson(item))
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

  Future<List<TaskTypeStatusModel>> getStatusByTaskTypeId(
      BuildContext context, String taskTypeId, String viewInId) async {
    List<TaskTypeStatusModel> statusList = [];

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getStatusByTaskTypeId}/$taskTypeId/$viewInId");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          statusList = (data as List<dynamic>)
              .map((item) => TaskTypeStatusModel.fromJson(item))
              .toList();
        }
        return statusList;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        return statusList;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      return statusList;
    }
  }

  void getDocumentType(BuildContext context, {String searchQuery = ""}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchDocumentType,
          bodyData: {'Document_Type_Name': searchQuery});

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _documentType = (data as List<dynamic>)
              .map((item) => DocumentTypeModel.fromJson(item))
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

  void getLocations(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getLocation, bodyData: {'Location_Name': ''});

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _locationList = (data as List<dynamic>)
              .map((item) => LocationModel.fromJson(item))
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

  Future<void> fetchAndSetAssignedUser({
    required BuildContext context,
    required String leadId,
    required int? branchId,
    required int? departmentId,
    required dynamic leadProvider,
  }) async {
    if (leadId.isEmpty ||
        leadId == '0' ||
        departmentId == null ||
        departmentId == 0) {
      return;
    }

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getFollowupAssignedUser,
        bodyData: {
          'Lead_Id': leadId,
          'Department_Id': departmentId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('success') &&
            responseData['success'] == true) {
          responseData = responseData['data'];
        }

        Map<String, dynamic>? userMap;
        if (responseData is List<dynamic> && responseData.isNotEmpty) {
          userMap = responseData.first as Map<String, dynamic>;
        } else if (responseData is Map<String, dynamic>) {
          userMap = responseData;
        }

        if (userMap != null) {
          int? parsedUserId;
          final rawUserId = userMap['User_Details_Id'] ??
              userMap['user_details_id'] ??
              userMap['User_Id'] ??
              userMap['user_id'] ??
              userMap['Id'] ??
              userMap['id'];
          if (rawUserId != null) {
            parsedUserId = int.tryParse(rawUserId.toString());
          }

          final String parsedUserName = (userMap['User_Details_Name'] ??
                  userMap['user_details_name'] ??
                  userMap['User_Name'] ??
                  userMap['user_name'] ??
                  userMap['To_User_Name'] ??
                  userMap['to_user_name'] ??
                  userMap['Name'] ??
                  userMap['name'] ??
                  '')
              .toString()
              .trim();

          if (parsedUserId != null &&
              parsedUserId > 0 &&
              parsedUserName.isNotEmpty) {
            final alreadyInSearchUser =
                _searchUserDetails.any((u) => u.userDetailsId == parsedUserId);
            if (!alreadyInSearchUser) {
              _searchUserDetails.add(SearchUserDetails(
                userDetailsId: parsedUserId,
                userDetailsName: parsedUserName,
                workingStatus: "1",
                branchId: branchId?.toString(),
                departmentId: departmentId.toString(),
              ));
            }

            final alreadyInFilteredStaff =
                filteredStaffData.any((u) => u.userDetailsId == parsedUserId);
            if (!alreadyInFilteredStaff) {
              filteredStaffData.add(SearchUserDetails(
                userDetailsId: parsedUserId,
                userDetailsName: parsedUserName,
                workingStatus: "1",
                branchId: branchId?.toString(),
                departmentId: departmentId.toString(),
              ));
            }

            setSelectedUserId(parsedUserId);
            leadProvider.searchUserController.text = parsedUserName;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Exception occurred in fetchAndSetAssignedUser: $e');
    }
  }
}
