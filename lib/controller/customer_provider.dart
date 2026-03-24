import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/models/mandatory_status_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

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
  List<int> _selectedUserIds = [0];
  List<int> _selectedEnquiryForIds = [0];
  List<int> _selectedEnquirySourceIds = [0];
  int _customerId = 0;
  int _startLimit = 1;
  int _endLimit = 20;
  final int _limit = 10;
  int _totalCount = 0;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;
  List<MandatoryStatusModel> _statusData = [];
  List<MandatoryStatusModel> get statusData => _statusData;

  int? get selectedUser => _selectedUser;
  int? get selectedEnquiryFor => _selectedEnquiryFor;
  int? get selectedEnquirySource => _selectedEnquirySource;
  List<int> get selectedUserIds => _selectedUserIds;
  List<int> get selectedEnquiryForIds => _selectedEnquiryForIds;
  List<int> get selectedEnquirySourceIds => _selectedEnquirySourceIds;

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
  int? expandedIndex;
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
            scrollController.position.maxScrollExtent - 100) {
      if (!isLoadingMore && hasMoreData && _endLimit < _totalCount) {
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
    notifyListeners();

    try {
      _startLimit += 20;
      _endLimit += 20;

      if (_status.isEmpty || _status == 'null') {
        _status = '0';
      }

      String isDate = (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=$toUserId&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit&Enquiry_For_Id=$enquiryForId&Enquiry_Source_Id=$enquirySourceId');

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
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
    notifyListeners();
  }

  void setFilter(bool filter) {
    _isFilter = filter;
    notifyListeners(); // Notify listeners about the change
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
    _selectedStatus = _selectedStatusIds.isNotEmpty ? _selectedStatusIds.first : null;
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

  void setLimit() {
    _startLimit = 1;
    _endLimit = 20;
    notifyListeners(); // Notify listeners about the change
  }

  Future<void> fetchNextPage(BuildContext context) async {
    if (_endLimit < _totalCount) {
      loadMoreCustomers(context);
    }
    notifyListeners();
  }

  // Fetch previous page data
  Future<void> fetchPreviousPage(BuildContext context) async {
    if (_startLimit > 0) {
      _startLimit -= 20;
      _endLimit -= 20;
      getSearchCustomers(context);
    }
    // print('Start' + _startLimit.toString());
    // print('End' + _endLimit.toString());
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

  Future<void> getSearchCustomers(BuildContext context) async {
    _startLimit = 1;
    _endLimit = 20;

    try {
      _isLoading = true;
      // notifyListeners(); // Could clear here but replacing is smoother in UI

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

      String isDate = (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');

      Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=$toUserId&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit&Enquiry_For_Id=$enquiryForId&Enquiry_Source_Id=$enquirySourceId');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data != null && data is List) {
          List<SearchLeadModel> allItems =
              data.map((item) => SearchLeadModel.fromJson(item)).toList();

          // Correct metadata handling using tp field
          _customerData = allItems.where((item) => item.tp == 1).toList();

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
      Loader.stopLoader(context);
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

      String isDate = (_fromDateS.isNotEmpty || _toDateS.isNotEmpty) ? "1" : "0";

      String toUserId = _selectedUserIds.join(',');
      String enquiryForId = _selectedEnquiryForIds.join(',');
      String enquirySourceId = _selectedEnquirySourceIds.join(',');

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=$toUserId&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit&Enquiry_For_Id=$enquiryForId&Enquiry_Source_Id=$enquirySourceId');

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
    _selectedUserIds = [0];
    _selectedEnquiryForIds = [0];
    _selectedEnquirySourceIds = [0];
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
