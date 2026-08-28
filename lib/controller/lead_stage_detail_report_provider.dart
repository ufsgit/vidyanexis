import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/lead_stage_detail_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class LeadStageDetailReportProvider extends ChangeNotifier {
  List<LeadStageDetailReportModel> _reportData = [];
  List<LeadStageDetailReportModel> get reportData => _reportData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchReportData(BuildContext context, int stageId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.getLeadsByStage}?Stage_Id=$stageId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['Status'] == true && data['Data'] != null) {
          _reportData = (data['Data'] as List<dynamic>)
              .map((item) => LeadStageDetailReportModel.fromJson(item))
              .toList();
        } else {
          _reportData = [];
        }
      } else {
        _reportData = [];
      }
    } catch (e) {
      debugPrint("Error fetching lead stage detail report: $e");
      _reportData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
