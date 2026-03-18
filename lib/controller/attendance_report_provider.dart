import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/attendance_details_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class AttendanceReportProvider extends ChangeNotifier {
  List<AttendanceDetails> _taskReport = [];
  List<AttendanceDetails> get taskReport => _taskReport;
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
  Future<void> getSearchTaskReport(BuildContext context) async {
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
              '${HttpUrls.getAttendanceByDate}?fromDate=$_fromDateS&toDate=$_toDateS&userId=$toUserId&searchName=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          log(data['data'].toString());
          final dataItem = data['data'] ?? [];

          _taskReport = (dataItem as List<dynamic>)
              .map((item) => AttendanceDetails.fromJson(item))
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

  Future<void> getSearchTaskReportNoContext() async {
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
              '${HttpUrls.getAttendanceByDate}?fromDate=$_fromDateS&toDate=$_toDateS&userId=$toUserId&searchName=$_Search');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null) {
          // log(data.toString());
          log(data['data'].toString());
          final dataItem = data['data'] ?? [];

          _taskReport = (dataItem as List<dynamic>)
              .map((item) => AttendanceDetails.fromJson(item))
              .toList();

          notifyListeners();
        }
      } else {}
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> getLocation({required BuildContext context}) async {
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
        // High precision settings
        LocationSettings locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          forceLocationManager: true,
        );

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );

        double latVal = position.latitude;
        double lonVal = position.longitude;

        if (latVal != 0.0 && lonVal != 0.0) {
          print('current');
          latitude = latVal.toString();
          longitude = lonVal.toString();
          location = await getAddressFromCoordinates(latVal, lonVal);
        }
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
          String address = [
            place.name,
            place.subThoroughfare,
            place.street,
            place.locality,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
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
    bool isLoaderStopped = false;
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
        endPoint: HttpUrls.saveAttendance,
        bodyData: bodyData,
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
            await prefs.remove('check_out_time_$selectedUserId');
            _currentCheckInTime = checkInTime;
            _currentCheckOutTime = '';
            _isCompletedToday = false;
            notifyListeners();

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
            await prefs.setString(
                'check_out_time_$selectedUserId', checkOutTime);
            await prefs.setBool('is_completed_today_$selectedUserId', true);
            _currentCheckInTime = '';
            _currentCheckOutTime = checkOutTime;
            _currentAttendanceDetailId = 0;
            _isCompletedToday = true;
            notifyListeners();
          }
        } catch (e) {
          print('Error saving local state: $e');
        }

        // Stop loader first
        Loader.stopLoader(context);
        isLoaderStopped = true;

        if (closeOnSuccess) {
          Navigator.pop(context);
        }

        if (context.mounted) {
          _showSuccessDialog(context, checkInTime != null);
        }
        print(data);
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
        Loader.stopLoader(context);
        isLoaderStopped = true;
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
      Loader.stopLoader(context);
      isLoaderStopped = true;
      return false;
    } finally {
      if (!isLoaderStopped) {
        Loader.stopLoader(context);
      }
    }
  }

  void _showSuccessDialog(BuildContext context, bool isCheckIn) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isCheckIn ? "Check-in Successful" : "Check-out Successful",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isCheckIn
                      ? "Your attendance check-in was successful."
                      : "Your attendance check-out was successful.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _currentCheckInTime = '';
  String get currentCheckInTime => _currentCheckInTime;

  String _currentCheckOutTime = '';
  String get currentCheckOutTime => _currentCheckOutTime;

  bool _isCompletedToday = false;
  bool get isCompletedToday => _isCompletedToday;

  Future<bool> checkIsCheckedIn(int userId, {bool forceApi = false}) async {
    // Initial cleanup of in-memory state, but we'll try to restore it from Prefs
    _isCompletedToday = false;
    _currentCheckInTime = '';
    _currentCheckOutTime = '';
    _currentAttendanceDetailId = 0;

    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final prefs = await SharedPreferences.getInstance();

      // Load local state for today as a baseline
      final savedStatus = prefs.getBool('is_checked_in_$userId') ?? false;
      final savedDate = prefs.getString('check_in_date_$userId');
      final savedCheckIn = prefs.getString('check_in_time_$userId') ?? '';
      final savedCheckOut = prefs.getString('check_out_time_$userId') ?? '';
      final savedId = prefs.getInt('attendance_id_$userId') ?? 0;
      final savedCompleted =
          prefs.getBool('is_completed_today_$userId') ?? false;

      // If we have local state for today, use it as baseline
      bool localStateIsValidToday = (savedDate == dateStr);
      if (localStateIsValidToday) {
        _currentAttendanceDetailId = savedId;
        _currentCheckInTime = savedCheckIn;
        _currentCheckOutTime = savedCheckOut;
        _isCompletedToday = savedCompleted;
      }

      // If NO forceApi and local state is valid for today, return it immediately
      if (!forceApi && localStateIsValidToday) {
        return savedStatus;
      }

      // Fetch from API to sync/verify
      final response = await HttpRequest.httpGetRequest(
          endPoint:
              '${HttpUrls.getAttendanceByDate}?fromDate=$dateStr&toDate=$dateStr&userId=$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          final dataItem = data['data'] ?? [];
          if (dataItem is List && dataItem.isNotEmpty) {
            bool foundActiveCheckIn = false;
            _isCompletedToday = false; // Reset to check from API items

            for (var item in dataItem) {
              String checkIn = item['Check_In_Time']?.toString() ?? '';
              String checkOut = item['Check_Out_Time']?.toString() ?? '';
              int attendanceId = int.tryParse(
                      item['Attendance_Master_Id']?.toString() ?? "0") ??
                  0;

              // If checked in but not checked out, then IsCheckedIn is true
              if (checkIn.isNotEmpty &&
                  (checkOut.isEmpty || checkOut == 'null')) {
                foundActiveCheckIn = true;
                _currentAttendanceDetailId = attendanceId;
                _currentCheckInTime = checkIn;
                _isCompletedToday = false;

                // Sync local storage
                await prefs.setBool('is_checked_in_$userId', true);
                await prefs.setString('check_in_date_$userId', dateStr);
                await prefs.setInt('attendance_id_$userId', attendanceId);
                await prefs.setString('check_in_time_$userId', checkIn);
                await prefs.setBool('is_completed_today_$userId', false);
              }

              if (checkIn.isNotEmpty &&
                  checkOut.isNotEmpty &&
                  checkOut != 'null') {
                // If we haven't found an active check-in yet, this might be a completed session
                if (!foundActiveCheckIn) {
                  _isCompletedToday = true;
                  _currentCheckOutTime = checkOut;
                  await prefs.setString('check_out_time_$userId', checkOut);
                }
              }
            }

            if (foundActiveCheckIn) {
              notifyListeners();
              return true;
            } else {
              // All items are completed
              await prefs.setBool('is_checked_in_$userId', false);
              await prefs.setString('check_in_date_$userId', dateStr);
              await prefs.remove('attendance_id_$userId');
              await prefs.remove('check_in_time_$userId');
              await prefs.setBool(
                  'is_completed_today_$userId', _isCompletedToday);

              _currentAttendanceDetailId = 0;
              _currentCheckInTime = '';
              notifyListeners();
              return false;
            }
          } else {
            // No records on server for today
            await prefs.setBool('is_checked_in_$userId', false);
            await prefs.setString('check_in_date_$userId', dateStr);
            await prefs.remove('attendance_id_$userId');
            await prefs.remove('check_in_time_$userId');
            await prefs.setBool('is_completed_today_$userId', false);
            await prefs.remove('check_out_time_$userId');
            _currentAttendanceDetailId = 0;
            _currentCheckInTime = '';
            _currentCheckOutTime = '';
            _isCompletedToday = false;
            notifyListeners();
            return false;
          }
        }
      } else {
        // API Failed (e.g. 500, 404, or network error with status 0)
        // If we have a valid baseline for today, keep it instead of defaulting to false
        if (localStateIsValidToday) {
          print('API Failed, falling back to local state for today');
          notifyListeners();
          return savedStatus;
        }
      }
    } catch (e) {
      print('Error checking status: $e');
    }

    // Default return if everything else fails but we have no local state
    notifyListeners();
    return false;
  }
}
