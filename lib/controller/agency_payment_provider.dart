import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/agency_payment_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class AgencyPaymentProvider extends ChangeNotifier {
  // Search controller for agency payment listing
  final TextEditingController searchController = TextEditingController();

  // Form controllers for Add Agency Payment dialog
  final TextEditingController amountController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  int? _selectedEnquirySourceId;
  int? get selectedEnquirySourceId => _selectedEnquirySourceId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDeleteLoading = false;
  bool get isDeleteLoading => _isDeleteLoading;

  List<AgencyPaymentModel> _agencyPaymentList = [];
  List<AgencyPaymentModel> get agencyPaymentList => _agencyPaymentList;

  bool _isListLoading = false;
  bool get isListLoading => _isListLoading;

  List<AgencyPaymentModel> get filteredAgencyPaymentList {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _agencyPaymentList;
    }
    return _agencyPaymentList.where((item) {
      return item.enquirySourceName.toLowerCase().contains(query) ||
          item.remark.toLowerCase().contains(query) ||
          item.paymentDate.toLowerCase().contains(query) ||
          item.amount.toString().contains(query);
    }).toList();
  }

  void setSelectedEnquirySource(int? id) {
    _selectedEnquirySourceId = id;
    notifyListeners();
  }

  void setPaymentDate(String date) {
    paymentDateController.text = date;
    notifyListeners();
  }

  void clearForm() {
    amountController.clear();
    paymentDateController.clear();
    remarkController.clear();
    _selectedEnquirySourceId = null;
    notifyListeners();
  }

  Future<void> getAgencyPayments(BuildContext context) async {
    try {
      _isListLoading = true;
      notifyListeners();

      dynamic response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.listagencypayment,
        bodyData: {},
      );

      _isListLoading = false;

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final data = response.data;
        if (data != null) {
          dynamic listData;
          if (data is Map && data['data'] != null) {
            listData = data['data'];
          } else if (data is List) {
            listData = data;
          } else if (data is Map && data['response'] != null) {
            listData = data['response'];
          }

          if (listData is List) {
            _agencyPaymentList = listData
                .map((item) => AgencyPaymentModel.fromJson(
                    item is Map<String, dynamic>
                        ? item
                        : Map<String, dynamic>.from(item)))
                .toList();
          }
        }
      }
      notifyListeners();
    } catch (e) {
      _isListLoading = false;
      notifyListeners();
      debugPrint('Error fetching agency payments: $e');
    }
  }

  Future<bool> saveAgencyPayment({
    required BuildContext context,
    required String enquirySourceName,
  }) async {
    if (selectedEnquirySourceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select enquiry source')),
      );
      return false;
    }
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return false;
    }
    if (paymentDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select payment date')),
      );
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();
      Loader.showLoader(context);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ??
          prefs.getString('user_id') ??
          prefs.getString('UserId') ??
          prefs.getInt('user_id')?.toString() ??
          '';

      final Map<String, dynamic> bodyData = {
        "Agency_Payment_Id": 0,
        "Enquiry_Source": selectedEnquirySourceId,
        "Remark": remarkController.text.trim(),
        "Payment_Date": paymentDateController.text.trim(),
        "Amount": double.tryParse(amountController.text.trim()) ?? 0,
        "User_Id": int.tryParse(userId) ?? 0,
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveagencypayment,
        bodyData: bodyData,
      );

      if (context.mounted) {
        Loader.stopLoader(context);
      }
      _isLoading = false;
      notifyListeners();

      if (response != null && response.statusCode == 200) {
        if (context.mounted) {
          final data = response.data;
          String message = 'Agency payment saved successfully';
          if (data is Map && data['message'] != null) {
            message = data['message'].toString();
          }
          Navigator.pop(context, true);
          clearForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          if (context.mounted) {
            getAgencyPayments(context);
          }
        }
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save agency payment')),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving agency payment: $e');
      return false;
    }
  }

  Future<void> deleteAgencyPayment(
      BuildContext context, int agencyPaymentId) async {
    try {
      _isDeleteLoading = true;
      Loader.showLoader(context);

      final Map<String, dynamic> bodyData = {
        "Agency_Payment_Id": agencyPaymentId,
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.deleteagencypayment,
        bodyData: bodyData,
      );

      if (context.mounted) {
        Loader.stopLoader(context);
      }

      if (response != null && response.statusCode == 200) {
        _agencyPaymentList
            .removeWhere((item) => item.agencyPaymentId == agencyPaymentId);
        notifyListeners();
        if (context.mounted) {
          getAgencyPayments(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Agency payment deleted successfully')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete agency payment')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      _isDeleteLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    amountController.dispose();
    paymentDateController.dispose();
    remarkController.dispose();
    super.dispose();
  }
}
