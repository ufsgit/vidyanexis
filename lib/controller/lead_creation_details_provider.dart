import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/lead_report_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class LeadCreationDetailsProvider extends ChangeNotifier {
  List<LeadReportModel> _detailedReports = [];
  List<LeadReportModel> get detailedReports => _detailedReports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchDetailedReports(BuildContext context, {
    required int employeeId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      // Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.searchLeadCreatedDetails}/?Employee_Id=$employeeId&Fromdate=$fromDate&Todate=$toDate',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          if (data is List) {
            _detailedReports = data.map((item) => LeadReportModel.fromJson(item)).toList();
          } else if (data is Map && data['Data'] is List) {
            _detailedReports = (data['Data'] as List)
                .map((item) => LeadReportModel.fromJson(item))
                .toList();
          } else {
            _detailedReports = [];
          }
        } else {
          _detailedReports = [];
        }
      } else {
        _detailedReports = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to fetch lead creation details')),
          );
        }
      }
    } catch (e) {
      log('Error fetching lead creation details: $e');
      _detailedReports = [];
    } finally {
      _isLoading = false;
      // Loader.stopLoader(context);
      notifyListeners();
    }
  }

  void clearData() {
    _detailedReports = [];
  }
}
