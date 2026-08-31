import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/task_aging_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class TaskAgingReportProvider extends ChangeNotifier {
  List<TaskAgingReportModel> _reportData = [];
  List<TaskAgingReportModel> get reportData => _reportData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchReportData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.taskAgingReport);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data is List) {
            _reportData = data
                .map((item) =>
                    TaskAgingReportModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else if (data['Status'] == true && data['Data'] != null) {
            _reportData = (data['Data'] as List<dynamic>)
                .map((item) =>
                    TaskAgingReportModel.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            _reportData = [];
          }
        } else {
          _reportData = [];
        }
      } else {
        _reportData = [];
      }
    } catch (e) {
      debugPrint("Error fetching task aging report: $e");
      _reportData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
