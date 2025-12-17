import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/time_track_model.dart';
import 'package:vidyanexis/controller/models/time_track_chart_data.dart';
import 'package:vidyanexis/controller/models/time_track_record.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';

class TimeTrackReportProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TimeTrackChartData> _chartData = [];
  List<TimeTrackChartData> get chartData => _chartData;

  //List<TimeTrackRecord> _allRecords = [];
  List<TimeTrackRecord> _filteredRecords = [];
  List<TimeTrackRecord> get records => _filteredRecords;

  String? _selectedDateFilter;
  String? get selectedDateFilter => _selectedDateFilter;

  bool _isFilter = false;
  bool get isFilter => _isFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Filter state
  DateTime? _fromDate;
  DateTime? get fromDate => _fromDate;
  DateTime? _toDate;
  DateTime? get toDate => _toDate;

  String _formattedFromDate = '';
  String _formattedToDate = '';
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;

  int? _selectedUser;
  int? get selectedUser => _selectedUser;

  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;

  List<TimeTrackModel> _timeTrackList = [];
  List<TimeTrackModel> get timeTrackList => _timeTrackList;

  TimeTrackReportProvider() {
    // _generateDummyData();
  }

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      _selectedDateFilterIndex = null;
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
    } else {
      _selectedDateFilterIndex = index;
      formatDate();
    }
    notifyListeners();
  }

  void setDateFilter(String title) {
    final now = DateTime.now();

    switch (title) {
      case 'Yesterday':
        _fromDate = now.subtract(const Duration(days: 1));
        _toDate = now.subtract(const Duration(days: 1));
        break;
      case 'Today':
        _fromDate = now;
        _toDate = now;
        break;
      case 'Tomorrow':
        _fromDate = now.add(const Duration(days: 1));
        _toDate = now.add(const Duration(days: 1));
        break;
      case 'This Week':
        _fromDate = now.subtract(Duration(days: now.weekday - 1));
        _toDate = now.add(Duration(days: 7 - now.weekday));
        break;
      case 'This Month':
        _fromDate = DateTime(now.year, now.month, 1);
        _toDate = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        _fromDate = null;
        _toDate = null;
        break;
    }
    notifyListeners();
  }

  void setFromDate(DateTime date) {
    _fromDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    notifyListeners();
  }

  void setToDate(DateTime date) {
    _toDate = date;
    _selectedDateFilterIndex = -1;
    formatDate();
    notifyListeners();
  }

  void formatDate() {
    if (_fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(_fromDate!);
    } else {
      _formattedFromDate = '';
    }

    if (_toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(_toDate!);
    } else {
      _formattedToDate = '';
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setFromDate(pickedDate);
    }
    notifyListeners();
  }

  void setUserFilter(int? userId) {
    _selectedUser = userId;
    // _applyFilters(); // API call will happen on 'Apply' or specific trigger
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _fromDate = null;
    _toDate = null;
    _formattedFromDate = '';
    _formattedToDate = '';
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    notifyListeners();
  }

  Future<void> getTimeTrackReport(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      // String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();
      String fromDateStr = _formattedFromDate;
      String toDateStr = _formattedToDate;

      // Handle "All" date case if strings are empty
      // If assumed logic: if empty send empty string or something else?
      // FollowupReport logic: if empty string, sends empty string.
      // API url construction:

      String url =
          '${HttpUrls.timeTrack}?Fromdate=$fromDateStr&By_User_Id=$toUserId';

      final response = await HttpRequest.httpGetRequest(endPoint: url);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null) {
          if (responseData is Map<String, dynamic> &&
              responseData.containsKey('success') &&
              responseData.containsKey('data')) {
            if (responseData['success'] == true) {
              final data = responseData['data'];

              if (data is List<dynamic>) {
                _timeTrackList =
                    data.map((item) => TimeTrackModel.fromJson(item)).toList();

                _chartData = _timeTrackList.map((item) {
                  return TimeTrackChartData(
                    item.entryDate,
                    item.count.toDouble(),
                    0,
                  );
                }).toList();

                notifyListeners();
              } else {
                print('Data is not a List: ${data.runtimeType}');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid data format')),
                  );
                }
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request failed')),
                );
              }
            }
          } else {
            // Handle the specific response format: [[{data}, ...], {metadata}]
            if (responseData is List<dynamic>) {
              List<dynamic> targetData = [];

              // Check if it's the nested format [[data], metadata]
              if (responseData.isNotEmpty && responseData[0] is List<dynamic>) {
                targetData = responseData[0];
              } else {
                // Assume it's a direct list of items
                targetData = responseData;
              }

              try {
                _timeTrackList = targetData
                    .map((item) =>
                        TimeTrackModel.fromJson(item as Map<String, dynamic>))
                    .toList();

                _chartData = _timeTrackList.map((item) {
                  return TimeTrackChartData(
                    item.entryDate,
                    item.count.toDouble(),
                    0,
                  );
                }).toList();

                notifyListeners();
              } catch (e) {
                print('Parsing error: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error parsing data')),
                  );
                }
              }
            } else {
              print(
                  'Unexpected response structure: ${responseData.runtimeType}');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unexpected response format')),
                );
              }
            }
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
