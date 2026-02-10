// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print

import 'dart:developer';
import 'dart:io';
// import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/checklist_category_model.dart';
import 'package:vidyanexis/controller/models/checklist_item_model.dart';
import 'package:vidyanexis/controller/models/custom_field_dropdown.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'package:vidyanexis/controller/models/customer_details_model.dart';
import 'package:vidyanexis/controller/models/expense_type_model.dart';
import 'package:vidyanexis/controller/models/project_model.dart';
import 'package:vidyanexis/controller/models/project_type_model.dart';
import 'package:vidyanexis/controller/models/source_category_model.dart';
import 'package:vidyanexis/controller/models/stage_model.dart';
import 'package:vidyanexis/controller/models/tax_slab_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/category_model.dart';
import 'package:vidyanexis/controller/models/checklist_type_model.dart';
import 'package:vidyanexis/controller/models/company_details_model.dart';
import 'package:vidyanexis/controller/models/department_model.dart';
import 'package:vidyanexis/controller/models/document_type_model.dart';
import 'package:vidyanexis/controller/models/dummy_models.dart';
import 'package:vidyanexis/controller/models/enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/enquiry_settings_model.dart';
import 'package:vidyanexis/controller/models/get_menu_permsiion_model.dart';
import 'package:vidyanexis/controller/models/get_user_model.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/models/search_status_model.dart';
import 'package:vidyanexis/controller/models/search_user_model.dart';
import 'package:vidyanexis/controller/models/search_working_status_model.dart';
import 'package:vidyanexis/controller/models/show_menu_model.dart';
import 'package:vidyanexis/controller/models/sub_user_model.dart';
import 'package:vidyanexis/controller/models/supplier_model.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/unit_model.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class SettingsProvider extends ChangeNotifier {
  SidebarProvider? _sideBarProvider;
  SidebarProvider? get sideBarProvider {
    if (_sideBarProvider == null &&
        navigatorKey.currentState?.context != null) {
      _sideBarProvider = Provider.of<SidebarProvider>(
          navigatorKey.currentState!.context,
          listen: false);
    }
    return _sideBarProvider;
  }

  //variables
  bool _allowAppLogin = false;

  bool _isSavingTeam = false;
  String _selectedMenu = 'Users';

  String get selectedMenu => _selectedMenu;

  bool _passwordVisible = false;
  bool _newpasswordVisible = false;
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController searchUnitController = TextEditingController();

  //controllers
  final TextEditingController versionController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userTypeController = TextEditingController();
  final TextEditingController passWordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController searchCategoryController =
      TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController defaultStatusController = TextEditingController();
  final TextEditingController categoryNameController = TextEditingController();

  final TextEditingController workingStatusController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController searchStatusController = TextEditingController();
  final TextEditingController searchEnquiryController = TextEditingController();
  final TextEditingController searchStageController = TextEditingController();
  final TextEditingController searchSourceCategoryController =
      TextEditingController();
  final TextEditingController searchCustomFieldController =
      TextEditingController();

  final TextEditingController searchEnquiryForController =
      TextEditingController();
  final TextEditingController searchDocumentTypeController =
      TextEditingController();
  final TextEditingController searchCheckListController =
      TextEditingController();
  final TextEditingController searchTaskTypeController =
      TextEditingController();
  final TextEditingController departmentUserController =
      TextEditingController();
  final TextEditingController employeeCodeController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController dateOfJoinController = TextEditingController();
  //status controllers
  final TextEditingController statusController = TextEditingController();

  final TextEditingController folloupController = TextEditingController();

  final TextEditingController isRegisterController = TextEditingController();
  final TextEditingController viewInController = TextEditingController();
  final TextEditingController stageStatusController = TextEditingController();
  final TextEditingController progressValueController = TextEditingController();
  final TextEditingController sourceCategoryEnquiryController =
      TextEditingController();
  final TextEditingController projectController = TextEditingController();
  final TextEditingController searchProjectController = TextEditingController();
  final TextEditingController projectTypeController = TextEditingController();
  final TextEditingController searchProjectTypeController =
      TextEditingController();

  //enquiry source
  final TextEditingController enquirySourceController = TextEditingController();
//STAGE
  final TextEditingController stageController = TextEditingController();
//source category
  final TextEditingController sourceCategoryController =
      TextEditingController();

  //enquiry for
  final TextEditingController enquiryForController = TextEditingController();

  //document type
  final TextEditingController documentTypeController = TextEditingController();

  //checklist
  final TextEditingController checkListController = TextEditingController();

  //custom field
  final TextEditingController fieldNameController = TextEditingController();
  final TextEditingController fieldTypeController = TextEditingController();
  final TextEditingController fieldListController = TextEditingController();
  List<String> fieldListItems = [];

  //tasktype
  final TextEditingController taskTypeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController departmentTaskController =
      TextEditingController();
  final TextEditingController statusTaskController = TextEditingController();

