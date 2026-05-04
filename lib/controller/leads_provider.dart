import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/controller/models/lead_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/save_lead_dropdown_model.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
// import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'dart:html' as html;

class LeadsProvider extends ChangeNotifier {
  //controllers for add lead
  final TextEditingController leadNameController = TextEditingController();
  final TextEditingController leadAgeController = TextEditingController();
  final TextEditingController enquiryForController = TextEditingController();

  final TextEditingController enquirySourceController = TextEditingController();
  final TextEditingController sourceCategoryController =
      TextEditingController();

  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController referenceNameController = TextEditingController();

  final TextEditingController emailIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mapLinkController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController followUpStatusController =
      TextEditingController();
  final TextEditingController branchController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController sourceCategoryControllerLead =
      TextEditingController();

  final TextEditingController workTypeController = TextEditingController();
  final TextEditingController searchUserController = TextEditingController();
  final TextEditingController peController = TextEditingController();
  final TextEditingController creController = TextEditingController();
  final TextEditingController leadtypeController = TextEditingController();
  final TextEditingController assignToController = TextEditingController();
  final TextEditingController followUpDateController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  //controllers for add followup
  final TextEditingController statusController = TextEditingController();

  final TextEditingController nextFollowUpDateController =
      TextEditingController();
  final TextEditingController assignToFollowUpController =
      TextEditingController();
  final TextEditingController messageController = TextEditingController();

  //consumer
  final TextEditingController consumerNoController = TextEditingController();
  final TextEditingController subDivisionController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();
  final TextEditingController circleController = TextEditingController();
  final TextEditingController connectedLoadController = TextEditingController();
  final TextEditingController proposedKWController = TextEditingController();
  final TextEditingController roofTypeController = TextEditingController();
  final TextEditingController applicationNumberController =
      TextEditingController();
  final TextEditingController repController = TextEditingController();
  final TextEditingController leadByController = TextEditingController();
  final TextEditingController electricalSectionController =
      TextEditingController();
  final TextEditingController additionalCommentscONTROLLER =
      TextEditingController();
  final TextEditingController costIncludesController = TextEditingController();

  final TextEditingController amountPaidController = TextEditingController();
  final TextEditingController deadlineDateController = TextEditingController();
  bool _isChecked = false;
  bool get isChecked => _isChecked;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingCustomFields = false;
  bool get isLoadingCustomFields => _isLoadingCustomFields;

  bool _isLoadingEnquiryCustomFields = false;
  bool get isLoadingEnquiryCustomFields => _isLoadingEnquiryCustomFields;
  final bool _isSavingFollowup = false;
  bool get isSavingFollowup => _isSavingFollowup;
  bool _isFeasibilityChecked = false;
  bool get isFeasibilityChecked => _isFeasibilityChecked;
  bool _isSpinChecked = false;
  bool get isSpinChecked => _isSpinChecked;
  int _loanValue = 0;
  int get loanValue => _loanValue;
  int _feasibilityValue = 0;
  int get feasibilityValue => _feasibilityValue;
  int _spinValue = 0;
  int get spinValue => _spinValue;
  int? _openIndex;

  int? get openIndex => _openIndex;

  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int pageSize = 20;

//cost
  final TextEditingController projectCostController = TextEditingController();
  final TextEditingController additionalCostControler = TextEditingController();
  final TextEditingController advanceAmountController = TextEditingController();
  final TextEditingController commissionController = TextEditingController();
  //invoice
  final TextEditingController invoiceNoController = TextEditingController();
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController invoiceAmountController = TextEditingController();
  List<SearchLeadModel> _leadData = [];
  List<LeadReportModel> _leadReportData = [];

  SaveLeadDropdownModel? _leadDropdownData; // Change from List to single object

  List<SearchLeadModel> _tempData = [];

  bool _isFilter = false;
  bool _isImporting = false;
  double _importProgress = 0.0;
  String _importStatusText = '';

  bool get isImporting => _isImporting;
  double get importProgress => _importProgress;
  String get importStatusText => _importStatusText;
  List<int> _selectedStatusIds = [0];
  List<int> _selectedUserIds = [0];
  List<int> _selectedEnquiryForIds = [0];
  List<int> _selectedEnquirySourceIds = [0];

  int? _selectedStatus;
  int? _selectedUser;
  int? _selectedEnquiryFor;
  int? _selectedEnquirySource;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  int? _selectedDateFilterIndex;
  int _customerId = 0;
  int _startLimit = 1;
  int _endLimit = 20;
  // final int _limit = 25;
  int _totalCount = 0;

  int get startLimit => _startLimit;
  int get endLimit => _endLimit;
  int get totalCount => _totalCount;
  int get customerId => _customerId;
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  set formattedFromDate(String value) {
    _formattedFromDate = value;
    notifyListeners();
  }

  set formattedToDate(String value) {
    _formattedToDate = value;
    notifyListeners();
  }

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  List<int> get selectedStatusIds => _selectedStatusIds;
  List<int> get selectedUserIds => _selectedUserIds;
  List<int> get selectedEnquiryForIds => _selectedEnquiryForIds;

  int? get selectedStatus => _selectedStatus;
  int? get selectedUser => _selectedUser;
  int? get selectedEnquiryFor => _selectedEnquiryFor;
  int? get selectedEnquirySource => _selectedEnquirySource;
  bool get isFilter => _isFilter;
  List<SearchLeadModel> get leadData => _leadData;
  List<LeadReportModel> get leadReportData => _leadReportData;

  SaveLeadDropdownModel? get leadDropdownData => _leadDropdownData;

  String _search = '';
  String _leadId = '0';
  String _fromDateS = '';
  String _toDateS = '';
  String _status = '';
  String _enquiryForS = '';

  String get search => _search;
  String get leadId => _leadId;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get status => _status;
  String get enquiryForS => _enquiryForS;
  int _loginUserId = 0;
  int get loginUserId => _loginUserId;
  String _loginUserName = '';
  String get loginUserName => _loginUserName;

  //from login details
  int _loginBranchId = 0;
  int get loginBranchId => _loginBranchId;
  String _loginBranchName = '';
  String get loginBranchName => _loginBranchName;
  int _loginDepartmentId = 0;
  int get loginDepartmentId => _loginDepartmentId;
  String _loginDepartmentName = '';
  String get loginDepartmentName => _loginDepartmentName;
  String _loginUserTypeName = '';
  String get loginUserTypeName => _loginUserTypeName;

