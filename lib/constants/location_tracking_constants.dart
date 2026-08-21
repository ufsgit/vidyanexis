import 'package:flutter/foundation.dart';

/// Centralized configuration constants for User/Employee Location Tracking.
class LocationTrackingConstants {
  // --- Tracking Frequency & Distance Settings ---
  /// Target location capture interval (2 to 5 minutes). Default: 3 minutes.
  static const Duration locationInterval = Duration(minutes: 3);

  /// Minimum displacement in meters required to trigger a GPS position update. Default: 50 meters.
  static const double minimumDistance = 50.0;

  /// Fast tracking interval for testing or high-accuracy requirements.
  static const Duration fastLocationInterval = Duration(seconds: 30);

  // --- Synchronization Settings ---
  /// Maximum number of location records uploaded in a single batch.
  static const int batchUploadSize = 50;

  /// Minimum interval between auto-sync runs when active.
  static const Duration syncThrottleDuration = Duration(seconds: 15);

  /// Controlled retry backoff ladder for failed synchronization attempts.
  static const List<Duration> retryDelays = [
    Duration.zero,
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 15),
  ];

  /// Maximum retry count before holding a record until manual sync.
  static const int maxRetryCount = 10;

  /// Retention period for synchronized location records before automated cleanup.
  static const Duration syncedDataRetention = Duration(days: 7);

  // --- Database Settings ---
  static const String databaseName = 'vidyanexis_location.db';
  static const int databaseVersion = 1;
  static const String tableNameLocations = 'locations';

  // --- Android Foreground Service Notification Settings ---
  static const String notificationChannelId = 'vidyanexis_duty_tracking_channel';
  static const String notificationChannelName = 'Duty Location Tracking';
  static const String notificationChannelDescription =
      'Shows foreground notification while duty location tracking is active.';
  static const String notificationTitle = 'VidyaNexis Duty Tracking';
  static const String notificationContent =
      'Recording field location for attendance and route tracking.';

  // --- Preferences Keys ---
  static const String prefActiveSessionId = 'active_tracking_session_id';
  static const String prefTrackingStartedAt = 'tracking_started_at';
  static const String prefIsTrackingActive = 'is_duty_tracking_active';
  static const String prefLastSyncTimestamp = 'last_location_sync_time';

  // --- Logging Helper ---
  static void log(String message) {
    if (kDebugMode) {
      // Avoid printing sensitive tokens/passwords
      debugPrint('[LOCATION] $message');
    }
  }
}
