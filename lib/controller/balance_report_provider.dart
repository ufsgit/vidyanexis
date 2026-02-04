import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/balance_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class BalanceReportProvider extends ChangeNotifier {
  List<BalanceReportModel> _balanceReportList = [];
  List<BalanceReportModel> get balanceReportList => _balanceReportList;

  DateTime? _selectedDate = DateTime.now();
  DateTime? get selectedDate => _selectedDate;

  String _formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get formattedDate => _formattedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _search = '';
  String get search => _search;

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void setSearch(String query) {
    _search = query;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    _formattedDate = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setDate(picked);
      getBalanceReport(context);
    }
  }

  Future<void> getBalanceReport(BuildContext context) async {
    try {
      _isLoading = true;
      Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.balanceReport}?Date=$_formattedDate&Customer_Name=$_search',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _balanceReportList =
            data.map((json) => BalanceReportModel.fromJson(json)).toList();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch balance report')),
        );
      }
    } catch (e) {
      debugPrint('Error fetching balance report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching report')),
      );
    } finally {
      _isLoading = false;
      Loader.stopLoader(context);
      notifyListeners();
    }
  }
}
