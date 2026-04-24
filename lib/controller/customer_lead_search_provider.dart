import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/search_lead_by_contact_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class CustomerLeadSearchProvider extends ChangeNotifier {
  final TextEditingController contactNoController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SearchLeadByContactModel> _leadResults = [];
  List<SearchLeadByContactModel> get leadResults => _leadResults;

  Future<void> searchLeadByContact() async {
    if (contactNoController.text.isEmpty) {
      return;
    }

    _isLoading = true;
    _leadResults.clear();
    notifyListeners();

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: "${HttpUrls.searchLeadByContact}?Contact_No=${contactNoController.text}",
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _leadResults = data
            .map((item) => SearchLeadByContactModel.fromJson(item))
            .toList();
      } else {
        log("Error searching lead: ${response.statusCode}");
      }
    } catch (e) {
      log("Error searching lead: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    contactNoController.clear();
    _leadResults.clear();
    notifyListeners();
  }
}
