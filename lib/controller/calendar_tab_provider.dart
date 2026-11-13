import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'package:vidyanexis/controller/models/calendar_tab_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class CalendarTabProvider extends ChangeNotifier {
  // Controllers for form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController itemDateController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController searchUserController = TextEditingController();

  int? selectedDepartmentId;
  int? selectedUserId;

  List<CalendarTabModel> _calendarList = [];
  List<CalendarTabModel> get calendarList => _calendarList;

  List<CalendarItemModel> _calendarItems = [];
  List<CalendarItemModel> get calendarItems => _calendarItems;

  int? _editingItemIndex;
  int? get editingItemIndex => _editingItemIndex;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── List ────────────────────────────────────────────────────────────────
  Future<void> getCalendarByCustomer(
      String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.getCalendar}/$customerId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        log('getCalendarByCustomer: $data');

        List<dynamic> list = [];

        if (data is List) {
          list = data;
        } else if (data is Map) {
          // API shape: { "Status": true, "Data": [ ... ] }
          final raw = data['Data'] ?? data['data'];
          if (raw is List) {
            list = raw;
          }
        }

        _calendarList = list
            .map((item) => CalendarTabModel.fromJson(
                item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item as Map)))
            .toList();
      } else {
        _calendarList = [];
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
    } catch (e) {
      log('getCalendarByCustomer error: $e');
      _calendarList = [];
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Details ─────────────────────────────────────────────────────────────
  Future<CalendarTabModel?> getCalendarDetails(
      String calendarId, String customerId, BuildContext context) async {
    try {
      try {
        return _calendarList.firstWhere((c) => c.calendarId == calendarId);
      } catch (_) {}

      await getCalendarByCustomer(customerId, context);
      try {
        return _calendarList.firstWhere((c) => c.calendarId == calendarId);
      } catch (_) {
        return null;
      }
    } catch (e) {
      log('getCalendarDetails error: $e');
      return null;
    }
  }

  // ─── Save (create / update) ──────────────────────────────────────────────
  Future<bool> saveCalendar({
    required String customerId,
    required bool isEdit,
    required String editId,
    required BuildContext context,
  }) async {
    if (nameController.text.trim().isEmpty) return false;
    if (_calendarItems.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      Loader.showLoader(context);

      final body = {
        'Calendar_Id':
            isEdit && editId != '0' ? (int.tryParse(editId) ?? 0) : 0,
        'Customer_Id': int.tryParse(customerId) ?? 0,
        'Calendar_Name': nameController.text.trim(),
        'Calendar_Details': _calendarItems.map((e) => e.toJson()).toList(),
      };

      log('saveCalendar body: $body');

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveCalendar,
        bodyData: body,
      );

      Loader.stopLoader(context);

      if (response != null && response.statusCode == 200) {
        log('saveCalendar success: ${response.data}');
        clearForm();
        await getCalendarByCustomer(customerId, context);
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save calendar')),
          );
        }
        return false;
      }
    } catch (e) {
      log('saveCalendar error: $e');
      try {
        Loader.stopLoader(context);
      } catch (_) {}
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Delete ──────────────────────────────────────────────────────────────
  Future<void> deleteCalendar(
      String calendarId, String customerId, BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.deleteCalendar}/$calendarId',
      );

      if (response.statusCode == 200) {
        log('deleteCalendar success');
        await getCalendarByCustomer(customerId, context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Calendar deleted')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete')),
          );
        }
      }
    } catch (e) {
      log('deleteCalendar error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load for edit ───────────────────────────────────────────────────────
  Future<void> loadForEdit(
      String calendarId, String customerId, BuildContext context) async {
    final model = await getCalendarDetails(calendarId, customerId, context);
    if (model != null) {
      nameController.text = model.name;
      _calendarItems = List.from(model.items);
      notifyListeners();
    }
  }

  // ─── Item management (date + description) ────────────────────────────────
  void addOrUpdateCalendarItem(CalendarItemModel item) {
    if (_editingItemIndex != null) {
      _calendarItems[_editingItemIndex!] = item;
      _editingItemIndex = null;
    } else {
      _calendarItems.add(item);
    }
    clearItemFields();
    notifyListeners();
  }

  void editCalendarItem(int index) {
    if (index < 0 || index >= _calendarItems.length) return;
    final item = _calendarItems[index];
    itemDateController.text = item.date;
    itemDescriptionController.text = item.description;
    departmentController.text = item.departmentName;
    searchUserController.text = item.userName;
    selectedDepartmentId = int.tryParse(item.departmentId);
    selectedUserId = int.tryParse(item.userId);
    _editingItemIndex = index;
    notifyListeners();
  }

  void removeCalendarItem(int index) {
    if (index < 0 || index >= _calendarItems.length) return;
    _calendarItems.removeAt(index);
    if (_editingItemIndex == index) {
      _editingItemIndex = null;
      clearItemFields();
    } else if (_editingItemIndex != null && _editingItemIndex! > index) {
      _editingItemIndex = _editingItemIndex! - 1;
    }
    notifyListeners();
  }

  void clearItemFields() {
    itemDateController.clear();
    itemDescriptionController.clear();
    departmentController.clear();
    searchUserController.clear();
    selectedDepartmentId = null;
    selectedUserId = null;
  }

  void clearForm() {
    nameController.clear();
    clearItemFields();
    _calendarItems = [];
    _editingItemIndex = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    itemDateController.dispose();
    itemDescriptionController.dispose();
    departmentController.dispose();
    searchUserController.dispose();
    super.dispose();
  }

  Future<Uint8List?> getCalendarItemPdfBytes(
      String customerId, String calanderId) async {
    try {
      final response = await HttpRequest.httpGetRequest(
          endPoint: '${HttpUrls.printCalendarItem}/$customerId/$calanderId',
          returnBytes: true);

      if (response.statusCode == 200 && response.data is List<int>) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      print('Exception occurred: $e');
      return null;
    }
  }

  Future<void> getCalendarItemPdf(
      String customerId, String calanderId, BuildContext context) async {
    try {
      final data = await getCalendarItemPdfBytes(customerId, calanderId);

      if (data != null) {
        if (kIsWeb) {
          final blob = html.Blob([data], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute("download", "Calendar_$customerId.pdf")
            ..click();

          // Delay cleanup to ensure download starts
          await Future.delayed(const Duration(seconds: 2));
          html.Url.revokeObjectUrl(url);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Downloading PDF...')));
          }
        } else {
          if (context.mounted) {
            await Printing.layoutPdf(onLayout: (format) async => data);
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server Error')),
          );
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred')),
        );
      }
    }
  }
}