  Future<void> loadLoginDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _loginUserId = int.tryParse(preferences.getString('userId') ?? '0') ?? 0;
    _loginUserName = preferences.getString('userName') ?? '';
    _loginBranchId =
        int.tryParse(preferences.getString('branchId') ?? '0') ?? 0;
    _loginBranchName = preferences.getString('branchName') ?? '';
    _loginDepartmentId =
        int.tryParse(preferences.getString('departmentId') ?? '0') ?? 0;
    _loginDepartmentName = preferences.getString('departmentName') ?? '';
    _loginUserTypeName = preferences.getString('userTypeName') ?? '';
    notifyListeners();
  }

  void setLeadId(String value) {
    _leadId = value.isEmpty ? '0' : value;
    notifyListeners();
  }

  // --- NEW: Enquiry Source Filter ---
  List<int> get selectedEnquirySourceIds => _selectedEnquirySourceIds;

  void toggleEnquirySourceFilter(int value) {
    if (value == 0) {
      _selectedEnquirySourceIds = [0];
    } else {
      if (_selectedEnquirySourceIds.contains(value) &&
          _selectedEnquirySourceIds.length == 1) {
        _selectedEnquirySourceIds = [0];
      } else {
        _selectedEnquirySourceIds = [value];
      }
    }
    _selectedEnquirySource = _selectedEnquirySourceIds.isNotEmpty
        ? _selectedEnquirySourceIds.first
        : null;
    notifyListeners();
  }

  void setStatus(int? value) {
    _selectedStatus = value;
    _selectedStatusIds = [value ?? 0];
    notifyListeners();
  }

  void setUserFilterStatus(int? value) {
    _selectedUser = value;
    _selectedUserIds = [value ?? 0];
    notifyListeners();
  }

  void setEnquiryForFilter(int? value) {
    _selectedEnquiryFor = value;
    _selectedEnquiryForIds = [value ?? 0];
    notifyListeners();
  }

  void setEnquirySourceFilter(int? value) {
    _selectedEnquirySource = value;
    _selectedEnquirySourceIds = [value ?? 0];
    notifyListeners();
  }

  //invertor and panel details
  final TextEditingController invertorBrandController = TextEditingController();
  final TextEditingController invertorCapacityController =
      TextEditingController();
  final TextEditingController inverterTypeController = TextEditingController();
  final TextEditingController invertorModelController = TextEditingController();
  final TextEditingController invertorSnController = TextEditingController();
  final TextEditingController panelBrandController = TextEditingController();
  final TextEditingController panelWattsController = TextEditingController();
  final TextEditingController panelSnController = TextEditingController();
  final TextEditingController installationDateController =
      TextEditingController();
  final TextEditingController panelPhaseController = TextEditingController();

  final TextEditingController panelCapacityController = TextEditingController();

  final TextEditingController expiryDateController = TextEditingController();
  int _isWarrentyChecked = 0;
  int get isWarrentyChecked => _isWarrentyChecked;
  List<CustomFieldByStatusId> _customFieldList = [];
  List<CustomFieldByStatusId> get customFieldList => _customFieldList;

  List<CustomFieldByStatusId> _customFieldEnquiryFor = [];
  List<CustomFieldByStatusId> get customFieldEnquiryFor =>
      _customFieldEnquiryFor;

  int _missingMandatoryDocumentCount = 0;
  int get missingMandatoryDocumentCount => _missingMandatoryDocumentCount;
  ScrollController scrollController = ScrollController();
  int? expandedIndex;
  String _aadharImage = '';
  String get aadharImage => _aadharImage;
  String _electricityBillImage = '';
  String get electricityBillImage => _electricityBillImage;
  String _cancelledPassBookImage = '';
  String get cancelledPassBookImage => _cancelledPassBookImage;
  String _passPortImage = '';
  String get passportImage => _passPortImage;
  String _upiImage = '';
  String get upiImage => _upiImage;

  //dropdown ids
  int? _selectedPanelId;
  int? _selectedRoofId;
  int? _selectedSubsidyId;
  int? _selectedCostIncId;
  int? _selectedAmountPaidId;
  int? _selectedPhaseId;
  int? _selectedWorkTypeId;
  int? _selectedInverterId;

  int? get selectedPanelId => _selectedPanelId;
  int? get selectedRoofId => _selectedRoofId;
  int? get selectedSubsidyId => _selectedSubsidyId;
  int? get selectedCostIncId => _selectedCostIncId;
  int? get selectedAmountPaidId => _selectedAmountPaidId;
  int? get selectedPhaseId => _selectedPhaseId;
  int? get selectedWorkTypeId => _selectedWorkTypeId;
  int? get selectedInverterId => _selectedInverterId;
  set aadharImage(String value) {
    _aadharImage = value;
    notifyListeners();
  }

  set selectedPanelId(int? value) {
    if (_selectedPanelId != value) {
      _selectedPanelId = value;
      notifyListeners();
    }
  }

  set selectedRoofId(int? value) {
    if (_selectedRoofId != value) {
      _selectedRoofId = value;
      notifyListeners();
    }
  }

  set selectedSubsidyId(int? value) {
    if (_selectedSubsidyId != value) {
      _selectedSubsidyId = value;
      notifyListeners();
    }
  }

  set selectedCostIncId(int? value) {
    if (_selectedCostIncId != value) {
      _selectedCostIncId = value;
      notifyListeners();
    }
  }

  set selectedAmountPaidId(int? value) {
    if (_selectedAmountPaidId != value) {
      _selectedAmountPaidId = value;
      notifyListeners();
    }
  }

  set selectedPhaseId(int? value) {
    if (_selectedPhaseId != value) {
      _selectedPhaseId = value;
      notifyListeners();
    }
  }

  set selectedWorkTypeId(int? value) {
    if (_selectedWorkTypeId != value) {
      _selectedWorkTypeId = value;
      notifyListeners();
    }
  }

  set selectedInverterId(int? value) {
    if (_selectedInverterId != value) {
      _selectedInverterId = value;
      notifyListeners();
    }
  }

  void setPanelId(int id) {
    _selectedPanelId = id;
    notifyListeners();
  }

  void setRoofTypeId(int id) {
    _selectedRoofId = id;
    notifyListeners();
  }

  void setInverterId(int id) {
    _selectedInverterId = id;
    notifyListeners();
  }

  void setWorkTypeId(int id) {
    _selectedWorkTypeId = id;
    notifyListeners();
  }

  void setPhaseId(int id) {
    _selectedPhaseId = id;
    notifyListeners();
  }

  void setAmountPaidId(int id) {
    _selectedAmountPaidId = id;
    notifyListeners();
  }

  void setCostIncId(int id) {
    _selectedCostIncId = id;
    notifyListeners();
  }

  void setSelectedSubsidyId(int id) {
    _selectedSubsidyId = id;
    notifyListeners();
  }

  void toggle(int index) {
    if (_openIndex == index) {
      _openIndex = null; // Allow the current one to be closed
    } else {
      _openIndex = index; // Open the new one
    }
    notifyListeners();
  }

  set electricityBillImage(String value) {
    _electricityBillImage = value;
    notifyListeners();
  }

  set cancelledPassBookImage(String value) {
    _cancelledPassBookImage = value;
    notifyListeners();
  }

  set passportImage(String value) {
    _passPortImage = value;
    notifyListeners();
  }

  set upiImage(String value) {
    _upiImage = value;
    notifyListeners();
  }

  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = null;
    } else {
      expandedIndex = index;
    }
    notifyListeners();
  }

  void resetExpansion() {
    expandedIndex = null;
    notifyListeners();
  }

  void toggleWarrentyCheckbox(bool value) {
    _isWarrentyChecked = value ? 1 : 0;
    print(_isWarrentyChecked.toString());
    notifyListeners();
  }

  void clearAllLeadControllers(BuildContext context) {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    clearCustomFieldValues();
    followUpStatusController.clear();
    branchController.clear();
    departmentController.clear();
    inverterTypeController.clear();
    panelBrandController.clear();
    panelPhaseController.clear();
    workTypeController.clear();
    costIncludesController.clear();
    amountPaidController.clear();
    searchUserController.clear();
    assignToController.clear();
    leadNameController.clear();
    enquirySourceController.clear();
    sourceCategoryController.clear();
    referenceNameController.clear();
    branchController.clear();
    departmentController.clear();
    contactNoController.clear();
    emailIdController.clear();
    addressController.clear();
    mapLinkController.clear();
    latitudeController.clear();
    longitudeController.clear();
    pincodeController.clear();
    cityController.clear();
    districtController.clear();
    stateController.clear();
    consumerNoController.clear();
    electricalSectionController.clear();
    invertorCapacityController.clear();
    panelCapacityController.clear();
    enquirySourceController.clear();
    sourceCategoryController.clear();
    dropDownProvider.selectedpeUserId = null;
    dropDownProvider.selectedcreUserId = null;
    dropDownProvider.selectedleadtypeUserId = null;
    dropDownProvider.selectedEnquirySourceId = null;
    dropDownProvider.selectedStatusId = null;
    dropDownProvider.selectedFollowUPId = null;
    dropDownProvider.selectedLocationId = null;
    settingsProvider.selectedBranchId = null;
    settingsProvider.setSelectedDepartmentId(0);

    enquiryForController.clear();
    projectCostController.clear();
    additionalCostControler.clear();
    advanceAmountController.clear();
    commissionController.clear();
    connectedLoadController.clear();
    repController.clear();
    roofTypeController.clear();
    remarksController.clear();
    leadByController.clear();
    additionalCommentscONTROLLER.clear();
    nextFollowUpDateController.clear();
    applicationNumberController.clear();
    installationDateController.clear();
    expiryDateController.clear();
    leadAgeController.clear();
    peController.clear();
    creController.clear();
    leadtypeController.clear();
    aadharImage = '';
    electricityBillImage = '';
    passportImage = '';
    cancelledPassBookImage = '';
    upiImage = '';
    toggleWarrentyCheckbox(false);
    setLoanChecked(0);

    setFeasibilityChecked(0);
    setSpinChecked(0);
    setCostIncId(0);
    setAmountPaidId(0);
    setInverterId(0);
    setPhaseId(0);
    setWorkTypeId(0);
    setPanelId(0);
    setRoofTypeId(0);
    setSelectedSubsidyId(0);
    notifyListeners();
  }
