import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/helpers/location_database_helper.dart';
import 'package:vidyanexis/helpers/location_sync_service.dart';
import 'package:vidyanexis/http/location_api_service.dart';
import 'package:vidyanexis/model/location/location_point.dart';

enum TrackingStatus {
  idle,
  permissionRequired,
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  starting,
  active,
  stopping,
  stopped,
  error
}

/// Service managing background and foreground GPS location capture and persistence.
class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  final LocationDatabaseHelper _dbHelper = LocationDatabaseHelper();
  final LocationSyncService _syncService = LocationSyncService();
  final Battery _battery = Battery();

  StreamSubscription<Position>? _positionStreamSubscription;
  TrackingStatus _status = TrackingStatus.idle;
  String? _currentSessionId;
  LocationPoint? _lastCapturedLocation;

  final StreamController<TrackingStatus> _statusController = StreamController<TrackingStatus>.broadcast();
  final StreamController<LocationPoint> _locationStreamController = StreamController<LocationPoint>.broadcast();

  Stream<TrackingStatus> get statusStream => _statusController.stream;
  Stream<LocationPoint> get locationStream => _locationStreamController.stream;

  TrackingStatus get status => _status;
  bool get isTracking => _status == TrackingStatus.active || _status == TrackingStatus.starting;
  String? get currentSessionId => _currentSessionId;
  LocationPoint? get lastCapturedLocation => _lastCapturedLocation;

  /// Initializes the tracking service and restores session state if previously active.
  Future<void> initialize() async {
    await _syncService.initialize();

    final prefs = await SharedPreferences.getInstance();
    final wasActive = prefs.getBool(LocationTrackingConstants.prefIsTrackingActive) ?? false;
    _currentSessionId = prefs.getString(LocationTrackingConstants.prefActiveSessionId);

    _lastCapturedLocation = await _dbHelper.getLatestLocation();

    LocationTrackingConstants.log('Service initialized (wasActive: $wasActive, session: $_currentSessionId)');

    if (wasActive && _currentSessionId != null) {
      // Resume active tracking
      await startTracking(resumeExisting: true);
    }
  }

  /// Checks location permission and service status.
  Future<TrackingStatus> checkPermissions() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LocationTrackingConstants.log('Location services disabled on device.');
      _setStatus(TrackingStatus.serviceDisabled);
      return TrackingStatus.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _setStatus(TrackingStatus.permissionRequired);
      return TrackingStatus.permissionRequired;
    }

    if (permission == LocationPermission.deniedForever) {
      _setStatus(TrackingStatus.permissionPermanentlyDenied);
      return TrackingStatus.permissionPermanentlyDenied;
    }

    return TrackingStatus.idle;
  }

  /// Requests foreground and background permissions.
  Future<bool> requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setStatus(TrackingStatus.serviceDisabled);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        LocationTrackingConstants.log('Permission denied by user.');
        _setStatus(TrackingStatus.permissionDenied);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LocationTrackingConstants.log('Permission permanently denied by user.');
      _setStatus(TrackingStatus.permissionPermanentlyDenied);
      return false;
    }

    // Request notification permission for Android 13+ foreground service
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await ph.Permission.notification.request();
      } catch (e) {
        LocationTrackingConstants.log('Notification permission request note: $e');
      }
    }

    LocationTrackingConstants.log('Location permissions granted.');
    return true;
  }

  /// Starts location tracking engine.
  Future<bool> startTracking({bool resumeExisting = false}) async {
    if (isTracking) {
      LocationTrackingConstants.log('Tracking is already active.');
      return true;
    }

    _setStatus(TrackingStatus.starting);

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      LocationTrackingConstants.log('Cannot start tracking: No authenticated user session found.');
      _setStatus(TrackingStatus.error);
      return false;
    }

    // Manage tracking session
    if (!resumeExisting || _currentSessionId == null) {
      final now = DateTime.now().toUtc();
      final startResponse = await LocationApiService.startTrackingSession(startedAt: now);

      if (startResponse.success && startResponse.trackingSessionId != null) {
        _currentSessionId = startResponse.trackingSessionId;
      } else {
        // Fallback local session ID when offline to maintain offline-first tracking
        _currentSessionId = 'TS-${const Uuid().v4()}';
        LocationTrackingConstants.log('Offline mode: Generated local session ID: $_currentSessionId');
      }

      await prefs.setString(LocationTrackingConstants.prefActiveSessionId, _currentSessionId!);
      await prefs.setString(LocationTrackingConstants.prefTrackingStartedAt, now.toIso8601String());
    }

    await prefs.setBool(LocationTrackingConstants.prefIsTrackingActive, true);

    // Platform-specific LocationSettings for continuous background tracking
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: LocationTrackingConstants.minimumDistance.toInt(),
        forceLocationManager: false,
        intervalDuration: LocationTrackingConstants.locationInterval,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: LocationTrackingConstants.notificationTitle,
          notificationText: LocationTrackingConstants.notificationContent,
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true,
          color: Color(0xFF005A45),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: LocationTrackingConstants.minimumDistance.toInt(),
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      );
    }

    try {
      // Capture immediate initial location
      try {
        final initialPos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );
        await _handlePositionUpdate(initialPos, userId);
      } catch (e) {
        LocationTrackingConstants.log('Initial location capture timed out: $e');
      }

      _positionStreamSubscription?.cancel();
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          await _handlePositionUpdate(position, userId);
        },
        onError: (error) {
          LocationTrackingConstants.log('Position stream error: $error');
          _setStatus(TrackingStatus.error);
        },
      );

      _setStatus(TrackingStatus.active);
      LocationTrackingConstants.log('Tracking started successfully with session: $_currentSessionId');
      return true;
    } catch (e) {
      LocationTrackingConstants.log('Error starting tracking stream: $e');
      _setStatus(TrackingStatus.error);
      return false;
    }
  }

  /// Processes each captured GPS coordinate.
  Future<void> _handlePositionUpdate(Position position, String userId) async {
    try {
      int? batteryLevel;
      try {
        batteryLevel = await _battery.batteryLevel;
      } catch (e) {
        LocationTrackingConstants.log('Battery reading skipped: $e');
      }

      final point = LocationPoint(
        userId: userId,
        trackingSessionId: _currentSessionId ?? 'TS-UNKNOWN',
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp.toUtc(),
        batteryLevel: batteryLevel,
        isSynced: false,
        retryCount: 0,
        createdAt: DateTime.now().toUtc(),
      );

      _lastCapturedLocation = point;
      _locationStreamController.add(point);

      // Save locally first (offline-first guarantee)
      await _dbHelper.insertLocation(point);

      // Trigger sync
      _syncService.syncPendingLocations();
    } catch (e) {
      LocationTrackingConstants.log('Error handling position update: $e');
    }
  }

  /// Stops tracking, flushes pending locations, and closes the tracking session.
  Future<void> stopTracking() async {
    _setStatus(TrackingStatus.stopping);
    LocationTrackingConstants.log('Stopping tracking service...');

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    final prefs = await SharedPreferences.getInstance();
    final activeSessionId = _currentSessionId ?? prefs.getString(LocationTrackingConstants.prefActiveSessionId);

    // Attempt final flush of pending records before closing session
    if (activeSessionId != null) {
      try {
        await _syncService.syncPendingLocations(force: true, explicitSessionId: activeSessionId);
      } catch (e) {
        LocationTrackingConstants.log('Final sync attempt error: $e');
      }

      // Close backend session
      try {
        await LocationApiService.stopTrackingSession(
          trackingSessionId: activeSessionId,
          stoppedAt: DateTime.now().toUtc(),
        );
      } catch (e) {
        LocationTrackingConstants.log('Stop tracking session API error: $e');
      }
    }

    await prefs.remove(LocationTrackingConstants.prefActiveSessionId);
    await prefs.remove(LocationTrackingConstants.prefTrackingStartedAt);
    await prefs.setBool(LocationTrackingConstants.prefIsTrackingActive, false);

    _currentSessionId = null;
    _setStatus(TrackingStatus.stopped);
    LocationTrackingConstants.log('Tracking stopped successfully.');
  }

  void _setStatus(TrackingStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }

  /// Disposes controllers and active subscriptions.
  void dispose() {
    _positionStreamSubscription?.cancel();
    _statusController.close();
    _locationStreamController.close();
  }
}
