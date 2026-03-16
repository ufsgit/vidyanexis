import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class ChartData {
  final DateTime date;
  final double value;

  ChartData(this.date, this.value);
}

class SolarLeadReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<SearchLeadModel> _allLeads = [];
  
  List<ChartData> _leadsCreatedPerDay = [];
  List<ChartData> _conversionsPerDay = [];
  List<ChartData> _projectCostPerDay = [];

  List<ChartData> get leadsCreatedPerDay => _leadsCreatedPerDay;
  List<ChartData> get conversionsPerDay => _conversionsPerDay;
  List<ChartData> get projectCostPerDay => _projectCostPerDay;

  DateTime? _fromDate;
  DateTime? _toDate;
  
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  void setDateRange(DateTime? from, DateTime? to) {
    _fromDate = from;
    _toDate = to;
    notifyListeners();
  }

  Future<void> fetchReportData(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch leads without date filter (Is_Date=0) to get a pool for both Chart 1 (Created) and 2&3 (Converted)
      // This ensures we catch leads created in one period but converted in another.
      const int poolLimit = 2000;
      final response = await HttpRequest.httpGetRequest(
        endPoint: '${HttpUrls.searchLead}?lead_Name=&Is_Date=0&Fromdate=&Todate=&Page_Index1=1&Page_Index2=$poolLimit'
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is List) {
          _allLeads = data
              .map((item) => SearchLeadModel.fromJson(item))
              .toList();
          
          if (_allLeads.isNotEmpty && _allLeads.last.customerId == 0) {
             _allLeads.removeLast();
          }

          // Debug Logging as per Requirement 6
          debugPrint("Total leads fetched for processing: ${_allLeads.length}");
          _processData();
        }
      }
    } catch (e) {
      debugPrint('Error fetching solar lead report data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == "null") return null;
    try {
      // Try standard ISO parse
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Try DD/MM/YYYY or DD-MM-YYYY
        if (dateStr.contains('/')) {
          return DateFormat('dd/MM/yyyy').parse(dateStr);
        } else if (dateStr.contains('-') && dateStr.split('-')[0].length == 2) {
          return DateFormat('dd-MM-yyyy').parse(dateStr);
        }
      } catch (_) {}
    }
    return null;
  }

  void _processData() {
    Map<String, int> leadsCreatedGrouped = {};
    Map<String, int> conversionsGrouped = {};
    Map<String, double> projectCostGrouped = {};

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    
    // Date Range filtering
    DateTime rangeStart = _fromDate ?? DateTime(2000);
    DateTime rangeEnd = _toDate ?? DateTime.now().add(const Duration(days: 1));
    // Normalize range end to include the whole day
    rangeEnd = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day, 23, 59, 59);

    for (var lead in _allLeads) {
      // 1. Leads Created Per Day (Grouped by DATE only)
      // Filter by Entry_Date within range
      DateTime? createdDate = _parseDate(lead.entryDate);
      if (createdDate != null) {
        if (createdDate.isAfter(rangeStart.subtract(const Duration(seconds: 1))) && 
            createdDate.isBefore(rangeEnd.add(const Duration(seconds: 1)))) {
          String key = formatter.format(createdDate);
          leadsCreatedGrouped[key] = (leadsCreatedGrouped[key] ?? 0) + 1;
        }
      }

      // 2. Lead Conversion Count & 3. Project Cost
      // Filter by Registered_Date (conversion date) within range
      DateTime? conversionDate = _parseDate(lead.registeredDate);
      if (conversionDate != null) {
        if (conversionDate.isAfter(rangeStart.subtract(const Duration(seconds: 1))) && 
            conversionDate.isBefore(rangeEnd.add(const Duration(seconds: 1)))) {
          String key = formatter.format(conversionDate);
          
          // Group conversions count
          conversionsGrouped[key] = (conversionsGrouped[key] ?? 0) + 1;
          
          // Group project cost sum
          String cleanCost = lead.totalProjectCost.replaceAll(RegExp(r'[^0-9.]'), '');
          double cost = double.tryParse(cleanCost) ?? 0.0;
          projectCostGrouped[key] = (projectCostGrouped[key] ?? 0.0) + cost;
        }
      }
    }

    // Convert grouped Maps back to sorted Lists of ChartData
    _leadsCreatedPerDay = leadsCreatedGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _conversionsPerDay = conversionsGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    _projectCostPerDay = projectCostGrouped.entries
        .map((e) => ChartData(formatter.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Debug Logging as per Requirement 6
    debugPrint("Conversion chart data points: ${_conversionsPerDay.length}");
    debugPrint("Project cost chart data points: ${_projectCostPerDay.length}");
    if (_conversionsPerDay.isNotEmpty) {
      debugPrint("Sample conversion data: ${_conversionsPerDay.first.date} -> ${_conversionsPerDay.first.value}");
    }
  }
}
