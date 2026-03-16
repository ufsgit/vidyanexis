import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/task_summary_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:intl/intl.dart';

class TaskSummaryProvider extends ChangeNotifier {
  List<TaskSummaryModel> _taskSummaries = [];
  List<TaskSummaryModel> get taskSummaries => _taskSummaries;

  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isDateCheck = false;

  DateTime? get fromDate => _fromDate;
  DateTime? get to_toDate => _toDate;
  bool get isDateCheck => _isDateCheck;

  void setFromDate(DateTime date) {
    _fromDate = date;
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    notifyListeners();
  }

  void setIsDateCheck(bool value) {
    _isDateCheck = value;
    notifyListeners();
  }

  Future<void> getTaskSummary(BuildContext context) async {
    try {
      Loader.showLoader(context);
      
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "";

      String fromDateStr = _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : '';
      String toDateStr = _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : '';
      int isDateCheckInt = _isDateCheck ? 1 : 0;

      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.taskSummary}?Fromdate_=$fromDateStr&Todate_=$toDateStr&Is_Date_Check_=$isDateCheckInt&Login_User_Id_=$userId'
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _taskSummaries = data.map((json) => TaskSummaryModel.fromJson(json)).toList();
        } else {
          _taskSummaries = [];
        }
        notifyListeners();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load task summary')),
        );
      }
    } catch (e) {
      print('Error fetching task summary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching task summary')),
      );
    } finally {
      Loader.stopLoader(context);
    }
  }

  void resetFilters() {
    _fromDate = null;
    _toDate = null;
    _isDateCheck = false;
    notifyListeners();
  }
}
