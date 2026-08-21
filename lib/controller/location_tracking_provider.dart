import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/helpers/location_sync_service.dart';
import 'package:vidyanexis/helpers/location_tracking_service.dart';
import 'package:vidyanexis/model/location/location_point.dart';

/// Provider for managing and exposing location tracking state and user actions to UI.
class LocationTrackingProvider extends ChangeNotifier {
  final LocationTrackingService _trackingService = LocationTrackingService();
  final LocationSyncService _syncService = LocationSyncService();

  StreamSubscription<TrackingStatus>? _statusSubscription;
  StreamSubscription<LocationPoint>? _locationSubscription;
  StreamSubscription<SyncState>? _syncStateSubscription;
  StreamSubscription<int>? _pendingCountSubscription;

  TrackingStatus _status = TrackingStatus.idle;
  bool _isOnline = true;
  bool _isSyncing = false;
  int _pendingCount = 0;
  LocationPoint? _lastLocation;
  DateTime? _lastSyncTime;
  String? _errorMessage;

  TrackingStatus get status => _status;
  bool get isTracking => _trackingService.isTracking;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  int get pendingLocationCount => _pendingCount;
  LocationPoint? get lastLocation =>
      _lastLocation ?? _trackingService.lastCapturedLocation;
  DateTime? get lastSyncTime => _lastSyncTime ?? _syncService.lastSyncTime;
  String? get trackingSessionId => _trackingService.currentSessionId;
  String? get errorMessage => _errorMessage;

  LocationTrackingProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _status = _trackingService.status;
    _isOnline = _syncService.isOnline;
    _isSyncing = _syncService.isSyncing;
    _lastSyncTime = _syncService.lastSyncTime;
    _lastLocation = _trackingService.lastCapturedLocation;

    _statusSubscription = _trackingService.statusStream.listen((newStatus) {
      _status = newStatus;
      notifyListeners();
    });

    _locationSubscription = _trackingService.locationStream.listen((point) {
      _lastLocation = point;
      notifyListeners();
    });

    _syncStateSubscription = _syncService.syncStateStream.listen((syncState) {
      _isSyncing = (syncState == SyncState.syncing);
      _isOnline = (syncState != SyncState.offline);
      _lastSyncTime = _syncService.lastSyncTime;
      notifyListeners();
    });

    _pendingCountSubscription = _syncService.pendingCountStream.listen((count) {
      _pendingCount = count;
      notifyListeners();
    });

    await _trackingService.initialize();
    _pendingCount = await _syncService.refreshPendingCount();
    notifyListeners();
  }

  /// Initiates location tracking with session establishment.
  Future<bool> startTracking(BuildContext? context) async {
    _errorMessage = null;
    LocationTrackingConstants.log('Provider: startTracking requested');

    final started = await _trackingService.startTracking();
    if (!started) {
      if (_status == TrackingStatus.permissionRequired ||
          _status == TrackingStatus.permissionDenied ||
          _status == TrackingStatus.permissionPermanentlyDenied) {
        _errorMessage = 'Location permission is required to track duty routes.';
      } else if (_status == TrackingStatus.serviceDisabled) {
        _errorMessage = 'Please enable GPS / Location Services on your device.';
      } else {
        _errorMessage = 'Failed to start tracking session.';
      }
    }
    await refreshPendingCount();
    notifyListeners();
    return started;
  }

  /// Stops tracking, performs final sync, and ends session.
  Future<void> stopTracking() async {
    LocationTrackingConstants.log('Provider: stopTracking requested');
    await _trackingService.stopTracking();
    await refreshPendingCount();
    notifyListeners();
  }

  /// Requests location permissions from the system.
  Future<bool> requestPermission(BuildContext context) async {
    final granted = await _trackingService.requestPermissions();
    if (!granted && _status == TrackingStatus.permissionPermanentlyDenied) {
      // Prompt user to open app settings
      await ph.openAppSettings();
    }
    notifyListeners();
    return granted;
  }

  /// Manually triggers sync for pending location queue.
  Future<void> syncNow() async {
    LocationTrackingConstants.log('Provider: manual sync requested');
    await _syncService.syncPendingLocations(force: true);
    await refreshPendingCount();
    notifyListeners();
  }

  /// Refreshes the pending location records count.
  Future<void> refreshPendingCount() async {
    _pendingCount = await _syncService.refreshPendingCount();
    notifyListeners();
  }

  /// Opens device application settings.
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _locationSubscription?.cancel();
    _syncStateSubscription?.cancel();
    _pendingCountSubscription?.cancel();
    super.dispose();
  }
}
