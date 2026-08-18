// ignore_for_file: use_build_context_synchronously, unused_local_variable, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io';
// import 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/department_custom_field_model.dart';
import 'package:vidyanexis/controller/models/designation_model.dart';
import 'package:vidyanexis/controller/models/inventory_customer_model.dart';
import 'package:vidyanexis/controller/models/lead_customer_model.dart';
import 'package:vidyanexis/controller/models/location_model.dart';
import 'package:vidyanexis/controller/models/branch_model.dart';
import 'package:vidyanexis/controller/models/checklist_category_model.dart';
import 'package:vidyanexis/controller/models/checklist_item_model.dart';
import 'package:vidyanexis/controller/models/custom_field_dropdown.dart';
import 'package:vidyanexis/controller/models/custom_field_model.dart';
import 'package:vidyanexis/controller/models/customer_details_model.dart';
import 'package:vidyanexis/controller/models/expense_type_model.dart';
import 'package:vidyanexis/controller/models/campaign_model.dart';
import 'package:vidyanexis/controller/models/project_model.dart';
import 'package:vidyanexis/controller/models/project_type_model.dart';
import 'package:vidyanexis/controller/models/source_category_model.dart';
import 'package:vidyanexis/controller/models/stage_model.dart';
import 'package:vidyanexis/controller/models/sub_status_model.dart';
import 'package:vidyanexis/controller/models/tax_slab_model.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';
import 'package:vidyanexis/controller/models/user_enquiry_for_model.dart';
import 'package:vidyanexis/controller/models/user_enquiry_source_model.dart';
import 'package:vidyanexis/controller/models/user_task_type_model.dart';
import 'package:vidyanexis/controller/models/priority_model.dart';
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
import 'package:vidyanexis/constants/app_styles.dart';

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider _instance = SettingsProvider._internal();

  factory SettingsProvider() => _instance;

  SettingsProvider._internal() {
    _initCache();
  }

  VoidCallback? onAddPressed;

  void setOnAddPressed(VoidCallback? callback) {
    onAddPressed = callback;
    notifyListeners();
  }

  bool _isCacheLoaded = false;
  Future<void> _initCache() async {
    if (_isCacheLoaded) return;
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? cachedLogo = preferences.getString('cached_company_logo');
      String? cachedTitle = preferences.getString('cached_company_title');
      String? cachedNotificationTopic =
          preferences.getString('cached_company_notification_topic');

      print('DEBUG1: notification_topic loaded from cache: $notificationTopic');

      if (cachedLogo != null ||
          cachedTitle != null ||
          cachedNotificationTopic != null) {
        logo = cachedLogo ?? logo;
        title = cachedTitle ?? title;
        notificationTopic = cachedNotificationTopic ?? notificationTopic;
        print(
            'DEBUG: notification_topic loaded from cache: $notificationTopic');
        AppStyles.updateCachedBranding(title, logo);
        _updateAppSwitcher();
        _isCacheLoaded = true;
        print(
            'Branding loaded from cache: $title - $logo - $notificationTopic');
        notifyListeners();
      }
    } catch (e) {
      print('Error loading branding cache: $e');
    }
  }

  void _updateAppSwitcher() {
    SystemChrome.setApplicationSwitcherDescription(
      ApplicationSwitcherDescription(
        label: displayTitle,
        primaryColor: AppColors.primaryBlue.value,
      ),
    );
  }

  Future<void> _loadCache() async {
    await _initCache();
  }

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
  bool _isSavingUserEnquiryFor = false;
  bool get isSavingUserEnquiryFor => _isSavingUserEnquiryFor;
  bool _isSavingUserEnquirySource = false;
  bool get isSavingUserEnquirySource => _isSavingUserEnquirySource;
  bool _isSavingUserTaskType = false;
  bool get isSavingUserTaskType => _isSavingUserTaskType;
  bool _isAddingUser = false;
  bool get isAddingUser => _isAddingUser;

  bool _isCreateNew = false;
  bool get isCreateNew => _isCreateNew;
  set isCreateNew(bool value) {
    _isCreateNew = value;
    notifyListeners();
  }

  bool _isShowFollowupDate = false;
  bool get isShowFollowupDate => _isShowFollowupDate;
  set isShowFollowupDate(bool value) {
    _isShowFollowupDate = value;
    notifyListeners();
  }

  String _selectedMenu = 'Users';

  String get selectedMenu => _selectedMenu;

  bool _passwordVisible = false;
  bool _newpasswordVisible = false;
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController searchUnitController = TextEditingController();

  //controllers
  final TextEditingController versionController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
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
  final TextEditingController whatsappTemplateIdController =
      TextEditingController();
  final TextEditingController templateIdController = TextEditingController();
  final TextEditingController statusDurationController =
      TextEditingController();

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
  final TextEditingController enquiryCodeController = TextEditingController();

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
  final TextEditingController dailyTargetController = TextEditingController();
  final TextEditingController monthlyTargetController = TextEditingController();
  final TextEditingController orderByController = TextEditingController();
  final TextEditingController departmentTaskController =
      TextEditingController();
  final TextEditingController statusTaskController = TextEditingController();
  final TextEditingController taskTypeDescriptionController =
      TextEditingController();

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

  //location
  final TextEditingController searchLocationController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();

  //Campaign
  final TextEditingController campaignNameController = TextEditingController();
  final TextEditingController campaignIdStringController =
      TextEditingController();
  final TextEditingController searchCampaignController =
      TextEditingController();

  //Supplier
  final TextEditingController searchSupplierController =
      TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  TextEditingController supplierAddressController = TextEditingController();
  TextEditingController supplierAddress1Controller = TextEditingController();
  TextEditingController supplierAddress2Controller = TextEditingController();
  TextEditingController supplierAddress3Controller = TextEditingController();
  TextEditingController supplierPhoneController = TextEditingController();
  TextEditingController supplierMobileController = TextEditingController();
  TextEditingController supplierEmailController = TextEditingController();
  TextEditingController supplierGstNoController = TextEditingController();
  TextEditingController supplierOpeningBalanceController =
      TextEditingController();

  //lists
  List<BranchModel> _branchModel = [];
  List<BranchModel> _allBranchModel = [];
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
  List<LocationModel> _locationModelList = [];
  List<LocationModel> get locationModelList => _locationModelList;

  List<CampaignModel> _campaignList = [];
  List<CampaignModel> get campaignList => _campaignList;

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
  int? _formViewInId;
  int? get formViewInId => _formViewInId;

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

  /// Travel Allowance Permission Checkers (Menu ID: 166)
  bool get hasTravelAllowancePermission =>
      (menuIsViewMap[166] ?? 0).toString() == '1';
  bool get hasTravelAllowanceAddPermission =>
      (menuIsSaveMap[166] ?? 0).toString() == '1';
  bool get hasTravelAllowanceEditPermission =>
      (menuIsEditMap[166] ?? 0).toString() == '1';
  bool get hasTravelAllowanceDeletePermission =>
      (menuIsDeleteMap[166] ?? 0).toString() == '1';
  //show checkbox
  final Map<int, int> _showView = {};
  Map<int, int> get showView => _showView;
  final Map<int, int> _showEdit = {};
  Map<int, int> get showEdit => _showEdit;
  final Map<int, int> _showSave = {};
  Map<int, int> get showSave => _showSave;
  final Map<int, int> _showDelete = {};
  Map<int, int> get showDelete => _showDelete;

  //for print
  final Map<int, int> _menuIsViewMapPrint = {};
  Map<int, int> get menuIsViewMapPrint => _menuIsViewMapPrint;

  List<PriorityModel> _priorities = [];
  List<PriorityModel> get priorities => _priorities;
  final Map<int, int> _menuIsEditMapPrint = {};
  Map<int, int> get menuIsEditMapPrint => _menuIsEditMapPrint;
  final Map<int, int> _menuIsSaveMapPrint = {};
  Map<int, int> get menuIsSaveMapPrint => _menuIsSaveMapPrint;
  final Map<int, int> _menuIsDeleteMapPrint = {};
  Map<int, int> get menuIsDeleteMapPrint => _menuIsDeleteMapPrint;
  //show checkbox
  final Map<int, int> _showViewPrint = {};
  Map<int, int> get showViewPrint => _showViewPrint;
  final Map<int, int> _showEditPrint = {};
  Map<int, int> get showEditPrint => _showEditPrint;
  final Map<int, int> _showSavePrint = {};
  Map<int, int> get showSavePrint => _showSavePrint;
  final Map<int, int> _showDeletePrint = {};
  Map<int, int> get showDeletePrint => _showDeletePrint;

  List<Company> _companyDetails = [];
  List<Company> get companyDetails => _companyDetails;
  String logo = '';
  String title = '';
  String notificationTopic = '';
  bool _isLogoLoading = false;
  bool get isLogoLoading => _isLogoLoading;

  String get displayLogo {
    if (logo.isNotEmpty) {
      if (logo.startsWith('http')) {
        return logo;
      } else {
        return "${HttpUrls.imgBaseUrl}$logo";
      }
    }
    return AppStyles.logo();
  }

  String get displayTitle => title.isNotEmpty ? title : AppStyles.name();

  String get currentNotificationTopic => notificationTopic;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailBranchController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController gstNoController = TextEditingController();
  final TextEditingController panCardNoController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController bankHolderNameController =
      TextEditingController();
  final TextEditingController bankAccountNoController = TextEditingController();
  final TextEditingController bankBranchController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController logoController = TextEditingController();
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
  final TextEditingController cgstNoController = TextEditingController();
  final TextEditingController cpanNoController = TextEditingController();
  final TextEditingController ccinNoController = TextEditingController();
  final TextEditingController ccompanyCodeController = TextEditingController();
  final TextEditingController cuserCountController = TextEditingController();

  final List<Uint8List> _images = [];
  List<Uint8List> get images => _images;
  String uploadedFilePath = '';

  int _toggleValue = 0;
  int _enquiryForMandatory = 0;
  int _enquirySourceMandatory = 0;
  int _consumerNameMandatory = 0;
  int _consumerContactNoMandatory = 0;
  int _leadInSales = 0;
  int _quotationItem = 0;
  int _additionalExpense = 0;
  int _commercialProposal = 0;
  int _districtCityMandatory = 0;
  int _leadMobileExistedCheck = 0;
  int _taskRemarkMandatory = 0;
  int _leadNameChangeToCustomerName = 0;
  int _leadCodeWithEnquiryCode = 0;
  int _documentButtonTaskStatus = 0;
  int? _selectedStatusId;

  int get toggleValue => _toggleValue;
  int get enquiryForMandatory => _enquiryForMandatory;
  int get enquirySourceMandatory => _enquirySourceMandatory;
  int get consumerNameMandatory => _consumerNameMandatory;
  int get consumerContactNoMandatory => _consumerContactNoMandatory;
  int get leadInSales => _leadInSales;
  int get quotationItem => _quotationItem;

  int get additionalExpense => _additionalExpense;
  int get commercialProposal => _commercialProposal;
  int get districtCityMandatory => _districtCityMandatory;
  int get leadMobileExistedCheck => _leadMobileExistedCheck;
  int get taskRemarkMandatory => _taskRemarkMandatory;
  int get leadNameChangeToCustomerName => _leadNameChangeToCustomerName;
  int get leadCodeWithEnquiryCode => _leadCodeWithEnquiryCode;
  int get documentButtonTaskStatus => _documentButtonTaskStatus;

  int _leadPermissionMeAndAll = 0;
  int get leadPermissionMeAndAll => _leadPermissionMeAndAll;
  String get leadNameLabel =>
      _leadNameChangeToCustomerName == 1 ? 'Customer Name' : 'Lead Name';

  String getPermissionCaption(dynamic key, String defaultCaption) {
    if (_companyDetails.isNotEmpty &&
        _companyDetails[0].permissions.isNotEmpty) {
      for (var p in _companyDetails[0].permissions) {
        if (key is int &&
            (p.companyPermissionId == key ||
                (key == 40 && p.companyPermissionId == 17) ||
                (key == 41 && p.companyPermissionId == 18) ||
                (key == 42 && p.companyPermissionId == 19) ||
                (key == 17 && p.companyPermissionId == 40) ||
                (key == 18 && p.companyPermissionId == 41) ||
                (key == 19 && p.companyPermissionId == 42)) &&
            p.caption.isNotEmpty) {
          return p.caption;
        }
        if (key is String &&
            p.caption.toLowerCase().contains(key.toLowerCase()) &&
            p.caption.isNotEmpty) {
          return p.caption;
        }
      }
    }
    return defaultCaption;
  }

  void _syncPermissionValueToState(int permissionId, int value, [String? caption]) {
    if (permissionId == 1 || permissionId == 3) {
      _toggleValue = value;
    } else if (permissionId == 4) {
      _enquiryForMandatory = value;
    } else if (permissionId == 5) {
      _enquirySourceMandatory = value;
    } else if (permissionId == 6) {
      _consumerNameMandatory = value;
    } else if (permissionId == 7) {
      _consumerContactNoMandatory = value;
    } else if (permissionId == 8) {
      _leadInSales = value;
    } else if (permissionId == 9) {
      _quotationItem = value;
    } else if (permissionId == 10) {
      _additionalExpense = value;
    } else if (permissionId == 11) {
      _commercialProposal = value;
    } else if (permissionId == 12) {
      _districtCityMandatory = value;
    } else if (permissionId == 13) {
      _leadMobileExistedCheck = value;
    } else if (permissionId == 14) {
      _leadNameChangeToCustomerName = value;
    } else if (permissionId == 15) {
      _leadCodeWithEnquiryCode = value;
    } else if (permissionId == 16) {
      _documentButtonTaskStatus = value;
    } else if (permissionId == 17 || permissionId == 40 || (caption != null && caption.toLowerCase().contains('lead permission me and all'))) {
      _leadPermissionMeAndAll = value;
    } else if (permissionId == 18 || permissionId == 41 || (caption != null && caption.toLowerCase().contains('customer permission me and all'))) {
      _customerPermissionMeAndAll = value;
    } else if (permissionId == 19 || permissionId == 42 || (caption != null && caption.toLowerCase().contains('task permission me and all'))) {
      _taskPermissionMeAndAll = value;
    } else if (permissionId == 20 || (caption != null && caption.toLowerCase().contains('hide warranty'))) {
      _hideWarranty = value;
    } else if (permissionId == 21) {
      _taskRemarkMandatory = value;
    }
  }

  void setDocumentButtonTaskStatus(int value) {
    _documentButtonTaskStatus = value;
    notifyListeners();
  }

  void setLeadPermissionMeAndAll(int value) {
    _leadPermissionMeAndAll = value;
    notifyListeners();
  }

  int _customerPermissionMeAndAll = 0;
  int get customerPermissionMeAndAll => _customerPermissionMeAndAll;

  int _taskPermissionMeAndAll = 0;
  int get taskPermissionMeAndAll => _taskPermissionMeAndAll;

  int _hideWarranty = 0;
  int get hideWarranty => _hideWarranty;

  void setCustomerPermissionMeAndAll(int value) {
    _customerPermissionMeAndAll = value;
    notifyListeners();
  }

  void setTaskPermissionMeAndAll(int value) {
    _taskPermissionMeAndAll = value;
    notifyListeners();
  }

  void setHideWarranty(int value) {
    _hideWarranty = value;
    _syncStateToPermissionsList(20, value);
    notifyListeners();
  }

  void _syncStateToPermissionsList(int permissionId, int value) {
    if (_companyDetails.isNotEmpty &&
        _companyDetails[0].permissions.isNotEmpty) {
      final index = _companyDetails[0]
          .permissions
          .indexWhere((p) => p.companyPermissionId == permissionId);
      if (index != -1) {
        final old = _companyDetails[0].permissions[index];
        _companyDetails[0].permissions[index] = CompanyPermission(
          companyPermissionId: old.companyPermissionId,
          caption: old.caption,
          value: value,
        );
      }
    }
  }

  void _syncAllCompanyPermissions() {
    if (_companyDetails.isNotEmpty) {
      _enquiryForMandatory = _companyDetails[0].enquiryForMandatory;
      _enquirySourceMandatory = _companyDetails[0].enquirySourceMandatory;
      _consumerNameMandatory = _companyDetails[0].consumerNameMandatory;
      _consumerContactNoMandatory =
          _companyDetails[0].consumerContactNoMandatory;
      _leadInSales = _companyDetails[0].leadInSales;
      _quotationItem = _companyDetails[0].quotationItemValue;
      _additionalExpense = _companyDetails[0].additionalExpense;
      _commercialProposal = _companyDetails[0].commercialProposal;
      _districtCityMandatory = _companyDetails[0].districtCityMandatory;
      _leadMobileExistedCheck = _companyDetails[0].leadMobileExistedCheck;
      _taskRemarkMandatory = _companyDetails[0].taskRemarkMandatory;
      _toggleValue = _companyDetails[0].isLocation;

      if (_companyDetails[0].permissions.isNotEmpty) {
        for (var p in _companyDetails[0].permissions) {
          _syncPermissionValueToState(p.companyPermissionId, p.value, p.caption);
        }
      }
    }
  }

  void updateCompanyPermission(int permissionId, int newValue) {
    if (_companyDetails.isNotEmpty &&
        _companyDetails[0].permissions.isNotEmpty) {
      final index = _companyDetails[0].permissions.indexWhere((p) =>
          p.companyPermissionId == permissionId ||
          (permissionId == 40 && p.companyPermissionId == 17) ||
          (permissionId == 41 && p.companyPermissionId == 18) ||
          (permissionId == 42 && p.companyPermissionId == 19) ||
          (permissionId == 17 && p.companyPermissionId == 40) ||
          (permissionId == 18 && p.companyPermissionId == 41) ||
          (permissionId == 19 && p.companyPermissionId == 42));
      if (index != -1) {
        final old = _companyDetails[0].permissions[index];
        _companyDetails[0].permissions[index] = CompanyPermission(
          companyPermissionId: old.companyPermissionId,
          caption: old.caption,
          value: newValue,
        );
        _syncPermissionValueToState(old.companyPermissionId, newValue, old.caption);
        notifyListeners();
      }
    } else {
      _syncPermissionValueToState(permissionId, newValue);
      notifyListeners();
    }
  }

  int? _selectedBranchId = -1;
  int? get selectedBranchId => _selectedBranchId;

  int _selectedDesignationId = 0;
  int get selectedDesignationId => _selectedDesignationId;
  set selectedDesignationId(int id) {
    _selectedDesignationId = id;
    notifyListeners();
  }

  int _isOTPChecked = 0;
  int get isOTPChecked => _isOTPChecked;
  int _isFeedbackChecked = 0;
  int get isFeedbackChecked => _isFeedbackChecked;
  int? get selectedStatusId => _selectedStatusId;

  List<DepartmentModel> _selectedTransferDepartments = [];
  List<DepartmentModel> get selectedTransferDepartments =>
      _selectedTransferDepartments;

  void toggleTransferDepartment(DepartmentModel department) {
    bool exists = _selectedTransferDepartments
        .any((element) => element.departmentId == department.departmentId);
    if (exists) {
      _selectedTransferDepartments.removeWhere(
          (element) => element.departmentId == department.departmentId);
    } else {
      _selectedTransferDepartments.add(department);
    }
    notifyListeners();
  }

  void clearTransferDepartments() {
    _selectedTransferDepartments.clear();
    notifyListeners();
  }

  void setTransferDepartments(List<DepartmentModel> departments) {
    _selectedTransferDepartments = List.from(departments);
    notifyListeners();
  }

  List<ProjectTypeModel> _projectTypeList = [];
  List<ProjectTypeModel> get projectTypeList => _projectTypeList;
  List<ProjectModel> _projectList = [];
  List<ProjectModel> get projectList => _projectList;

  set selectedBranchId(int? id) {
    _selectedBranchId = id;
    notifyListeners();
  }

  int? _selectedFilterBranchId = 0;
  int? get selectedFilterBranchId => _selectedFilterBranchId;

  set selectedFilterBranchId(int? id) {
    _selectedFilterBranchId = id ?? 0;
    notifyListeners();
  }

  int? _selectedFilterDepartmentId = 0;
  int? get selectedFilterDepartmentId => _selectedFilterDepartmentId;

  set selectedFilterDepartmentId(int? id) {
    _selectedFilterDepartmentId = id ?? 0;
    notifyListeners();
  }

  int? _selectedTaskTypeFilterEnquiryForId = 0;
  int? get selectedTaskTypeFilterEnquiryForId =>
      _selectedTaskTypeFilterEnquiryForId;

  set selectedTaskTypeFilterEnquiryForId(int? id) {
    _selectedTaskTypeFilterEnquiryForId = id ?? 0;
    notifyListeners();
  }

  void clearUserFilters() {
    searchController.clear();
    _selectedFilterBranchId = 0;
    _selectedFilterDepartmentId = 0;
    notifyListeners();
  }

  // Inventory Customer search controller
  final TextEditingController searchInventoryCustomerController =
      TextEditingController();
  // Inventory Customer controllers (separate from existing customer code)
  final TextEditingController inventoryCustomerNameController =
      TextEditingController();
  TextEditingController inventoryCustomerAddressController =
      TextEditingController();
  TextEditingController inventoryCustomerAddress1Controller =
      TextEditingController();
  TextEditingController inventoryCustomerAddress2Controller =
      TextEditingController();
  TextEditingController inventoryCustomerAddress3Controller =
      TextEditingController();
  TextEditingController inventoryCustomerPhoneController =
      TextEditingController();
  TextEditingController inventoryCustomerMobileController =
      TextEditingController();
  TextEditingController inventoryCustomerEmailController =
      TextEditingController();
  TextEditingController inventoryCustomerGstNoController =
      TextEditingController();
  TextEditingController inventoryCustomerOpeningBalanceController =
      TextEditingController();
  //inventory sales controller
  final TextEditingController salesCustomerNameController =
      TextEditingController();
  TextEditingController salesInvoicenoController = TextEditingController();
  TextEditingController salesAddressController = TextEditingController();
  TextEditingController salesInvoicedateController = TextEditingController();
  // Inventory Customer list
  List<InventoryCustomerModel> _searchInventoryCustomer = [];
  List<InventoryCustomerModel> get searchInventoryCustomer =>
      _searchInventoryCustomer;

  List<LeadCustomerModel> _searchLeadCustomer = [];
  List<LeadCustomerModel> get searchLeadCustomer => _searchLeadCustomer;

  Future<void> saveBranch({
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
            "contact_person": contactPersonController.text,
            "logo": logoController.text,
            "gst_no": gstNoController.text,
            "pan_card_no": panCardNoController.text,
            "bank_name": bankNameController.text,
            "bank_holder_name": bankHolderNameController.text,
            "bank_account_no": bankAccountNoController.text,
            "bank_branch": bankBranchController.text,
            "ifsc_code": ifscCodeController.text
          });

      if (response!.statusCode == 200) {
        branchController.clear();
        addressController.clear();
        phoneController.clear();
        pinCodeController.clear();
        emailBranchController.clear();
        contactPersonController.clear();
        logoController.clear();
        gstNoController.clear();
        panCardNoController.clear();
        bankNameController.clear();
        bankHolderNameController.clear();
        bankAccountNoController.clear();
        bankBranchController.clear();
        ifscCodeController.clear();
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
    logoController.clear();
    gstNoController.clear();
    panCardNoController.clear();
    bankNameController.clear();
    bankHolderNameController.clear();
    bankAccountNoController.clear();
    bankBranchController.clear();
    ifscCodeController.clear();
    branchCampaignController.clear();
  }

  Future<void> searchBranch(BuildContext context, {String query = '', bool forceRefresh = false}) async {
    if (query.isEmpty && !forceRefresh && _allBranchModel.isNotEmpty) return;
    try {
      if (_allBranchModel.isEmpty || query.isEmpty) {
        final response =
            await HttpRequest.httpGetRequest(endPoint: HttpUrls.getAllBranch);

        if (response.statusCode == 200) {
          final data = response.data;

          if (data != null && data['success'] == true) {
            List<dynamic> branchList = data['data'];

            _allBranchModel =
                branchList.map((item) => BranchModel.fromJson(item)).toList();
          }
        }
      }

      if (query.isEmpty) {
        _branchModel = List.from(_allBranchModel);
      } else {
        _branchModel = _allBranchModel
            .where((b) => (b.branchName ?? '')
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
      notifyListeners();
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> searchCampaignData(String query, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getCampaignList}?Campaign_Name=$query");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<dynamic> campaignListData;
          if (data is List) {
            campaignListData = data;
          } else if (data is Map &&
              data['success'] == true &&
              data['data'] != null) {
            campaignListData = data['data'];
          } else {
            return;
          }
          _campaignList = campaignListData
              .map((item) => CampaignModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      log('Exception occurred in searchCampaignData: $e');
    }
  }

  Future<void> saveCampaign({
    required BuildContext context,
    required String campaignId,
    required String userIds,
    required int enquirySourceId,
    required String enquirySourceName,
    required int enquiryForId,
    required String enquiryForName,
  }) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveCampaign,
          bodyData: {
            "Campaign_Id": int.parse(campaignId),
            "Campaign_Name": campaignNameController.text,
            "Campaign_Id_String": campaignIdStringController.text,
            "User_Ids": userIds,
            "Enquiry_Source_Id": enquirySourceId,
            "Enquiry_Source_Name": enquirySourceName,
            "Enquiry_For_Id": enquiryForId,
            "Enquiry_For_Name": enquiryForName,
          });

      if (response != null && response.statusCode == 200) {
        campaignNameController.clear();
        campaignIdStringController.clear();
        searchCampaignData('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save campaign')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      log('Exception occurred in saveCampaign: $e');
    }
  }

  Future<CampaignModel?> getCampaignById(
      BuildContext context, String campaignId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getCampaignById}?Campaign_Id=$campaignId");

      if (response.statusCode == 200) {
        final data = response.data;
        // API returns: { "campaign": {...}, "users": [{"User_Id": X}, ...] }
        if (data != null && data['campaign'] != null) {
          final campaignMap =
              Map<String, dynamic>.from(data['campaign'] as Map);
          final usersList = (data['users'] as List<dynamic>?) ?? [];
          // Build comma-separated User_Ids string from the users array
          final userIdsStr = usersList
              .map((u) => (u['User_Id'] ?? 0).toString())
              .where((s) => s != '0')
              .join(',');
          campaignMap['User_Ids'] = userIdsStr;
          return CampaignModel.fromJson(campaignMap);
        }
      }
    } catch (e) {
      log('Exception occurred in getCampaignById: $e');
    }
    return null;
  }

  Future<void> deleteCampaign(BuildContext context, int campaignId) async {
    // Optimistic UI update: Remove from list immediately for "quick and fast" feel
    final campaignIndex =
        _campaignList.indexWhere((element) => element.campaignId == campaignId);
    if (campaignIndex == -1) return;

    final removedCampaign = _campaignList[campaignIndex];
    _campaignList.removeAt(campaignIndex);
    notifyListeners();

    try {
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteCampaign,
          bodyData: {"Campaign_Id": campaignId});

      if (response != null && response.statusCode == 200) {
        // Even though it was successful, we refresh to ensure state consistency with server
        searchCampaignData('', context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Campaign deleted successfully')),
          );
        }
      } else {
        // Revert on failure
        _campaignList.insert(campaignIndex, removedCampaign);
        notifyListeners();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete campaign')),
          );
        }
      }
    } catch (e) {
      // Revert on error
      _campaignList.insert(campaignIndex, removedCampaign);
      notifyListeners();
      log('Exception occurred in deleteCampaign: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during deletion')),
        );
      }
    }
  }

  Future<void> saveCustomField(
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

  String _customFieldSearchQuery = '';
  String get customFieldSearchQuery => _customFieldSearchQuery;

  void searchCustomField(String query) {
    _customFieldSearchQuery = query;
    notifyListeners();
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
          Navigator.pop(context);
        } else {
          showToastInDialog("Not deleted", context);

          Loader.stopLoader(context);
          Navigator.pop(context);
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

  Future<void> deleteBranch(BuildContext context, int branchId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: "${HttpUrls.deleteBranch}/$branchId");

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
          Navigator.pop(context);
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
    _syncStateToPermissionsList(1, value);
    _syncStateToPermissionsList(3, value);
    notifyListeners();
  }

  void setEnquiryForMandatory(int value) {
    _enquiryForMandatory = value;
    _syncStateToPermissionsList(4, value);
    notifyListeners();
  }

  void setEnquirySourceMandatory(int value) {
    _enquirySourceMandatory = value;
    _syncStateToPermissionsList(5, value);
    notifyListeners();
  }

  void setConsumerNameMandatory(int value) {
    _consumerNameMandatory = value;
    _syncStateToPermissionsList(6, value);
    notifyListeners();
  }

  void setConsumerContactNoMandatory(int value) {
    _consumerContactNoMandatory = value;
    _syncStateToPermissionsList(7, value);
    notifyListeners();
  }

  void setLeadInSales(int value) {
    _leadInSales = value;
    _syncStateToPermissionsList(8, value);
    notifyListeners();
  }

  void setQuotationItem(int value) {
    _quotationItem = value;
    _syncStateToPermissionsList(9, value);
    notifyListeners();
  }

  void setAdditionalExpense(int value) {
    _additionalExpense = value;
    _syncStateToPermissionsList(10, value);
    notifyListeners();
  }

  void setCommercialProposal(int value) {
    _commercialProposal = value;
    _syncStateToPermissionsList(11, value);
    notifyListeners();
  }

  void setDistrictCityMandatory(int value) {
    _districtCityMandatory = value;
    _syncStateToPermissionsList(12, value);
    notifyListeners();
  }

  void setLeadMobileExistedCheck(int value) {
    _leadMobileExistedCheck = value;
    _syncStateToPermissionsList(2, value);
    _syncStateToPermissionsList(13, value);
    notifyListeners();
  }

  void setLeadNameChangeToCustomerName(int value) {
    _leadNameChangeToCustomerName = value;
    _syncStateToPermissionsList(14, value);
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

  void setTaskRemarkMandatory(int value) {
    _taskRemarkMandatory = value;
    _syncStateToPermissionsList(21, value);
    notifyListeners();
  }

  Future<void> searchSupplierApi(String query, BuildContext context) async {
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

  Future<void> addSupplier({
    required BuildContext context,
    required String statusId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveSupplier,
          bodyData: {
            'Supplier_Id': statusId,
            'Supplier_Name': supplierNameController.text.trim(),
            'Address': supplierAddressController.text.trim(),
            'Address1': supplierAddress1Controller.text.trim(),
            'Address2': supplierAddress2Controller.text.trim(),
            'Address3': supplierAddress3Controller.text.trim(),
            'PhoneNo': supplierPhoneController.text.trim(),
            'MobileNo': supplierMobileController.text.trim(),
            'Email': supplierEmailController.text.trim(),
            'GSTNO': supplierGstNoController.text.trim(),
            'OpeningBalance': supplierOpeningBalanceController.text.isEmpty
                ? '0'
                : supplierOpeningBalanceController.text.trim(),
          });

      if (response!.statusCode == 200) {
        supplierClear();

        final data = response.data;
        searchSupplierApi('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchSupplierController.clear();
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

  void supplierClear() {
    supplierNameController.clear();
    supplierAddressController.clear();
    supplierAddress1Controller.clear();
    supplierAddress2Controller.clear();
    supplierAddress3Controller.clear();
    supplierPhoneController.clear();
    supplierMobileController.clear();
    supplierEmailController.clear();
    supplierGstNoController.clear();
    supplierOpeningBalanceController.clear();
  }

  void deleteSupplier(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteSupplier}/$userId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Enquiry_Source_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Supplier \n that is currently in use on the Lead page!");
        } else {
          searchSupplierApi('', context);
          supplierClear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Supplier')),
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

  void clearAllPermissions() {
    for (int i = 0; i < _getMenuPermission.length; i++) {
      _getMenuPermission[i] = _getMenuPermission[i].copyWith(
        isView: 0,
        isSave: 0,
        isEdit: 0,
        isDelete: 0,
      );
    }
    notifyListeners();
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

  Future<void> getSearchLeadStatus(
      String query, String viewId, BuildContext context) async {
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
          Navigator.pop(context);
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
          Navigator.pop(context);
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

  Future<void> addCategoryName({
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

  Future<void> addUnitName({
    required BuildContext context,
    required String statusId,
    required String statusName,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addUnit,
          bodyData: {"Unit_Id": statusId, "Unit_Name": statusName});

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

  Future<void> saveMenuPermission({
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

  Future<void> getUserDetails(String query, BuildContext context) async {
    try {
      // Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String url = '${HttpUrls.searchUser}?user_details_Name=$query';
      if (selectedFilterDepartmentId != null &&
          selectedFilterDepartmentId != 0) {
        url += '&Department_Id=$selectedFilterDepartmentId';
      }
      if (selectedFilterBranchId != null && selectedFilterBranchId != 0) {
        url += '&Branch_Id=$selectedFilterBranchId';
      }

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          List<GetUserModel> allUsers = (data as List<dynamic>)
              .map((item) => GetUserModel.fromJson(item))
              .toList();

          if (selectedFilterDepartmentId != null &&
              selectedFilterDepartmentId != 0) {
            allUsers = allUsers
                .where((user) =>
                    user.departmentId == selectedFilterDepartmentId.toString())
                .toList();
          }
          if (selectedFilterBranchId != null && selectedFilterBranchId != 0) {
            allUsers = allUsers
                .where((user) =>
                    user.branchId == selectedFilterBranchId.toString())
                .toList();
          }
          _searchUserDetails = allUsers;
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

  Future<void> getMenuPermissionData(
      String userId, BuildContext context) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    print('[PERF-RELOAD] getMenuPermissionData START for userId = $userId');
    try {
      log(userId);
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getMenuPermission}/$userId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          var rawData = data as List<dynamic>;

          // Filter out permissions that are hidden by the backend (Menu_Status == 0) or deleted (DeleteStatus == 1)
          var filteredData = rawData
              .where((item) =>
                  (item['Menu_Status'] ?? 1) != 0 &&
                  (item['DeleteStatus'] ?? 0) != 1)
              .toList();

          _getMenuPermission = filteredData
              .map((item) => GetMenuPermissionModel.fromJson(item))
              .toList();
          _getMenuPermission
              .removeWhere((item) => item.menuId == 82 || item.menuId == 83);

          // Rename or add permission 55 as Print Quotation 2
          bool has55 = false;
          bool has32 = false;
          bool has163 = false;
          bool has164 = false;
          for (var i = 0; i < _getMenuPermission.length; i++) {
            if (_getMenuPermission[i].menuId == 55) {
              _getMenuPermission[i].menuName = 'Print Quotation 2';
              has55 = true;
            }
            if (_getMenuPermission[i].menuId == 32) {
              _getMenuPermission[i].menuName = 'Print Quotation 1';
              has32 = true;
            }
            if (_getMenuPermission[i].menuId == 163) {
              _getMenuPermission[i].menuName = 'Work Completion Report';
              has163 = true;
            }
            if (_getMenuPermission[i].menuId == 164) {
              _getMenuPermission[i].menuName = 'Checklist';
              has164 = true;
            }
          }

          if (!has32) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 32,
                menuName: 'Print Quotation 1',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
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

          if (!has163) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 163,
                menuName: 'Work Completion Report',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          if (!has164) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 164,
                menuName: 'Checklist',
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

          if (!_getMenuPermission.any((element) => element.menuId == 166)) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 166,
                menuName: 'Travel allowance',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          // Register Dashboard Tabs and new Report IDs
          final Map<int, String> customPermissions = {
            49: 'Leads Overview',
            50: 'Work Overview',
            51: 'Task Overview',
            52: 'Task Summary',
            65: 'Balance Reports',
            72: 'Payment Reports',
            73: 'Upcoming Payment Reports',
            74: 'Total Outstanding Reports',
            75: 'Outstanding Reports',
            76: 'AMC Notification',
            77: 'Payment Reminders',
            84: 'Dashboard count',
            120: 'Lead Search',
          };

          for (var entry in customPermissions.entries) {
            for (var i = 0; i < _getMenuPermission.length; i++) {
              if (_getMenuPermission[i].menuId == entry.key) {
                _getMenuPermission[i].menuName = entry.value;
                break;
              }
            }
          }

          SharedPreferences preferences = await SharedPreferences.getInstance();
          String loginuserId = preferences.getString('userId') ?? "";
          if (loginuserId == userId) {
            final newViewMap = <int, int>{};
            final newEditMap = <int, int>{};
            final newDeleteMap = <int, int>{};
            final newSaveMap = <int, int>{};

            for (var permission in _getMenuPermission) {
              newViewMap[permission.menuId] = int.tryParse(permission.isView.toString()) ?? 0;
              newEditMap[permission.menuId] = int.tryParse(permission.isEdit.toString()) ?? 0;
              newDeleteMap[permission.menuId] = int.tryParse(permission.isDelete.toString()) ?? 0;
              newSaveMap[permission.menuId] = int.tryParse(permission.isSave.toString()) ?? 0;
            }

            _menuIsViewMap.clear();
            _menuIsViewMap.addAll(newViewMap);
            _menuIsEditMap.clear();
            _menuIsEditMap.addAll(newEditMap);
            _menuIsDeleteMap.clear();
            _menuIsDeleteMap.addAll(newDeleteMap);
            _menuIsSaveMap.clear();
            _menuIsSaveMap.addAll(newSaveMap);
          }
          print('[PERF-RELOAD] getMenuPermissionData COMPLETE: ${DateTime.now().millisecondsSinceEpoch - startTime} ms for userId = $userId');
          notifyListeners();
        }
      } else {
        print('[PERF-RELOAD] getMenuPermissionData failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('[PERF-RELOAD] Exception occurred in getMenuPermissionData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  Future<void> getMenuPermissionDataPrint(
      String userId, BuildContext context) async {
    try {
      log(userId);
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getMenuPermissionPrint}/$userId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          var rawData = data as List<dynamic>;

          // Filter out permissions that are hidden by the backend (Menu_Status == 0) or deleted (DeleteStatus == 1)
          var filteredData = rawData
              .where((item) =>
                  (item['Menu_Status'] ?? 1) != 0 &&
                  (item['DeleteStatus'] ?? 0) != 1)
              .toList();

          _getMenuPermission = filteredData
              .map((item) => GetMenuPermissionModel.fromJson(item))
              .toList();
          // _getMenuPermission
          //     .removeWhere((item) => item.menuId == 82 || item.menuId == 83);

          // Rename or add permission 55 as Print Quotation 2
          // bool has55 = false;
          // bool has32 = false;
          bool has163 = false;
          bool has164 = false;
          for (var i = 0; i < _getMenuPermission.length; i++) {
            //   if (_getMenuPermission[i].menuId == 55) {
            //     _getMenuPermission[i].menuName = 'Print Quotation 2';
            //     has55 = true;
            //   }
            //   if (_getMenuPermission[i].menuId == 32) {
            //     _getMenuPermission[i].menuName = 'Print Quotation 1';
            //     has32 = true;
            //   }
            if (_getMenuPermission[i].menuId == 163) {
              _getMenuPermission[i].menuName = 'Work Completion Report';
              has163 = true;
            }
            if (_getMenuPermission[i].menuId == 164) {
              _getMenuPermission[i].menuName = 'Checklist';
              has164 = true;
            }
          }

          // if (!has32) {
          //   _getMenuPermission.add(GetMenuPermissionModel(
          //       menuId: 32,
          //       menuName: 'Print Quotation 1',
          //       isView: 0,
          //       isSave: 0,
          //       isEdit: 0,
          //       isDelete: 0));
          // }

          // if (!has55) {
          //   _getMenuPermission.add(GetMenuPermissionModel(
          //       menuId: 55,
          //       menuName: 'Print Quotation 2',
          //       isView: 0,
          //       isSave: 0,
          //       isEdit: 0,
          //       isDelete: 0));
          // }

          if (!has163) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 163,
                menuName: 'Work Completion Report',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          if (!has164) {
            _getMenuPermission.add(GetMenuPermissionModel(
                menuId: 164,
                menuName: 'Checklist',
                isView: 0,
                isSave: 0,
                isEdit: 0,
                isDelete: 0));
          }

          // if (!_getMenuPermission.any((element) => element.menuId == 67)) {
          //   _getMenuPermission.add(GetMenuPermissionModel(
          //       menuId: 67,
          //       menuName: 'Voice Recording',
          //       isView: 0,
          //       isSave: 0,
          //       isEdit: 0,
          //       isDelete: 0));
          // }

          // // Register Dashboard Tabs and new Report IDs
          // final Map<int, String> customPermissions = {
          //   49: 'Leads Overview',
          //   50: 'Work Overview',
          //   51: 'Task Overview',
          //   52: 'Task Summary',
          //   65: 'Balance Reports',
          //   72: 'Payment Reports',
          //   73: 'Upcoming Payment Reports',
          //   74: 'Total Outstanding Reports',
          //   75: 'Outstanding Reports',
          //   76: 'AMC Notification',
          //   77: 'Payment Reminders',
          //   84: 'Dashboard count',
          //   120: 'Lead Search',
          // };

          // for (var entry in customPermissions.entries) {
          //   for (var i = 0; i < _getMenuPermission.length; i++) {
          //     if (_getMenuPermission[i].menuId == entry.key) {
          //       _getMenuPermission[i].menuName = entry.value;
          //       break;
          //     }
          //   }
          // }

          // SharedPreferences preferences = await SharedPreferences.getInstance();
          // String loginuserId = preferences.getString('userId') ?? "";
          // if (loginuserId == userId) {
          _menuIsViewMapPrint.clear();
          _menuIsEditMapPrint.clear();
          _menuIsDeleteMapPrint.clear();
          _menuIsSaveMapPrint.clear();

          //view
          for (var permission in _getMenuPermission) {
            menuIsViewMapPrint[permission.menuId] = permission.isView;
            menuIsEditMapPrint[permission.menuId] = permission.isEdit;
            menuIsDeleteMapPrint[permission.menuId] = permission.isDelete;
            menuIsSaveMapPrint[permission.menuId] = permission.isSave;
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
          // }
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

  Future<void> searchPermissionPrint(BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchmenuPrint}?menu_Name');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _showMenu = (data as List<dynamic>)
              .map((item) => MenuPermissionModel.fromJson(item))
              .toList();

          // Filter out permissions that are hidden by the backend (Menu_Status == 0)
          _showMenu.removeWhere((item) => item.menuStatus == 0);

          // _showMenu
          //     .removeWhere((item) => item.menuId == 82 || item.menuId == 83);

          // // Rename or add permission 55 as Print Quotation 2
          // bool has55 = false;
          // bool has32 = false;
          // for (var i = 0; i < _showMenu.length; i++) {
          //   if (_showMenu[i].menuId == 55) {
          //     _showMenu[i].menuName = 'Print Quotation 2';
          //     has55 = true;
          //   }
          //   if (_showMenu[i].menuId == 32) {
          //     _showMenu[i].menuName = 'Print Quotation 1';
          //     has32 = true;
          //   }
          // }

          // if (!has32) {
          //   _showMenu.add(MenuPermissionModel(
          //       menuId: 32,
          //       menuName: 'Print Quotation 1',
          //       menuOrder: 0,
          //       menuOrderSub: 0,
          //       isEdit: 1,
          //       isSave: 1,
          //       isDelete: 1,
          //       isView: 1,
          //       menuStatus: 1,
          //       menuType: 1));
          // }

          // if (!has55) {
          //   _showMenu.add(MenuPermissionModel(
          //       menuId: 55,
          //       menuName: 'Print Quotation 2',
          //       menuOrder: 0,
          //       menuOrderSub: 0,
          //       isEdit: 1,
          //       isSave: 1,
          //       isDelete: 1,
          //       isView: 1,
          //       menuStatus: 1,
          //       menuType: 1));
          // }

          // Register Dashboard Tabs and new Report IDs for showMenu fallback
          // final Map<int, String> customPermissionsShow = {
          //   49: 'Leads Overview',
          //   50: 'Work Overview',
          //   51: 'Task Overview',
          //   52: 'Task Summary',
          //   65: 'Balance Reports',
          //   72: 'Payment Reports',
          //   73: 'Upcoming Payment Reports',
          //   74: 'Total Outstanding Reports',
          //   75: 'Outstanding Reports',
          //   76: 'AMC Notification',
          //   77: 'Payment Reminders',
          //   84: 'Dashboard count',
          //   120: 'Lead Search',
          // };

          // for (var entry in customPermissionsShow.entries) {
          //   for (var i = 0; i < _showMenu.length; i++) {
          //     if (_showMenu[i].menuId == entry.key) {
          //       _showMenu[i].menuName = entry.value;
          //       break;
          //     }
          //   }
          // }

          // var recordingMenu = _showMenu.firstWhere((e) => e.menuId == 67,
          //     orElse: () => MenuPermissionModel(
          //         menuId: 67,
          //         menuName: 'Voice Recording', // Fallback name
          //         // Audio Recording Section
          //         menuOrder: 0,
          //         menuOrderSub: 0,
          //         isEdit: 0, // Default to 0
          //         isSave: 0, // Default to 0
          //         isDelete: 0, // Default to 0
          //         isView: 0, // Default to 0
          //         menuStatus: 1,
          //         menuType: 1));

          // // Ensure it's in the list
          // if (!_showMenu.contains(recordingMenu)) {
          //   _showMenu.add(recordingMenu);
          // } else {
          //   // Force enable checkboxes if it came from backend with 0
          //   recordingMenu.isView = 1;
          //   recordingMenu.isEdit = 1;
          //   recordingMenu.isSave = 1;
          //   recordingMenu.isDelete = 1;
          // }

          _showViewPrint.clear();
          _showEditPrint.clear();
          _showDeletePrint.clear();
          _showSavePrint.clear();

          //view
          for (var permission in _showMenu) {
            showViewPrint[permission.menuId] = permission.isView;
          }
          //edit
          for (var permission in _showMenu) {
            showEditPrint[permission.menuId] = permission.isEdit;
          }
          //delete
          for (var permission in _showMenu) {
            showDeletePrint[permission.menuId] = permission.isDelete;
          }
          //save
          for (var permission in _showMenu) {
            showSavePrint[permission.menuId] = permission.isSave;
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

  Future<void> saveMenuPermissionPrint({
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
        endPoint: HttpUrls.saveMenuPermissionPrint,
        bodyData: menuSelectionModel.toJson(),
      );

      if (response?.statusCode == 200) {
        final data = response?.data;
        Navigator.pop(context);
        Loader.stopLoader(context);
        print(data);
        getMenuPermissionDataPrint(userId.toString(), context);
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

  Future<void> searchUnitApi(String query, BuildContext context) async {
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

  Future<void> searchCategoryApi(String query, BuildContext context) async {
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
          clearUserFilters();
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

  Future<void> searchUserTypeDetails(BuildContext context) async {
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

  Future<void> searchWorkingStatusData(BuildContext context) async {
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

  Future<void> searchEnquiryStatusData(
      String query, BuildContext context) async {
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

  Future<void> searchStageData(String query, BuildContext context) async {
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

  Future<void> searchsourceCategoryData(
      String query, BuildContext context, {bool forceRefresh = false}) async {
    if (query.isEmpty && !forceRefresh && _searchSourceCategory.isNotEmpty) return;
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

  Future<void> addCheckListItem({
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
          getDocumentCheckList(context);
          Navigator.pop(context, true);
          notifyListeners();
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

  Future<void> addUser({
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
    String? firstName,
    String? lastName,
  }) async {
    if (_isAddingUser) return;
    _isAddingUser = true;
    notifyListeners();

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
            "User_Name": userDetailsName,
            "First_Name": firstNameController.text.isNotEmpty
                ? firstNameController.text
                : (firstName ?? ''),
            "Last_Name": lastNameController.text.isNotEmpty
                ? lastNameController.text
                : (lastName ?? ''),
            "Password": password,
            "Pass": password,
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
            "Designation_Id": _selectedDesignationId,
            "DOJ": dateOfJoinController.text.toyyyymmdd(),
            "Transfer_Departments":
                _selectedTransferDepartments.map((e) => e.toJson()).toList(),
          });

      if (response!.statusCode == 200) {
        final data = response.data;

        clearUserFilters();
        await getUserDetails('', context);

        Loader.stopLoader(context);
        _isAddingUser = false;
        notifyListeners();
        print(data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
        _isAddingUser = false;
        notifyListeners();
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
      _selectedTransferDepartments.clear();
      _isAddingUser = false;
      notifyListeners();
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

  Future<List<UserEnquiryForModel>> getUserEnquiryFor(
      String userId, BuildContext context) async {
    List<UserEnquiryForModel> list = [];
    try {
      List<EnquiryForModel> masterList = [];
      try {
        final masterResponse = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchEnquiryFor}?Enquiry_For_Name=',
        );
        if (masterResponse.statusCode == 200 && masterResponse.data != null) {
          masterList = (masterResponse.data as List<dynamic>)
              .map((item) => EnquiryForModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('Error fetching master Enquiry For: $e');
      }

      List<UserEnquiryForModel> userList = [];
      try {
        final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getUserEnquiryFor}/$userId',
        );
        if (response.statusCode == 200 &&
            response.data != null &&
            response.data['data'] != null) {
          final responseData = response.data['data'];
          List<dynamic> dataList;
          if (responseData is Map && responseData['enquiry_for_list'] != null) {
            dataList = responseData['enquiry_for_list'] as List<dynamic>;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            dataList = [];
          }
          userList = dataList
              .map((item) => UserEnquiryForModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('Error fetching user Enquiry For: $e');
      }

      for (var master in masterList) {
        final matchedUserItem = userList.firstWhere(
          (u) => u.enquiryForId == master.enquiryForId,
          orElse: () => UserEnquiryForModel(
            isview: 0,
            enquiryForId: master.enquiryForId,
            enquiryForName: master.enquiryForName,
            userId: int.tryParse(userId),
          ),
        );

        list.add(UserEnquiryForModel(
          userEnquiryForId: matchedUserItem.userEnquiryForId,
          userId: int.tryParse(userId),
          userDetailsName: matchedUserItem.userDetailsName,
          enquiryForId: master.enquiryForId,
          enquiryForName: master.enquiryForName,
          isview: matchedUserItem.isview,
          deleteStatus: master.deleteStatus,
        ));
      }
    } catch (e) {
      print('Exception occurred in getUserEnquiryFor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred loading settings')),
      );
    }
    return list;
  }

  Future<List<UserEnquirySourceModel>> getUserEnquirySource(
      String userId, BuildContext context) async {
    List<UserEnquirySourceModel> list = [];
    try {
      List<EnquirySourceModel> masterList = [];
      try {
        final masterResponse = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchEnquiryStatus}?Enquiry_Source_Name=',
        );
        if (masterResponse.statusCode == 200 && masterResponse.data != null) {
          masterList = (masterResponse.data as List<dynamic>)
              .map((item) => EnquirySourceModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('Error fetching master Enquiry Source: $e');
      }

      List<UserEnquirySourceModel> userList = [];
      try {
        final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getUserEnquirySource}/$userId',
        );
        if (response.statusCode == 200 &&
            response.data != null &&
            response.data['data'] != null) {
          final responseData = response.data['data'];
          List<dynamic> dataList;
          if (responseData is Map &&
              responseData['enquiry_source_list'] != null) {
            dataList = responseData['enquiry_source_list'] as List<dynamic>;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            dataList = [];
          }
          userList = dataList
              .map((item) => UserEnquirySourceModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('Error fetching user Enquiry Source: $e');
      }

      for (var master in masterList) {
        final matchedUserItem = userList.firstWhere(
          (u) => u.enquirySourceId == master.enquirySourceId,
          orElse: () => UserEnquirySourceModel(
            isview: 0,
            enquirySourceId: master.enquirySourceId,
            enquirySourceName: master.enquirySourceName,
            userId: int.tryParse(userId),
          ),
        );

        list.add(UserEnquirySourceModel(
          userEnquirySourceId: matchedUserItem.userEnquirySourceId,
          userId: int.tryParse(userId),
          userDetailsName: matchedUserItem.userDetailsName,
          enquirySourceId: master.enquirySourceId,
          enquirySourceName: master.enquirySourceName,
          isview: matchedUserItem.isview,
          deleteStatus: master.deleteStatus,
        ));
      }
    } catch (e) {
      print('Exception occurred in getUserEnquirySource: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred loading settings')),
      );
    }
    return list;
  }

  Future<List<UserTaskTypeModel>> getUserTaskType(
      String userId, BuildContext context) async {
    List<UserTaskTypeModel> list = [];
    try {
      List<TaskTypeModel> masterList = [];
      try {
        final masterResponse = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.searchTaskType}?Task_Type_Name=',
        );
        if (masterResponse.statusCode == 200 && masterResponse.data != null) {
          masterList = (masterResponse.data as List<dynamic>)
              .map((item) => TaskTypeModel.fromJson(item))
              .toList();
        }
      } catch (e) {
        print('Error fetching master Task Type: $e');
      }

      List<UserTaskTypeModel> userList = [];
      try {
        final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getUserTaskType}/$userId',
        );
        if (response.statusCode == 200 &&
            response.data != null &&
            response.data['data'] != null) {
          final responseData = response.data['data'];
          List<dynamic> dataList;
          if (responseData is Map && responseData['task_type_list'] != null) {
            dataList = responseData['task_type_list'] as List<dynamic>;
          } else if (responseData is List) {
            dataList = responseData;
          } else {
            dataList = [];
          }
          userList =
              dataList.map((item) => UserTaskTypeModel.fromJson(item)).toList();
        }
      } catch (e) {
        print('Error fetching user Task Type: $e');
      }

      for (var master in masterList) {
        final matchedUserItem = userList.firstWhere(
          (u) => u.taskTypeId == master.taskTypeId,
          orElse: () => UserTaskTypeModel(
            isview: 0,
            taskTypeId: master.taskTypeId,
            taskTypeName: master.taskTypeName,
            userId: int.tryParse(userId),
          ),
        );

        list.add(UserTaskTypeModel(
          userTaskTypeId: matchedUserItem.userTaskTypeId,
          userId: int.tryParse(userId),
          userDetailsName: matchedUserItem.userDetailsName,
          taskTypeId: master.taskTypeId,
          taskTypeName: master.taskTypeName,
          isview: matchedUserItem.isview,
          deleteStatus: master.deleteStatus,
        ));
      }
    } catch (e) {
      print('Exception occurred in getUserTaskType: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred loading task types')),
      );
    }
    return list;
  }

  Future<void> saveUserTaskTypeList({
    required BuildContext context,
    required String userId,
    required List<UserTaskTypeModel> updatedList,
  }) async {
    _isSavingUserTaskType = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveUserTaskType,
        bodyData: {
          "user_id": int.parse(userId),
          "task_type_list": updatedList
              .map((item) => {
                    "task_type_id": item.taskTypeId ?? 0,
                    "isview": item.isview,
                  })
              .toList(),
        },
      );

      _isSavingUserTaskType = false;
      notifyListeners();

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == false || data['success'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save')),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      _isSavingUserTaskType = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during save')),
      );
    }
  }

  Future<void> saveUserEnquiryForList({
    required BuildContext context,
    required String userId,
    required List<UserEnquiryForModel> updatedList,
  }) async {
    _isSavingUserEnquiryFor = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveUserEnquiryFor,
        bodyData: {
          "user_id": int.parse(userId),
          "enquiry_for_list": updatedList
              .map((item) => {
                    "enquiry_for_id": item.enquiryForId ?? 0,
                    "isview": item.isview,
                  })
              .toList(),
        },
      );

      _isSavingUserEnquiryFor = false;
      notifyListeners();

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == false || data['success'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save')),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      _isSavingUserEnquiryFor = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during save')),
      );
    }
  }

  Future<void> saveUserEnquirySourceList({
    required BuildContext context,
    required String userId,
    required List<UserEnquirySourceModel> updatedList,
  }) async {
    _isSavingUserEnquirySource = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveUserEnquirySource,
        bodyData: {
          "user_id": int.parse(userId),
          "enquiry_source_list": updatedList
              .map((item) => {
                    "enquiry_source_id": item.enquirySourceId ?? 0,
                    "isview": item.isview,
                  })
              .toList(),
        },
      );

      _isSavingUserEnquirySource = false;
      notifyListeners();

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == false || data['success'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save')),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      _isSavingUserEnquirySource = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during save')),
      );
    }
  }

  Future<void> addLeadStatus({
    required BuildContext context,
    required String statusId,
    required String statusName,
    required String statusOrder,
    required String followUp,
    required String isRegistered,
    required String colorCode,
    required final customFields,
    required final taskTypes,
    required String whatsappTemplateId,
  }) async {
    try {
      Loader.showLoader(context);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);

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
            "ViewIn_Id": formViewInId ?? 0,
            "ViewIn_Name": viewInController.text.toString(),
            "Stage_Id": stageId,
            "Stage_Name": stageStatusController.text.toString(),
            "Progress_Value": progressValueController.text.isEmpty
                ? "0"
                : progressValueController.text,
            "Custom_Fields": customFields,
            "Task_Type": taskTypes,
            "Task_Types": taskTypes,
            "Whatsapp_Template_Id": whatsappTemplateId,
            "Sub_Status": selectedSubStatusesForApi,
            "Is_transfer": _isTransfer ? 1 : 0,
            "Is_Time": _isTime ? 1 : 0,
            "Is_Transfer_Status": _isTransferStatus ? 1 : 0,
            "Transfer_Status": selectedTransferStatusesForApi,
            "Is_Send_User": _isSendUser ? 1 : 0,
            "Template_Id": templateIdController.text,
            "Is_Link_Form": _isLinkForm ? 1 : 0,
            "Form_Id": int.tryParse(_selectedFormId) ?? 0,
            "Form_Name": _selectedFormName,
            "Is_Amount": _isAmount ? 1 : 0,
            "Department_Id": _selectedDepartmentId,
            "Department_Name":
                leadProvider.departmentController.text.toString(),
            "User_Id": dropDownProvider.selectedUserId,
            "User_Name": leadProvider.searchUserController.text.toString(),
            "Duration": int.tryParse(statusDurationController.text) ?? 0,
            "Create_New": _isCreateNew ? 1 : 0,
            "View_Date_Followup": _isShowFollowupDate ? 1 : 0,
          });

      if (response!.statusCode == 200) {
        // notifyListeners() might be enough to refresh the list,
        // but we don't clear form fields here to prevent flicker/reset before pop.
        getSearchLeadStatus(
            searchStatusController.text, viewInId.toString(), context);
        Loader.stopLoader(context);
        Navigator.pop(context);
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

  Future<void> addEnquiryName({
    required BuildContext context,
    required String statusId,
    required String statusName,
    int isMoreDetails = 0,
    String contactPerson = '',
    String phone = '',
    String email = '',
    String website = '',
    String phone2 = '',
    String contact2 = '',
    String address = '',
    String description = '',
  }) async {
    try {
      Loader.showLoader(context);

      final Map<String, dynamic> bodyData = {
        "Enquiry_Source_Id": statusId,
        "Enquiry_Source_Name": statusName,
        "Is_More_Details": isMoreDetails,
      };

      if (isMoreDetails == 1) {
        bodyData.addAll({
          "Contact_Person": contactPerson,
          "Phone": phone,
          "Email": email,
          "Website": website,
          "Phone_2": phone2,
          "Contact_2": contact2,
          "Address": address,
          "Description": description,
        });
      }

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addEnquirySource, bodyData: bodyData);

      if (response!.statusCode == 200) {
        enquirySourceController.clear();
        searchEnquiryController.clear();
        sourceCategoryEnquiryController.clear();
        setSourceId(0);

        final data = response.data;
        searchEnquiryStatusData('', context);
        Loader.stopLoader(context);
        Navigator.pop(context);

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

  Future<void> addStage({
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
        Loader.stopLoader(context);
        Navigator.pop(context);
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

  Future<void> addSourceCategory({
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
        Loader.stopLoader(context);
        Navigator.pop(context);
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

  Future<void> addEnquiryForName({
    required BuildContext context,
    required String forId,
    required String forName,
    String enquiryCode = '',
    required final customFields,
    required final taskTypes,
  }) async {
    try {
      Loader.showLoader(context);
      Map<String, dynamic> bodyData = {
        "Enquiry_For_Id": forId,
        "Enquiry_For_Name": forName,
        "Enquiry_Code": enquiryCode,
        "enquiry_code": enquiryCode,
        "Source_Category_Id": sourceCategoryId,
        "Source_Category_Name": sourceCategoryEnquiryController.text,
        "Custom_Fields": customFields,
        "Task_Types": taskTypes,
      };

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addEnquiryFor, bodyData: bodyData);

      if (response!.statusCode == 200) {
        enquirySourceController.clear();
        searchEnquiryForController.clear();
        sourceCategoryEnquiryController.clear();
        enquiryForController.clear();
        enquiryCodeController.clear();
        setSourceId(0);
        final data = response.data;
        searchEnquiryForData('', context);
        Loader.stopLoader(context);
        Navigator.pop(context);
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

  Future<void> searchEnquiryForData(String query, BuildContext context) async {
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
          Navigator.pop(context);
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

  Future<void> saveDepartment({
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
        Loader.stopLoader(context);
        Navigator.pop(context);
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

  void searchDepartment(String search, BuildContext context, {bool forceRefresh = false}) async {
    if (search.isEmpty && !forceRefresh && _departmentModel.isNotEmpty) return;
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
          _departmentModel = [];
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

  Future<void> deleteDepartment(BuildContext context, int userId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteDepartment,
          bodyData: {"department_id": userId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['department_id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete an Department \n that is currently in use");
        } else {
          searchDepartment('', context);
          departmentController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Department deleted successfully')),
          );
          Loader.stopLoader(context);
          Navigator.pop(context);
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Department')),
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

  void setFormViewInId(int? value) {
    _formViewInId = value;
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
    _selectedTransferDepartments.clear();

    firstNameController.clear();
    lastNameController.clear();
    userNameController.clear();
    userTypeController.clear();
    passWordController.clear();
    confirmPasswordController.clear();
    mobileNoController.clear();
    emailIdController.clear();
    workingStatusController.clear();
    departmentUserController.clear();
    branchController.clear();
    defaultStatusController.clear();
    employeeCodeController.clear();
    designationController.clear();
    dateOfJoinController.clear();
    _allowAppLogin = false;
    _selectedDesignationId = 0;
    notifyListeners();
  }

  void reset() {
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

  bool _isCommissionChecked = false;

  bool get isCommissionChecked => _isCommissionChecked;
  bool _isManualCreation = false;
  bool get isManualCreation => _isManualCreation;

  bool _isEnquiryForVisible = false;
  bool get isEnquiryForVisible => _isEnquiryForVisible;

  bool _isQuotationCustom = false;
  bool get isQuotationCustom => _isQuotationCustom;

  bool _isViewInQuotation = false;
  bool get isViewInQuotation => _isViewInQuotation;

  bool _isCommercial = false;
  bool get isCommercial => _isCommercial;

  bool _isChecked = false;
  bool get isChecked => _isChecked;

  void toggleEnquiryForVisible(bool value) {
    _isEnquiryForVisible = value;
    notifyListeners();
  }

  void toggleQuotationCustom(bool value) {
    _isQuotationCustom = value;
    notifyListeners();
  }

  void toggleViewInQuotation(bool value) {
    _isViewInQuotation = value;
    notifyListeners();
  }

  void toggleCommercial(bool value) {
    _isCommercial = value;
    notifyListeners();
  }

  void toggleIsChecked(bool value) {
    _isChecked = value;
    notifyListeners();
  }

  void toggleLocation(bool value) {
    _isLocationTracking = value;
    notifyListeners();
  }

  void toggleCommission(bool value) {
    _isCommissionChecked = value;
    notifyListeners();
  }

  void toggleManualCreation(bool value) {
    _isManualCreation = value;
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

  Future<void>? _getCompanyDetailsFuture;

  Future<void> getCompanyDetails() async {
    if (_getCompanyDetailsFuture != null) {
      print('getCompanyDetails: awaiting existing request...');
      return _getCompanyDetailsFuture;
    }

    _getCompanyDetailsFuture = _performGetCompanyDetails();
    try {
      await _getCompanyDetailsFuture;
    } finally {
      _getCompanyDetailsFuture = null;
    }
  }

  Future<void> _performGetCompanyDetails() async {
    final startTime = DateTime.now().millisecondsSinceEpoch;
    print('[PERF-RELOAD] getCompanyDetails START');
    _isLogoLoading = true;
    notifyListeners();
    try {
      await _initCache(); // Ensure cache is loaded first

      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getCompany);
      print('getcompmayoutput');
      if (response.statusCode == 200) {
        final data = response.data;
        print('SettingsProvider.getCompanyDetails1 $data');

        if (data != null && data is List && data.isNotEmpty) {
          if (data[0] is Map<String, dynamic> &&
              (data[0]['Company_Permission_Id'] != null ||
                  data[0]['company_permission_id'] != null ||
                  data[0]['Caption'] != null ||
                  data[0]['caption'] != null)) {
            List<CompanyPermission> perms = (data as List)
                .map((item) => CompanyPermission.fromJson(item))
                .toList();

            if (_companyDetails.isEmpty) {
              _companyDetails = [
                Company(
                  companyId: 0,
                  companyName: title,
                  address1: '',
                  address2: '',
                  address3: '',
                  address4: '',
                  mobileNumber: '',
                  phoneNumber: '',
                  email: '',
                  website: '',
                  logo: logo,
                  gstNo: '',
                  panNo: '',
                  cinNo: '',
                  companyCode: '',
                  userCount: '',
                  deleteStatus: 0,
                  isLocation: 0,
                  notificationTopic: notificationTopic,
                  enquiryForMandatory: 0,
                  enquirySourceMandatory: 0,
                  consumerNameMandatory: 0,
                  consumerContactNoMandatory: 0,
                  leadInSales: 0,
                  quotationItemValue: 0,
                  additionalExpense: 0,
                  commercialProposal: 0,
                  districtCityMandatory: 0,
                  leadMobileExistedCheck: 0,
                  taskRemarkMandatory: 0,
                  permissions: perms,
                )
              ];
            } else {
              Company existing = _companyDetails[0];
              _companyDetails[0] = Company(
                companyId: existing.companyId,
                companyName: existing.companyName,
                address1: existing.address1,
                address2: existing.address2,
                address3: existing.address3,
                address4: existing.address4,
                mobileNumber: existing.mobileNumber,
                phoneNumber: existing.phoneNumber,
                email: existing.email,
                website: existing.website,
                logo: existing.logo,
                gstNo: existing.gstNo,
                panNo: existing.panNo,
                cinNo: existing.cinNo,
                companyCode: existing.companyCode,
                userCount: existing.userCount,
                deleteStatus: existing.deleteStatus,
                isLocation: existing.isLocation,
                notificationTopic: existing.notificationTopic,
                enquiryForMandatory: existing.enquiryForMandatory,
                enquirySourceMandatory: existing.enquirySourceMandatory,
                consumerNameMandatory: existing.consumerNameMandatory,
                consumerContactNoMandatory: existing.consumerContactNoMandatory,
                leadInSales: existing.leadInSales,
                quotationItemValue: existing.quotationItemValue,
                additionalExpense: existing.additionalExpense,
                commercialProposal: existing.commercialProposal,
                districtCityMandatory: existing.districtCityMandatory,
                leadMobileExistedCheck: existing.leadMobileExistedCheck,
                taskRemarkMandatory: existing.taskRemarkMandatory,
                permissions: perms,
              );
            }
            _syncAllCompanyPermissions();
          } else {
            // If the API returns the classic Company format, still initialize it for other pages
            try {
              _companyDetails =
                  data.map((item) => Company.fromJson(item)).toList();
              if (_companyDetails.isNotEmpty) {
                _syncAllCompanyPermissions();
              }
            } catch (e) {
              print(
                  'SettingsProvider.getCompanyDetails: Failed to parse Company format - $e');
            }
          }

          final item = data[0];
          String newLogo = item['company_logo'] ?? item['Logo'] ?? '';
          String newTitle = item['company_name'] ?? item['Company_Name'] ?? '';
          String newNotificationTopic = item['notification_topic'] ?? '';

          SharedPreferences preferences = await SharedPreferences.getInstance();
          await preferences.setString('cached_company_logo', logo);
          await preferences.setString('cached_company_title', title);
          await preferences.setString(
              'cached_company_notification_topic', notificationTopic);

          if (newLogo != logo ||
              newTitle != title ||
              newNotificationTopic != notificationTopic) {
            logo = newLogo;
            title = newTitle;
            notificationTopic = newNotificationTopic;
            print(
                'DEBUG: notification_topic updated from API (list): $notificationTopic');

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.setString('cached_company_logo', logo);
            await preferences.setString('cached_company_title', title);
            await preferences.setString(
                'cached_company_notification_topic', notificationTopic);
            print(
                'DEBUG: notification_topic saved to cache: $notificationTopic');
            AppStyles.updateCachedBranding(title, logo);
            _updateAppSwitcher();
            print('Branding updated from API and cached: $title');
            notifyListeners();
          }
        } else if (data != null && data is Map<String, dynamic>) {
          // In case the endpoint actually returns a direct map { "company_name": "...", "company_logo": "..." }
          String newLogo = data['company_logo'] ?? data['Logo'] ?? '';
          String newTitle = data['company_name'] ?? data['Company_Name'] ?? '';
          String newNotificationTopic = data['notification_topic'] ?? '';
          _enquiryForMandatory = data['Enquiry_For_Mandatory'] ?? 0;
          _enquirySourceMandatory = data['Enquiry_Source_Mandatory'] ?? 0;
          _consumerNameMandatory = data['Consumer_Name_Mandatory'] ?? 0;
          _consumerContactNoMandatory = data['Contact_Number_Mandatory'] ?? 0;
          _leadInSales = data['Lead_In_Sales'] ?? 0;
          _quotationItem = data['Quotation_Item_Value'] ?? 0;
          _additionalExpense = data['Additional_Expense'] ?? 0;
          _commercialProposal = data['Commercial_Proposal'] ?? 0;
          _districtCityMandatory = data['District_City_Mandatory'] ?? 0;
          _leadMobileExistedCheck = data['Lead_Mobile_Existed_Check'] ?? 0;
          try {
            _companyDetails = [Company.fromJson(data)];
            _syncAllCompanyPermissions();
          } catch (e) {
            print(
                'SettingsProvider.getCompanyDetails (map): Failed to parse Company format - $e');
          }

          if (newLogo != logo ||
              newTitle != title ||
              newNotificationTopic != notificationTopic) {
            logo = newLogo;
            title = newTitle;
            notificationTopic = newNotificationTopic;
            print(
                'DEBUG: notification_topic updated from API (map): $notificationTopic');

            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.setString('cached_company_logo', logo);
            await preferences.setString('cached_company_title', title);
            await preferences.setString(
                'cached_company_notification_topic', notificationTopic);
            AppStyles.updateCachedBranding(title, logo);
            _updateAppSwitcher();
            print('Branding updated from API MAP and cached: $title');
            notifyListeners();
          }
        } else {
          print('getCompanyDetails: No company data found in response');
        }
      } else {
        print(
            'getCompanyDetails failed: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e, stackTrace) {
      print('Exception occurred in getCompanyDetails: $e');
      print(stackTrace);
    } finally {
      _isLogoLoading = false;
      notifyListeners();
    }
  }

  void saveImagePath(path) {
    uploadedFilePath = path;
  }

  Future<void> saveCompanyDetails({
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
            "Gst_No": cgstNoController.text.toString(),
            "Pan_No": cpanNoController.text.toString(),
            "Cin_No": ccinNoController.text.toString(),
            "Company_Code": ccompanyCodeController.text.toString(),
            "User_Count": cuserCountController.text.toString(),
            "Is_Location": _toggleValue,
            "Enquiry_For_Mandatory": _enquiryForMandatory,
            "Enquiry_Source_Mandatory": _enquirySourceMandatory,
            "Consumer_Name_Mandatory": _consumerNameMandatory,
            "Contact_Number_Mandatory": _consumerContactNoMandatory,
            "Lead_In_Sales": _leadInSales,
            "Quotation_Item_Value": _quotationItem,
            "Additional_Expense": _additionalExpense,
            "Commercial_Proposal": _commercialProposal,
            "District_City_Mandatory": _districtCityMandatory,
            "Lead_Mobile_Existed_Check": _leadMobileExistedCheck,
            "permissions": _companyDetails.isNotEmpty &&
                    _companyDetails[0].permissions.isNotEmpty
                ? _companyDetails[0].permissions.map((e) => e.toJson()).toList()
                : [],
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
        if (uploadedFilePath.isNotEmpty) {
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
    cgstNoController.clear();
    cpanNoController.clear();
    ccinNoController.clear();
    ccompanyCodeController.clear();
    cuserCountController.clear();
    uploadedFilePath = '';
    _toggleValue = 0;
    _enquiryForMandatory = 0;
    _enquirySourceMandatory = 0;
    _leadPermissionMeAndAll = 0;
    _customerPermissionMeAndAll = 0;
    _taskPermissionMeAndAll = 0;
    _taskRemarkMandatory = 0;
    _leadNameChangeToCustomerName = 0;
    _leadCodeWithEnquiryCode = 0;
    _documentButtonTaskStatus = 0;
    _hideWarranty = 0;
    notifyListeners();
  }

  Future<void> searchPermission(BuildContext context) async {
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

          // Filter out permissions that are hidden by the backend (Menu_Status == 0) or deleted (DeleteStatus == 1)
          _showMenu.removeWhere(
              (item) => item.menuStatus == 0 || item.deleteStatus == 1);

          _showMenu
              .removeWhere((item) => item.menuId == 82 || item.menuId == 83);

          // Rename or add permission 55 as Print Quotation 2
          bool has55 = false;
          bool has32 = false;
          for (var i = 0; i < _showMenu.length; i++) {
            if (_showMenu[i].menuId == 55) {
              _showMenu[i].menuName = 'Print Quotation 2';
              has55 = true;
            }
            if (_showMenu[i].menuId == 32) {
              _showMenu[i].menuName = 'Print Quotation 1';
              has32 = true;
            }
          }

          if (!has32) {
            _showMenu.add(MenuPermissionModel(
                menuId: 32,
                menuName: 'Print Quotation 1',
                menuOrder: 0,
                menuOrderSub: 0,
                isEdit: 1,
                isSave: 1,
                isDelete: 1,
                isView: 1,
                menuStatus: 1,
                menuType: 1));
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

          // Register Dashboard Tabs and new Report IDs for showMenu fallback
          final Map<int, String> customPermissionsShow = {
            49: 'Leads Overview',
            50: 'Work Overview',
            51: 'Task Overview',
            52: 'Task Summary',
            65: 'Balance Reports',
            72: 'Payment Reports',
            73: 'Upcoming Payment Reports',
            74: 'Total Outstanding Reports',
            75: 'Outstanding Reports',
            76: 'AMC Notification',
            77: 'Payment Reminders',
            84: 'Dashboard count',
            120: 'Lead Search',
          };

          for (var entry in customPermissionsShow.entries) {
            for (var i = 0; i < _showMenu.length; i++) {
              if (_showMenu[i].menuId == entry.key) {
                _showMenu[i].menuName = entry.value;
                break;
              }
            }
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

  Future<void> addDocumentType({
    required BuildContext context,
    required String forId,
    required String forName,
    required int isMandatory,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.addDocumentType,
          bodyData: {
            "Document_Type_Id": forId,
            "Document_Type_Name": forName,
            "mandatory": isMandatory
          });

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

  Future<void> saveStatus({
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

  //not using
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

  Future<void> getPriorities(BuildContext context, {bool forceRefresh = false}) async {
    // if (!forceRefresh && _priorities.isNotEmpty) return;
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getPriority,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data is List<dynamic>) {
            _priorities =
                data.map((item) => PriorityModel.fromJson(item)).toList();
          } else if (data is Map<String, dynamic> && data.containsKey('data')) {
            _priorities = (data['data'] as List<dynamic>)
                .map((item) => PriorityModel.fromJson(item))
                .toList();
          } else {
            _priorities = [];
          }
          notifyListeners();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error fetching priorities')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching priorities')),
      );
    }
  }

  Future<void> savePriority({
    required BuildContext context,
    required int priorityId,
    required String priorityName,
    required String colorCode,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.savePriority,
        bodyData: {
          "Priority_Id": priorityId,
          "Priority_Name": priorityName,
          "Color_Code": colorCode,
        },
      );

      if (response != null && response.statusCode == 200) {
        getPriorities(context);
        Navigator.pop(context);
        Loader.stopLoader(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error saving priority')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while saving priority')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<void> deletePriority(BuildContext context, int priorityId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deletePriority}/$priorityId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['Priority_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete a Priority \n that is currently in use!");
        } else {
          getPriorities(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Priority deleted successfully')),
          );
          Loader.stopLoader(context);
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete priority')),
        );
        Loader.stopLoader(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting priority')),
      );
      Loader.stopLoader(context);
    }
  }

  Future<void> searchDocumentType(String query, BuildContext context) async {
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

  Future<void> searchStatus(BuildContext context, String viewId) async {
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
          Navigator.pop(context);
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
  Future<void> addCheckListType({
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

  Future<void> searchCheckList(String query, BuildContext context) async {
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

  void searchTaskType(String search, BuildContext context,
      {String enquiryForId = '0'}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchTaskType}?Task_Type_Name=$search&Enquiry_For_Id=$enquiryForId');

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

  Future<void> addTaskType({
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
        dailyTargetController.clear();
        monthlyTargetController.clear();
        orderByController.clear();
        taskTypeDescriptionController.clear();
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
          orderByController.clear();
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

  Future<void> addCheckListCategory({
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
          Navigator.pop(context);
        } else {
          showToastInDialog(message, context);

          Loader.stopLoader(context);
          Navigator.pop(context);
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
    return null;
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
          Navigator.pop(context);
        } else {
          showToastInDialog(message, context);

          Loader.stopLoader(context);
          Navigator.pop(context);
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
    return null;
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

  Future<void> addExpenseType({
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

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> expenseDataList = [];
        if (response.data is Map && response.data["data"] != null) {
          final data = response.data["data"];
          if (data is List && data.isNotEmpty && data[0] is List) {
            expenseDataList = data[0];
          } else if (data is List) {
            expenseDataList = data;
          }
        } else if (response.data is List) {
          if (response.data.isNotEmpty && response.data[0] is List) {
            expenseDataList = response.data[0];
          } else {
            expenseDataList = response.data;
          }
        }

        _expenseTypeList = expenseDataList
            .whereType<Map<String, dynamic>>()
            .map((item) => ExpenseTypeModel.fromJson(item))
            .where((item) => item.deleteStatus == 0)
            .toList();
      } else {
        _expenseTypeList = [];
      }
    } catch (e, stack) {
      debugPrint('Error in SettingsProvider.getExpenseType: $e\n$stack');
      _expenseTypeList = [];
    } finally {
      notifyListeners();
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
          Navigator.pop(context);
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

  Future<void> addProject({
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

  Future<void> addProjectType({
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
          endPoint: HttpUrls.deleteProjectType,
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
          endPoint: HttpUrls.deleteProjects,
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
        endPoint: HttpUrls.getAllLeadDropDown,
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

      final String endPoint = taskId == '0' || taskId.isEmpty
          ? HttpUrls.getAllTax
          : '${HttpUrls.getAllTax}/$taskId';
      final response = await HttpRequest.httpGetRequest(endPoint: endPoint);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is List) {
          _taxSlabModel =
              data.map((item) => TaxSlabModel.fromJson(item)).toList();

          notifyListeners();
        } else if (data != null && data is Map && data.containsKey('message')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'].toString())),
          );
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

  Future<void> searchLocation(String search, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getLocation}?Location_Name=$search');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> locationList = [];

        if (data is List) {
          locationList = data;
        } else if (data is Map) {
          if (data['data'] is List) {
            locationList = data['data'];
          } else if (data['data'] != null && data['data'] is Map) {
            // Handle cases where data['data'] might be a map containing the list
          }
        }

        if (locationList.isNotEmpty) {
          _locationModelList =
              locationList.map((item) => LocationModel.fromJson(item)).toList();
        } else {
          _locationModelList = [];
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

  Future<void> saveLocation({
    required BuildContext context,
    required String locationId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveLocation,
          bodyData: {
            "Location_Id": locationId,
            "Location_Name": locationController.text
          });

      if (response != null && response.statusCode == 200) {
        locationController.clear();
        searchLocation('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location saved successfully')),
        );
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

  Future<void> deleteLocation(BuildContext context, int locationId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.deleteLocation,
          bodyData: {"Location_Id": locationId});

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Location_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete a Location \n that is currently in use");
        } else {
          searchLocation('', context);
          locationController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Location')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      Loader.stopLoader(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  // Inventory Customer methods (separate from existing customer code)
  Future<void> addInventoryCustomer({
    required BuildContext context,
    required String statusId,
  }) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveInventoryCustomer,
          bodyData: {
            'Customer_Id': statusId,
            'Customer_Name': inventoryCustomerNameController.text.trim(),
            'Address': inventoryCustomerAddressController.text.trim(),
            'Address1': inventoryCustomerAddress1Controller.text.trim(),
            'Address2': inventoryCustomerAddress2Controller.text.trim(),
            'Address3': inventoryCustomerAddress3Controller.text.trim(),
            'PhoneNo': inventoryCustomerPhoneController.text.trim(),
            'MobileNo': inventoryCustomerMobileController.text.trim(),
            'Email': inventoryCustomerEmailController.text.trim(),
            'GSTNO': inventoryCustomerGstNoController.text.trim(),
            'OpeningBalance':
                inventoryCustomerOpeningBalanceController.text.isEmpty
                    ? '0'
                    : inventoryCustomerOpeningBalanceController.text.trim(),
          });

      if (response!.statusCode == 200) {
        inventoryCustomerClear();

        final data = response.data;
        await searchInventoryCustomerApi('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
        searchInventoryCustomerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer saved successfully')),
        );
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

  void inventoryCustomerClear() {
    inventoryCustomerNameController.clear();
    inventoryCustomerAddressController.clear();
    inventoryCustomerAddress1Controller.clear();
    inventoryCustomerAddress2Controller.clear();
    inventoryCustomerAddress3Controller.clear();
    inventoryCustomerPhoneController.clear();
    inventoryCustomerMobileController.clear();
    inventoryCustomerEmailController.clear();
    inventoryCustomerGstNoController.clear();
    inventoryCustomerOpeningBalanceController.clear();
  }

  // Inventory Customer search API
  Future<void> searchInventoryCustomerApi(
      String query, BuildContext context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getInventoryCustomer}?Customer_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'];
          print(newData);
          _searchInventoryCustomer = (newData as List<dynamic>)
              .map((item) => InventoryCustomerModel.fromJson(item))
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

  Future<void> searchLeadCustomerApi(String query, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getLeadCustomerList}?Search_Value_=$query');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          final newData = data['data'];
          _searchLeadCustomer = (newData as List<dynamic>)
              .where((item) => item != null)
              .map((item) => LeadCustomerModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  // Delete Inventory Customer
  void deleteInventoryCustomer(BuildContext context, int customerId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteInventoryCustomer}/$customerId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['Customer_Id'] == -1) {
          Loader.stopLoader(context);
          alert(context,
              "You are attempting to delete a Customer \n that is currently in use!");
        } else {
          searchInventoryCustomerApi('', context);
          inventoryCustomerClear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Customer')),
        );
      }
    } catch (e) {
      print('Exception occurred: $e');
      Loader.stopLoader(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  List<DepartmentCustomFieldMapping> _departmentCustomFieldMappings = [];
  List<DepartmentCustomFieldMapping> get departmentCustomFieldMappings =>
      _departmentCustomFieldMappings;

  /// Save Custom Fields Mapping for a Department
  Future<void> saveDepartmentCustomFields({
    required int departmentId,
    required Map<int, List<CustomFieldModel>> mapping,
    required BuildContext context,
  }) async {
    try {
      Loader.showLoader(context);

      final List<DepartmentCustomFieldMapping> list =
          searchEnquiryFor.map((enquiryFor) {
        return DepartmentCustomFieldMapping(
          departmentId: departmentId,
          enquiryForId: enquiryFor.enquiryForId,
          enquiryForName: enquiryFor.enquiryForName,
          customFields: mapping[enquiryFor.enquiryForId] ?? [],
        );
      }).toList();

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveDepartmentCustomFields,
        bodyData: {
          "department_id": departmentId,
          "enquiry_for": list.map((m) => m.toJson()).toList(),
        },
      );

      if (response != null && response.statusCode == 200) {
        _departmentCustomFieldMappings = list;
        notifyListeners();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Custom fields mapping saved successfully"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save custom fields"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving department custom fields: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while saving"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      Loader.stopLoader(context);
      Navigator.pop(context);
    }
  }

  Future<void> getDepartmentCustomFields({
    required int departmentId,
    required BuildContext context,
  }) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.getDepartmentCustomFields}?Department_Id=$departmentId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['success'] == true && data['data'] != null) {
          final deptData = data['data'] as Map<String, dynamic>;
          final List<dynamic> enquiryList = deptData['enquiry_for'] ?? [];

          _departmentCustomFieldMappings = enquiryList.map((item) {
            final mapping = DepartmentCustomFieldMapping.fromApi(
                item as Map<String, dynamic>,
                deptData['department_id'] ?? departmentId);

            // Resolve full CustomFieldModel objects
            mapping.customFields = customFieldModelList
                .where((field) =>
                    mapping.customFieldIds.contains(field.customFieldId))
                .toList();

            return mapping;
          }).toList();

          notifyListeners();
        } else {
          _departmentCustomFieldMappings = [];
        }
      } else {
        _departmentCustomFieldMappings = [];
      }
    } catch (e) {
      print('Error fetching department custom fields: $e');
      _departmentCustomFieldMappings = [];
      notifyListeners();
    }
  }

  List<CustomFieldModel> getCustomFieldsForEnquiryFor(
      int departmentId, int enquiryForId) {
    final mapping = _departmentCustomFieldMappings.firstWhere(
      (m) => m.departmentId == departmentId && m.enquiryForId == enquiryForId,
      orElse: () => DepartmentCustomFieldMapping(
        departmentId: departmentId,
        enquiryForId: enquiryForId,
        enquiryForName: '',
      ),
    );
    return mapping.customFields;
  }

  List<SearchLeadStatusModel> _subStatusGetModels = [];
  List<SearchLeadStatusModel> get subStatusGetModels => _subStatusGetModels;

  List<SubStatus> _uniqueStatuses = [];
  List<SubStatus> get uniqueSubStatuses {
    if (_formViewInId == null || _formViewInId == 0) {
      return _uniqueStatuses;
    }
    final validStatusIds = _subStatusGetModels
        .where((model) => model.viewInId == _formViewInId)
        .map((model) => model.statusId)
        .toSet();
    return _uniqueStatuses
        .where((subStatus) => validStatusIds.contains(subStatus.subStatusId))
        .toList();
  }

  List<SubStatus> get uniqueTransferStatuses {
    if (_formViewInId == null || _formViewInId == 0) {
      return _uniqueStatuses;
    }
    final validStatusIds = _subStatusGetModels
        .where((model) => model.viewInId == _formViewInId)
        .map((model) => model.statusId)
        .toSet();
    return _uniqueStatuses
        .where((subStatus) => validStatusIds.contains(subStatus.subStatusId))
        .toList();
  }

  Set<int> _selectedSubIds = {};
  Set<int> _selectedTransferIds = {};

  Set<int> get selectedSubStatusIds => _selectedSubIds;
  Set<int> get selectedTransferStatusIds => _selectedTransferIds;

  bool _isTransfer = false;
  bool get isTransfer => _isTransfer;
  set isTransfer(bool value) {
    _isTransfer = value;
    notifyListeners();
  }

  bool _isAmount = false;
  bool get isAmount => _isAmount;
  set isAmount(bool value) {
    _isAmount = value;
    notifyListeners();
  }

  bool _isTime = false;
  bool get isTime => _isTime;
  set isTime(bool value) {
    _isTime = value;
    notifyListeners();
  }

  bool _isTransferStatus = false;
  bool get isTransferStatus => _isTransferStatus;
  set isTransferStatus(bool value) {
    _isTransferStatus = value;
    notifyListeners();
  }

  bool _isSendUser = false;
  bool get isSendUser => _isSendUser;
  set isSendUser(bool value) {
    _isSendUser = value;
    notifyListeners();
  }

  bool _isLinkForm = false;
  bool get isLinkForm => _isLinkForm;
  set isLinkForm(bool value) {
    _isLinkForm = value;
    notifyListeners();
  }

  String _selectedFormId = "";
  String get selectedFormId => _selectedFormId;

  String _selectedFormName = "";
  String get selectedFormName => _selectedFormName;

  void setSelectedForm(String id, String name) {
    _selectedFormId = id;
    _selectedFormName = name;
    notifyListeners();
  }

// Common initialization
  void _initializeUniqueStatuses() {
    _uniqueStatuses = _subStatusGetModels
        .fold<Map<int, SubStatus>>({}, (map, element) {
          final id = element.statusId;
          if (id != null) {
            map[id] ??= SubStatus(
              subStatusId: id,
              subStatusName: element.statusName,
            );
          }
          return map;
        })
        .values
        .toList();
  }

// Using toJson() - Much cleaner
  List<Map<String, dynamic>> get selectedSubStatusesForApi {
    return uniqueSubStatuses
        .where((s) => _selectedSubIds.contains(s.subStatusId))
        .map((s) => s.toJson())
        .toList();
  }

  List<Map<String, dynamic>> get selectedTransferStatusesForApi {
    return uniqueTransferStatuses
        .where((s) => _selectedTransferIds.contains(s.subStatusId))
        .map((s) => s.toJson())
        .toList();
  }

  void setSelectedSubStatuses(List<SubStatus> statuses) {
    _selectedSubIds = statuses
        .where((s) => s.subStatusId != null)
        .map((s) => s.subStatusId!)
        .toSet();
    notifyListeners();
  }

  void setSelectedTransferStatuses(List<SubStatus> statuses) {
    _selectedTransferIds = statuses
        .where((s) => s.subStatusId != null)
        .map((s) => s.subStatusId!)
        .toSet();
    notifyListeners();
  }

  void toggleSubStatus(SubStatus status) {
    if (status.subStatusId == null) return;
    _selectedSubIds.contains(status.subStatusId!)
        ? _selectedSubIds.remove(status.subStatusId!)
        : _selectedSubIds.add(status.subStatusId!);
    notifyListeners();
  }

  void toggleTransferStatus(SubStatus status) {
    if (status.subStatusId == null) return;
    _selectedTransferIds.contains(status.subStatusId!)
        ? _selectedTransferIds.remove(status.subStatusId!)
        : _selectedTransferIds.add(status.subStatusId!);
    notifyListeners();
  }

  Future<void> fetchSubStatuses() async {
    try {
      _subStatusGetModels.clear();
      _uniqueStatuses.clear();
      // DO NOT clear selectedSubIds and selectedTransferIds here, as it breaks Edit mode initialization.

      final int viewInIdParam = _formViewInId ?? 0;
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchStatus}?status_Name=&ViewIn_Id=$viewInIdParam');

      if (response.statusCode == 200 && response.data != null) {
        _subStatusGetModels = (response.data as List)
            .map((item) => SearchLeadStatusModel.fromJson(item))
            .toList();

        _initializeUniqueStatuses();
        notifyListeners();
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  //follow up
  Future<List<SearchLeadStatusModel>> getStatusById(
      BuildContext context, String statusId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getStatusById}?status_id=$statusId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data is List) {
            return data.map((e) => SearchLeadStatusModel.fromJson(e)).toList();
          } else if (data is Map<String, dynamic>) {
            return [SearchLeadStatusModel.fromJson(data)];
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred in getStatusById: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
    return [];
  }

  //transferStatus
  Future<List<SearchLeadStatusModel>> getTransferStatusById(
      BuildContext context, String statusId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getTransferStatusById}?status_id=$statusId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data is List) {
            return data.map((e) => SearchLeadStatusModel.fromJson(e)).toList();
          } else if (data is Map<String, dynamic>) {
            return [SearchLeadStatusModel.fromJson(data)];
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      print('Exception occurred in getStatusById: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
    return [];
  }

  // Terms & Warranty
  final TextEditingController warrantyController = TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final TextEditingController description1Controller = TextEditingController();
  final TextEditingController description2Controller = TextEditingController();
  final TextEditingController description3Controller = TextEditingController();
  final TextEditingController advancePercentageController =
      TextEditingController();
  final TextEditingController onMaterialDeliveryPercentageController =
      TextEditingController();
  final TextEditingController onWorkCompletionPercentageController =
      TextEditingController();

  String _warrantyText = '';
  String _termsText = '';
  String _description1Text = '';
  String _description2Text = '';
  String _description3Text = '';
  String _advancePercentageText = '';
  String _onMaterialDeliveryPercentageText = '';
  String _onWorkCompletionPercentageText = '';
  int _termsWarrantyId = 0;

  String get warrantyText => _warrantyText;
  String get termsText => _termsText;
  String get description1Text => _description1Text;
  String get description2Text => _description2Text;
  String get description3Text => _description3Text;
  String get advancePercentageText => _advancePercentageText;
  String get onMaterialDeliveryPercentageText =>
      _onMaterialDeliveryPercentageText;
  String get onWorkCompletionPercentageText => _onWorkCompletionPercentageText;
  int get termsWarrantyId => _termsWarrantyId;

  Future<void> getTermsAndWarranty(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getTermsAndWarranty,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data != null) {
          _termsWarrantyId = data['Id'] ?? 0;
          _warrantyText = data['Warranty']?.toString() ?? '';
          _termsText = data['Terms_And_Conditions']?.toString() ?? '';
          _description1Text = data['Description_1']?.toString() ?? '';
          _description2Text = data['Description_2']?.toString() ?? '';
          _description3Text = data['Description_3']?.toString() ?? '';
          _advancePercentageText =
              (data['advance_percentage'] ?? data['Advance_Percentage'])
                      ?.toString() ??
                  '';
          _onMaterialDeliveryPercentageText =
              (data['onmaterialdelivery_percentage'] ??
                          data['OnMaterialDelivery_Percentage'])
                      ?.toString() ??
                  '';
          _onWorkCompletionPercentageText =
              (data['onWork_completetion_percentage'] ??
                          data['onWork_completion_percentage'] ??
                          data['OnWorkCompletion_Percentage'])
                      ?.toString() ??
                  '';
        }

        warrantyController.text = _warrantyText;
        termsController.text = _termsText;
        description1Controller.text = _description1Text;
        description2Controller.text = _description2Text;
        description3Controller.text = _description3Text;
        advancePercentageController.text = _advancePercentageText;
        onMaterialDeliveryPercentageController.text =
            _onMaterialDeliveryPercentageText;
        onWorkCompletionPercentageController.text =
            _onWorkCompletionPercentageText;
        notifyListeners();
      }
    } catch (e) {
      print('Exception in getTermsAndWarranty: $e');
    }
  }

  Future<void> saveTermsAndWarranty(BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveTermsAndWarranty,
        bodyData: {
          "Id": _termsWarrantyId,
          "Terms_And_Conditions": termsController.text.trim(),
          "Warranty": warrantyController.text.trim(),
          "Description_1": description1Controller.text.trim(),
          "Description_2": description2Controller.text.trim(),
          "Description_3": description3Controller.text.trim(),
          "Advance_Percentage": advancePercentageController.text.trim(),
          "OnMaterialDelivery_Percentage":
              onMaterialDeliveryPercentageController.text.trim(),
          "OnWorkCompletion_Percentage":
              onWorkCompletionPercentageController.text.trim(),
        },
      );

      if (response != null && response.statusCode == 200) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Terms and Warranty updated successfully')),
        );
        await getTermsAndWarranty(context);
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception in saveTermsAndWarranty: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  void clearTermsFields() {
    warrantyController.clear();
    termsController.clear();
    description1Controller.clear();
    description2Controller.clear();
    description3Controller.clear();
    advancePercentageController.clear();
    onMaterialDeliveryPercentageController.clear();
    onWorkCompletionPercentageController.clear();
    _warrantyText = '';
    _termsText = '';
    _description1Text = '';
    _description2Text = '';
    _description3Text = '';
    _advancePercentageText = '';
    _onMaterialDeliveryPercentageText = '';
    _onWorkCompletionPercentageText = '';
    _termsWarrantyId = 0;
    notifyListeners();
  }

  // ========== Designation ==========
  final TextEditingController designationNameController =
      TextEditingController();
  final TextEditingController searchDesignationController =
      TextEditingController();

  List<DesignationModel> _designationList = [];
  List<DesignationModel> get designationList => _designationList;

  Future<void> searchDesignation(String query, BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.getDesignation}?Designation_Name=$query',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          _designationList =
              data.map((e) => DesignationModel.fromJson(e)).toList();
        } else if (data is Map && data['data'] != null) {
          _designationList = (data['data'] as List)
              .map((e) => DesignationModel.fromJson(e))
              .toList();
        } else {
          _designationList = [];
        }
        notifyListeners();
      }
    } catch (e) {
      print('searchDesignation error: $e');
    }
  }

  Future<void> addDesignation({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveDesignation, // you need to add this URL
        bodyData: data,
      );

      if (response != null && response.statusCode == 200) {
        designationNameController.clear();
        searchDesignation('', context);
        Navigator.pop(context);
        Loader.stopLoader(context);
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('addDesignation error: $e');
    }
  }

  void deleteDesignation(BuildContext context, int designationId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteDesignation}/$designationId',
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        if (data['Designation_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context, "This Designation is currently in use");
        } else {
          searchDesignation('', context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Designation deleted successfully')),
          );
          Loader.stopLoader(context);
        }
        notifyListeners();
      } else {
        Loader.stopLoader(context);
      }
    } catch (e) {
      Loader.stopLoader(context);
      print(e);
    }
  }
}
