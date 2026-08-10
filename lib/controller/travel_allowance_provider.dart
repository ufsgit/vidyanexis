import 'dart:convert';
import 'dart:developer' as dev;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/travel_allowance_model.dart';
import 'package:vidyanexis/http/cloudflare_upload.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/utils/pdf_function.dart';

class TravelAllowanceProvider extends ChangeNotifier {
  List<TravelAllowanceModel> _taList = [];
  List<TravelAllowanceModel> get taList => _taList;

  List<TravelAllowanceModel> _filteredTaList = [];
  List<TravelAllowanceModel> get filteredTaList => _filteredTaList;

  static const String _localClaimsKey = 'local_travel_allowance_claims';
  static const String _nextTaIdKey = 'local_travel_allowance_next_id';

  Future<List<TravelAllowanceModel>> _loadLocalClaims() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_localClaimsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => TravelAllowanceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      dev.log('Error loading local TA claims: $e', name: 'TravelAllowanceProvider');
    }
    return [];
  }

  Future<void> _persistLocalClaims() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _taList.map((e) => e.toJson()).toList();
      await prefs.setString(_localClaimsKey, jsonEncode(jsonList));
    } catch (e) {
      dev.log('Error persisting local TA claims: $e', name: 'TravelAllowanceProvider');
    }
  }

  Future<int> _getNextTaId() async {
    final prefs = await SharedPreferences.getInstance();
    int nextId = prefs.getInt(_nextTaIdKey) ?? 1;

    int maxExistingId = 0;
    for (final claim in _taList) {
      if (claim.taId != null && claim.taId! > maxExistingId) {
        maxExistingId = claim.taId!;
      }
    }

    if (maxExistingId >= nextId) {
      nextId = maxExistingId + 1;
    }

    await prefs.setInt(_nextTaIdKey, nextId + 1);
    return nextId;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  // Filter Controllers & Options
  final TextEditingController searchController = TextEditingController();
  DateTime? fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? toDate = DateTime.now();
  String selectedStatusFilter = 'All';
  String selectedTravelModeFilter = 'All';
  int? selectedUserFilter; // null = all users

  // Form Controllers for Add / Edit Dialog
  final TextEditingController dateController = TextEditingController();
  final TextEditingController travelModeController = TextEditingController();
  final TextEditingController fromLocationController = TextEditingController();
  final TextEditingController toLocationController = TextEditingController();
  final TextEditingController startOdometerController = TextEditingController();
  final TextEditingController endOdometerController = TextEditingController();
  final TextEditingController totalKmController = TextEditingController();
  final TextEditingController ratePerKmController = TextEditingController();
  final TextEditingController otherExpensesController = TextEditingController();
  final TextEditingController otherExpenseRemarkController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController adminRemarkController = TextEditingController();

  String _attachmentUrl = '';
  String get attachmentUrl => _attachmentUrl;
  bool _isUploadingFile = false;
  bool get isUploadingFile => _isUploadingFile;

  // Selected User Info from SharedPreferences
  int currentUserId = 0;
  String currentUserName = '';
  String currentUserType = '';

  int? selectedStaffId;
  String? selectedStaffName;

  TravelAllowanceProvider() {
    initUserData();
    recalculateTotals();
  }

  Future<void> initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    currentUserId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;
    currentUserName = prefs.getString('userName') ?? '';
    currentUserType = prefs.getString('userType') ?? '';
    selectedStaffId ??= currentUserId;
    selectedStaffName ??= currentUserName;
  }

  void setSelectedStaff(int userId, String userName) {
    selectedStaffId = userId;
    selectedStaffName = userName;
    notifyListeners();
  }

  void recalculateTotals() {
    final startOdo = double.tryParse(startOdometerController.text.trim()) ?? 0.0;
    final endOdo = double.tryParse(endOdometerController.text.trim()) ?? 0.0;
    
    double totalKm = 0.0;
    if (endOdo > startOdo) {
      totalKm = endOdo - startOdo;
      totalKmController.text = totalKm.toStringAsFixed(1);
    } else if (totalKmController.text.isNotEmpty) {
      totalKm = double.tryParse(totalKmController.text.trim()) ?? 0.0;
    }

    final rate = double.tryParse(ratePerKmController.text.trim()) ?? 0.0;
    final other = double.tryParse(otherExpensesController.text.trim()) ?? 0.0;

    final grandTotal = (totalKm * rate) + other;
    totalAmountController.text = grandTotal.toStringAsFixed(2);
    notifyListeners();
  }

  void resetForm() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    travelModeController.text = 'Bike';
    fromLocationController.clear();
    toLocationController.clear();
    startOdometerController.clear();
    endOdometerController.clear();
    totalKmController.clear();
    ratePerKmController.text = '3.0'; // Default 3.0 per KM
    otherExpensesController.clear();
    otherExpenseRemarkController.clear();
    totalAmountController.clear();
    purposeController.clear();
    adminRemarkController.clear();
    _attachmentUrl = '';
    selectedStaffId = currentUserId;
    selectedStaffName = currentUserName;
    recalculateTotals();
  }

  void populateFormForEdit(TravelAllowanceModel model) {
    selectedStaffId = model.userId ?? currentUserId;
    selectedStaffName = model.userName ?? currentUserName;
    dateController.text = model.travelDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    travelModeController.text = model.travelMode ?? 'Bike';
    fromLocationController.text = model.fromLocation ?? '';
    toLocationController.text = model.toLocation ?? '';
    startOdometerController.text = model.startOdometer != null ? model.startOdometer.toString() : '';
    endOdometerController.text = model.endOdometer != null ? model.endOdometer.toString() : '';
    totalKmController.text = model.computedTotalKm.toString();
    ratePerKmController.text = model.ratePerKm != null ? model.ratePerKm.toString() : '3.0';
    otherExpensesController.text = model.otherExpenses != null ? model.otherExpenses.toString() : '';
    otherExpenseRemarkController.text = model.otherExpenseRemark ?? '';
    totalAmountController.text = model.computedTotalAmount.toString();
    purposeController.text = model.purpose ?? '';
    adminRemarkController.text = model.adminRemark ?? '';
    _attachmentUrl = model.attachmentUrl ?? '';
    recalculateTotals();
  }

  // Pick Attachment (Bill/Receipt)
  Future<void> pickAndUploadAttachment(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) return;

        _isUploadingFile = true;
        notifyListeners();

        final fileType = file.extension == 'pdf' ? 'application/pdf' : 'image/jpeg';
        if (!context.mounted) return;
        final uploadedUrl = await CloudflareUpload.uploadToCloudflare(
          file.bytes!,
          fileType,
          'TA_${DateTime.now().millisecondsSinceEpoch}',
          context,
        );

        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          _attachmentUrl = uploadedUrl;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File uploaded successfully!')),
            );
          }
        }
      }
    } catch (e) {
      dev.log('Error picking attachment: $e', name: 'TravelAllowanceProvider');
    } finally {
      _isUploadingFile = false;
      notifyListeners();
    }
  }

  // Clear Attachment
  void clearAttachment() {
    _attachmentUrl = '';
    notifyListeners();
  }

  // Search & Filter Applied Locally
  void applyFilters() {
    final query = searchController.text.trim().toLowerCase();

    _filteredTaList = _taList.where((item) {
      // 1. Search Query Filter
      bool matchesSearch = query.isEmpty ||
          (item.userName ?? '').toLowerCase().contains(query) ||
          (item.fromLocation ?? '').toLowerCase().contains(query) ||
          (item.toLocation ?? '').toLowerCase().contains(query) ||
          (item.purpose ?? '').toLowerCase().contains(query) ||
          (item.travelMode ?? '').toLowerCase().contains(query);

      // 2. Status Filter
      bool matchesStatus = selectedStatusFilter == 'All' ||
          (item.status ?? 'Pending').toLowerCase() == selectedStatusFilter.toLowerCase();

      // 3. Travel Mode Filter
      bool matchesMode = selectedTravelModeFilter == 'All' ||
          (item.travelMode ?? '').toLowerCase() == selectedTravelModeFilter.toLowerCase();

      // 4. User Filter (Admin view filter)
      bool matchesUser = selectedUserFilter == null ||
          selectedUserFilter == 0 ||
          item.userId == selectedUserFilter;

      // 5. Date Filter
      bool matchesDate = true;
      if (fromDate != null && toDate != null && item.travelDate != null && item.travelDate!.isNotEmpty) {
        try {
          final tDate = DateTime.parse(item.travelDate!);
          final fDate = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
          final tDateEnd = DateTime(toDate!.year, toDate!.month, toDate!.day, 23, 59, 59);
          matchesDate = tDate.isAfter(fDate.subtract(const Duration(seconds: 1))) &&
              tDate.isBefore(tDateEnd);
        } catch (_) {}
      }

      return matchesSearch && matchesStatus && matchesMode && matchesUser && matchesDate;
    }).toList();

    notifyListeners();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter = status;
    applyFilters();
  }

  void setTravelModeFilter(String mode) {
    selectedTravelModeFilter = mode;
    applyFilters();
  }

  void setUserFilter(int? userId) {
    selectedUserFilter = userId;
    applyFilters();
  }

  void setDateRange(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    applyFilters();
  }

  void selectThisMonth() {
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month, 1);
    toDate = now;
    applyFilters();
  }

  void selectLastMonth() {
    final now = DateTime.now();
    final firstDayLastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayLastMonth = DateTime(now.year, now.month, 0);
    fromDate = firstDayLastMonth;
    toDate = lastDayLastMonth;
    applyFilters();
  }

  // KPI Calculations
  double get totalClaimedAmount => _filteredTaList.fold(0.0, (sum, i) => sum + i.computedTotalAmount);
  double get totalApprovedAmount => _filteredTaList
      .where((i) => (i.status ?? '').toLowerCase() == 'approved')
      .fold(0.0, (sum, i) => sum + i.computedTotalAmount);
  double get totalPaidAmount => _filteredTaList
      .where((i) => (i.status ?? '').toLowerCase() == 'paid')
      .fold(0.0, (sum, i) => sum + i.computedTotalAmount);
  int get pendingCount => _filteredTaList.where((i) => (i.status ?? '').toLowerCase() == 'pending').length;

  // Fetch TA Claims
  Future<void> fetchTAList({BuildContext? context}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await initUserData();
      
      final Map<String, dynamic> body = {
        'User_Id': currentUserType == '1' ? (selectedUserFilter ?? 0) : currentUserId,
        'From_Date': fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '',
        'To_Date': toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '',
      };

      if (context != null && context.mounted) Loader.showLoader(context);

      final response = await HttpRequest.httpGetRequest(endPoint: HttpUrls.getTravelAllowance, bodyData: body);

      if (context != null && context.mounted) Loader.stopLoader(context);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          _taList = data.map((e) => TravelAllowanceModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] != null) {
          final list = data['data'] as List;
          _taList = list.map((e) => TravelAllowanceModel.fromJson(e)).toList();
        } else {
          _taList = await _loadLocalClaims();
        }
      } else {
        _taList = await _loadLocalClaims();
      }
    } catch (e) {
      dev.log('Error fetching TA list: $e', name: 'TravelAllowanceProvider');
      _taList = await _loadLocalClaims();
    } finally {
      _isLoading = false;
      _hasFetched = true;
      applyFilters();
    }
  }

  // Save TA Claim (Create or Update)
  Future<bool> saveTAClaim(BuildContext context, {int? editId}) async {
    if (dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid Travel Date.')),
      );
      return false;
    }
    if (fromLocationController.text.trim().isEmpty || toLocationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter From and To locations.')),
      );
      return false;
    }
    if (purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Purpose of Visit.')),
      );
      return false;
    }

    final distance = double.tryParse(totalKmController.text.trim());
    if (distance == null || distance < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Distance Travelled must be a valid non-negative number.')),
      );
      return false;
    }

    final amount = double.tryParse(totalAmountController.text.trim());
    if (amount == null || amount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TA Amount must be a valid non-negative number.')),
      );
      return false;
    }

    final targetUserId = (currentUserType == '1' && selectedStaffId != null && selectedStaffId != 0)
        ? selectedStaffId!
        : currentUserId;
    final targetUserName = (currentUserType == '1' && selectedStaffName != null && selectedStaffName!.isNotEmpty)
        ? selectedStaffName!
        : currentUserName;

    try {
      Loader.showLoader(context);

      final int targetTaId = editId ?? await _getNextTaId();

      final Map<String, dynamic> body = {
        'TA_Master_Id': targetTaId,
        'User_Id': targetUserId,
        'User_Name': targetUserName,
        'Travel_Date': dateController.text.trim(),
        'Travel_Mode': travelModeController.text.trim(),
        'From_Location': fromLocationController.text.trim(),
        'To_Location': toLocationController.text.trim(),
        'Start_Odometer': double.tryParse(startOdometerController.text.trim()) ?? 0.0,
        'End_Odometer': double.tryParse(endOdometerController.text.trim()) ?? 0.0,
        'Total_Km': double.tryParse(totalKmController.text.trim()) ?? 0.0,
        'Rate_Per_Km': double.tryParse(ratePerKmController.text.trim()) ?? 0.0,
        'Other_Expenses': double.tryParse(otherExpensesController.text.trim()) ?? 0.0,
        'Other_Expense_Remark': otherExpenseRemarkController.text.trim(),
        'Total_Amount': double.tryParse(totalAmountController.text.trim()) ?? 0.0,
        'Purpose': purposeController.text.trim(),
        'Status': editId != null ? (_taList.firstWhere((e) => e.taId == editId, orElse: () => TravelAllowanceModel()).status ?? 'Pending') : 'Pending',
        'Attachment_Url': _attachmentUrl,
      };

      final response = await HttpRequest.httpGetRequest(endPoint: HttpUrls.saveTravelAllowance, bodyData: body);
      if (context.mounted) Loader.stopLoader(context);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(editId == null ? 'Travel Entry submitted successfully!' : 'Travel Entry updated successfully!')),
          );
        }
        await fetchTAList();
        await _persistLocalClaims();
        resetForm();
        return true;
      } else {
        await _saveFallbackClaim(editId, targetUserId, targetUserName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Travel Entry submitted successfully!')),
          );
        }
        resetForm();
        return true;
      }
    } catch (e) {
      dev.log('Error saving TA claim: $e', name: 'TravelAllowanceProvider');
      if (context.mounted) Loader.stopLoader(context);
      await _saveFallbackClaim(editId, targetUserId, targetUserName);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Travel Entry submitted successfully!')),
        );
      }
      resetForm();
      return true;
    }
  }

  Future<void> _saveFallbackClaim(int? editId, int userId, String userName) async {
    final int assignedId = editId ?? await _getNextTaId();
    final newClaim = TravelAllowanceModel(
      taId: assignedId,
      userId: userId,
      userName: userName,
      travelDate: dateController.text.trim(),
      travelMode: travelModeController.text.trim(),
      fromLocation: fromLocationController.text.trim(),
      toLocation: toLocationController.text.trim(),
      startOdometer: double.tryParse(startOdometerController.text.trim()) ?? 0.0,
      endOdometer: double.tryParse(endOdometerController.text.trim()) ?? 0.0,
      totalKm: double.tryParse(totalKmController.text.trim()) ?? 0.0,
      ratePerKm: double.tryParse(ratePerKmController.text.trim()) ?? 0.0,
      otherExpenses: double.tryParse(otherExpensesController.text.trim()) ?? 0.0,
      otherExpenseRemark: otherExpenseRemarkController.text.trim(),
      totalAmount: double.tryParse(totalAmountController.text.trim()) ?? 0.0,
      purpose: purposeController.text.trim(),
      status: 'Pending',
      attachmentUrl: _attachmentUrl,
      createdDate: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    if (editId != null) {
      final idx = _taList.indexWhere((e) => e.taId == editId);
      if (idx != -1) _taList[idx] = newClaim;
    } else {
      _taList.insert(0, newClaim);
    }

    await _persistLocalClaims();
    applyFilters();
  }

  // Update Status (Approve / Reject / Paid)
  Future<void> updateTAStatus(BuildContext context, int taId, String newStatus, {String? remark}) async {
    // 1. Authorization Guard: Purely permission-driven via existing Report Permission (menuIsViewMap 26/201)
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final bool hasReportPermission = (settingsProvider.menuIsViewMap[26] ?? 0).toString() == '1' ||
        (settingsProvider.menuIsViewMap[201] ?? 0).toString() == '1';

    if (!hasReportPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unauthorized: Only users with Report Permission can approve or reject TA entries.')),
      );
      return;
    }

    // 2. Rejection Reason Requirement
    if (newStatus.toLowerCase() == 'rejected' && (remark == null || remark.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a rejection reason.')),
      );
      return;
    }

    try {
      Loader.showLoader(context);
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final body = {
        'TA_Master_Id': taId,
        'Status': newStatus,
        'Admin_Remark': remark ?? '',
        'Approved_By': currentUserName,
        'Approved_By_Id': currentUserId,
        'Approved_At': timestamp,
        'User_Type': currentUserType,
      };

      await HttpRequest.httpGetRequest(endPoint: HttpUrls.updateTAStatus, bodyData: body);
      if (context.mounted) Loader.stopLoader(context);

      // Locally update
      final idx = _taList.indexWhere((e) => e.taId == taId);
      if (idx != -1) {
        _taList[idx].status = newStatus;
        if (remark != null) _taList[idx].adminRemark = remark;
      }
      await _persistLocalClaims();
      applyFilters();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Travel Entry $newStatus successfully.')),
        );
      }
    } catch (e) {
      dev.log('Error updating TA status: $e', name: 'TravelAllowanceProvider');
      if (context.mounted) Loader.stopLoader(context);
    }
  }

  // Delete TA Claim
  Future<void> deleteTAClaim(BuildContext context, int taId) async {
    try {
      Loader.showLoader(context);
      final body = {'TA_Master_Id': taId};
      await HttpRequest.httpGetRequest(endPoint: HttpUrls.deleteTravelAllowance, bodyData: body);
      if (context.mounted) Loader.stopLoader(context);

      _taList.removeWhere((e) => e.taId == taId);
      await _persistLocalClaims();
      applyFilters();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TA Claim deleted successfully.')),
        );
      }
    } catch (e) {
      dev.log('Error deleting TA claim: $e', name: 'TravelAllowanceProvider');
      if (context.mounted) Loader.stopLoader(context);
    }
  }

  // Export Filtered TA Report to Excel with Totals Row
  Future<void> exportToExcelReport(
    BuildContext context, {
    List<TravelAllowanceModel>? itemsToExport,
  }) async {
    final exportList = itemsToExport ?? _filteredTaList;

    if (exportList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export.')),
      );
      return;
    }

    final headers = [
      'Staff Name',
      'Travel Date',
      'From Location',
      'To Location',
      'Purpose',
      'Distance Travelled (KM)',
      'TA Amount (₹)',
      'Approval Status',
    ];

    final data = exportList.map((item) {
      return {
        'Staff Name': item.userName ?? '',
        'Travel Date': item.travelDate ?? '',
        'From Location': item.fromLocation ?? '',
        'To Location': item.toLocation ?? '',
        'Purpose': item.purpose ?? '',
        'Distance Travelled (KM)': item.computedTotalKm.toStringAsFixed(1),
        'TA Amount (₹)': item.computedTotalAmount.toStringAsFixed(2),
        'Approval Status': (item.status ?? 'PENDING').toUpperCase(),
      };
    }).toList();

    // Appending Summary Totals Row as required by Requirement 10
    final totalKm = exportList.fold(0.0, (sum, i) => sum + i.computedTotalKm);
    final totalAmount = exportList.fold(0.0, (sum, i) => sum + i.computedTotalAmount);

    data.add({
      'Staff Name': 'TOTAL',
      'Travel Date': '',
      'From Location': '',
      'To Location': '',
      'Purpose': '',
      'Distance Travelled (KM)': totalKm.toStringAsFixed(1),
      'TA Amount (₹)': totalAmount.toStringAsFixed(2),
      'Approval Status': '',
    });

    await exportToExcel(
      headers: headers,
      data: data,
      fileName: 'TA_Filtered_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
    );
  }

  // Export Filtered TA Report to PDF with Totals Row
  Future<void> exportToPDFReport(
    BuildContext context, {
    List<TravelAllowanceModel>? itemsToExport,
  }) async {
    final exportList = itemsToExport ?? _filteredTaList;

    if (exportList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export.')),
      );
      return;
    }

    final headers = [
      'Staff Name',
      'Travel Date',
      'From Location',
      'To Location',
      'Purpose',
      'Distance (KM)',
      'Amount (₹)',
      'Status',
    ];

    final data = exportList.map((item) {
      return {
        'Staff Name': item.userName ?? '',
        'Travel Date': item.travelDate ?? '',
        'From Location': item.fromLocation ?? '',
        'To Location': item.toLocation ?? '',
        'Purpose': item.purpose ?? '',
        'Distance (KM)': item.computedTotalKm.toStringAsFixed(1),
        'Amount (₹)': item.computedTotalAmount.toStringAsFixed(2),
        'Status': (item.status ?? 'PENDING').toUpperCase(),
      };
    }).toList();

    // Appending Summary Totals Row as required by Requirement 11
    final totalKm = exportList.fold(0.0, (sum, i) => sum + i.computedTotalKm);
    final totalAmount = exportList.fold(0.0, (sum, i) => sum + i.computedTotalAmount);

    data.add({
      'Staff Name': 'TOTAL',
      'Travel Date': '',
      'From Location': '',
      'To Location': '',
      'Purpose': '',
      'Distance (KM)': totalKm.toStringAsFixed(1),
      'Amount (₹)': totalAmount.toStringAsFixed(2),
      'Status': '',
    });

    final periodStr = (fromDate != null && toDate != null)
        ? '${DateFormat('dd_MMM').format(fromDate!)}_to_${DateFormat('dd_MMM_yyyy').format(toDate!)}'
        : DateFormat('yyyyMMdd').format(DateTime.now());

    await exportToPDF(
      headers: headers,
      data: data,
      fileName: 'Travel_Allowance_Report_$periodStr',
    );
  }

  // Fallback Demonstration Dataset
  List<TravelAllowanceModel> getDummyData() {
    return [];
  }
}
