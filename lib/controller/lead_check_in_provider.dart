import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/models/lead_check_in_model.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';

class LeadCheckInProvider extends ChangeNotifier {
  Map<int, List<LeadCheckIn>> _customerCheckInHistory = {};
  Map<int, List<LeadCheckIn>> get customerCheckInHistory =>
      _customerCheckInHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Local persistence for check-in status (fallback when history is empty)
  final Map<int, bool> _localCheckedInStatus = {};

  Future<void> initLocalStatus(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getBool('lead_checked_in_$customerId') ?? false;
    _localCheckedInStatus[customerId] = status;
    notifyListeners();
  }

  List<LeadCheckIn> getHistoryForCustomer(int customerId) {
    final history = _customerCheckInHistory[customerId] ?? [];
    // Ensure history is sorted by date descending (newest first)
    history.sort((a, b) {
      final dateA = _getLatestDate(a);
      final dateB = _getLatestDate(b);
      return dateB.compareTo(dateA);
    });
    return history;
  }

  DateTime _getLatestDate(LeadCheckIn record) {
    try {
      final inDate =
          record.checkinDate != null && record.checkinDate!.isNotEmpty
              ? DateTime.parse(record.checkinDate!)
              : DateTime(1900);
      final outDate =
          record.checkoutDate != null && record.checkoutDate!.isNotEmpty
              ? DateTime.parse(record.checkoutDate!)
              : DateTime(1900);
      return inDate.isAfter(outDate) ? inDate : outDate;
    } catch (e) {
      return DateTime(1900);
    }
  }

  bool isCheckedIn(int customerId) {
    final history = getHistoryForCustomer(customerId);
    if (history.isEmpty) {
      // Fallback to local persistence if history is empty (e.g. after app restart)
      return _localCheckedInStatus[customerId] ?? false;
    }
    final lastRecord = history.first;
    
    // Check both status string and checkoutData flag
    final status = lastRecord.checkinStatus?.toLowerCase() ?? "";
    final isStatusIn = status.contains("checked in") || status == "check in";
    final isDataIn =
        lastRecord.checkoutData == 1 || lastRecord.checkoutData == "1";

    // IMPORTANT: Check date-based status as seen in real API responses
    final hasCheckInDate = lastRecord.checkinDate != null && lastRecord.checkinDate!.isNotEmpty;
    final hasCheckOutDate = lastRecord.checkoutDate != null && lastRecord.checkoutDate!.isNotEmpty;
    
    // If we have a check-in date but no check-out date, the user is checked in
    final isDateCheckedIn = hasCheckInDate && !hasCheckOutDate;

    bool result = isStatusIn || isDataIn || isDateCheckedIn;

    // Keep local status in sync with history
    _localCheckedInStatus[customerId] = result;

    return result;
  }


  Future<void> fetchLeadCheckInReports(BuildContext context, String customerId,
      {String? fromDate, String? toDate}) async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";

      // Using the new report endpoint for history as well
      final response = await HttpRequest.httpGetRequest(
        endPoint:
            '${HttpUrls.getCheckinReport}?From_Date=${fromDate ?? ""}&To_Date=${toDate ?? ""}&User_Id=$userId',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null) {
          List<LeadCheckIn> allReports = [];
          if (data is List) {
            allReports = data
                .map((item) => LeadCheckIn.fromJson(item))
                .toList();
          } else {
            final leadResponse = LeadCheckInResponse.fromJson(data);
            allReports = leadResponse.data ?? [];
          }

          // FILTER for the specific customerId
          // The API returns Lead_Id in the LeadCheckIn model
          _customerCheckInHistory[int.parse(customerId)] = allReports.where((record) {
            // Check both customerId and leadId as consistency varies in API
            return record.customerId?.toString() == customerId || 
                   record.leadId?.toString() == customerId;
          }).toList();
        }
      }
    } catch (e) {
      log('Error fetching lead check-in reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> saveLeadCheckIn({
    required BuildContext context,
    required int customerId,
    required bool isCheckIn,
    String? leadName,
  }) async {
    bool isLoaderStopped = false;
    try {
      Loader.showLoader(context);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Loader.stopLoader(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      // High precision settings
      LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        forceLocationManager: true,
      );

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      double lat = position.latitude;
      double lon = position.longitude;

      if (lat == 0.0 || lon == 0.0) {
        Loader.stopLoader(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not capture location')),
        );
        return;
      }

      String address = "Lat: $lat, Long: $lon";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          address = [
            place.name,
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        }
      } catch (e) {
        log('Error fetching address: $e');
      }

      SharedPreferences preferences = await SharedPreferences.getInstance();

      String userId = preferences.getString('userId') ?? "";

      // Optimistic update for instant UI feedback
      final optimisticRecord = LeadCheckIn(
        customerId: customerId,
        checkinStatus: isCheckIn ? "Checked In" : "Checked Out",
        leadName: leadName,
        checkinDate: isCheckIn ? DateTime.now().toString() : null,
        checkoutDate: !isCheckIn ? DateTime.now().toString() : null,
        latitude: lat,
        longitude: lon,
      );
      if (_customerCheckInHistory.containsKey(customerId)) {
        _customerCheckInHistory[customerId]!.insert(0, optimisticRecord);
      } else {
        _customerCheckInHistory[customerId] = [optimisticRecord];
      }
      notifyListeners();

      final Map<String, dynamic> body = {
        "Location": address,
        "Lead_Id": customerId,
        "UserDetail_Id": int.tryParse(userId) ?? 0,
        "CheckoutData": isCheckIn ? 1 : 0,
        // Send as strings and with multiple possible keys for server compatibility
        "latitude": lat.toString(),
        "longitude": lon.toString(),
        "Latitude": lat.toString(),
        "Longitude": lon.toString(),
      };

      // If it's a checkout, add specific checkout keys just in case
      if (!isCheckIn) {
        body["checkout_latitude"] = lat.toString();
        body["checkout_longitude"] = lon.toString();
        body["Checkout_Latitude"] = lat.toString();
        body["Checkout_Longitude"] = lon.toString();
        body["checkout_location"] = address;
      } else {
        body["checkin_location"] = address;
      }

      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.checkin,
        bodyData: body,
      );

      if (response != null && response.statusCode == 200) {
        log('Check-in Response: ${response.data}');
        log('--- Lead Check-in Detail ---');
        log('Lead ID: $customerId');
        log('Status: ${isCheckIn ? "Checked In" : "Checked Out"}');
        log('Location: $address');
        log('Time: ${DateTime.now()}');
        log('--------------------------');

        // Stop loader BEFORE showing success dialog to avoid navigation stack issues
        Loader.stopLoader(context);
        isLoaderStopped = true;

        if (context.mounted) {
          _showSuccessDialog(context, isCheckIn);
        }

        // Persist status locally
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('lead_checked_in_$customerId', isCheckIn);
          _localCheckedInStatus[customerId] = isCheckIn;
        } catch (e) {
          log('Error saving local lead status: $e');
        }

        fetchLeadCheckInReports(context, customerId.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server Error')),
        );
      }
    } catch (e) {
      log('Exception occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
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
                      ? "You have successfully checked in for this lead."
                      : "You have successfully checked out for this lead.",
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
}
