import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtify/controller/models/amc_status_model.dart';
import 'package:techtify/controller/models/district_model.dart';
import 'package:techtify/controller/models/document_type_model.dart';
import 'package:techtify/controller/models/enquiry_for_model.dart';
import 'package:techtify/controller/models/enquiry_source_model.dart';
import 'package:techtify/controller/models/follow_up_model.dart';
import 'package:techtify/controller/models/follow_up_status_model.dart';
import 'package:techtify/controller/models/search_lead_status_model.dart';
import 'package:techtify/controller/models/search_user_details_model.dart';
import 'package:techtify/controller/models/task_type_model.dart';
import 'package:techtify/controller/models/task_type_status_model.dart';
import 'package:techtify/http/http_requests.dart';

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

  List<Enquirysourcemodel> get enquiryData => _enquiryData;
  List<EnquiryForModel> get enquiryForList => _enquiryForList;
  List<FollowUpStatusModel> get followUpStatusList => _followUpStatusList;

  List<SearchUserDetails> get searchUserDetails => _searchUserDetails;
  List<SearchLeadStatusModel> get followUpData => _followUpstatus;
  List<TaskTypeModel> get taskType => _taskType;
  List<DocumentTypeModel> get documentType => _documentType;
  List<AMCStatusModel> get amcStatus => _amcStatus;
  // List<Enquirysourcemodel> filteredEnquiryData = []; // New filtered list
  List<EnquiryForModel> filteredEnquiryForData = []; // New filtered list

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
  int? _selectedFollowUpId;
  int? _selectedDepartmentId;

  int? get selectedUserId => _selectedUserId;
  int? get selectedpeUserId => _selectedpeUserId;
  String _selectedPEName = '';
  String get selectedPEName => _selectedPEName;
  int? get selectedcreUserId => _selectedcreUserId;
  int? get selectedleadtypeUserId => _selectedleadtypeUserId;
  int? get selectedStatusId => _selectedStatusId;
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
      // Example: notifyListeners();
    }
  }

  set selectedUserId(int? value) {
    // You can add logic here if needed (e.g., validation, state changes, etc.)
    if (_selectedUserId != value) {
      _selectedUserId = value;
      // Optionally, trigger a state change, call a method, or notify listeners if using providers
      // Example: notifyListeners();
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

  void setSelectedUserId(int id) {
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

  void setSelectedStatusId(int id) {
    _selectedStatusId = id;
    notifyListeners();
  }

  void setSelectedFollowUPId(int id) {
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
      print(selectedStatus.followup == 1);
      return selectedStatus.followup == 1;
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
      print(selectedStatus.followup == 1);
      return selectedStatus.followup == 1;
    }
    return false;
  }

  void getEnquirySource(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.enquirySource}?Enquiry_Source_Name=');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _enquiryData = (data as List<dynamic>)
              .map((item) => Enquirysourcemodel.fromJson(item))
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

  void getAllFollowUpStatus(BuildContext context, String viewId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.searchStatus}?status_Name=&ViewIn_Id=$viewId");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _followUpStatusList = (data as List<dynamic>)
              .map((item) => FollowUpStatusModel.fromJson(item))
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

  void getEnquiryFor(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.enquiryFor}?Enquiry_For_Name=');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _enquiryForList = (data as List<dynamic>)
              .map((item) => EnquiryForModel.fromJson(item))
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

  void getFollowUpStatus(BuildContext context, String viewId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchStatus}?status_Name=&ViewIn_Id=$viewId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _followUpstatus = (data as List<dynamic>)
              .map((item) => SearchLeadStatusModel.fromJson(item))
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

  void getTaskType(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchTaskType}?Task_Type_Name');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _taskType = (data as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
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

  void getAMCStatus(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchAMCStatus}?amc_status_Name');

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

  void getDocumentType(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchDocumentType}?Document_Type_Name=');

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
}
