import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/attendance_record_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class AttendanceReportProvider extends ChangeNotifier {
  List<AttendanceRecord> _taskReport = [];
  List<AttendanceRecord> get taskReport => _taskReport;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _formattedFromDate = '';
  String _formattedToDate = '';
  String get formattedFromDate => _formattedFromDate;
  String get formattedToDate => _formattedToDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  bool _isFilter = false;
  bool get isFilter => _isFilter;
  String _Search = '';
  String _fromDateS = '';
  String _toDateS = '';
  String _Status = '';
  String _AssignedTo = '';
  String _TaskType = '';

  String get Search => _Search;
  String get fromDateS => _fromDateS;
  String get toDateS => _toDateS;
  String get Status => _Status;
  String get AssignedTo => _AssignedTo;
  String get TaskType => _TaskType;
  int? _selectedStatus;
  int? _selectedAMCStatus;
  int? _selectedUser;
  int? _selectedTaskType;
  int? _selectedDateFilterIndex;
  int? get selectedDateFilterIndex => _selectedDateFilterIndex;
  int? get selectedStatus => _selectedStatus;
  int? get selectedAMCStatus => _selectedAMCStatus;
  int? get selectedUser => _selectedUser;
  int? get selectedTaskType => _selectedTaskType;

  String location = '';
  String latitude = '';
  String longitude = '';
  int _currentAttendanceDetailId = 0;

  final TextEditingController assignToFollowUpController =
      TextEditingController();

  void toggleFilter() {
    _isFilter = !_isFilter;
    notifyListeners();
  }

  void selectDateFilterOption(int? index) {
    if (index == null) {
      // If the index is null, we are clearing the filter
      _selectedDateFilterIndex = null; // Reset to the default "no filter" state
      _fromDate = null;
      _toDate = null;
      _formattedFromDate = '';
      _formattedToDate = '';
    } else {
      _selectedDateFilterIndex = index; // Set the new selected filter index
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

    notifyListeners(); // Notify listeners to rebuild the UI
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
    if (fromDate != null) {
      _formattedFromDate = DateFormat('yyyy-MM-dd').format(fromDate!);
    } else {
      _formattedFromDate = '';
    }

    if (toDate != null) {
      _formattedToDate = DateFormat('yyyy-MM-dd').format(toDate!);
    } else {
      _formattedToDate = '';
    }
  }

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2000), // Minimum date
      lastDate: DateTime(2101), // Maximum date
    );

    if (pickedDate != null) {
      if (isFromDate) {
        setFromDate(pickedDate); // Set the 'from' date in provider
      } else {
        setToDate(pickedDate); // Set the 'to' date in provider
      }
    }
    notifyListeners();
  }

  void setStatus(int newStatus) {
    _selectedStatus = newStatus;
    print(_selectedStatus.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setUserFilterStatus(int newStatus) {
    _selectedUser = newStatus;
    print(_selectedUser.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void setTaskType(int newStatus) {
    _selectedTaskType = newStatus;
    print(_selectedTaskType.toString());
    notifyListeners(); // Notify listeners about the change
  }

  void removeStatus() {
    _selectedStatus = null;
    _selectedUser = null;
    _selectedDateFilterIndex = null;
    _selectedTaskType = null;
    _fromDateS = '';
    _toDateS = '';
    notifyListeners();
  }

  void setTaskSearchCriteria(String search, String fromDate, String toDate,
      String status, String assignedTo, String taskType) {
    _Search = search;
    _fromDateS = fromDate;
    _toDateS = toDate;
    _Status = status;
    _AssignedTo = assignedTo;
    _TaskType = taskType;
    notifyListeners(); // Notify listeners so that UI can rebuild
  }

  //task report
  getSearchTaskReport(BuildContext context) async {
    try {
      Loader.showLoader(context);
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      print(_fromDateS);
      print(_toDateS);
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        if (_fromDateS.isEmpty) {
          _fromDateS = "";
        }
        if (_toDateS.isEmpty) {
          _toDateS = "";
        }
      } else {
        isDate = "1";
      }
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      if (_TaskType.isEmpty || _TaskType == 'null') {
        _TaskType = '0';
      }

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getAttendance}?fromDate=$_fromDateS&toDate=$_toDateS&userId=$toUserId&searchName=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data['data'].toString());
          final dataItem = data['data'] ?? [];

          _taskReport = (dataItem as List<dynamic>)
              .map((item) => AttendanceRecord.fromJson(item))
              .toList();

          Loader.stopLoader(context);
          notifyListeners();
        }
      } else {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      Loader.stopLoader(context);
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    }
  }

  getSearchTaskReportNoContext() async {
    try {
      if (_Status.isEmpty || _Status == 'null') {
        _Status = '0';
      }
      String isDate = "0";
      if (_fromDateS.isEmpty && _toDateS.isEmpty) {
        isDate = "0";
        if (_fromDateS.isEmpty) {
          _fromDateS = "2024-01-01";
        }
        if (_toDateS.isEmpty) {
          _toDateS = "2024-01-01";
        }
      } else {
        isDate = "1";
      }
      print(_fromDateS);
      print(_toDateS);
      // SharedPreferences preferences = await SharedPreferences.getInstance();
      // String userId = preferences.getString('userId') ?? "";

      String toUserId = (_selectedUser ?? 0).toString();

      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getAttendance}?fromDate=$_fromDateS&toDate=$_toDateS&userId=$toUserId&searchName=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());
          log(data['data'].toString());
          final dataItem = data['data'] ?? [];

          _taskReport = (dataItem as List<dynamic>)
              .map((item) => AttendanceRecord.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  getLocation({required BuildContext context}) async {
    // if (!kIsWeb) {
    Loader.showLoader(context);
    PermissionStatus locationStatus = await Permission.location.status;

    print(locationStatus.isPermanentlyDenied);
    if (locationStatus.isDenied) {
      locationStatus = await Permission.location.request();

      print(locationStatus);
    }

    if (locationStatus.isPermanentlyDenied) {
      await openAppSettings();
    }

    if (!locationStatus.isDenied) {
      try {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        print('current');
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        location = await getAddressFromCoordinates(
            position.latitude, position.longitude);
        print(location);
        print(latitude);
        print(longitude);
        Loader.stopLoader(context);
      } catch (e) {
        Loader.stopLoader(context);
        print('Error: $e');
      }
    }
    // }
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      // Ensure GeocodingPlatform.instance is available and not null
      final geocoding = GeocodingPlatform.instance;
      if (geocoding != null) {
        // Get the list of placemarks based on latitude and longitude
        List<Placemark> placemarks =
            await geocoding.placemarkFromCoordinates(latitude, longitude);

        // If the list is not empty, return the first result
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String address =
              '${place.street}, ${place.locality}, ${place.country}';
          return address; // Return the formatted address
        } else {
          return ''; // In case no address is found
        }
      } else {
        return '';
      }
    } catch (e) {
      print('Error occurred: $e');
      return '';
    }
  }

  Future<bool> saveAttendance(int selectedUserId, BuildContext context,
      {String? checkInTime,
      String? checkOutTime,
      String? employeeCode,
      bool closeOnSuccess = true}) async {
    print(selectedUserId);
    print(assignToFollowUpController.text.toString());
    try {
      Loader.showLoader(context);

      final Map<String, dynamic> bodyData = {
        "User_Details_Id": selectedUserId,
        "User_Details_Name": assignToFollowUpController.text.toString(),
        "photo": "",
        "location": location,
        "latitude": latitude,
        "longitude": longitude,
        "Employee_Code": employeeCode ?? "",
        "Attendance_Master_Id":
            checkInTime != null ? 0 : _currentAttendanceDetailId,
      };

      if (checkInTime != null) {
        final dt = DateTime.parse(checkInTime);
        bodyData["Check_In_Date"] = DateFormat('yyyy-MM-dd').format(dt);
        bodyData["Check_In_Time_Only"] = DateFormat('HH:mm:ss').format(dt);
      }

      if (checkOutTime != null) {
        final dt = DateTime.parse(checkOutTime);
        bodyData["Check_Out_Date"] = DateFormat('yyyy-MM-dd').format(dt);
        bodyData["Check_Out_Time_Only"] = DateFormat('HH:mm:ss').format(dt);
      }
      //... rest of the function

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.saveAttendanceMultiple,
        bodyData: {
          "attendanceList": [bodyData]
        },
      );

      if (response!.statusCode == 200) {
        final data = response.data;
        log('Success');
        getSearchTaskReport(context);
        assignToFollowUpController.clear();

        // Save state locally
        try {
          final prefs = await SharedPreferences.getInstance();
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          if (checkInTime != null) {
            // User Checked In
            await prefs.setBool('is_checked_in_$selectedUserId', true);
            await prefs.setString('check_in_date_$selectedUserId', todayStr);
            await prefs.setString('check_in_time_$selectedUserId', checkInTime);
            await prefs.setBool('is_completed_today_$selectedUserId', false);
            _currentCheckInTime = checkInTime;

            // We don't have the ID yet, so we must fetch it.
            // Add delay to allow server validation/indexing.
            await Future.delayed(const Duration(milliseconds: 500));
            bool foundOnServer =
                await checkIsCheckedIn(selectedUserId, forceApi: true);

            if (!foundOnServer) {
              // If server doesn't show it yet, FORCE local state to true so UI doesn't revert.
              await prefs.setBool('is_checked_in_$selectedUserId', true);
              await prefs.setString('check_in_date_$selectedUserId', todayStr);
              await prefs.setBool('is_completed_today_$selectedUserId', false);
              // Ensure time is preserved
              if (_currentCheckInTime.isEmpty) {
                _currentCheckInTime = checkInTime;
                await prefs.setString(
                    'check_in_time_$selectedUserId', checkInTime);
              }
            }
          } else if (checkOutTime != null) {
            // User Checked Out
            await prefs.setBool('is_checked_in_$selectedUserId', false);
            await prefs.setString('check_in_date_$selectedUserId', todayStr);
            await prefs.remove('attendance_id_$selectedUserId');
            await prefs.remove('check_in_time_$selectedUserId');
            await prefs.setBool('is_completed_today_$selectedUserId', true);
            _currentCheckInTime = '';
            _currentAttendanceDetailId = 0;
          }
        } catch (e) {
          print('Error saving local state: $e');
        }

        if (closeOnSuccess) {
          Navigator.pop(context);
        }
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance Saved')),
        );
        print(data);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
      return false;
    }
  }

  String _currentCheckInTime = '';
  String get currentCheckInTime => _currentCheckInTime;

  bool _isCompletedToday = false;
  bool get isCompletedToday => _isCompletedToday;

  Future<bool> checkIsCheckedIn(int userId, {bool forceApi = false}) async {
    _isCompletedToday = false;
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final prefs = await SharedPreferences.getInstance();

      // Check local storage first (if not forced)
      if (!forceApi) {
        final savedDate = prefs.getString('check_in_date_$userId');
        if (savedDate == dateStr) {
          if (prefs.containsKey('is_checked_in_$userId')) {
            _currentAttendanceDetailId =
                prefs.getInt('attendance_id_$userId') ?? 0;
            _currentCheckInTime =
                prefs.getString('check_in_time_$userId') ?? '';
            bool status = prefs.getBool('is_checked_in_$userId') ?? false;

            // Check implicit completion (new pref)
            _isCompletedToday =
                prefs.getBool('is_completed_today_$userId') ?? false;

            return status;
          }
        }
      }

      // If no local state for today, fetch from API
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getAttendanceByDate}?fromDate=$dateStr&toDate=$dateStr&userId=$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          final dataItem = data['data'] ?? [];
          if (dataItem is List && dataItem.isNotEmpty) {
            for (var item in dataItem) {
              String checkIn = item['Check_In_Time']?.toString() ?? '';
              String checkOut = item['Check_Out_Time']?.toString() ?? '';
              int attendanceId = int.tryParse(
                      item['Attendance_Master_Id']?.toString() ?? "0") ??
                  0;

              // If checked in but not checked out, then IsCheckedIn is true
              if (checkIn.isNotEmpty &&
                  (checkOut.isEmpty || checkOut == 'null')) {
                // Sync local storage
                await prefs.setBool('is_checked_in_$userId', true);
                await prefs.setString('check_in_date_$userId', dateStr);
                await prefs.setInt('attendance_id_$userId', attendanceId);
                await prefs.setString('check_in_time_$userId', checkIn);
                await prefs.setBool('is_completed_today_$userId', false);
                _currentAttendanceDetailId = attendanceId;
                _currentCheckInTime = checkIn;
                return true;
              }

              if (checkIn.isNotEmpty &&
                  (checkOut.isNotEmpty && checkOut != 'null')) {
                _isCompletedToday = true;
              }
            }
            // If we found records but none were active check-ins (all checked out)
            await prefs.setBool('is_checked_in_$userId', false);
            await prefs.setString('check_in_date_$userId', dateStr);
            await prefs.remove('attendance_id_$userId');
            await prefs.remove('check_in_time_$userId');

            // If _isCompletedToday was set to true in the loop, save it to prefs
            await prefs.setBool(
                'is_completed_today_$userId', _isCompletedToday);

            _currentAttendanceDetailId = 0;
            _currentCheckInTime = '';
            // _isCompletedToday is already set to true in the loop
            return false;
          } else {
            // No records implies not checked in
            await prefs.setBool('is_checked_in_$userId', false);
            await prefs.setString('check_in_date_$userId', dateStr);
            await prefs.remove('attendance_id_$userId');
            await prefs.remove('check_in_time_$userId');
            await prefs.setBool(
                'is_completed_today_$userId', false); // Explicitly false
            _currentAttendanceDetailId = 0;
            _currentCheckInTime = '';
          }
        }
      }
    } catch (e) {
      print('Error checking status: $e');
    }
    return false;
  }
}
