import 'package:flutter/material.dart';
import 'package:vidyanexis/model/project_duration_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class ProjectDurationReportProvider extends ChangeNotifier {
  List<ProjectDurationModel> _projectDurationReport = [];
  List<ProjectDurationModel> get projectDurationReport => _projectDurationReport;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getProjectDurationReport(BuildContext context) async {
    if (_isLoading) return;
    try {
      _isLoading = true;
      Loader.showLoader(context);
      
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getProjectDurationReport);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          _projectDurationReport = (data as List<dynamic>)
              .map((item) => ProjectDurationModel.fromJson(item))
              .toList();
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
    } finally {
      Loader.stopLoader(context);
      _isLoading = false;
      notifyListeners();
    }
  }
}