//api for dropdowns

//.......................................................................

  bool _isScrollInitialized = false;

  void scrollListener(BuildContext context) {
    // Pagination disabled per user request to show all data at once
  }

  Future<void> loadMoreLeads(BuildContext context) async {
    if (isLoadingMore || !hasMoreData) return;

    try {
      isLoadingMore = true;
      currentPage++;
      notifyListeners();

      await getSearchLeads(context, isPagination: true);
    } catch (e) {
      log('Error loading more leads: $e');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

//........................................................................

  void toggleIsChecked() {
    _isChecked = !_isChecked;
    _loanValue = _isChecked ? 1 : 0; // Set loanValue based on isChecked
    notifyListeners();
  }

  // Function to toggle _isFeasibilityChecked and update feasibilityValue
  void toggleIsFeasibilityChecked() {
    _isFeasibilityChecked = !_isFeasibilityChecked;
    _feasibilityValue = _isFeasibilityChecked ? 1 : 0;
    if (_feasibilityValue == 0) {
      setSpinChecked(0);
      deadlineDateController.clear();
    }
    notifyListeners();
  }

  void toggleIsSpinChecked() {
    _isSpinChecked = !_isSpinChecked;
    _spinValue = _isSpinChecked ? 1 : 0;
    notifyListeners();
  }

  // Function to directly set loanValue
  void setLoanChecked(int value) {
    _loanValue = value;
    _isChecked = value == 1;
    print('Loan$_loanValue');
    notifyListeners();
  }

  void setFeasibilityChecked(int value) {
    _feasibilityValue = value;
    _isFeasibilityChecked = value == 1;
    print('Loan$_feasibilityValue');
    notifyListeners();
  }

  void setSpinChecked(int value) {
    _spinValue = value;
    _isSpinChecked = value == 1;
    print('Spin$_spinValue');
    notifyListeners();
  }

  void setSearchCriteria(String search, String fromDate, String toDate,
      {String leadId = '0'}) {
    leadData.clear();
    _search = search;
    _leadId = leadId.isEmpty ? '0' : leadId;
    _fromDateS = fromDate;
    _toDateS = toDate;

    // Convert List<int> to comma separated strings
    _status = _selectedStatusIds.join(',');
    _enquiryForS = _selectedEnquiryForIds.join(',');
    // _selectedUser is handled slightly differently in API call (To_User_Id), but we can also join
    // However the API only seems to take one To_User_Id based on existing code.
    // I'll assume it supports multi if I pass comma sep.

    _startLimit = 1;
    _endLimit = 20;
    currentPage = 1;
    hasMoreData = true;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    // selectDateFilterOption(null);
    // removeStatus();
    notifyListeners();
  }

  void setFilter(bool filter) {
    _isFilter = filter;

    notifyListeners(); // Notify listeners about the change
  }

  void clearAllFilters() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedEnquiryFor = null;
    _selectedEnquirySource = null;
    _selectedStatusIds = [0];
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _fromDateS = '';
    _toDateS = '';
    _search = '';
    _leadId = '0';
    _status = '';
    _enquiryForS = '';
    _isFilter = false;
    _selectedDateFilterIndex = null;
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
      if (_selectedUserIds.contains(value) && _selectedUserIds.length == 1) {
        _selectedUserIds = [0];
      } else {
        _selectedUserIds = [value];
      }
    }
    _selectedUser = _selectedUserIds.isNotEmpty ? _selectedUserIds.first : null;
    notifyListeners();
  }

  void clearUserFilter() {
    _selectedUserIds = [0];
    _selectedUser = null;
    notifyListeners();
  }

  void toggleEnquiryForFilter(int value) {
    if (value == 0) {
      _selectedEnquiryForIds = [0];
    } else {
      if (_selectedEnquiryForIds.contains(value) &&
          _selectedEnquiryForIds.length == 1) {
        _selectedEnquiryForIds = [0];
      } else {
        _selectedEnquiryForIds = [value];
      }
    }
    _selectedEnquiryFor =
        _selectedEnquiryForIds.isNotEmpty ? _selectedEnquiryForIds.first : null;
    notifyListeners();
  }

  Future<void> fetchNextPage(BuildContext context) async {
    print("Next Clicked → current page: $currentPage total: $_totalCount");

    if (_endLimit >= _totalCount) return;

    currentPage++;
    await getSearchLeads(context, isWebPagination: true);
  }

  // Fetch previous page data
  Future<void> fetchPreviousPage(BuildContext context) async {
    print("Previous Clicked → current page: $currentPage total: $_totalCount");

    if (currentPage <= 1) return;

    currentPage--;
    await getSearchLeads(context, isWebPagination: true);
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

  Future<void> getSearchLeads(BuildContext context,
      {bool isPagination = false,
      bool isWebPagination = false,
      bool isSilent = false}) async {
    try {
      if (!isPagination && !isWebPagination) {
        if (!isSilent) {
          _isLoading = true;
          notifyListeners();
        }
        currentPage = 1;
        hasMoreData = true;
        _leadData.clear();
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      }

      if (isWebPagination) {
        _leadData.clear();
      }
      pageSize =
          AppStyles.isWebScreen(context) ? 20 : 10000; //web 20 and mobile 10000

      _startLimit = ((currentPage - 1) * pageSize) + 1;
      _endLimit = currentPage * pageSize;

      _status = _selectedStatusIds.join(',');
      _enquiryForS = _selectedEnquiryForIds.join(',');

      print('Start$_startLimit');
      print('End$_endLimit');

      if (_status.isEmpty || _status == 'null') {
        _status = '0';
      }
      if (_enquiryForS.isEmpty || _enquiryForS == 'null') {
        _enquiryForS = '0';
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
      String userId = preferences.getString('userId') ?? "0";
      String username = preferences.getString('userName') ?? "";
      _loginUserId = int.parse(userId);
      _loginUserName = username;

      String toUserId = _selectedUserIds.join(',');
      String enquirySourceIds = _selectedEnquirySourceIds.join(',');

      if (!isSilent && !isPagination && !isWebPagination) {
        Loader.showLoader(context);
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchLead}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&To_User_Id_=$toUserId&Login_User_Id_=$_loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$_enquiryForS&Enquiry_Source_Id_=$enquirySourceIds&User_Details_Id_=$_loginUserId&Lead_Id_=$_leadId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<SearchLeadModel> allItems = (data as List<dynamic>)
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();

          // Extract real data (tp == 1)
          List<SearchLeadModel> newItems =
              allItems.where((item) => item.tp == 1).toList();

          if (newItems.isNotEmpty) {
            _leadData.addAll(newItems);

            // Find metadata (tp == 2) safely
            int metadataIndex = allItems.indexWhere((item) => item.tp == 2);
            if (metadataIndex != -1) {
              _totalCount = allItems[metadataIndex].customerId;
            }

            hasMoreData = _leadData.length < _totalCount;
          } else {
            hasMoreData = false;
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      log('Exception in getSearchLeads: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      if (!isSilent && !isPagination && !isWebPagination) {
        Loader.stopLoader(context);
      }
    }
  }

  // getSearchLeads(BuildContext context) async {
  //   try {
  //     Loader.showLoader(context);
  //     print('Start$_startLimit');
  //     print('End$_endLimit');

  //     if (_status.isEmpty || _status == 'null') {
  //       _status = '0';
  //     }
  //     if (_enquiryForS.isEmpty || _enquiryForS == 'null') {
  //       _enquiryForS = '0';
  //     }

  //     String isDate = "0";
  //     if (_fromDateS.isEmpty && _toDateS.isEmpty) {
  //       isDate = "0";
  //       if (_fromDateS.isEmpty) {
  //         _fromDateS = "";
  //       }
  //       if (_toDateS.isEmpty) {
  //         _toDateS = "";
  //       }
  //     } else {
  //       isDate = "1";
  //     }

  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String userId = preferences.getString('userId') ?? "0";
  //     String username = preferences.getString('userName') ?? "";
  //     _loginUserId = int.parse(userId);
  //     _loginUserName = username;

  //     String toUserId = (_selectedUser ?? 0).toString();

  //     final response = await HttpRequest.httpGetRequest(
  //         endPoint:
  //             '${HttpUrls.searchLead}?lead_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=$toUserId&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit&Enquiry_For_Id=$_enquiryForS');

  //     if (response.statusCode == 200) {
  //       final data = response.data;

  //       if (data != null) {
  //         _tempData = (data as List<dynamic>)
  //             .map((item) => SearchLeadModel.fromJson(item))
  //             .toList();

  //         _totalCount = _tempData.last.customerId;
  //         print("Last customer's ID: $_totalCount");

  //         _tempData.removeLast();

  //         if (AppStyles.isWebScreen(context)) {
  //           _leadData = List.from(_tempData);
  //         } else {
  //           if (_search.isEmpty &&
  //               _fromDateS.isEmpty &&
  //               _toDateS.isEmpty &&
  //               _status == "0" &&
  //               _enquiryForS == '0') {
  //             // Create a set of existing lead IDs
  //             final existingIds =
  //                 _leadData.map((lead) => lead.customerId).toSet();

  //             // Only add leads that don't already exist
  //             _leadData.addAll(_tempData
  //                 .where((lead) => !existingIds.contains(lead.customerId)));
  //           } else {
  //             _leadData.clear();
  //             _leadData = List.from(_tempData);
  //           }
  //         }

  //         Loader.stopLoader(context);
  //         notifyListeners();
  //       }
  //     } else {
  //       Loader.stopLoader(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Server Error')),
  //       );
  //     }
  //   } catch (e) {
  //     Loader.stopLoader(context);
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred')),
  //     );
  //   }
  // }

// //no context only for back in customer detail
  Future<void> getSearchLeadsNoContext() async {
    try {
      // Loader.showLoader(context);
      // _isLoading = true;
      _status = _selectedStatusIds.join(',');
      print('Start$_startLimit');
      print('End$_endLimit');
      if (_enquiryForS.isEmpty || _enquiryForS == 'null') {
        _enquiryForS = '0';
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
      String userIdPref = preferences.getString('userId') ?? "0";
      _loginUserId = int.parse(userIdPref);
      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchLead}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&To_User_Id_=$toUserId&Login_User_Id_=$_loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$_enquiryForS&User_Details_Id_=$_loginUserId&Lead_Id_=$_leadId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          List<SearchLeadModel> allItems = (data as List<dynamic>)
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();

          _leadData = allItems.where((item) => item.tp == 1).toList();

          int metadataIndex = allItems.indexWhere((item) => item.tp == 2);
          if (metadataIndex != -1) {
            _totalCount = allItems[metadataIndex].customerId;
          }

          hasMoreData = _leadData.length < _totalCount;

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> saveLead({
    required BuildContext context,
    required String customerName,
    required String contactNumber,
    required String contactPerson,
    required String email,
    required String address1,
    required String address2,
    required String address3,
    required String address4,
    required int createdBy,
    required int custId,
    required String createdByName,
    required String entryDate,
    required String consumerNo,
    required String subDistrict,
    required String village,
    required String section,
    required String subDivision,
    required String division,
    required String circle,
    required String connectedLoad,
    required String proposedKW,
    required String roofType,
    required int enquirySourceId,
    required String enquirySourceName,
    required String mapLink,
    required String pincode,
    required String nextFollowUpDate,
    required int statusId,
    required String statusName,
    required int byUserId,
    required String byUserName,
    required int toUserId,
    required String toUserName,
    required int followUp,
    required String remark,
    required int enquiryForId,
    required String enquiryForName,
    required int districtId,
    required String districtName,
    required int branchId,
    required String branchName,
    required int departmentId,
    required String departmentName,
    required int sourceId,
    required String sourceName,
    required int age,
    required int peId,
    required String peName,
    required int creId,
    required String creName,
    required int leadtypeId,
    required String leadtypeName,
    int? locationId,
  }) async {
    try {
      Loader.showLoader(context);

      if (nextFollowUpDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(nextFollowUpDate);
        } catch (e) {
          parsedDate = DateTime.parse(nextFollowUpDate);
        }
        nextFollowUpDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        nextFollowUpDate = '';
      }
      String invoiceDate = invoiceDateController.text.toString();
      if (invoiceDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(invoiceDate);
        } catch (e) {
          parsedDate = DateTime.parse(invoiceDate);
        }
        invoiceDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        invoiceDate = '';
      }
      String deadlineDate = deadlineDateController.text.toString();
      if (deadlineDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(deadlineDate);
        } catch (e) {
          parsedDate = DateTime.parse(deadlineDate);
        }
        deadlineDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        deadlineDate = '';
      }
      String invoiceAmount = invoiceAmountController.text.toString();
      if (invoiceAmount.isEmpty || invoiceAmount == 'null') {
        invoiceAmount = '0';
      }
      String installationDate = installationDateController.text.toString();
      if (installationDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(installationDate);
        } catch (e) {
          parsedDate = DateTime.parse(installationDate);
        }
        installationDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        installationDate = '';
      }
      String expiryDate = expiryDateController.text.toString();
      if (expiryDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(expiryDate);
        } catch (e) {
          parsedDate = DateTime.parse(expiryDate);
        }
        expiryDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        expiryDate = '';
      }
      print('date$nextFollowUpDate');
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userName = preferences.getString('userName') ?? "";
      String userIdStr = preferences.getString('userId') ?? "0";
      final int byUserIdInt = int.tryParse(userIdStr) ?? 0;

      // Before API call: upload any pending files from enquiryFor custom fields
      final enquiryWidgetState = customFieldEnquirySourceKey.currentState;
      if (enquiryWidgetState != null) {
        final pendingBytes = enquiryWidgetState.getPendingFileBytes();
        final pendingTypes = enquiryWidgetState.getPendingFileContentTypes();
        if (pendingBytes.isNotEmpty) {
          for (final entry in pendingBytes.entries) {
            final fieldId = entry.key;
            final bytes = entry.value;
            final contentType =
                pendingTypes[fieldId] ?? 'application/octet-stream';
            final uploadKey = await CloudflareUpload.uploadToCloudflare(
                bytes, contentType, '$fieldId', context);
            if (uploadKey != null) {
              final fullUrl = HttpUrls.imgBaseUrl + uploadKey;
              enquiryWidgetState.updateFieldValue(fieldId, fullUrl);
            }
          }
        }
      }

      final response = await HttpRequest
          .httpPostRequest(endPoint: HttpUrls.saveLead, bodyData: {
        "lead": {
          "Customer_Id": custId,
          "Customer_Name": leadNameController.text.isEmpty
              ? 'Null'
              : leadNameController.text,
          "Address": addressController.text,
          "City": cityController.text,
          "State": stateController.text,
          "Latitude": latitudeController.text,
          "Longitude": longitudeController.text,
          "Pincode": pincodeController.text,
          "Email_Address": emailIdController.text,
          "Phone_Number": contactNoController.text,
          "Reference_Name": referenceNameController.text,
          "Location": mapLinkController.text,
          "Consumer_Number": consumerNoController.text,
          "Electrical_Section": electricalSectionController.text,
          "Inverter_Capacity":
              double.tryParse(invertorCapacityController.text) ?? 0,
          "Inverter_Type_Id": selectedInverterId,
          "inverter_type_name": inverterTypeController.text,
          "panel_type_name": panelBrandController.text,
          "Panel_Capacity": double.tryParse(panelCapacityController.text) ?? 0,
          "Panel_Type_Id": selectedPanelId,
          "Phase_Id": selectedPhaseId,
          "phase_name": panelPhaseController.text,
          "Roof_Type_Id": selectedRoofId,
          "roof_type_name": roofTypeController.text,
          "Enquiry_Source_Id": enquirySourceId,
          "Enquiry_Source_Name": enquirySourceName,
          "Enquiry_For_Id": enquiryForId,
          "Enquiry_For_Name": enquiryForName,
          "Project_Cost": double.tryParse(projectCostController.text) ?? 0,
          "Additional_Cost": double.tryParse(additionalCostControler.text) ?? 0,
          "Advance_Amount": double.tryParse(advanceAmountController.text) ?? 0,
          "Commission": double.tryParse(commissionController.text) ?? 0,
          "Amount_Paid_Through_Id": selectedAmountPaidId,
          "amount_paid_through_name": amountPaidController.text,
          "UPI_Transfer_Photo": upiImage,
          "Cost_Includes_Id": selectedCostIncId,
          "cost_includes_name": costIncludesController.text,
          "Electricity_Bill_Photo": electricityBillImage,
          "Cancelled_Cheque_Passbook": cancelledPassBookImage,
          "Adhaar_Card_Back": aadharImage,
          "Passport_Size_Photo": passportImage,
          "Connected_Load": double.tryParse(connectedLoadController.text) ?? 0,
          "Rep": repController.text,
          "Lead_By": leadByController.text,
          "Work_Type_Id": selectedWorkTypeId,
          "work_type_name": workTypeController.text,
          "Subsidy_Type_Id": selectedSubsidyId,
          "subsidy_type_name": '',
          "Additional_Comments": additionalCommentscONTROLLER.text,
          "Total_Task": 0,
          "Completed_Task": 0,
          "FollowUp_Value": followUp,
          "District_Id": districtId,
          "District": districtName,
          "Source_Category_Id": sourceId,
          "Source_Category_Name": sourceName,
          "customFields": (customFieldLeadStatusKey.currentState
                      ?.getFilledFieldValues()
                      .isNotEmpty ??
                  false)
              ? customFieldLeadStatusKey.currentState?.getFieldValuesAsJson()
              : null,
          "enquiryForCustomFields":
              customFieldEnquirySourceKey.currentState?.getFieldValuesAsJson(),
          "Age": age,
          "PE_Id": peId,
          "PE_Name": peName,
          "CRE_Id": creId,
          "CRE_Name": creName,
          "Lead_Type_Id": leadtypeId,
          "Lead_Type_Name": leadtypeName,
          "Location_Id": locationId,
        },
        "followup": {
          "Next_FollowUp_date": nextFollowUpDate,
          "Status_Id": statusId,
          "Status_Name": statusName,
          "Branch_Id": branchId,
          "Branch_Name": branchName,
          "Department_Id": departmentId,
          "Department_Name": departmentName,
          "By_User_Id": byUserIdInt,
          "By_User_Name": userName,
          "To_User_Id": toUserId,
          "To_User_Name": toUserName,

          // "FollowUp": followUp,
          "Remark": remark,
        }
      });

      if (response!.statusCode == 200) {
        final data = response.data;
        if (data['Customer_Id_'] == -2) {
          Loader.stopLoader(context);
          alert(context, "Email Already Exists");
        } else if (data['Customer_Id_'] == -1) {
          Loader.stopLoader(context);
          alert(context, "Mobile No. Already Exists");
        } else {
          log('Success');
          leadData.clear();
          await getSearchLeads(context);
          final customerDetailsProvider =
              Provider.of<CustomerDetailsProvider>(context, listen: false);
          final leadDetailsProvider =
              Provider.of<LeadDetailsProvider>(context, listen: false);
          leadDetailsProvider.fetchLeadDetailsNoContext(custId.toString());
          customerDetailsProvider.fetchLeadDetails(custId.toString(), context);
          clearAllLeadControllers(context);

          final dropDownProvider =
              Provider.of<DropDownProvider>(context, listen: false);
          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          dropDownProvider.updateEnquiryForName(null, '');
          dropDownProvider.updateDistrict(null, '');
          settingsProvider.selectedDepartmentId = 0;
          settingsProvider.selectedBranchId = 0;
          dropDownProvider.setSourceCategoryId(0);

          final dashboardProvider =
              Provider.of<DashboardProvider>(context, listen: false);
          dashboardProvider.refreshDashboardData(context);

          Navigator.pop(context);
          Loader.stopLoader(context);
          notifyListeners();
          print(data);
        }
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

  Future<void> saveFollowUp({
    required BuildContext context,
    required int statusId,
    required String statusName,
    required String followUpDate,
    required int toUserId,
    required String toUserName,
    required int followUp,
    required String message,
    required int custId,
    required int branchId,
    required String branchName,
    required int departmentId,
    required String departmentName,
    List<Map<String, String>>? audioFiles, // Add this parameter
  }) async {
    try {
      if (followUpDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(followUpDate);
        } catch (e) {
          parsedDate = DateTime.parse(followUpDate);
        }
        followUpDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        followUpDate = '';
      }
      print('date$followUpDate');
      Loader.showLoader(context);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userName = preferences.getString('userName') ?? "";
      String userIdPref = preferences.getString('userId') ?? "0";
      _loginUserId = int.tryParse(userIdPref) ?? 0;

      final response = await HttpRequest.httpPostRequest(
          endPoint: HttpUrls.saveFollowUp,
          bodyData: {
            "FollowUp": {
              "Status_Id": statusId,
              "Status_Name": statusName,
              "Next_FollowUp_date": followUpDate,
              "By_User_Id": _loginUserId,
              "By_User_Name": userName,
              "To_User_Id": toUserId,
              "To_User_Name": toUserName,
              "Branch_Id": branchId,
              "Branch_Name": branchName,
              "Department_Id": departmentId,
              "Department_Name": departmentName,
              "customFields":
                  customFieldLeadStatusKey.currentState?.getFieldValuesAsJson(),
              "Remark": message,
              // Add audio files if any
              // if (audioFiles != null && audioFiles.isNotEmpty)
              "Audio_Files": audioFiles,
            },
            "Customer_Id": custId
          });

      if (response != null && response.statusCode == 200) {
        Loader.stopLoader(context);
        final customerProvider =
            Provider.of<CustomerProvider>(context, listen: false);
        final leadDetailsProvider =
            Provider.of<LeadDetailsProvider>(context, listen: false);
        final data = response.data;
        log('Success');

        if (!AppStyles.isWebScreen(context)) {
          customerProvider.setLimit();
          _startLimit = 1;
          _endLimit = 10;
          customerProvider.customerData.clear();
          _leadData.clear();
        }

        await getSearchLeads(context);
        leadDetailsProvider.fetchLeadDetails(custId.toString(), context);
        leadDetailsProvider.fetchFollowUpHistory(custId.toString());
        await customerProvider.getSearchCustomers(context);

        messageController.clear();
        statusController.clear();
        assignToFollowUpController.clear();
        nextFollowUpDateController.clear();

        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        dashboardProvider.refreshDashboardData(context);

        notifyListeners();
        print(data);
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
    } finally {
      Loader.stopLoader(context);
    }
  }

  final Map<int, String> _customFieldValues = {};

  // Getter for custom field values
  Map<int, String> get customFieldValues => _customFieldValues;

  // Method to update custom field value
  void updateCustomFieldValue(int fieldId, String value) {
    _customFieldValues[fieldId] = value;
    notifyListeners();
  }

  // Method to get custom field value
  String getCustomFieldValue(int fieldId) {
    return _customFieldValues[fieldId] ?? '';
  }

  void clearCustomFieldValues() {
    _customFieldValues.clear();
    notifyListeners();
  }

  Future<void> getCustomFieldsByStatusId(BuildContext context,
      {required int statusId, required int leadId}) async {
    try {
      // Loader.showLoader(context);
      _isLoadingCustomFields = true;
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getCustomFieldByStatusId}?status_id=$statusId&lead_id=$leadId');

      if (response.statusCode == 200) {
        final data = response.data;
        print('dfooigwe9 $data');
        print('missing_mandatory_document_count check: $data');

        // Initialize to 0
        _missingMandatoryDocumentCount = 0;
        _customFieldList = [];

        if (data != null) {
          // Check if data is a Map (with missing_mandatory_document_count at root)
          if (data is Map<String, dynamic>) {
            // Try to get missing_mandatory_document_count from various possible keys
            _missingMandatoryDocumentCount = int.tryParse(
                    data['missing_mandatory_document_count']?.toString() ??
                        '0') ??
                0;

            // Also check alternative key names
            if (_missingMandatoryDocumentCount == 0) {
              _missingMandatoryDocumentCount = int.tryParse(
                      data['missingMandatoryDocumentCount']?.toString() ??
                          '0') ??
                  0;
            }

            // Check if custom_fields is in the map
            if (data['custom_fields'] != null &&
                (data['custom_fields'] as List).isNotEmpty) {
              _customFieldList = (data['custom_fields'] as List<dynamic>)
                  .map((e) => CustomFieldByStatusId.fromJson(e))
                  .toList();
            } else if (data['data'] != null &&
                (data['data'] is List) &&
                (data['data'] as List).isNotEmpty) {
              // Some APIs wrap the list in a 'data' field
              _customFieldList = (data['data'] as List<dynamic>)
                  .map((e) => CustomFieldByStatusId.fromJson(e))
                  .toList();
            } else if (data['data'] != null &&
                data['data'] is List &&
                (data['data'] as List).isEmpty) {
              _customFieldList = [];
            }
          } else if (data is List && data.isNotEmpty) {
            // If data is a List, parse it directly
            _customFieldList =
                data.map((e) => CustomFieldByStatusId.fromJson(e)).toList();
            // If the API returns a list, missing_mandatory_document_count might be in the first element
            _missingMandatoryDocumentCount = int.tryParse(
                    data[0]['missing_mandatory_document_count']?.toString() ??
                        '0') ??
                0;
          } else if (data is List && data.isEmpty) {
            _customFieldList = [];
            _missingMandatoryDocumentCount = 0;
          }
        }

        print(
            'Parsed missing_mandatory_document_count: $_missingMandatoryDocumentCount');
        // Loader.stopLoader(context);
      } else {
        // Loader.stopLoader(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      // Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoadingCustomFields = false;
      notifyListeners();
    }
  }

  Future<void> getCustomFieldsByEnquiryForId(BuildContext context,
      {required int enquiryForId, required int leadId}) async {
    try {
      _isLoadingEnquiryCustomFields = true;
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getCustomFieldByEnquiryForId}?enquiry_for_id=$enquiryForId&lead_id=$leadId');

      if (response.statusCode == 200) {
        _isLoadingEnquiryCustomFields = false;

        final data = response.data;
        print('Custom fields by enquiry for ID: $data');
        if (data != null && data.isNotEmpty) {
          _customFieldEnquiryFor = (data as List<dynamic>)
              .map((e) => CustomFieldByStatusId.fromJson(e))
              .toList();
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
    } finally {
      _isLoadingEnquiryCustomFields = false;
      notifyListeners();
    }
  }
  // saveFollowUp({
  //   required BuildContext context,
  //   required int statusId,
  //   required String statusName,
  //   required String followUpDate,
  //   required int toUserId,
  //   required String toUserName,
  //   required int followUp,
  //   required String message,
  //   required int custId,
  // }) async {
  //   try {
  //     if (followUpDate.isNotEmpty) {
  //       DateTime parsedDate;
  //       try {
  //         parsedDate = DateFormat('dd MMM yyyy').parse(followUpDate);
  //       } catch (e) {
  //         parsedDate = DateTime.parse(followUpDate);
  //       }
  //       followUpDate = DateFormat('yyyy-MM-dd').format(parsedDate);
  //     } else {
  //       followUpDate = '';
  //     }
  //     print('date$followUpDate');

  //     Loader.showLoader(context);
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String userId = preferences.getString('userId') ?? "";
  //     String userName = preferences.getString('userName') ?? "";

  //     final response = await HttpRequest.httpPostRequest(
  //         endPoint: HttpUrls.saveFollowUp,
  //         bodyData: {
  //           "FollowUp": {
  //             "Next_FollowUp_date": followUpDate,
  //             "Status_Id": statusId,
  //             "Status_Name": statusName,
  //             "By_User_Id": userId,
  //             "By_User_Name": userName,
  //             "To_User_Id": toUserId,
  //             "To_User_Name": toUserName,
  //             "Remark": message
  //           },
  //           "Customer_Id": custId
  //         });

  //     if (response!.statusCode == 200) {
  //       final data = response.data;
  //       log('Success');
  //       int index = _leadData.indexWhere((lead) => lead.customerId == custId);
  //       if (index != -1) {
  //         _leadData[index] = _leadData[index].copyWith(
  //           statusId: statusId.toString(),
  //           statusName: statusName,
  //           nextFollowUpDate: followUpDate,
  //           toUserId: toUserId.toString(),
  //           toUserName: toUserName,
  //         );
  //       }

  //       await getSearchLeads(context);
  //       final customerProvider =
  //           Provider.of<CustomerProvider>(context, listen: false);
  //       final leadDetailsProvider =
  //           Provider.of<LeadDetailsProvider>(context, listen: false);
  //       leadDetailsProvider.fetchLeadDetails(customerId.toString(), context);
  //       customerProvider.getSearchCustomers(context);
  //       messageController.clear();
  //       statusController.clear();
  //       assignToFollowUpController.clear();
  //       nextFollowUpDateController.clear();
  //       Navigator.pop(context);
  //       Loader.stopLoader(context);
  //       notifyListeners();
  //       print(data);
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Server Error')),
  //       );
  //       Loader.stopLoader(context);
  //     }
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('An error occurred')),
  //     );
  //     Loader.stopLoader(context);
  //   }
  // }

  Future<void> deleteLead(BuildContext context, String custId) async {
    bool loaderShown = false;
    try {
      if (context.mounted) {
        Loader.showLoader(context);
        loaderShown = true;
      }
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteLead}/$custId');

      if (response != null && response.statusCode == 200) {
        log('Lead deleted successfully');
        removeLeadFromList(custId);
        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        dashboardProvider.refreshDashboardData(context);
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      if (loaderShown) {
        Loader.stopLoader(context);
      }
    }
  }

  void removeLeadFromList(String id) {
    _leadData.removeWhere((lead) => lead.customerId.toString() == id);
    notifyListeners();
  }

  Future<void> convertLead(BuildContext context, String customerId) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.convertLead,
        bodyData: {'Customer_Id': int.tryParse(customerId) ?? 0},
      );
      Loader.stopLoader(context);

      if (response != null && response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Lead Converted Successfully");
        await getSearchLeads(context);
        final dashboardProvider =
            Provider.of<DashboardProvider>(context, listen: false);
        dashboardProvider.refreshDashboardData(context);
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.pop(context); // Close the details/dialog
        }
      } else {
        log('Failed to convert lead. Status: ${response?.statusCode}, Data: ${response?.data}');
        Fluttertoast.showToast(msg: "Failed to Convert Lead");
      }
    } catch (e) {
      Loader.stopLoader(context);
      log('Error converting lead: $e');
      Fluttertoast.showToast(msg: "An error occurred");
    }
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

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedEnquiryFor = null;
    _selectedEnquirySource = null;
    _selectedStatusIds = [0];
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    notifyListeners();
  }

  void setCutomerId(int customerId) {
    _customerId = customerId;
    print(_customerId);
  }

  Future<void> getLeadDropdowns(BuildContext context) async {
    try {
      final response =
          await HttpRequest.httpGetRequest(endPoint: HttpUrls.getLeadDropdowns);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map<String, dynamic>) {
          _leadDropdownData =
              SaveLeadDropdownModel.fromJson(data); // Assign directly
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

  Future<void> getSearchLeadReports(String search, String fromDate,
      String toDate, String status, BuildContext context) async {
    try {
      Loader.showLoader(context);
      print('Start$_startLimit');
      print('End$_endLimit');
      if (status.isEmpty || status == 'null') {
        status = '0';
      }
      String isDate = "0";
      String fromDate = formattedFromDate;
      String toDate = formattedToDate;
      if (fromDate.isEmpty && toDate.isEmpty) {
        isDate = "0";
        if (fromDate.isEmpty) {
          fromDate = "";
        }
        if (toDate.isEmpty) {
          toDate = "";
        }
      } else {
        isDate = "1";
      }
      // SharedPreferences preferences = await SharedPreferences.getInstance();

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchLeadReports}?lead_Name=$search&Is_Date=$isDate&Fromdate=$fromDate&Todate=$toDate&To_User_Id=$toUserId&Status_Id=${_selectedStatus ?? 0}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          Loader.stopLoader(context);

          // log(data.toString());

          _leadReportData = (data as List<dynamic>)
              .map((item) => LeadReportModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
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

  void alert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
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

  Future<void> saveBulkImport({
    required List data,
    required BuildContext context,
    required int statusId,
    required String statusName,
    required String followUpDate,
    required int toUserId,
    required String toUserName,
    required int followUp,
    required String message,
    required int custId,
    required int enquiryForId,
    required String enquiryForName,
    required int enquirySourceId,
    required String enquirySourceName,
  }) async {
    try {
      _isImporting = true;
      _importProgress = 0.0;
      _importStatusText = 'Preparing import...';
      notifyListeners();

      if (followUpDate.isNotEmpty) {
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd MMM yyyy').parse(followUpDate);
        } catch (e) {
          parsedDate = DateTime.parse(followUpDate);
        }
        followUpDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } else {
        followUpDate = '';
      }

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";
      String userName = preferences.getString('userName') ?? "";

      int totalRecords = data.length;
      int batchSize = 100;
      int processedCount = 0;

      for (int i = 0; i < totalRecords; i += batchSize) {
        int end = (i + batchSize < totalRecords) ? i + batchSize : totalRecords;
        List batch = data.sublist(i, end);

        bool batchSuccess = false;
        int retryCount = 0;
        int maxRetries = 3;

        while (!batchSuccess && retryCount < maxRetries) {
          try {
            _importStatusText = retryCount == 0
                ? 'Importing ${i + 1} to $end of $totalRecords...'
                : 'Retrying batch ${i + 1}-$end (Attempt ${retryCount + 1}/$maxRetries)...';
            notifyListeners();

            final response = await HttpRequest.httpPostRequest(
              endPoint: HttpUrls.bulkImport,
              bodyData: {
                "Lead_Details": batch,
                "By_User_Id": userId,
                "By_User_Name": userName,
                "Status": statusId,
                "Status_Name": statusName,
                "To_User": toUserId,
                "To_User_Name": toUserName,
                "Enquiry_Source": enquirySourceId,
                "Enquiry_Source_Name": enquirySourceName,
                "Next_FollowUp_Date": followUpDate,
                "Status_FollowUp": followUp,
                "Remark": '',
                "Enquiry_For_Id": enquiryForId,
                "Enquiry_For_Name": enquiryForName
              },
            );

            if (response != null && response.statusCode == 200) {
              processedCount += batch.length;
              _importProgress = processedCount / totalRecords;
              batchSuccess = true;
              notifyListeners();
            } else {
              retryCount++;
              if (retryCount >= maxRetries) {
                throw Exception(
                    "Batch import failed at record ${i + 1} after $maxRetries attempts.");
              }
              await Future.delayed(const Duration(seconds: 2));
            }
          } catch (e) {
            log('Batch Error (Attempt ${retryCount + 1}): $e');
            retryCount++;
            if (retryCount >= maxRetries) {
              rethrow; // Rethrow to be caught by the outer catch
            }
            _importStatusText = 'Connection reset. Retrying in 2 seconds...';
            notifyListeners();
            await Future.delayed(const Duration(seconds: 2));
          }
        }
      }

      _importStatusText = 'Import Complete!';
      _importProgress = 1.0;
      notifyListeners();

      Fluttertoast.showToast(
        msg: "Success! $totalRecords leads imported.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );

      final dashboardProvider =
          Provider.of<DashboardProvider>(context, listen: false);
      dashboardProvider.refreshDashboardData(context);
    } catch (e) {
      log('Import Exception: $e');
      _importStatusText = 'Import failed. Process stopped.';
      notifyListeners();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Import Error'),
          content: Text('The import stopped due to an error: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> downloadExcelFile() async {
    try {
      // Load the Excel file from assets
      final data = await rootBundle.load('assets/excel_format.xlsx');
      final bytes = data.buffer.asUint8List();
      String filePath = '';

      if (kIsWeb) {
        print('web-download');
        // Web: Download using a data URI
        final dataUri =
            'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,${base64Encode(bytes)}';
        await launchUrl(Uri.parse(dataUri),
            mode: LaunchMode.externalApplication);
      } else if (Platform.isAndroid) {
        // Get the downloads directory
        print('android-download');
        // Define the asset path and destination file name
        const assetPath = 'assets/excel_format.xlsx';
        const fileName = 'excel_format.xlsx';

        // Load the file from assets
        final byteData = await rootBundle.load(assetPath);

        // Get the local documents directory
        Directory? directory = await getDownloadsDirectory();
        if (directory == null) {
          print('Download directory null');
          directory = await getApplicationDocumentsDirectory();
        }

        final file = File('${directory.path}/$fileName');

        // Write the file to the local storage
        await file.writeAsBytes(byteData.buffer.asUint8List());

        print('File saved to: ${file.path}');
      } else if (Platform.isIOS) {
        print('ios-download');
        // Get documents directory for iOS
        final Directory docDir = await getApplicationDocumentsDirectory();
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        filePath = '${docDir.path}/excel_file_$timestamp.xlsx';

        // Write file for iOS
        final file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        throw Exception('Platform not supported');
      }
    } catch (e) {
      // Handle errors if any
      debugPrint('Error downloading file: $e');
    }
  }

  void extractCoordinates() {
    final uri = Uri.parse(mapLinkController.text.toString());
    final path = uri.path;
    final coordinatesPattern = RegExp(r'@([\d.-]+),([\d.-]+),');
    final match = coordinatesPattern.firstMatch(path);

    if (match != null) {
      String latitude = match.group(1)!; // Assign latitude
      String longitude = match.group(2)!; // Assign longitude
      latitudeController.text = latitude;
      longitudeController.text = longitude;
      print(latitude);
      print(longitude);
    } else {
      latitudeController.text = '';
      longitudeController.text = '';
      print('Coordinates not found');
    }
  }

  Future<void> useCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      // High precision settings
      LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        forceLocationManager: true,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      if (lat != 0.0 && lon != 0.0) {
        // Set latitude and longitude
        latitudeController.text = lat.toString();
        longitudeController.text = lon.toString();

        // Fetch location details using the coordinates
        await fetchLocationDetails(lat, lon);

        // Generate a Google Maps link
        mapLinkController.text = 'https://www.google.com/maps?q=$lat,$lon';
      }
    } catch (e) {
      print('Error getting current location: $e');
    }

    notifyListeners();
  }

  Future<void> fetchLocationDetails(double latitude, double longitude) async {
    try {
      // geocoding: ^2.1.0

      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        // Fill the text fields with the fetched data
        cityController.text = place.locality ?? '';
        districtController.text = place.subAdministrativeArea ?? '';
        pincodeController.text = place.postalCode ?? '';
        stateController.text = place.administrativeArea ?? '';

        // Update address field if it's empty
        if (addressController.text.isEmpty) {
          addressController.text = [
            place.name,
            place.subThoroughfare,
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country,
          ]
              .where(
                  (element) => element != null && element.toString().isNotEmpty)
              .join(', ');
        }
      }
    } catch (e) {
      print('Error fetching location details: $e');
    }

    notifyListeners();
  }

  Future<bool> checkLeadContactExists(String mobileNumber) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.checkLeadContactExists}?Phone_Number=$mobileNumber');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['Exists_Status'] == 1;
      }
      return false;
    } catch (e) {
      print('Error checking lead contact: $e');
      return false;
    }
  }
}
