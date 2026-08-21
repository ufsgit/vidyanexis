import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/models/mandatory_status_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProvider extends ChangeNotifier {
  List<SearchLeadModel> _customerData = [];
  bool _isFilter = false;
  bool _isLoading = false;
  List<int> _selectedStatusIds = [0];
  int? _selectedStatus = 0;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  int? _selectedDateFilterIndex;

  DateTime? _amcFromDate;
  DateTime? _amcToDate;
  String _formattedAmcFromDate = '';
  String _formattedAmcToDate = '';
  int? _selectedAmcDateFilterIndex;

  DateTime? _wcFromDate;
  DateTime? _wcToDate;
  String _formattedWcFromDate = '';
  String _formattedWcToDate = '';
  int? _selectedWcDateFilterIndex;

  int? _selectedUser;
  int? _selectedEnquiryFor;
  int? _selectedEnquirySource;
  int? _selectedBranch;
  List<int> _selectedUserIds = [0];
  List<int> _selectedEnquiryForIds = [0];
  List<int> _selectedEnquirySourceIds = [0];
  List<int> _selectedBranchIds = [0];
  int _customerId = 0;
  int _startLimit = 1;
  int _endLimit = 20;
  final int _limit = 20;
  int _totalCount = 0;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  List<MandatoryStatusModel> _statusData = [];
  List<MandatoryStatusModel> get statusData => _statusData;

  int? get selectedUser => _selectedUser;
  int? get selectedEnquiryFor => _selectedEnquiryFor;
  int? get selectedEnquirySource => _selectedEnquirySource;
  int? get selectedBranch => _selectedBranch;
  List<int> get selectedUserIds => _selectedUserIds;
  List<int> get selectedEnquiryForIds => _selectedEnquiryForIds;
  List<int> get selectedEnquirySourceIds => _selectedEnquirySourceIds;
  List<int> get selectedBranchIds => _selectedBranchIds;

  int get startLimit => _startLimit;
  int get endLimit => _endLimit;
  int get totalCount => _totalCount;
  int get customerId => _customerId;
  String get formattedFromDate => _formattedFromDate;
  bool get isLoading => _isLoading;

  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  DateTime? get amcFromDate => _amcFromDate;
  DateTime? get amcToDate => _amcToDate;
  String get formattedAmcFromDate => _formattedAmcFromDate;
  String get formattedAmcToDate => _formattedAmcToDate;
  int? get selectedAmcDateFilterIndex => _selectedAmcDateFilterIndex;

  DateTime? get wcFromDate => _wcFromDate;
  DateTime? get wcToDate => _wcToDate;
  String get formattedWcFromDate => _formattedWcFromDate;
  String get formattedWcToDate => _formattedWcToDate;
  int? get selectedWcDateFilterIndex => _selectedWcDateFilterIndex;

  List<int> get selectedStatusIds => _selectedStatusIds;
  int? get selectedStatus => _selectedStatus;
  bool get isFilter => _isFilter;
  List<SearchLeadModel> get customerData => _customerData;

  String _search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _amcFromDateS = '';
  String _amcToDateS = '';
  String _wcFromDateS = '';
  String _wcToDateS = '';
  String _status = '';

  String get search => _search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get amcFromDateS => _amcFromDateS;
  String get amcToDateS => _amcToDateS;
  String get wcFromDateS => _wcFromDateS;
  String get wcToDateS => _wcToDateS;
  String get status => _status;

  String _entryType = 'myown';
  String get entryType => _entryType;
  void setEntryType(String value) {
    _entryType = value;
    notifyListeners();
  }

  int? expandedIndex;

  int _selectedSortOption =
      0; // 0: Default, 1: ID, 2: Creation Date, 3: Followup Date
  int get selectedSortOption => _selectedSortOption;

  String _sortOrder = 'DESC'; // ASC or DESC
  String get sortOrder => _sortOrder;

  int _currentSortOptionIndex = 0;
  int get currentSortOptionIndex => _currentSortOptionIndex;

  void setSortOption(int option, BuildContext context) {
    _currentSortOptionIndex = option;
    switch (option) {
      case 0:
        _selectedSortOption = 0;
        _sortOrder = 'DESC';
        break;
      case 1:
        _selectedSortOption = 1;
        _sortOrder = 'DESC';
        break;
      case 2:
        _selectedSortOption = 1;
        _sortOrder = 'ASC';
        break;
      case 3:
        _selectedSortOption = 2;
        _sortOrder = 'DESC';
        break;
      case 4:
        _selectedSortOption = 2;
        _sortOrder = 'ASC';
        break;
      case 5:
        _selectedSortOption = 3;
        _sortOrder = 'DESC';
        break;
      case 6:
        _selectedSortOption = 3;
        _sortOrder = 'ASC';
        break;
      case 7:
        _selectedSortOption = 4;
        _sortOrder = 'ASC';
        break;
      case 8:
        _selectedSortOption = 4;
        _sortOrder = 'DESC';
        break;
      case 9:
        _selectedSortOption = 2;
        _sortOrder = 'DESC';
        break;
    }
    currentPage = 1;
    _startLimit = 1;
    _endLimit = 20;
    _customerData.clear();
    notifyListeners();
    getSearchCustomers(context);
  }

  void toggleSortOrder(BuildContext context) {
    _sortOrder = _sortOrder == 'ASC' ? 'DESC' : 'ASC';
    notifyListeners();
    getSearchCustomers(context);
  }

  ScrollController scrollController = ScrollController();

//api for dropdowns

//.......................................................................

//........................................................................
  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = null;
    } else {
      expandedIndex = index;
    }
    notifyListeners();
  }

  void scrollListener(BuildContext context) {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        loadMoreCustomers(context);
      }
    }
  }

  Future<void> loadMoreCustomers(BuildContext context) async {
    if (isLoadingMore || !hasMoreData || _endLimit >= _totalCount) {
      if (_endLimit >= _totalCount) {
        hasMoreData = false;
        notifyListeners();
      }
      return;
    }

    isLoadingMore = true;
    _status = _selectedStatusIds.join(',');
    notifyListeners();

    try {
      _startLimit += 20;
      _endLimit += 20;

      if (_status.isEmpty || _status == 'null') {
        _status = '0';
      }

      String isDate =
          (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";
      String isAmcDate =
          (_amcFromDateS.isNotEmpty || _amcToDateS.isNotEmpty) ? "1" : "0";
      String isWcDate =
          (_wcFromDateS.isNotEmpty || _wcToDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');
      String branchIds = _selectedBranchIds.join(',');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userIdPref = preferences.getString('userId') ?? "0";
      int loginUserId = int.parse(userIdPref);

      int apiSortOption = _selectedSortOption == 4 ? 0 : _selectedSortOption;

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&Is_AMC_Date_=$isAmcDate&AMC_Fromdate_=$_amcFromDateS&AMC_Todate_=$_amcToDateS&Is_Work_Completion_Date_=$isWcDate&Work_Completion_Fromdate_=$_wcFromDateS&Work_Completion_Todate_=$_wcToDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&Branch_Id_=$branchIds&User_Details_Id_=$loginUserId&Lead_Id_=0&Order_By_=$apiSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data is List) {
          List<SearchLeadModel> allItems =
              data.map((item) => SearchLeadModel.fromJson(item)).toList();

          // Extract real data and metadata
          List<SearchLeadModel> newItems =
              allItems.where((item) => item.tp == 1).toList();

          if (newItems.isEmpty) {
            hasMoreData = false;
          } else {
            _customerData.addAll(newItems);
            fetchAmcDatesForCustomers(newItems);

            if (_selectedSortOption == 4) {
              if (_sortOrder == 'ASC') {
                _customerData.sort((a, b) => a.customerName
                    .toLowerCase()
                    .compareTo(b.customerName.toLowerCase()));
              } else {
                _customerData.sort((a, b) => b.customerName
                    .toLowerCase()
                    .compareTo(a.customerName.toLowerCase()));
              }
            } else if (_selectedSortOption == 2 && _sortOrder == 'DESC') {
              _customerData.sort((a, b) {
                final dateA = a.parsedCreationDate;
                final dateB = b.parsedCreationDate;
                if (dateA == null && dateB == null) return 0;
                if (dateA == null) return 1;
                if (dateB == null) return -1;
                return dateB.compareTo(dateA);
              });
            }

            // Find metadata safely
            int metadataIndex = allItems.indexWhere((item) => item.tp == 2);
            if (metadataIndex != -1) {
              _totalCount = allItems[metadataIndex].customerId;
            }

            if (_customerData.length >= _totalCount) {
              hasMoreData = false;
            }
          }
        }
      }
    } catch (e) {
      log('Error loading more customers: $e');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearchCriteria(String search, String fromDate, String toDate,
      {String? amcFromDate,
      String? amcToDate,
      String? wcFromDate,
      String? wcToDate}) {
    _customerData.clear();
    _search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    if (amcFromDate != null) _amcFromDateS = amcFromDate;
    if (amcToDate != null) _amcToDateS = amcToDate;
    if (wcFromDate != null) _wcFromDateS = wcFromDate;
    if (wcToDate != null) _wcToDateS = wcToDate;
    _status = _selectedStatusIds.join(',');
    _startLimit = 1;
    _endLimit = 20;
    currentPage = 1;
    hasMoreData = true;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    selectDateFilterOption(null);
    selectAmcDateFilterOption(null);
    selectWcDateFilterOption(null);
    _selectedStatusIds = [0];
    _selectedStatus = 0;
    _selectedUser = null;
    _selectedEnquiryFor = null;
    _selectedEnquirySource = null;
    _selectedBranch = null;
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    _selectedBranchIds = [0];
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
    _selectedBranch = null;
    _selectedStatusIds = [0];
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    _selectedBranchIds = [0];
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _fromDateS = '';
    _toDateS = '';
    _selectedDateFilterIndex = null;
    _amcFromDate = null;
    _amcToDate = null;
    _formattedAmcFromDate = '';
    _formattedAmcToDate = '';
    _amcFromDateS = '';
    _amcToDateS = '';
    _selectedAmcDateFilterIndex = null;
    _wcFromDate = null;
    _wcToDate = null;
    _formattedWcFromDate = '';
    _formattedWcToDate = '';
    _wcFromDateS = '';
    _wcToDateS = '';
    _selectedWcDateFilterIndex = null;
    _search = '';
    _status = '0';
    _entryType = 'myown';
    _isFilter = false;
    notifyListeners();
  }

  void resetExpansion() {
    expandedIndex = null;
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

  void setUserFilterStatus(int? value) {
    _selectedUser = value;
    _selectedUserIds = [value ?? 0];
    _isFilter = true;
    notifyListeners();
  }

  void setEnquiryForFilter(int? value) {
    _selectedEnquiryFor = value;
    _selectedEnquiryForIds = [value ?? 0];
    _isFilter = true;
    notifyListeners();
  }

  void setEnquirySourceFilter(int? value) {
    _selectedEnquirySource = value;
    _selectedEnquirySourceIds = [value ?? 0];
    _isFilter = true;
    notifyListeners();
  }

  void setBranchFilter(int? value) {
    _selectedBranch = value;
    _selectedBranchIds = [value ?? 0];
    _isFilter = true;
    notifyListeners();
  }

  void setLimit() {
    _startLimit = 1;
    _endLimit = 20;
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> fetchNextPage(BuildContext context) async {
    if (_endLimit < _totalCount) {
      if (AppStyles.isWebScreen(context)) {
        _startLimit += _limit;
        _endLimit += _limit;
        await getSearchCustomers(context, isSilent: true);
      } else {
        loadMoreCustomers(context);
      }
    }
    notifyListeners();
  }

  // Fetch previous page data
  Future<void> fetchPreviousPage(BuildContext context) async {
    if (_startLimit > 1) {
      _startLimit -= _limit;
      _endLimit -= _limit;
      await getSearchCustomers(context, isSilent: true);
    }
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
      _fromDateS = '';
      _toDateS = '';
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

  // --- AMC Date Filter Methods ---
  void selectAmcDateFilterOption(int? index) {
    if (index == null) {
      _selectedAmcDateFilterIndex = null;
      _amcFromDate = null;
      _amcToDate = null;
      _formattedAmcFromDate = '';
      _formattedAmcToDate = '';
      _amcFromDateS = '';
      _amcToDateS = '';
    } else {
      _selectedAmcDateFilterIndex = index;
      formatAmcDate();
    }
    notifyListeners();
  }

  void setAmcDateFilter(String title) {
    final now = DateTime.now();

    switch (title) {
      case 'Yesterday':
        _amcFromDate = now.subtract(const Duration(days: 1));
        _amcToDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        _amcFromDate = now;
        _amcToDate = now;
        break;
      case 'Tomorrow':
        _amcFromDate = now.add(const Duration(days: 1));
        _amcToDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _amcFromDate = now.subtract(Duration(days: now.weekday - 1));
        _amcToDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _amcFromDate = DateTime(now.year, now.month, 1);
        _amcToDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        _amcFromDate = null;
        _amcToDate = null;
        break;
    }

    notifyListeners();
  }

  void setAmcFromDate(DateTime date) {
    _amcFromDate = date;
    _selectedAmcDateFilterIndex = -1;
    formatAmcDate();
    notifyListeners();
  }

  void setAmcToDate(DateTime date) {
    _amcToDate = date;
    _selectedAmcDateFilterIndex = -1;
    formatAmcDate();
    notifyListeners();
  }

  void formatAmcDate() {
    if (_amcFromDate != null) {
      _formattedAmcFromDate = DateFormat('yyyy-MM-dd').format(_amcFromDate!);
    } else {
      _formattedAmcFromDate = '';
    }

    if (_amcToDate != null) {
      _formattedAmcToDate = DateFormat('yyyy-MM-dd').format(_amcToDate!);
    } else {
      _formattedAmcToDate = '';
    }
    _amcFromDateS = _formattedAmcFromDate;
    _amcToDateS = _formattedAmcToDate;
  }

  Future<void> selectAmcDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_amcFromDate ?? DateTime.now())
          : (_amcToDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setAmcFromDate(pickedDate);
      } else {
        setAmcToDate(pickedDate);
      }
    }
    notifyListeners();
  }

  // --- Work Completion Date Filter Methods ---
  void selectWcDateFilterOption(int? index) {
    if (index == null) {
      _selectedWcDateFilterIndex = null;
      _wcFromDate = null;
      _wcToDate = null;
      _formattedWcFromDate = '';
      _formattedWcToDate = '';
      _wcFromDateS = '';
      _wcToDateS = '';
    } else {
      _selectedWcDateFilterIndex = index;
      formatWcDate();
    }
    notifyListeners();
  }

  void setWcDateFilter(String title) {
    final now = DateTime.now();

    switch (title) {
      case 'Yesterday':
        _wcFromDate = now.subtract(const Duration(days: 1));
        _wcToDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        _wcFromDate = now;
        _wcToDate = now;
        break;
      case 'Tomorrow':
        _wcFromDate = now.add(const Duration(days: 1));
        _wcToDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _wcFromDate = now.subtract(Duration(days: now.weekday - 1));
        _wcToDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _wcFromDate = DateTime(now.year, now.month, 1);
        _wcToDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        _wcFromDate = null;
        _wcToDate = null;
        break;
    }

    notifyListeners();
  }

  void setWcFromDate(DateTime date) {
    _wcFromDate = date;
    _selectedWcDateFilterIndex = -1;
    formatWcDate();
    notifyListeners();
  }

  void setWcToDate(DateTime date) {
    _wcToDate = date;
    _selectedWcDateFilterIndex = -1;
    formatWcDate();
    notifyListeners();
  }

  void formatWcDate() {
    if (_wcFromDate != null) {
      _formattedWcFromDate = DateFormat('yyyy-MM-dd').format(_wcFromDate!);
    } else {
      _formattedWcFromDate = '';
    }

    if (_wcToDate != null) {
      _formattedWcToDate = DateFormat('yyyy-MM-dd').format(_wcToDate!);
    } else {
      _formattedWcToDate = '';
    }
    _wcFromDateS = _formattedWcFromDate;
    _wcToDateS = _formattedWcToDate;
  }

  Future<void> selectWcDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_wcFromDate ?? DateTime.now())
          : (_wcToDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setWcFromDate(pickedDate);
      } else {
        setWcToDate(pickedDate);
      }
    }
    notifyListeners();
  }

  Future<void> getSearchCustomers(BuildContext context,
      {bool isSilent = false}) async {
    try {
      if (!isSilent) {
        _isLoading = true;
        notifyListeners();
      }
      _status = _selectedStatusIds.join(',');

      // Fetch statuses if missing, don't block
      if (_statusData.isEmpty) {
        HttpRequest.httpGetRequest(
                endPoint:
                    '${HttpUrls.searchStatus}?status_Name=&Page_Index=1&PageSize=1000&ViewIn_Id=2')
            .then((response) {
          if (response.statusCode == 200 && response.data is List) {
            _statusData = response.data
                .map((item) => MandatoryStatusModel.fromJson(item))
                .toList();
            notifyListeners();
          }
        }).catchError((e) => log("Error fetching statuses: $e"));
      }

      if (_status.isEmpty || _status == 'null') {
        _status = '0';
      }

      String isDate =
          (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";
      String isAmcDate =
          (_amcFromDateS.isNotEmpty || _amcToDateS.isNotEmpty) ? "1" : "0";
      String isWcDate =
          (_wcFromDateS.isNotEmpty || _wcToDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');
      String branchIds = _selectedBranchIds.join(',');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userIdPref = preferences.getString('userId') ?? "0";
      int loginUserId = int.parse(userIdPref);

      if (!isSilent) {
        Loader.showLoader(context);
      }

      int apiSortOption = _selectedSortOption == 4 ? 0 : _selectedSortOption;

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&Is_AMC_Date_=$isAmcDate&AMC_Fromdate_=$_amcFromDateS&AMC_Todate_=$_amcToDateS&Is_Work_Completion_Date_=$isWcDate&Work_Completion_Fromdate_=$_wcFromDateS&Work_Completion_Todate_=$_wcToDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&Branch_Id_=$branchIds&User_Details_Id_=$loginUserId&Lead_Id_=0&Order_By_=$apiSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data is List) {
          List<SearchLeadModel> allItems =
              data.map((item) => SearchLeadModel.fromJson(item)).toList();
          _customerData = allItems.where((item) => item.tp == 1).toList();

          if (_selectedSortOption == 4) {
            if (_sortOrder == 'ASC') {
              _customerData.sort((a, b) => a.customerName
                  .toLowerCase()
                  .compareTo(b.customerName.toLowerCase()));
            } else {
              _customerData.sort((a, b) => b.customerName
                  .toLowerCase()
                  .compareTo(a.customerName.toLowerCase()));
            }
          }

          int metadataIndex = allItems.indexWhere((item) => item.tp == 2);
          if (metadataIndex != -1) {
            _totalCount = allItems[metadataIndex].customerId;
          }

          hasMoreData = _customerData.length < _totalCount;
          fetchAmcDatesForCustomers(_customerData);
        } else {
          log('API Error: Data is not a list or is null');
        }
      } else {
        log('API Error: Status code ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      log('Exception in getSearchCustomers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      if (!isSilent) {
        Loader.stopLoader(context);
      }
    }
  }

  //no context only for back in customer detail
  Future<void> getSearchCustomersNoContext() async {
    _startLimit = 1;
    _endLimit = 20;

    try {
      _isLoading = true;
      if (_status.isEmpty || _status == 'null') {
        _status = '0';
      }

      String isDate =
          (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";
      String isAmcDate =
          (_amcFromDateS.isNotEmpty || _amcToDateS.isNotEmpty) ? "1" : "0";
      String isWcDate =
          (_wcFromDateS.isNotEmpty || _wcToDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');
      String branchIds = _selectedBranchIds.join(',');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userIdPref = preferences.getString('userId') ?? "0";
      int loginUserId = int.parse(userIdPref);

      int apiSortOption = _selectedSortOption == 4 ? 0 : _selectedSortOption;

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&Is_AMC_Date_=$isAmcDate&AMC_Fromdate_=$_amcFromDateS&AMC_Todate_=$_amcToDateS&Is_Work_Completion_Date_=$isWcDate&Work_Completion_Fromdate_=$_wcFromDateS&Work_Completion_Todate_=$_wcToDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&Branch_Id_=$branchIds&User_Details_Id_=$loginUserId&Lead_Id_=0&Order_By_=$apiSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data is List) {
          List<SearchLeadModel> allItems =
              data.map((item) => SearchLeadModel.fromJson(item)).toList();

          _customerData = allItems.where((item) => item.tp == 1).toList();

          int metadataIndex = allItems.indexWhere((item) => item.tp == 2);
          if (metadataIndex != -1) {
            _totalCount = allItems[metadataIndex].customerId;
          }

          hasMoreData = _customerData.length < _totalCount;
          fetchAmcDatesForCustomers(_customerData);
        }
      }
    } catch (e) {
      log('Exception in getSearchCustomersNoContext: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _fromDateS = _formattedFromDate;
    _toDateS = _formattedToDate;
  }

  void removeStatus() {
    _selectedStatusIds = [0];
    _selectedStatus = 0;
    _selectedUser = null;
    _selectedEnquiryFor = null;
    _selectedEnquirySource = null;
    _selectedBranch = null;
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    _selectedBranchIds = [0];
    notifyListeners();
  }

  void setCutomerId(int customerId) {
    _customerId = customerId;
    print(_customerId);
  }

  void removeCustomerFromList(String id) {
    _customerData
        .removeWhere((customer) => customer.customerId.toString() == id);
    notifyListeners();
  }

  final Map<int, String> _customerAmcDateCache = {};

  Future<void> fetchAmcDatesForCustomers(
      List<SearchLeadModel> customers) async {
    final uncachedCustomerIds = customers
        .where((c) =>
            (c.amcDate.isEmpty || c.amcDate == '-') &&
            c.customerId > 0 &&
            !_customerAmcDateCache.containsKey(c.customerId))
        .map((c) => c.customerId)
        .toSet()
        .toList();

    if (uncachedCustomerIds.isEmpty) {
      _applyCachedAmcDates();
      return;
    }

    await Future.wait(uncachedCustomerIds.map((cid) async {
      try {
        final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getAmc}?Customer_Id=$cid&AMC_Status_Id=0',
        );
        if (response.statusCode == 200 &&
            response.data != null &&
            response.data is List) {
          final list = response.data as List;
          if (list.isNotEmpty) {
            String latestToDate = '';
            DateTime? latestDt;
            for (var amcItem in list) {
              if (amcItem is Map) {
                final toDateStr = (amcItem['To_Date'] ??
                            amcItem['to_date'] ??
                            amcItem['AMC_To_Date'] ??
                            amcItem['Date'])
                        ?.toString() ??
                    '';
                if (toDateStr.isNotEmpty) {
                  final dt = DateTime.tryParse(toDateStr);
                  if (dt != null) {
                    if (latestDt == null || dt.isAfter(latestDt)) {
                      latestDt = dt;
                      latestToDate = toDateStr;
                    }
                  } else if (latestToDate.isEmpty) {
                    latestToDate = toDateStr;
                  }
                }
              }
            }
            _customerAmcDateCache[cid] =
                latestToDate.isNotEmpty ? latestToDate : '-';
          } else {
            _customerAmcDateCache[cid] = '-';
          }
        } else {
          _customerAmcDateCache[cid] = '-';
        }
      } catch (e) {
        _customerAmcDateCache[cid] = '-';
      }
    }));

    _applyCachedAmcDates();
  }

  void _applyCachedAmcDates() {
    bool hasUpdates = false;
    for (int i = 0; i < _customerData.length; i++) {
      final cust = _customerData[i];
      if ((cust.amcDate.isEmpty || cust.amcDate == '-') &&
          _customerAmcDateCache.containsKey(cust.customerId)) {
        final cachedDate = _customerAmcDateCache[cust.customerId]!;
        if (cachedDate.isNotEmpty && cachedDate != '-') {
          _customerData[i] = cust.copyWith(amcDate: cachedDate);
          hasUpdates = true;
        }
      }
    }
    if (hasUpdates) {
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(BuildContext context, String custId) async {
    try {
      final response = await HttpRequest.httpDeleteRequest(
          endPoint: '${HttpUrls.deleteCustomer}/$custId');

      if (response != null && response.statusCode == 200) {
        log('Customer deleted successfully');
        removeCustomerFromList(custId);
        await getSearchCustomers(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete customer')),
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
