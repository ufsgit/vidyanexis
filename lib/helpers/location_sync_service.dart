import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/helpers/location_database_helper.dart';
import 'package:vidyanexis/http/location_api_service.dart';
import 'package:vidyanexis/model/location/location_point.dart';

enum SyncState { idle, syncing, offline, error }

/// Manages offline-first batch synchronization of location data with network awareness and backoff retries.
class LocationSyncService {
  static final LocationSyncService _instance = LocationSyncService._internal();
  factory LocationSyncService() => _instance;
  LocationSyncService._internal();

  final LocationDatabaseHelper _dbHelper = LocationDatabaseHelper();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  Timer? _throttleTimer;

  bool _isSyncing = false;
  bool _isOnline = true;
  int _consecutiveFailures = 0;
  DateTime? _lastSyncTime;

  final StreamController<SyncState> _syncStateController = StreamController<SyncState>.broadcast();
  final StreamController<int> _pendingCountController = StreamController<int>.broadcast();

  Stream<SyncState> get syncStateStream => _syncStateController.stream;
  Stream<int> get pendingCountStream => _pendingCountController.stream;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initializes connectivity listener and restores sync state.
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLastSync = prefs.getString(LocationTrackingConstants.prefLastSyncTimestamp);
    if (savedLastSync != null) {
      _lastSyncTime = DateTime.tryParse(savedLastSync);
    }

    final initialConnectivity = await _connectivity.checkConnectivity();
    _updateConnectivityState(initialConnectivity);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !_isOnline;
      _updateConnectivityState(results);

      if (_isOnline && wasOffline) {
        LocationTrackingConstants.log('Connectivity restored. Triggering automatic pending location sync...');
        syncPendingLocations(force: true);
      }
    });

    await refreshPendingCount();
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);

    LocationTrackingConstants.log('Network state updated: ${_isOnline ? "Online" : "Offline"}');
    if (!_isOnline) {
      _syncStateController.add(SyncState.offline);
    }
  }

  /// Triggers batch upload of pending location records.
  Future<void> syncPendingLocations({bool force = false, String? explicitSessionId}) async {
    if (_isSyncing) {
      LocationTrackingConstants.log('Sync already in progress. Skipping...');
      return;
    }

    if (!_isOnline && !force) {
      LocationTrackingConstants.log('Cannot sync: Device is offline.');
      _syncStateController.add(SyncState.offline);
      return;
    }

    _isSyncing = true;
    _syncStateController.add(SyncState.syncing);

    try {
      final pendingCount = await _dbHelper.getPendingLocationCount();
      _pendingCountController.add(pendingCount);

      if (pendingCount == 0) {
        LocationTrackingConstants.log('No pending locations to sync.');
        _isSyncing = false;
        _consecutiveFailures = 0;
        _syncStateController.add(SyncState.idle);
        return;
      }

      LocationTrackingConstants.log('Pending locations count: $pendingCount. Fetching batch...');

      final List<LocationPoint> batch = await _dbHelper.getPendingLocations(
        limit: LocationTrackingConstants.batchUploadSize,
      );

      if (batch.isEmpty) {
        _isSyncing = false;
        _syncStateController.add(SyncState.idle);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String sessionId = explicitSessionId ??
          prefs.getString(LocationTrackingConstants.prefActiveSessionId) ??
          batch.first.trackingSessionId;

      final response = await LocationApiService.uploadLocationBatch(
        trackingSessionId: sessionId,
        locations: batch,
      );

      if (response.success && response.acceptedIds.isNotEmpty) {
        // Mark accepted records as synced
        await _dbHelper.markLocationsAsSynced(response.acceptedIds);
        _consecutiveFailures = 0;

        _lastSyncTime = DateTime.now();
        await prefs.setString(
          LocationTrackingConstants.prefLastSyncTimestamp,
          _lastSyncTime!.toIso8601String(),
        );

        LocationTrackingConstants.log('Sync successful for ${response.acceptedIds.length} records.');

        // Handle any failed IDs in this batch
        if (response.failedIds.isNotEmpty) {
          await _dbHelper.incrementRetryCount(response.failedIds);
        }

        // Clean up old synced records
        await _dbHelper.deleteSyncedLocations();

        final remainingPending = await _dbHelper.getPendingLocationCount();
        _pendingCountController.add(remainingPending);

        _isSyncing = false;
        _syncStateController.add(SyncState.idle);

        // If more items remain, process next batch
        if (remainingPending > 0) {
          syncPendingLocations(explicitSessionId: sessionId);
        }
      } else {
        // Batch failed completely or was not accepted
        _consecutiveFailures++;
        final failedIds = batch.map((e) => e.id).toList();
        await _dbHelper.incrementRetryCount(failedIds);

        LocationTrackingConstants.log('Sync batch failed (Attempt $_consecutiveFailures). Scheduling retry ladder...');

        _isSyncing = false;
        _syncStateController.add(SyncState.error);
        _scheduleRetry();
      }
    } catch (e) {
      LocationTrackingConstants.log('Unhandled error during sync: $e');
      _consecutiveFailures++;
      _isSyncing = false;
      _syncStateController.add(SyncState.error);
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();

    int delayIndex = _consecutiveFailures.clamp(0, LocationTrackingConstants.retryDelays.length - 1);
    final delay = LocationTrackingConstants.retryDelays[delayIndex];

    if (delay == Duration.zero) return;

    LocationTrackingConstants.log('Scheduling sync retry in ${delay.inSeconds} seconds...');
    _retryTimer = Timer(delay, () {
      if (_isOnline) {
        syncPendingLocations();
      }
    });
  }

  /// Refreshes pending count for listeners.
  Future<int> refreshPendingCount() async {
    final count = await _dbHelper.getPendingLocationCount();
    _pendingCountController.add(count);
    return count;
  }

  /// Disposes subscriptions and timers.
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _throttleTimer?.cancel();
    _syncStateController.close();
    _pendingCountController.close();
  }
}
