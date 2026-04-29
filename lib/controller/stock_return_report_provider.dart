import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/stock_use_report_model.dart'; // Reusing the model if fields are same
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';

class StockReturnReportProvider extends ChangeNotifier {
  List<StockUseReportModel> _reportList = [];
  List<StockUseReportModel> get reportList => _reportList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ItemListModel> _stockItems = [];
  List<ItemListModel> get stockItems => _stockItems;

  List<DropdownItem<int>> _customers = [];
  List<DropdownItem<int>> get customers => _customers;

  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';

  String _customerName = '';
  String _itemName = '';
  bool _isFilter = false;

  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;
  bool get isFilter => _isFilter;
  String get customerName => _customerName;
  String get itemName => _itemName;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setItemName(String name) {
    _itemName = name;
    notifyListeners();
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    formatDate();
    notifyListeners();
  }

  void clearFilters() {
    _customerName = '';
    _itemName = '';
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    notifyListeners();
  }

  void formatDate() {
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    }
    if (_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
    }
  }

  Future<void> searchReport(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      String isDate =
          (_formattedFromDate.isNotEmpty || _formattedToDate.isNotEmpty)
              ? "1"
              : "0";

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.searchStockReturnReport}?Customer_Name=${Uri.encodeComponent(_customerName)}&Item_Name=${Uri.encodeComponent(_itemName)}&Is_Date=$isDate&Fromdate=$_formattedFromDate&Todate=$_formattedToDate',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _reportList = data
              .map((item) => StockUseReportModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else if (data != null && data is Map && data['data'] != null) {
          final list = data['data'] as List;
          _reportList = list
              .map((item) => StockUseReportModel.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          _reportList = [];
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      debugPrint('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStockDetails(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.getStockDetails,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final dataList = data['data'] as List;
          _stockItems = dataList.map((item) {
            return ItemListModel(
              itemId: int.tryParse(item['Item_Id']?.toString() ?? '0') ?? 0,
              stockId: int.tryParse(item['Stock_Id']?.toString() ?? '0') ?? 0,
              itemName: item['Item_Name']?.toString() ?? '',
              categoryId:
                  int.tryParse(item['Category_Id']?.toString() ?? '0') ?? 0,
              categoryName: item['Category_Name']?.toString() ?? '',
              unitId: int.tryParse(item['Unit_Id']?.toString() ?? '0') ?? 0,
              unitName: item['Unit_Name']?.toString() ?? '',
              unitPrice: item['Unit_Price']?.toString() ?? '0',
              cgst: item['CGST']?.toString() ?? '0.00',
              sgst: item['SGST']?.toString() ?? '0.00',
              gst: item['GST']?.toString() ?? '0.00',
              igst: item['IGST']?.toString() ?? '0.00',
              serviceCheckbox:
                  int.tryParse(item['Service_CheckBox']?.toString() ?? '0') ??
                      0,
              primaryCheckBox:
                  int.tryParse(item['Is_Primary']?.toString() ?? '0') ?? 0,
              hsnCode: item['HSNCode']?.toString() ?? '',
              quantity: item['Quantity']?.toString() ?? '0',
            );
          }).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching stock details: $e');
    }
  }

  Future<void> fetchCustomers(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.searchCustomer}?Customer_Name_=&Is_Date_=0&Fromdate_=&Todate_=&To_User_Id_=0&Status_Id_=0&Page_Index1_=1&Page_Index2_=1000',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          List<dynamic> dataList = List.from(data);
          if (dataList.isNotEmpty) {
            dataList.removeLast();
          }

          _customers = dataList.map((item) {
            return DropdownItem<int>(
              id: int.tryParse(item['Customer_Id']?.toString() ?? '0') ?? 0,
              name: item['Customer_Name']?.toString() ?? '',
            );
          }).toList();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    }
  }
}