//status
  final TextEditingController statusPageSearchController =
      TextEditingController();
  final TextEditingController statusPageController = TextEditingController();
  final TextEditingController statusFollowUpController =
      TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController searchDepartmentController =
      TextEditingController();

  final TextEditingController searchBranchController = TextEditingController();
  final TextEditingController branchController = TextEditingController();

  //expense type
  final TextEditingController searchExpenseTypeController =
      TextEditingController();
  final TextEditingController expenseTypeController = TextEditingController();

  //lists
  List<BranchModel> _branchModel = [];
  List<BranchModel> get branchModel => _branchModel;
  List<GetUserModel> _searchUserDetails = [];
  List<GetUserModel> get searchUserDetails => _searchUserDetails;
  List<SearchLeadStatusModel> _searchLeadType = [];
  List<SearchLeadStatusModel> get searchType => _searchLeadType;
  List<SupplierModel> _searchSupplier = [];
  List<SupplierModel> get searchSupplier => _searchSupplier;
  List<SubUsersDatum> _searchSubUsers = [];
  List<SubUsersDatum> get searchSubUsers => _searchSubUsers;
  List<CustomFieldTypeModel> _customFieldTypeModelList = [];
  List<CustomFieldTypeModel> get customFieldTypeModelList =>
      _customFieldTypeModelList;
  List<SearchUserTypeModel> _searchUserType = [];
  List<SearchUserTypeModel> get searchUserType => _searchUserType;
  List<SearchWorkingStatusModel> _searchWorkingStatus = [];
  List<SearchWorkingStatusModel> get searchWorkingStatus =>
      _searchWorkingStatus;
  List<GetMenuPermissionModel> _getMenuPermission = [];
  List<GetMenuPermissionModel> get getMenu => _getMenuPermission;
  List<EnquirySourceModel> _searchEnquiryStatus = [];
  List<EnquirySourceModel> get searchEnquiryStatus => _searchEnquiryStatus;
  //stage
  List<StageModel> _searchStage = [];
  List<StageModel> get searchStage => _searchStage;
  //source category
  List<SourceCategoryModel> _searchSourceCategory = [];
  List<SourceCategoryModel> get searchSourceCategory => _searchSourceCategory;
  List<EnquiryForModel> _searchEnquiryFor = [];
  List<EnquiryForModel> get searchEnquiryFor => _searchEnquiryFor;
  List<MenuPermissionModel> _showMenu = [];
  List<MenuPermissionModel> get showMenu => _showMenu;
  List<DocumentTypeModel> _documentType = [];
  List<DocumentTypeModel> get documentType => _documentType;
  List<CustomFieldModel> customFieldModelList = [];
  List<ExpenseTypeModel> _expenseTypeList = [];
  List<ExpenseTypeModel> get expenseTypeList => _expenseTypeList;
  List<CustomerModel> _customerTypeList = [];
  List<CustomerModel> get customerTypeList => _customerTypeList;
  List<TaxSlabModel> _taxSlabModel = [];
  List<TaxSlabModel> get taxSlabModel => _taxSlabModel;

  List<SearchStatusModel> _status = [];
  List<SearchStatusModel> get status => _status;
  List<CheckListTypeModel> _checkListType = [];
  List<CheckListTypeModel> get checkListType => _checkListType;
  List<TaskTypeModel> _taskType = [];
  List<TaskTypeModel> get taskType => _taskType;
  List<DepartmentModel> _departmentModel = [];
  List<DepartmentModel> get departmentModel => _departmentModel;
  bool get allowAppLogin => _allowAppLogin;
  int _selectedUserTypeId = -1;
  int _selectedWorkingStatusId = -1;
  int _selectedDefaultStatusId = -1;

  int _selectedDepartmentId = -1;
  List<CategoryModel> _searchCategory = [];
  List<CategoryModel> get searchCategory => _searchCategory;
  bool get passwordVisible => _passwordVisible;
  bool get isSavingTeam => _isSavingTeam;
  int _stageId = 0;
  int get stageId => _stageId;
  int _sourceCategoryId = 0;
  int get sourceCategoryId => _sourceCategoryId;
  int _fieldNameid = 0;
  int get fieldNameid => _fieldNameid;

  int? editingIndex;
  bool get newpasswordVisible => _newpasswordVisible;
  int get selectedUserTypeId => _selectedUserTypeId;
  int get selectedWorkingStatusId => _selectedWorkingStatusId;
  int get selectedDefaultStatusId => _selectedDefaultStatusId;

  int get selectedDepartmentId => _selectedDepartmentId;
  List<UnitModel> _searchUnit = [];
  List<UnitModel> get searchUnit => _searchUnit;
  int? selectedUserId;
  int? _selectedFollowUp;
  int? get selectedFollowUp => _selectedFollowUp;
  int _viewInId = 0;
  int get viewInId => _viewInId;

  dynamic _isRegister;
  dynamic get isRegister => _isRegister;

  final Map<int, int> _menuIsViewMap = {};
  Map<int, int> get menuIsViewMap => _menuIsViewMap;
  final Map<int, int> _menuIsEditMap = {};
  Map<int, int> get menuIsEditMap => _menuIsEditMap;
  final Map<int, int> _menuIsSaveMap = {};
  Map<int, int> get menuIsSaveMap => _menuIsSaveMap;
  final Map<int, int> _menuIsDeleteMap = {};
  Map<int, int> get menuIsDeleteMap => _menuIsDeleteMap;
  //show checkbox
  final Map<int, int> _showView = {};
  Map<int, int> get showView => _showView;
  final Map<int, int> _showEdit = {};
  Map<int, int> get showEdit => _showEdit;
  final Map<int, int> _showSave = {};
  Map<int, int> get showSave => _showSave;
  final Map<int, int> _showDelete = {};
  Map<int, int> get showDelete => _showDelete;

  List<Company> _companyDetails = [];
  List<Company> get companyDetails => _companyDetails;
  String logo = '';
  String title = '';

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailBranchController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController branchCampaignController =
      TextEditingController();
  final TextEditingController departmentCampaignController =
      TextEditingController();
  CustomFieldTypeModel _selectedCustomFieldType = CustomFieldTypeModel();
  CustomFieldTypeModel get selectedCustomFieldType => _selectedCustomFieldType;
  //company
  final TextEditingController cnameController = TextEditingController();
  final TextEditingController caddress1Controller = TextEditingController();
  final TextEditingController caddress2Controller = TextEditingController();
  final TextEditingController caddress3Controller = TextEditingController();
  final TextEditingController caddress4Controller = TextEditingController();
  final TextEditingController cphoneController = TextEditingController();
  final TextEditingController cmobileController = TextEditingController();
  final TextEditingController cemailController = TextEditingController();
  final List<Uint8List> _images = [];
  List<Uint8List> get images => _images;
  String uploadedFilePath = '';

  int _toggleValue = 0;
  int? _selectedStatusId;

  int get toggleValue => _toggleValue;
  int? _selectedBranchId = -1;
  int? get selectedBranchId => _selectedBranchId;

  int _isOTPChecked = 0;
  int get isOTPChecked => _isOTPChecked;
  int _isFeedbackChecked = 0;
  int get isFeedbackChecked => _isFeedbackChecked;
  int? get selectedStatusId => _selectedStatusId;

  List<ProjectTypeModel> _projectTypeList = [];
  List<ProjectTypeModel> get projectTypeList => _projectTypeList;
  List<ProjectModel> _projectList = [];
  List<ProjectModel> get projectList => _projectList;

  set selectedBranchId(int? id) {
    _selectedBranchId = id;
    notifyListeners();
  }

  saveBranch({
    required BuildContext context,
    required String branchId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveBranch,
          bodyData: {
            "branch_id": branchId,
            "branch_name": branchController.text,
            "address": addressController.text,
            "phone": phoneController.text,
            "pincode": pinCodeController.text,
            "email": emailBranchController.text,
            "contact_person": contactPersonController.text
          });

      if (response!.statusCode == 200) {
        branchController.clear();
        addressController.clear();
        phoneController.clear();
        pinCodeController.clear();
        emailBranchController.clear();
        contactPersonController.clear();
        final data = response.data;
        searchBranch(context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void clearBranchFields() {
    branchController.clear();
    addressController.clear();
    phoneController.clear();
    pinCodeController.clear();
    emailBranchController.clear();
    contactPersonController.clear();
  }

  void searchBranch(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getAllBranch);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['success'] == true) {
          List<dynamic> branchList = data['data'];

          _branchModel =
              branchList.map((item) => BranchModel.fromJson(item)).toList();

          notifyListeners();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No departments found')),
          );
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

  saveCustomField(
      BuildContext context, CustomFieldModel customFieldModel) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      // Use customFieldTypeId to determine which list to populate
      if (customFieldModel.customFieldTypeId == 3) {
        customFieldModel.dropDownValues = fieldListItems;
      } else if (customFieldModel.customFieldTypeId == 5) {
        customFieldModel.checkBoxValues = fieldListItems;
      }
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveCustomField,
          bodyData: customFieldModel.toJson());

      if (response!.statusCode == 200) {
        final data = response.data;

        getCustomField(context);
        notifyListeners();
        if (data != null) {}
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

  Future<List<CustomFieldModel>>? getCustomField(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getCustomField);
      print(response.data);
      if (response.statusCode == 200) {
        final body = response.data;
        if (body != null) {
          customFieldModelList = (body as List<dynamic>)
              .map((item) => CustomFieldModel.fromJson(item))
              .toList();
          notifyListeners();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
    } catch (e) {
      print('Exception occured: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occured')));
    }
    return customFieldModelList;
  }

  Future<bool?> deleteCustomField(
      BuildContext context, String customfieldId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteCustomField,
          bodyData: {"Custom_Field_Id": customfieldId});
      if (response != null && response.statusCode == 200) {
        final data = response.data;
        print("sdfgf $data");

        int id = int.parse(data[0]["p_custom_field_id"].toString());
        if (id > 0) {
          Loader.stopLoader(context);
          showToastInDialog("Success", context);
        } else {
          showToastInDialog("Not deleted", context);

          Loader.stopLoader(context);
        }
        notifyListeners();
        return id > 0;
      } else {
        showToastInDialog("'Failed to delete custom field'", context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      Loader.stopLoader(context);
    }
    return false;
  }

  deleteBranch(BuildContext context, int branchId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteBranch, bodyData: {"branch_id": branchId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['branch_id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an branch Type \n that is currently in use");
        } else {
          searchBranch(context);
          branchController.clear();
          addressController.clear();
          phoneController.clear();
          pinCodeController.clear();
          emailBranchController.clear();
          contactPersonController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Branch deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete branch')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void setToggleValue(int value) {
    _toggleValue = value;
    notifyListeners();
  }

  void setSelectedMenu(String menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  void toggle() {
    _toggleValue = _toggleValue == 1 ? 0 : 1;
    notifyListeners();
  }

  void toggleOTPCheckbox(bool value) {
    _isOTPChecked = value ? 1 : 0;
    print(_isOTPChecked.toString());
    notifyListeners();
  }

  void setFollowupId(int id) {
    _selectedStatusId = id;
    notifyListeners();
  }

  void toggleFeedbackCheckbox(bool value) {
    _isFeedbackChecked = value ? 1 : 0;
    print(_isFeedbackChecked.toString());
    notifyListeners();
  }

  searchSupplierApi(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchSupplier}?Supplier_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'];
          print(newData);
          _searchSupplier = (newData as List<dynamic>)
              .map((item) => SupplierModel.fromJson(item))
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

  void updateMenuPermission(int menuId, String permissionType, int value) {
    final menuIndex =
        _getMenuPermission.indexWhere((menu) => menu.menuId == menuId);
    if (menuIndex != -1) {
      final updatedMenu = _getMenuPermission[menuIndex].copyWith(
        isView: permissionType == 'isView'
            ? value
            : _getMenuPermission[menuIndex].isView,
        isSave: permissionType == 'isSave'
            ? value
            : _getMenuPermission[menuIndex].isSave,
        isEdit: permissionType == 'isEdit'
            ? value
            : _getMenuPermission[menuIndex].isEdit,
        isDelete: permissionType == 'isDelete'
            ? value
            : _getMenuPermission[menuIndex].isDelete,
      );
      _getMenuPermission[menuIndex] = updatedMenu;
      notifyListeners();
    }
  }

  Future<void> getSubUsers(String userdetailsId, BuildContext context,
      {Function(List<SubUsersDatum>)? onSubUsersLoaded}) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.getUsersSub}/$userdetailsId',
      );

      if (response.statusCode == 200) {
        final body = response.data;

        if (body != null && body['SubUsersData'] != null) {
          final List<dynamic> subUsersList = body['SubUsersData'];

          _searchSubUsers =
              subUsersList.map((item) => SubUsersDatum.fromJson(item)).toList();

          // Call the optional callback with the loaded sub-users
          if (onSubUsersLoaded != null) {
            onSubUsersLoaded(_searchSubUsers);
          }

          notifyListeners();
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('No sub-users found')),
          // );
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

  Future<void> getCustomFieldDropDown(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getCustomFieldType,
      );
      print(response.data);

      if (response.statusCode == 200) {
        final body = response.data;

        if (body != null) {
          _customFieldTypeModelList = (body as List<dynamic>)
              .map((item) => CustomFieldTypeModel.fromJson(item))
              .toList();

          // Call the optional callback with the loaded sub-users

          notifyListeners();
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('No sub-users found')),
          // );
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

  getSearchLeadStatus(String query, String viewId, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Use provided query or fall back to controller text
      String searchQuery = query;

      // Build endpoint and include ViewIn_Id only when provided
      String endPoint =
          '${HttpUrls.searchStatus}?status_Name=$searchQuery&Page_Index=1&PageSize=1000';
      if (viewId.isNotEmpty) {
        endPoint =
            '${HttpUrls.searchStatus}?status_Name=$searchQuery&ViewIn_Id=$viewId&Page_Index=1&PageSize=1000';
      }
      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // Handle both list and map responses
          if (data is List<dynamic>) {
            _searchLeadType = data
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _searchLeadType = (data['data'] as List<dynamic>)
                .map((item) => SearchLeadStatusModel.fromJson(item))
                .toList();
          } else {
            _searchLeadType = [];
          }
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

  void deleteUser(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteStatus}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['status_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Lead Status \n that is currently in use on the Lead page!");
        } else {
          _searchUserDetails
              .removeWhere((user) => user.userDetailsId == userId);
          getSearchLeadStatus(
              searchStatusController.text, viewInId.toString(), context);
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead Status deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void deleteEnquiry(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteEnquiry}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Enquiry_Source_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Enquiry Source \n that is currently in use on the Lead page!");
        } else {
          _searchEnquiryStatus
              .removeWhere((user) => user.enquirySourceId == userId);
          searchEnquiryStatusData('', context);
          enquirySourceController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enquiry deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete enquiry')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void deleteStage(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteStage}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Stage_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an stage \n that is currently in use on the Lead page!");
        } else {
          _searchStage.removeWhere((user) => user.stageId == userId);
          searchStageData('', context);
          searchStageController.clear();
          stageController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stage deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to Stage enquiry')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void deleteSourceCategory(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteSourceCategory}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Stage_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Source Category \n that is currently in use on the Lead page!");
        } else {
          _searchStage.removeWhere((user) => user.stageId == userId);
          searchsourceCategoryData('', context);
          searchSourceCategoryController.clear();
          sourceCategoryController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Source Category deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Source Category')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  addCategoryName({
    required BuildContext context,
    required String statusId,
    required String statusName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addCategory,
          bodyData: {"Category_Id": statusId, "Category_Name": statusName});

      if (response!.statusCode == 200) {
        categoryNameController.clear();

        final data = response.data;
        searchCategoryApi('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchCategoryController.clear();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addUnitName({
    required BuildContext context,
    required String statusId,
    required String statusName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addUnit,
          bodyData: {
            "Enquiry_Source_Id": statusId,
            "Enquiry_Source_Name": statusName
          });

      if (response!.statusCode == 200) {
        unitNameController.clear();

        final data = response.data;
        searchUnitApi('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchUnitController.clear();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void deleteUnit(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteUnit}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Enquiry_Source_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Unit \n that is currently in use on the Lead page!");
        } else {
          searchUnitApi('', context);
          unitNameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unit deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Unit')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void deleteCategory(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteCategory}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Category_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Category \n that is currently in use on the Lead page!");
        } else {
          searchCategoryApi('', context);
          categoryNameController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Category')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  saveMenuPermission({
    required BuildContext context,
    required int userId,
    required List<UserMenuSelection> menuPermissions,
  }) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();

      final menuSelectionModel = MenuSelectionModel(
        userId: userId,
        userMenuSelection: menuPermissions,
      );

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveMenuPermission,
        bodyData: menuSelectionModel.toJson(),
      );

      if (response?.statusCode == 200) {
        final data = response?.data;
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
        getMenuPermissionData(userId.toString(), context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error')),
        );

        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      const errorMessage = 'An error occurred';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(errorMessage)),
      );

      Loader.stopLoader(context);
    }
  }

  getUserDetails(String query, BuildContext context) async {
    try {
      // Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchUser}=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchUserDetails = (data as List<dynamic>)
              .map((item) => GetUserModel.fromJson(item))
              .toList();
        }
        notifyListeners();
        // Loader.stopLoader(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        // Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      // Loader.stopLoader(context);
    }
  }

  getMenuPermissionData(String userId, BuildContext context) async {
    try {
      log(userId);
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getMenuPermission}/$userId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _getMenuPermission = (data as List<dynamic>)
              .map((item) => GetMenuPermissionModel.fromJson(item))
              .toList();

          // Rename permission 32 to Print Quotation 1
          for (var i = 0; i < _getMenuPermission.length; i++) {
            if (_getMenuPermission[i].menuId == 32) {
              _getMenuPermission[i].menuName = 'Print Quotation 1';
            }
          }

          // Rename or add permission 55 as Print Quotation 2
          bool has55 = false;
          for (var i = 0; i < _getMenuPermission.length; i++) {
            if (_getMenuPermission[i].menuId == 55) {
              _getMenuPermission[i].menuName = 'Print Quotation 2';
              has55 = true;
            }
          }

          if (!has55) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 55,
                menuName: 'Print Quotation 2',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          if (!_getMenuPermission.any((element) => element.menuId == 67)) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 67,
                menuName: 'Voice Recording',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          SharedPreferences preferences = await SharedPreferences.getInstance();
          String loginuserId = preferences.getString('userId') ?? "";
          if (loginuserId == userId) {
            _menuIsViewMap.clear();
            _menuIsEditMap.clear();
            _menuIsDeleteMap.clear();
            _menuIsSaveMap.clear();

            //view
            for (var permission in _getMenuPermission) {
              menuIsViewMap[permission.menuId] = permission.isView;
              menuIsEditMap[permission.menuId] = permission.isEdit;
              menuIsDeleteMap[permission.menuId] = permission.isDelete;
              menuIsSaveMap[permission.menuId] = permission.isSave;
            }

            // Example: Access IsView dynamically for Menu_Id = 1
            // log('IsView for Users: ${menuIsViewMap[1]}');
            // log('IsView for Settings: ${menuIsViewMap[2]}');
            // log('IsView for Leads: ${menuIsViewMap[3]}');
            // log('IsView for Customer: ${menuIsViewMap[4]}');
            // log('IsView for Lead Status: ${menuIsViewMap[5]}');
            // log('IsView for Enquiry Source: ${menuIsViewMap[6]}');
            // log('IsView for Reports: ${menuIsViewMap[7]}');
            // log('IsDelete for Users: ${menuIsDeleteMap[1]}');
            // log('IsDelete for Settings: ${menuIsDeleteMap[2]}');
            // log('IsDelete for Leads: ${menuIsDeleteMap[3]}');
            // log('IsDelete for Customer: ${menuIsDeleteMap[4]}');
            // log('IsDelete for Lead Status: ${menuIsDeleteMap[5]}');
            // log('IsDelete for Enquiry Source: ${menuIsDeleteMap[6]}');
            // log('IsDelete for Reports: ${menuIsDeleteMap[7]}');
          }
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

  searchUnitApi(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchUnit}?Supplier_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'];
          print(newData);
          _searchUnit = (newData as List<dynamic>)
              .map((item) => UnitModel.fromJson(item))
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

  searchCategoryApi(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchCategory}?Supplier_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'];
          print(newData);
          _searchCategory = (newData as List<dynamic>)
              .map((item) => CategoryModel.fromJson(item))
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

  void deleteUserContent(BuildContext context, String userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteUser}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['user_details_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context, "Can not Delete User. Delete the follow up first ");
        } else {
          searchController.clear();
          getUserDetails('', context);
          notifyListeners();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead Status deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  searchUserTypeDetails(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.searchUserType);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchUserType = (data as List<dynamic>)
              .map((item) => SearchUserTypeModel.fromJson(item))
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

  searchWorkingStatusData(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.searchWorkingStatus);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchWorkingStatus = (data as List<dynamic>)
              .map((item) => SearchWorkingStatusModel.fromJson(item))
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

  searchEnquiryStatusData(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchEnquiryStatus}?Enquiry_Source_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchEnquiryStatus = (data as List<dynamic>)
              .map((item) => EnquirySourceModel.fromJson(item))
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

  searchStageData(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchStage}?Stage_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchStage = (data as List<dynamic>)
              .map((item) => StageModel.fromJson(item))
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

  searchsourceCategoryData(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchSourceCategoty}?Source_Category_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchSourceCategory = (data as List<dynamic>)
              .map((item) => SourceCategoryModel.fromJson(item))
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

  Future<List<CheckListCategoryModel>> getCheckListCategory(
      String query, BuildContext context) async {
    List<CheckListCategoryModel> categoryList = [];
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.searchCheckListCategory,
          bodyData: {"Check_List_Category_Name": query});

      if (response?.statusCode == 200) {
        final data = response?.data;
        final newData = data['data'];
        if (newData != null) {
          categoryList = (newData as List<dynamic>)
              .map((item) => CheckListCategoryModel.fromJson(item))
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
    return categoryList;
  }

  Future<List<CheckListItemModel>> getCheckListItem(
      String query, BuildContext context) async {
    List<CheckListItemModel> categoryList = [];
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.searchCheckListItem,
          bodyData: {"Check_List_Item_Name": query});

      if (response?.statusCode == 200) {
        final data = response?.data;
        final newData = data['data'];
        if (newData != null) {
          categoryList = (newData as List<dynamic>)
              .map((item) => CheckListItemModel.fromJson(item))
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
    return categoryList;
  }

  addCheckListItem({
    required BuildContext context,
    required CheckListItemModel itemModel,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveCheckListItem, bodyData: itemModel.toJson());

      Loader.stopLoader(context);

      if (response?.statusCode == 200) {
        final data = response!.data;
        final message = data["message"];

        showToastInDialog(message, context);

        if (data['success']) {
          Navigator.pop(context, true);
        }
      } else {
        showToastInDialog("Server Error", context);
      }
    } catch (e) {
      Loader.stopLoader(context);
      showToastInDialog("An error occurred", context);
    }
  }

  Future<List<CheckListCategoryModel>> getDocumentChecklistDetails(
      String checkListDocumentId, BuildContext context) async {
    List<CheckListCategoryModel> categoryList = [];
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              "${HttpUrls.getDocumentChecklistDetails}?Document_Check_List_Master_Id=$checkListDocumentId");

      if (response.statusCode == 200) {
        final data = response.data;
        final newData = data['data'];
        if (newData != null) {
          categoryList = (newData as List<dynamic>)
              .map((item) => CheckListCategoryModel.fromJson(item))
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
    return categoryList;
  }

  Future<List<DocumentChecklistModel>> getDocumentCheckList(
      BuildContext context) async {
    List<DocumentChecklistModel> dataList = [];
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getDocumentCheckList);

      if (response.statusCode == 200) {
        final data = response.data;
        final newData = data['data'];
        if (newData != null) {
          dataList = (newData as List<dynamic>)
              .map((item) => DocumentChecklistModel.fromJson(item))
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
    return dataList;
  }

  Future saveDocumentCheckList({
    required BuildContext context,
    required List<CheckListCategoryModel> categoryList,
    required DocumentChecklistModel checkListModel,
  }) async {
    try {
      Loader.showLoader(context);

      List<CheckListItemModel> checkedItems = categoryList
          .expand<CheckListItemModel>((category) => (category.items ?? [])
              .where((item) => item.isChecked == true)
              .map((item) => item.copyWith(
                    checkListCategoryId: category.checkListCategoryId,
                    checkListCategoryName: category.checkListCategoryName,
                  )))
          .toList();
      var data = {
        "checkListData": checkListModel,
        "items": checkedItems,
      };

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveDocumentCheckList, bodyData: data);

      Loader.stopLoader(context);

      if (response?.statusCode == 200) {
        final data = response!.data;
        final message = data["message"];

        showToastInDialog(message, context);

        if (data['success']) {
          Navigator.pop(context, true);
        }
      } else {
        showToastInDialog("Server Error", context);
      }
    } catch (e) {
      Loader.stopLoader(context);
      showToastInDialog("An error occurred", context);
    }
  }

  Future deleteChecklist(BuildContext context, int checkListMasterId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteDocumentCheckList,
          bodyData: {"Document_Check_List_Master_Id": checkListMasterId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final message = data["message"];
        int id = data["data"][0]["Deleted_Master_Id"];
        getDocumentCheckList(context);

        Loader.stopLoader(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete enquiry')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  addUser({
    required BuildContext context,
    required String userDetailsId,
    required String userDetailsName,
    required String password,
    required String workingStatus,
    required String userType,
    required String addressName1,
    required String addressName2,
    required String addressName3,
    required String addressName4,
    required String mobile,
    required String countryCodeName,
    required String gmail,
    required String departmentId,
    required String departmentName,
    required String branchId,
    required String branchName,
    required String appLogin,
  }) async {
    try {
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addUser,
          bodyData: {
            "User_Details_Id": userDetailsId,
            "User_Details_Name": userDetailsName,
            "Password": password,
            "Working_Status": workingStatus,
            "User_Type": userType,
            "Address1": addressName1,
            "Address2": addressName2,
            "Address3": addressName3,
            "Address4": addressName4,
            "Mobile": mobile,
            "Country_Code_Name": countryCodeName,
            "Email": gmail,
            "Department_Id": departmentId,
            "Department_Name": departmentName,
            "Branch_Id": branchId,
            "Branch_Name": branchName,
            "Allow_App_Login": appLogin,
            "Employee_Code": employeeCodeController.text,
            "Designation": designationController.text,
            "DOJ": dateOfJoinController.text.toyyyymmdd(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;

        await getUserDetails('', context);
        searchController.clear();

        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<void> addSubUserDetails({
    required BuildContext context,
    required String userDetailsId,
    required List<Map<String, dynamic>> subUsers,
  }) async {
    _isSavingTeam = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveSubUsers,
        bodyData: {
          "User_Details_Id": userDetailsId,
          "Sub_User_Details": subUsers,
        },
      );

      _isSavingTeam = false;
      notifyListeners();

      if (response!.statusCode == 200) {
        Navigator.pop(context);
        print(response.data);
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
      _isSavingTeam = false;
      notifyListeners();
    }
  }

  addLeadStatus({
    required BuildContext context,
    required String statusId,
    required String statusName,
    required String statusOrder,
    required String followUp,
    required String isRegistered,
    required String colorCode,
    required final customFields,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addLeadStatus,
          bodyData: {
            "Status_Id": statusId,
            "Status_Name": statusName,
            "Status_Order": statusOrder,
            "Followup": followUp,
            "Is_Registered": isRegistered,
            "registered": isRegistered,
            "Color_Code": colorCode,
            "ViewIn_Id": viewInId,
            "ViewIn_Name": viewInController.text.toString(),
            "Stage_Id": stageId,
            "Stage_Name": stageStatusController.text.toString(),
            "Progress_Value": progressValueController.text,
            "Custom_Fields": customFields,
          });

      if (response!.statusCode == 200) {
        // notifyListeners() might be enough to refresh the list,
        // but we don't clear form fields here to prevent flicker/reset before pop.
        getSearchLeadStatus(
            searchStatusController.text, viewInId.toString(), context);
        Navigator.pop(context);
        Loader.stopLoader(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addEnquiryName({
    required BuildContext context,
    required String statusId,
    required String statusName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addEnquirySource,
          bodyData: {
            "Enquiry_Source_Id": statusId,
            "Enquiry_Source_Name": statusName,
            // "Source_Category_Id": sourceCategoryId,
            // "Source_Category_Name": sourceCategoryEnquiryController.text
          });

      if (response!.statusCode == 200) {
        enquirySourceController.clear();
        searchEnquiryController.clear();
        sourceCategoryEnquiryController.clear();
        setSourceId(0);

        final data = response.data;
        searchEnquiryStatusData('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);

        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addStage({
    required BuildContext context,
    required String stageId,
    required String stageName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveStage,
          bodyData: {"Stage_Id": stageId, "Stage_Name": stageName});

      if (response!.statusCode == 200) {
        stageController.clear();

        final data = response.data;
        searchStageData('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchStageController.clear();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addSourceCategory({
    required BuildContext context,
    required String sourceCategoryId,
    required String sourceCategoryName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveSourceCategory,
          bodyData: {
            "Source_Category_Id": sourceCategoryId,
            "Source_Category_Name": sourceCategoryName
          });

      if (response!.statusCode == 200) {
        stageController.clear();

        final data = response.data;
        searchsourceCategoryData('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchSourceCategoryController.clear();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addEnquiryForName({
    required BuildContext context,
    required String forId,
    required String forName,
    required final customFields,
  }) async {
    try {
      Loader.showLoader(context);
      print('=== addEnquiryForName DEBUG ===');
      print('customFields type: ${customFields.runtimeType}');
      print('customFields: $customFields');
      print('customFields is List: ${customFields is List}');
      print('customFields length: ${customFields?.length ?? 0}');
      Map<String, dynamic> bodyData = {
        "Enquiry_For_Id": forId,
        "Enquiry_For_Name": forName,
        "Source_Category_Id": sourceCategoryId,
        "Source_Category_Name": sourceCategoryEnquiryController.text,
        "Custom_Fields": customFields,
      };

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addEnquiryFor, bodyData: bodyData);

      if (response!.statusCode == 200) {
        enquirySourceController.clear();
        searchEnquiryForController.clear();
        sourceCategoryEnquiryController.clear();
        setSourceId(0);
        final data = response.data;
        searchEnquiryForData('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  searchEnquiryForData(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchEnquiryFor}?Enquiry_For_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _searchEnquiryFor = (data as List<dynamic>)
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

  void deleteEnquiryFor(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteEnquiryFor}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Enquiry_For_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Enquiry For \n that is currently in use on the Lead page!");
        } else {
          searchEnquiryForData('', context);
          enquiryForController.clear();
          searchEnquiryForController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enquiry For deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete enquiry For')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  saveDepartment({
    required BuildContext context,
    required String departmentId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveDepartment,
          bodyData: {
            "department_id": departmentId,
            "department_name": departmentController.text
          });

      if (response!.statusCode == 200) {
        departmentController.clear();

        final data = response.data;
        searchDepartment('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void searchDepartment(String search, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchDepartment}?Search_department=$search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['success'] == true) {
          List<dynamic> departmentList = data['data'][0];

          _departmentModel = departmentList
              .map((item) => DepartmentModel.fromJson(item))
              .toList();

          notifyListeners();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No departments found')),
          );
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

  deleteDepartment(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: '${HttpUrls.deleteDepartment}',
          bodyData: {"department_id": userId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['department_id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Task Type \n that is currently in use");
        } else {
          searchDepartment('', context);
          departmentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task Type deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Task Type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void setSelectedUserId(int userId) {
    selectedUserId = userId;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _newpasswordVisible = !_newpasswordVisible;
    notifyListeners();
  }

  void setSelectedFollowUp(int? value) {
    _selectedFollowUp = value;
    notifyListeners();
  }

  void setViewInId(int value) {
    _viewInId = value;
    notifyListeners();
  }

  void setStageId(int value) {
    _stageId = value;
    notifyListeners();
  }

  void setSourceId(int value) {
    _sourceCategoryId = value;
    notifyListeners();
  }
  // void setFieldId(int value){
  //   _fieldNameid=value;
  //   notifyListeners();
  // }

//field list

  void setFieldId(CustomFieldTypeModel customFieldTypeModel) {
    _fieldNameid = customFieldTypeModel.customFieldTypeId ?? 0;
    _selectedCustomFieldType = customFieldTypeModel;
    fieldTypeController.text = customFieldTypeModel.customFieldTypeName ?? "";
    if (_fieldNameid != 3 && _fieldNameid != 5) fieldListItems.clear();

    notifyListeners();
  }

  void addFieldItem(String value) {
    fieldListItems.add(value);
    fieldListController.clear();
    notifyListeners();
  }

  void removeFieldItem(int index) {
    fieldListItems.removeAt(index);
    notifyListeners();
  }

  // void editFieldItem(int index, String newValue) {
  //   fieldListItems[index] = newValue;
  //   notifyListeners();
  // }

  void startEditingItem(int index) {
    editingIndex = index;
    fieldListController.text = fieldListItems[index];
    notifyListeners();
  }

  void clearEditing() {
    editingIndex = null;
    fieldListController.clear();
    notifyListeners();
  }

  void saveEditedItem(String newValue) {
    if (editingIndex != null &&
        editingIndex! >= 0 &&
        editingIndex! < fieldListItems.length) {
      fieldListItems[editingIndex!] = newValue;
    }
    clearEditing();
  }

  void setIsRegistered(dynamic value) {
    _isRegister = value;
    notifyListeners();
  }

  set selectedUserTypeId(int value) {
    _selectedUserTypeId = value;
    notifyListeners();
  }

  set selectedWorkingStatusId(int value) {
    _selectedWorkingStatusId = value;
    notifyListeners();
  }

  set selectedDefaultStatus(int value) {
    _selectedDefaultStatusId = value;
    notifyListeners();
  }

  set selectedDepartmentId(int? id) {
    _selectedDepartmentId = id ?? -1;
    notifyListeners();
  }

  void setSelectedDepartmentId(int id) {
    _selectedDepartmentId = id;
    notifyListeners();
  }

  void resetStates() {
    _selectedUserTypeId = -1;
    _selectedWorkingStatusId = -1;
    _selectedDepartmentId = -1;
    _selectedDefaultStatusId = -1;
    _selectedBranchId = -1;

    userNameController.clear();
    userTypeController.clear();
    passWordController.clear();
    confirmPasswordController.clear();
    mobileNoController.clear();
    emailIdController.clear();
    workingStatusController.clear();
    defaultStatusController.clear();
    employeeCodeController.clear();
    designationController.clear();
    dateOfJoinController.clear();
    _allowAppLogin = false;
    notifyListeners();
  }

  reset() {
    _selectedDepartmentId = -1;
    _selectedBranchId = -1;

    branchCampaignController.clear();
    departmentCampaignController.clear();
  }

  String? _selectedColor;

  String? get selectedColor => _selectedColor;

  bool _isConversionChecked = false;

  bool get isConversionChecked => _isConversionChecked;

  bool _isLocationTracking = false;

  bool get isLocationTracking => _isLocationTracking;

  bool _isQuotationCustom = false;
  bool get isQuotationCustom => _isQuotationCustom;

  bool _isViewInQuotation = false;
  bool get isViewInQuotation => _isViewInQuotation;

  void toggleQuotationCustom(bool value) {
    _isQuotationCustom = value;
    notifyListeners();
  }

  void toggleViewInQuotation(bool value) {
    _isViewInQuotation = value;
    notifyListeners();
  }

  void toggleLocation(bool value) {
    _isLocationTracking = value;
    notifyListeners();
  }

  void toggleConversionCheckbox(bool value) {
    _isConversionChecked = value;
    notifyListeners();
  }

  void setSelectedColor(String? color) {
    _selectedColor = color;
    notifyListeners();
  }

  // App Login Toggle
  void toggleAppLogin(bool value) {
    _allowAppLogin = value;
    notifyListeners();
  }

  void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Unable to Delete:',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> getCompanyDetails() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getCompany);

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _companyDetails = (data as List<dynamic>)
              .map((item) => Company.fromJson(item))
              .toList();
          logo = _companyDetails[0].logo;
          title = _companyDetails[0].companyName ?? '';
          print(logo);

          notifyListeners();
        }
      } else {
        print(
            'getCompanyDetails failed: ${response?.statusCode} - ${response?.statusMessage}');
      }
    } catch (e, stackTrace) {
      print('Exception occurred in getCompanyDetails: $e');
      print(stackTrace);
    }
  }

  void saveIamgePath(path) {
    uploadedFilePath = path;
  }

  void saveCompanyDetails({
    required BuildContext context,
    required String companyId,
  }) async {
    print(uploadedFilePath);
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveCompany,
          bodyData: {
            "Company_Id": companyId,
            "Company_Name": cnameController.text.toString(),
            "Address1": caddress1Controller.text.toString(),
            "Address2": caddress2Controller.text.toString(),
            "Address3": caddress3Controller.text.toString(),
            "Address4": caddress4Controller.text.toString(),
            "Mobile_Number": cmobileController.text.toString(),
            "Phone_Number": cphoneController.text.toString(),
            "Email": cemailController.text.toString(),
            "Website": '',
            "Logo": uploadedFilePath,
            "Gst_No": '',
            "Pan_No": '',
            "Is_Location": _toggleValue
          });

      if (response!.statusCode == 200) {
        final data = response.data;

        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
        getCompanyDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<void> addFile() async {
    if (!kIsWeb) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      _images.clear();
      Uint8List? fileData;
      final file = result.files.first;
      if (file.bytes != null) {
        // For Web
        fileData = file.bytes;
      } else if (file.path != null) {
        // For Android/iOS
        fileData = await File(file.path!).readAsBytes();
      }
      if (fileData != null) {
        _images.add(fileData);
      } else {
        print('Unable to read file data for ${file.name}');
      }
      notifyListeners();
    }
  }

  void removeImage(Uint8List image) {
    _images.remove(image);
    notifyListeners();
  }

  Future<void> uploadImagesToAws(String taskId, BuildContext context) async {
    await _uploadFilesToAws(_images, 'image/jpeg', taskId, context);
  }

  Future<void> _uploadFilesToAws(List<Uint8List> files, String fileType,
      String taskId, BuildContext context) async {
    try {
      Loader.showLoader(context);
      for (var fileData in files) {
        uploadedFilePath =
            await saveToAws(fileData, fileType, taskId, context) ?? '';
        if (uploadedFilePath.isEmpty) {
          print('$fileType uploaded: $uploadedFilePath');
        } else {
          print('Upload failed for $fileType');
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading Image')),
      );
      print('Error uploading Image: $e');
    } finally {
      Loader.stopLoader(context);
    }
  }

  Future<String?> saveToAws(Uint8List fileData, String fileType, String taskId,
      BuildContext context) async {
    try {
      final String? uploadedFilePath =
          await CloudflareUpload.uploadToCloudflare(
              fileData, fileType, taskId, context);
      return uploadedFilePath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Failed')),
      );
      print('Error uploading to AWS: $e');
      return '';
    }
  }

  void clearCompanyControllers() {
    caddress1Controller.clear();
    caddress2Controller.clear();
    caddress3Controller.clear();
    caddress4Controller.clear();
    cemailController.clear();
    cphoneController.clear();
    cmobileController.clear();
    cnameController.clear();
    uploadedFilePath = '';
  }

  searchPermission(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchmenu}?menu_Name');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _showMenu = (data as List<dynamic>)
              .map((item) => MenuPermissionModel.fromJson(item))
              .toList();

          // Rename permission 32 to Print Quotation 1
          for (var i = 0; i < _showMenu.length; i++) {
            if (_showMenu[i].menuId == 32) {
              _showMenu[i].menuName = 'Print Quotation 1';
            }
          }

          // Rename or add permission 55 as Print Quotation 2
          bool has55 = false;
          for (var i = 0; i < _showMenu.length; i++) {
            if (_showMenu[i].menuId == 55) {
              _showMenu[i].menuName = 'Print Quotation 2';
              has55 = true;
            }
          }

          if (!has55) {
            _showMenu.add(MenuPermissionModel(
                menuId: 55,
                menuName: 'Print Quotation 2',
                menuOrder: 0,
                menuOrderSub: 0,
                isEdit: 1,
                isSave: 1,
                isDelete: 1,
                isView: 1,
                menuStatus: 1,
                menuType: 1));
          }

          var recordingMenu = _showMenu.firstWhere((e) => e.menuId == 67,
              orElse: () => MenuPermissionModel(
                  menuId: 67,
                  menuName: 'Voice Recording', // Fallback name
                  // Audio Recording Section
                  menuOrder: 0,
                  menuOrderSub: 0,
                  isEdit: 0, // Default to 0
                  isSave: 0, // Default to 0
                  isDelete: 0, // Default to 0
                  isView: 0, // Default to 0
                  menuStatus: 1,
                  menuType: 1));

          // Ensure it's in the list
          if (!_showMenu.contains(recordingMenu)) {
            _showMenu.add(recordingMenu);
          } else {
            // Force enable checkboxes if it came from backend with 0
            recordingMenu.isView = 1;
            recordingMenu.isEdit = 1;
            recordingMenu.isSave = 1;
            recordingMenu.isDelete = 1;
          }

          _showView.clear();
          _showEdit.clear();
          _showDelete.clear();
          _showSave.clear();

          //view
          for (var permission in _showMenu) {
            showView[permission.menuId] = permission.isView;
          }
          //edit
          for (var permission in _showMenu) {
            showEdit[permission.menuId] = permission.isEdit;
          }
          //delete
          for (var permission in _showMenu) {
            showDelete[permission.menuId] = permission.isDelete;
          }
          //save
          for (var permission in _showMenu) {
            showSave[permission.menuId] = permission.isSave;
          }

          // Example: Access IsView dynamically for Menu_Id = 1
          // log('IsView for Users: ${menuIsViewMap[1]}');
          // log('IsView for Settings: ${menuIsViewMap[2]}');
          // log('IsView for Leads: ${menuIsViewMap[3]}');
          // log('IsView for Customer: ${menuIsViewMap[4]}');
          // log('IsView for Lead Status: ${menuIsViewMap[5]}');
          // log('IsView for Enquiry Source: ${menuIsViewMap[6]}');
          // log('IsView for Reports: ${menuIsViewMap[7]}');
          // log('IsDelete for Users: ${menuIsDeleteMap[1]}');
          // log('IsDelete for Settings: ${menuIsDeleteMap[2]}');
          // log('IsDelete for Leads: ${menuIsDeleteMap[3]}');
          // log('IsDelete for Customer: ${menuIsDeleteMap[4]}');
          // log('IsDelete for Lead Status: ${menuIsDeleteMap[5]}');
          // log('IsDelete for Enquiry Source: ${menuIsDeleteMap[6]}');
          // log('IsDelete for Reports: ${menuIsDeleteMap[7]}');
        }
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

  addDocumentType({
    required BuildContext context,
    required String forId,
    required String forName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addDocumentType,
          bodyData: {"Document_Type_Id": forId, "Document_Type_Name": forName});

      if (response!.statusCode == 200) {
        documentTypeController.clear();
        searchDocumentTypeController.clear();

        final data = response.data;
        searchDocumentType('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  saveStatus({
    required BuildContext context,
    required bool followUp,
    required int? statusId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveStatus,
          bodyData: {
            "Status_Id": statusId,
            "Status_Name": statusPageController.text,
            "Status_Order": 0,
            "Followup": followUp ? 1 : 0,
            "Is_Registered": 0,
            "Color_Code": ""
          });

      if (response!.statusCode == 200) {
        final data = response.data;
        searchStatus(context, '0');
        Navigator.pop(context);
        Loader.stopLoader(context);
        statusPageController.clear();
        statusFollowUpController.clear();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void deleteStatus(BuildContext context, int statusId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteStatus}/$statusId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['status_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete a Status \n that is currently in use!");
        } else {
          searchStatus(context, '0');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status deleted successfully')),
          );
          Loader.stopLoader(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete status')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  searchDocumentType(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchDocumentType}?Document_Type_Name=$query');

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

  searchStatus(BuildContext context, String viewId) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      // Build endpoint and include ViewIn_Id only when provided
      String query = statusPageSearchController.text;
      String endPoint =
          '${HttpUrls.searchStatus}?status_Name=$query&Page_Index=1&PageSize=1000';
      if (viewId.isNotEmpty) {
        endPoint =
            '${HttpUrls.searchStatus}?status_Name=$query&ViewIn_Id=$viewId&Page_Index=1&PageSize=1000';
      }
      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // Handle both list and map responses
          if (data is List<dynamic>) {
            _status =
                data.map((item) => SearchStatusModel.fromJson(item)).toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _status = (data['data'] as List<dynamic>)
                .map((item) => SearchStatusModel.fromJson(item))
                .toList();
          } else {
            _status = [];
          }
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

  void deleteDocumentType(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteDocumentType}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Document_Type_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Document Type \n that is currently in use");
        } else {
          searchDocumentType('', context);
          documentTypeController.clear();
          searchDocumentTypeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document Type deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Document Type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

//checklist
  addCheckListType({
    required BuildContext context,
    required String forId,
    required String forName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addCheckListType,
          bodyData: {"Checklist_Id": forId, "Checklist_Name": forName});

      if (response!.statusCode == 200) {
        checkListController.clear();
        searchCheckListController.clear();

        final data = response.data;
        searchCheckList('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  searchCheckList(String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchCheckListType}?Checklist_Name_=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _checkListType = (data as List<dynamic>)
              .map((item) => CheckListTypeModel.fromJson(item))
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

  void deleteCheckList(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteCheckListType}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Checklist_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an CheckList Type \n that is currently in use");
        } else {
          searchCheckList('', context);
          checkListController.clear();
          searchCheckListController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('CheckList Type deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete CheckList Type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void searchTaskType(String search, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchTaskType}?Task_Type_Name=$search');

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

  addTaskType({
    required BuildContext context,
    required var data,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addTaskType, bodyData: data);

      if (response!.statusCode == 200) {
        taskTypeController.clear();
        searchTaskTypeController.clear();
        defaultStatusController.clear();
        durationController.clear();
        _selectedDefaultStatusId = -1;
        _selectedDepartmentId = -1;
        final data = response.data;
        searchTaskType('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void deleteTaskType(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteTaskType}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Task_Type_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Task Type \n that is currently in use");
        } else {
          searchTaskType('', context);
          taskTypeController.clear();
          searchTaskTypeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task Type deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Task Type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void saveVersion(BuildContext context) async {
    print(uploadedFilePath);
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveVersion,
          bodyData: {"VersionNumber": versionController.text.toString()});

      if (response!.statusCode == 200) {
        final data = response.data;

        Loader.stopLoader(context);
        print(data);
        getVersion();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<void> getVersion() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getVersion);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          String version = data['VersionNumber'].toString();
          print('Version ----$version');
          if (version != 'null') {
            versionController.text = version;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  addCheckListCategory({
    required BuildContext context,
    required CheckListCategoryModel categoryModel,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveCheckListCategory,
          bodyData: categoryModel.toJson());

      Loader.stopLoader(context);

      if (response?.statusCode == 200) {
        final data = response!.data;
        final message = data["message"];

        showToastInDialog(message, context);

        if (data['success']) {
          Navigator.pop(context, true);
        }
      } else {
        showToastInDialog("Server Error", context);
      }
    } catch (e) {
      Loader.stopLoader(context);
      showToastInDialog("An error occurred", context);
    }
  }

  Future<bool?> deleteCheckListItem(BuildContext context, String itemId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteCheckListItem,
          bodyData: {"Check_List_Item_Id": itemId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final message = data["message"];

        int id = data["data"][0]["Deleted_Item_Id"];

        if (id > 0) {
          Loader.stopLoader(context);
          showToastInDialog(message, context);
        } else {
          showToastInDialog(message, context);

          Loader.stopLoader(context);
        }
        notifyListeners();
        return id > 0;
      } else {
        showToastInDialog("'Failed to delete category'", context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<bool?> deleteCheckListCategory(
      BuildContext context, String categoryId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteCheckListCategory,
          bodyData: {"Check_List_Category_Id": categoryId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        final message = data["message"];

        int id = data["data"][0]["Deleted_Category_Id"];

        if (id > 0) {
          Loader.stopLoader(context);
          showToastInDialog(message, context);
        } else {
          showToastInDialog(message, context);

          Loader.stopLoader(context);
        }
        notifyListeners();
        return id > 0;
      } else {
        showToastInDialog("'Failed to delete category'", context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<List<ProjectTypeModel>> searchProjectTypes(
      String query, BuildContext context) async {
    _projectTypeList = [];
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchProjectType}?Project_Type_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data["data"];

        if (data != null) {
          _projectTypeList = (data as List<dynamic>)
              .map((item) => ProjectTypeModel.fromJson(item))
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
    return _projectTypeList;
  }

  addExpenseType({
    required BuildContext context,
    required String expenseId,
    required String expenseName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addExpenseType,
          bodyData: {
            "Expense_Type_Id": expenseId,
            "Expense_Type_Name": expenseName
          });

      if (response!.statusCode == 200) {
        expenseTypeController.clear();
        searchExpenseTypeController.clear();

        final data = response.data;
        getExpenseType('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<List<ExpenseTypeModel>> getExpenseType(
      String query, BuildContext context) async {
    _expenseTypeList = [];
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getExpenseTypes}?Expense_Type_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data["data"];

        if (data != null &&
            data is List &&
            data.isNotEmpty &&
            data[0] is List) {
          List<dynamic> expenseDataList = data[0];

          _expenseTypeList = expenseDataList
              .map((item) =>
                  ExpenseTypeModel.fromJson(item as Map<String, dynamic>))
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
    return _expenseTypeList;
  }

  void deleteExpenseType(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteExpenseType}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Expense_Type_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Expense Type \n that is currently in use");
        } else {
          getExpenseType('', context);
          expenseTypeController.clear();
          searchExpenseTypeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense Type deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Expense Type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<List<ProjectModel>> searchProjects(
      String query, BuildContext context) async {
    _projectList = [];
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchProjects}?Project_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data["data"];

        if (data != null) {
          _projectList = (data as List<dynamic>)
              .map((item) => ProjectModel.fromJson(item))
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
    return _projectList;
  }

  addProject({
    required BuildContext context,
    required String forId,
    required String forName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveProjects,
          bodyData: {"project_ID": forId, "project_Name": forName});

      if (response!.statusCode == 200) {
        projectController.clear();
        searchProjectController.clear();

        final data = response.data;
        searchProjects('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  addProjectType({
    required BuildContext context,
    required String forId,
    required String forName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveProjectType,
          bodyData: {"Project_Type_Id": forId, "Project_Type_Name": forName});

      if (response!.statusCode == 200) {
        projectTypeController.clear();
        searchProjectTypeController.clear();

        final data = response.data;
        searchProjectTypes('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
    }
  }

  void deleteProjectType(BuildContext context, int projectIdTypeId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: '${HttpUrls.deleteProjectType}',
          bodyData: {"Project_Type_Id": projectIdTypeId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        int projectId = data['Project_Type_Id'];
        if (projectId > 0) {
          searchProjectTypes('', context);
          projectTypeController.clear();
          searchProjectTypeController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project type deleted successfully')),
          );
          Loader.stopLoader(context);
        } else {
          Loader.stopLoader(context);
          alert(context, "Project type delete failed");
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete project type')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void deleteProject(BuildContext context, int projectId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: '${HttpUrls.deleteProjects}',
          bodyData: {"project_ID": projectId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        int projectId = data['project_ID'];
        if (projectId > 0) {
          searchProjects('', context);
          projectController.clear();
          searchProjectController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Project deleted successfully')),
          );
          Loader.stopLoader(context);
        } else {
          Loader.stopLoader(context);
          alert(context, "Project delete failed");
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete project')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<List<CustomerModel>> getCustomerDropDown(BuildContext context) async {
    _customerTypeList = [];
    notifyListeners();

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.getAllLeadDropDown}',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is List) {
          _customerTypeList = data
              .map((item) =>
                  CustomerModel.fromJson(item as Map<String, dynamic>))
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

    return _customerTypeList;
  }

  Future<List<TaxSlabModel>> searchTaxSlab(
      BuildContext context, String taskId) async {
    _taxSlabModel = [];
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getAllTax}/$taskId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is List) {
          _taxSlabModel =
              data.map((item) => TaxSlabModel.fromJson(item)).toList();

          notifyListeners();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unexpected data format')),
          );
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
    return _taxSlabModel;
  }
}
