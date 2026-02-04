import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/payment_schedule_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class PaymentScheduleProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<PaymentScheduleModel> _paymentScheduleList = [];
  List<PaymentScheduleModel> get paymentScheduleList => _paymentScheduleList;

  final TextEditingController scheduleDateController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> getPaymentScheduleList(
      String customerId, BuildContext context) async {
    try {
      _isLoading = true;
      // notifyListeners(); // Usually not needed if notifyListeners is called in finally

      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.getPaymentSchedule}?Customer_Id=$customerId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _paymentScheduleList =
            data.map((json) => PaymentScheduleModel.fromJson(json)).toList();
      } else {
        // Handle error
      }
    } catch (e) {
      debugPrint('Error fetching payment schedule: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePaymentSchedule(
      String scheduleId, String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      final bodyData = {
        "Schedule_Id": scheduleId,
        "Customer_Id": customerId,
        "Schedule_Date": scheduleDateController.text,
        "Schedule_Amount": amountController.text,
        "Description": descriptionController.text,
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.savePaymentSchedule,
        bodyData: bodyData,
      );

      Loader.stopLoader(context);

      if (response?.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Schedule saved successfully')),
        );
        clearControllers();
        getPaymentScheduleList(customerId, context);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save Payment Schedule')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      debugPrint('Error saving payment schedule: $e');
    }
  }

  Future<void> deletePaymentSchedule(
      String scheduleId, String customerId, BuildContext context) async {
    try {
      Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.deletePaymentSchedule}/$scheduleId',
      );

      Loader.stopLoader(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Payment Schedule deleted successfully')),
        );
        getPaymentScheduleList(customerId, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete Payment Schedule')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      debugPrint('Error deleting payment schedule: $e');
    }
  }

  void clearControllers() {
    scheduleDateController.clear();
    amountController.clear();
    descriptionController.clear();
  }

  void setControllers(PaymentScheduleModel model) {
    scheduleDateController.text = model.scheduleDate;
    amountController.text = model.amount.toString();
    descriptionController.text = model.description;
  }
}
