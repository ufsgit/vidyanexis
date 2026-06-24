import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/enquiry_settings_model.dart';
import 'package:vidyanexis/controller/models/target_enquiry_source_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class TargetEnquirySourceProvider extends ChangeNotifier {
  // ── Enquiry Source dropdown ──────────────────────────────────────────────
  List<EnquirySourceModel> _enquirySources = [];
  List<EnquirySourceModel> get enquirySources => _enquirySources;

  EnquirySourceModel? _selectedEnquirySource;
  EnquirySourceModel? get selectedEnquirySource => _selectedEnquirySource;

  void setSelectedEnquirySource(EnquirySourceModel? source) {
    _selectedEnquirySource = source;
    notifyListeners();
  }

  // ── Target list ──────────────────────────────────────────────────────────
  List<TargetEnquirySourceModel> _targetList = [];
  List<TargetEnquirySourceModel> get targetList => _targetList;

  // ── Date pickers ─────────────────────────────────────────────────────────
  DateTime? _targetFrom;
  DateTime? _targetTo;
  DateTime? _durationFrom;
  DateTime? _durationTo;

  DateTime? get targetFrom => _targetFrom;
  DateTime? get targetTo => _targetTo;
  DateTime? get durationFrom => _durationFrom;
  DateTime? get durationTo => _durationTo;

  String get formattedTargetFrom =>
      _targetFrom != null ? DateFormat('yyyy-MM-dd').format(_targetFrom!) : '';
  String get formattedTargetTo =>
      _targetTo != null ? DateFormat('yyyy-MM-dd').format(_targetTo!) : '';
  String get formattedDurationFrom => _durationFrom != null
      ? DateFormat('yyyy-MM-dd').format(_durationFrom!)
      : '';
  String get formattedDurationTo =>
      _durationTo != null ? DateFormat('yyyy-MM-dd').format(_durationTo!) : '';

  // Display labels (dd/MM/yyyy for UI)
  String get displayTargetFrom =>
      _targetFrom != null ? DateFormat('dd/MM/yyyy').format(_targetFrom!) : '';
  String get displayTargetTo =>
      _targetTo != null ? DateFormat('dd/MM/yyyy').format(_targetTo!) : '';
  String get displayDurationFrom => _durationFrom != null
      ? DateFormat('dd/MM/yyyy').format(_durationFrom!)
      : '';
  String get displayDurationTo =>
      _durationTo != null ? DateFormat('dd/MM/yyyy').format(_durationTo!) : '';

  void setTargetFrom(DateTime date) {
    _targetFrom = date;
    notifyListeners();
  }

  void setTargetTo(DateTime date) {
    _targetTo = date;
    notifyListeners();
  }

  void setDurationFrom(DateTime date) {
    _durationFrom = date;
    notifyListeners();
  }

  void setDurationTo(DateTime date) {
    _durationTo = date;
    notifyListeners();
  }

  Future<void> pickDate(
    BuildContext context, {
    required void Function(DateTime) onPicked,
    DateTime? initial,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  void resetForm() {
    _selectedEnquirySource = null;
    _targetFrom = null;
    _targetTo = null;
    _durationFrom = null;
    _durationTo = null;
    notifyListeners();
  }

  // ── Fetch enquiry sources for dropdown ───────────────────────────────────
  Future<void> fetchEnquirySources(BuildContext context,
      {String query = ''}) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.searchEnquiryStatus}?Enquiry_Source_Name=$query');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          _enquirySources = (data as List<dynamic>)
              .map((item) => EnquirySourceModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        _showSnack(context, 'Failed to load enquiry sources');
      }
    } catch (e) {
      print('fetchEnquirySources error: $e');
      _showSnack(context, 'An error occurred');
    }
  }

  // ── Fetch saved targets ──────────────────────────────────────────────────
  Future<void> fetchTargetList(BuildContext context) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: HttpUrls.getTargetEnquirySource);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final List<dynamic> list;
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            list = data['data'] as List<dynamic>;
          } else if (data is List<dynamic>) {
            list = data;
          } else {
            list = [];
          }
          _targetList = list
              .map((item) => TargetEnquirySourceModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      } else {
        _showSnack(context, 'Failed to load target list');
      }
    } catch (e) {
      print('fetchTargetList error: $e');
      _showSnack(context, 'An error occurred');
    }
  }

  // ── Save / Update target ─────────────────────────────────────────────────
  Future<void> saveTarget(
    BuildContext context, {
    int editId = 0,
  }) async {
    if (_selectedEnquirySource == null) {
      _showSnack(context, 'Please select an enquiry source');
      return;
    }
    if (_targetFrom == null || _targetTo == null) {
      _showSnack(context, 'Please select target from and to dates');
      return;
    }
    if (_durationFrom == null || _durationTo == null) {
      _showSnack(context, 'Please select duration from and to dates');
      return;
    }

    try {
      Loader.showLoader(context);

      final body = {
        'Target_Enquiry_Source_Id': editId,
        'Enquiry_Source_Id': _selectedEnquirySource!.enquirySourceId,
        'Enquiry_Source_Name': _selectedEnquirySource!.enquirySourceName,
        'Target_From': formattedTargetFrom,
        'Target_To': formattedTargetTo,
        'Duration_From': formattedDurationFrom,
        'Duration_To': formattedDurationTo,
      };

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveTargetEnquirySource,
        bodyData: body,
      );

      Loader.stopLoader(context);

      if (response?.statusCode == 200) {
        final data = response!.data;
        final message =
            data is Map && data['message'] != null ? data['message'] : 'Saved';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message.toString())));
        resetForm();
        await fetchTargetList(context);
        Navigator.of(context).pop(true);
      } else {
        _showSnack(context, 'Server Error');
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('saveTarget error: $e');
      _showSnack(context, 'An error occurred');
    }
  }

  // ── Delete target ────────────────────────────────────────────────────────
  Future<void> deleteTarget(BuildContext context, int id) async {
    try {
      Loader.showLoader(context);
      final response = await HttpRequest.httpDeleteRequest(
        endPoint: '${HttpUrls.deleteTargetEnquirySource}/$id',
      );
      Loader.stopLoader(context);

      if (response != null && response.statusCode == 200) {
        _targetList.removeWhere((t) => t.targetEnquirySourceId == id);
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Target deleted successfully')));
      } else {
        _showSnack(context, 'Failed to delete target');
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('deleteTarget error: $e');
      _showSnack(context, 'An error occurred');
    }
  }

  // ── Populate form for editing ────────────────────────────────────────────
  void populateForEdit(TargetEnquirySourceModel model) {
    _selectedEnquirySource = EnquirySourceModel(
      enquirySourceId: model.enquirySourceId,
      enquirySourceName: model.enquirySourceName,
      sourceCategoryId: 0,
      sourceCategoryName: '',
      deleteStatus: 0,
    );
    _targetFrom = _parseDate(model.targetFrom);
    _targetTo = _parseDate(model.targetTo);
    _durationFrom = _parseDate(model.durationFrom);
    _durationTo = _parseDate(model.durationTo);
    notifyListeners();
  }

  DateTime? _parseDate(String value) {
    if (value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
