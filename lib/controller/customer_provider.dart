import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class CustomerProvider extends ChangeNotifier {
  List<SearchLeadModel> _customerData = [];
  List<SearchLeadModel> _tempData = [];
  bool _isFilter = false;
  bool _isLoading = false;
  int? _selectedStatus;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  int? _selectedDateFilterIndex;
  int _customerId = 0;
  int _startLimit = 1;
  int _endLimit = 20;
  final int _limit = 10;
  int _totalCount = 0;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 1;

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

      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
      } else {
        isDate = "1";
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=0&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<SearchLeadModel> nextData = (data as List<dynamic>)
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();

          _totalCount = nextData.last.customerId;
          nextData.removeLast();

          if (nextData.isEmpty) {
            hasMoreData = false;
          } else {
            _customerData.addAll(nextData);
            currentPage++;
            hasMoreData = nextData.length >= 20;
          }
        }
      } else {
        hasMoreData = false;
      }
    } catch (e) {
      log("Error loading more customers: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setSearchCriteria(
      String search, String fromDate, String toDate, String status) {
    _customerData.clear();
    _search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _status = status;
    _startLimit = 1;
    _endLimit = 20;
    currentPage = 1;
    hasMoreData = true;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    selectDateFilterOption(null);
    removeStatus();
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

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
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

  getSearchCustomers(BuildContext context) async {
    try {
      // Loader.showLoader(context);
      // _isLoading = true;
      if (_status.isEmpty || _status == 'null') {
        _status = '0';
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

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=0&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          _tempData = (data as List<dynamic>)
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();

          _totalCount = _tempData.last.tp > 0 ? _tempData.last.tp : _tempData.last.customerId;
          print("Last customer's ID: $_totalCount");

          _tempData.removeLast();

          if (AppStyles.isWebScreen(navigatorKey.currentState!.context)) {
            _customerData = List.from(_tempData);
          } else {
            if (_search.isEmpty &&
                _fromDateS.isEmpty &&
                _toDateS.isEmpty &&
                _status == "0") {
              for (var newLead in _tempData) {
                int index = _customerData.indexWhere(
                    (lead) => lead.customerId == newLead.customerId);

                if (index != -1) {
                  _customerData[index] =
                      SearchLeadModel.fromJson(newLead.toJson());
                } else {
                  _customerData.add(SearchLeadModel.fromJson(newLead.toJson()));
                }
              }

              _customerData = List.from(_customerData);
              notifyListeners();
              log("Updated Lead Data: ${_customerData.map((e) => e.toJson()).toList()}");
              // Create a set of existing customer IDs
            } else {
              _customerData.clear();
              _customerData = List.from(_tempData);
            }
          }

          // Loader.stopLoader(context);
          _isLoading = false;
          hasMoreData = _tempData.length >= 20;
          notifyListeners();
        }
      } else {
        // Loader.stopLoader(context);
        _isLoading = false;
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

//no context only for back in customer detail
  getSearchCustomersNoContext() async {
    try {
      if (_status.isEmpty || _status == 'null') {
        _status = '0';
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

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchCustomer}?Customer_Name=$_search&Is_Date=$isDate&Fromdate=$_fromDateS&Todate=$_toDateS&To_User_Id=0&Status_Id=$_status&Page_Index1=$_startLimit&Page_Index2=$_endLimit');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());

          // _customerData = (data as List<dynamic>)
          //     .map((item) => SearchLeadModel.fromJson(item))
          //     .toList();
          // notifyListeners();
          if (data != null) {
            // log(data.toString());

            _tempData = (data as List<dynamic>)
                .map((item) => SearchLeadModel.fromJson(item))
                .toList();

            // Remove the last item from _tempData and print its customerId

            _totalCount = _tempData.last.tp > 0 ? _tempData.last.tp : _tempData.last.customerId;
            print("Last customer's ID: $_totalCount");

            // Remove the last item from _tempData
            _tempData.removeLast();

            // Pass the remaining items in _tempData to _leadData
            _customerData = List.from(_tempData);

            notifyListeners();
          }
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
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
