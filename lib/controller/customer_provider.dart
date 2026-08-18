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
  List<int> get selectedStatusIds => _selectedStatusIds;
  int? get selectedStatus => _selectedStatus;
  bool get isFilter => _isFilter;
  List<SearchLeadModel> get customerData => _customerData;

  String _search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _status = '';

  String get search => _search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
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

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userIdPref = preferences.getString('userId') ?? "0";
      int loginUserId = int.parse(userIdPref);

      int apiSortOption = _selectedSortOption == 4 ? 0 : _selectedSortOption;

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&User_Details_Id_=$loginUserId&Lead_Id_=0&Order_By_=$apiSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

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

  void setSearchCriteria(String search, String fromDate, String toDate) {
    _customerData.clear();
    _search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
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
    _search = '';
    _status = '0';
    _entryType = 'myown';
    _selectedDateFilterIndex = null;
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
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&Branch_Id_=$branchIds&User_Details_Id_=$loginUserId&Order_By_=$apiSortOption&Order_Type_=$_sortOrder&Entry_Type_=$_entryType');

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

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');
      String branchIds = _selectedBranchIds.join(',');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userIdPref = preferences.getString('userId') ?? "0";
      int loginUserId = int.parse(userIdPref);

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name_=$_search&Is_Date_=$isDate&Fromdate_=$_fromDateS&Todate_=$_toDateS&To_User_Id_=$toUserId&Login_User_Id_=$loginUserId&Status_Id_=$_status&Page_Index1_=$_startLimit&Page_Index2_=$_endLimit&Enquiry_For_Id_=$enquiryForId&Enquiry_Source_Id_=$enquirySourceId&Branch_Id_=$branchIds&User_Details_Id_=$loginUserId&Lead_Id_=0&Entry_Type_=$_entryType');

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
