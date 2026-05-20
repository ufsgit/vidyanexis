import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/sales_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class SalesReportProvider with ChangeNotifier {
  List<SalesReportModel> _salesReport = [];
  List<SalesReportModel> get salesReport => _salesReport;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  // Filters
  String _search = '';
  String _invoiceNo = '';
  String _itemName = '';
  String _enquiryFor = '';

  DateTime? _fromDate;
  DateTime? _toDate;
  int? _selectedDateFilterIndex;

  String get search => _search;
  String get invoiceNo => _invoiceNo;
  String get itemName => _itemName;
  String get enquiryFor => _enquiryFor;

  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  String get formattedFromDate =>
      _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
  String get formattedToDate =>
      _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setSearchCriteria({
    String? search,
    String? invoiceNo,
    String? itemName,
    String? enquiryFor,
    String? fromDate,
    String? toDate,
  }) {
    if (search != null) _search = search;
    if (invoiceNo != null) _invoiceNo = invoiceNo;
    if (itemName != null) _itemName = itemName;
    if (enquiryFor != null) _enquiryFor = enquiryFor;
    if (fromDate != null)
      _fromDate = fromDate.isNotEmpty ? DateTime.tryParse(fromDate) : null;
    if (toDate != null)
      _toDate = toDate.isNotEmpty ? DateTime.tryParse(toDate) : null;
    notifyListeners();
  }

  void setDateFilter(String option) {
    DateTime now = DateTime.now();
    switch (option) {
      case 'Today':
        _fromDate = now;
        _toDate = now;
        break;
      case 'Yesterday':
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 'Tomorrow':
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now;
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = now;
        break;
      default:
        _fromDate = null;
        _toDate = null;
    }
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    _selectedDateFilterIndex = index;
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _fromDate : _toDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
      _selectedDateFilterIndex = null;
      notifyListeners();
    }
  }

  Future<void> getSalesReport(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: "${HttpUrls.getSalesReport}?"
              "From_Date_=$formattedFromDate&"
              "To_Date_=$formattedToDate&"
              "Invoice_No_=$_invoiceNo&"
              "Item_Id_=${_itemName.isEmpty ? 0 : _itemName}&"
              "Customer_Name_=$_search&"
              "Enquiry_For_=${_enquiryFor.isEmpty ? 0 : _enquiryFor}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        if (responseData['success'] == true && responseData['data'] is List) {
          final List listData = responseData['data'];
          _salesReport =
              listData.map((e) => SalesReportModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching sales report: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFilters() {
    _search = '';
    _invoiceNo = '';
    _itemName = '';
    _enquiryFor = '';
    _fromDate = null;
    _toDate = null;
    _selectedDateFilterIndex = null;
    notifyListeners();
  }
}
