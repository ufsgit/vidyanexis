import 'package:uuid/uuid.dart';

/// Represents a single captured GPS location data point.
class LocationPoint {
  final String id;
  final String userId;
  final String trackingSessionId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final int? batteryLevel;
  final bool isSynced;
  final int retryCount;
  final DateTime createdAt;

  LocationPoint({
    String? id,
    required this.userId,
    required this.trackingSessionId,
    required this.latitude,
    required this.longitude,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.speed = 0.0,
    this.heading = 0.0,
    DateTime? timestamp,
    this.batteryLevel,
    this.isSynced = false,
    this.retryCount = 0,
    DateTime? createdAt,
  })  : id = id ?? 'LOC-${const Uuid().v4()}',
        timestamp = timestamp ?? DateTime.now().toUtc(),
        createdAt = createdAt ?? DateTime.now().toUtc();

  /// Converts the entity into a Map suitable for SQLite persistence.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tracking_session_id': trackingSessionId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'battery_level': batteryLevel,
      'is_synced': isSynced ? 1 : 0,
      'retry_count': retryCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Reconstructs a LocationPoint instance from a SQLite row Map.
  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      trackingSessionId: map['tracking_session_id']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
      altitude: (map['altitude'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString())?.toUtc() ??
              DateTime.now().toUtc()
          : DateTime.now().toUtc(),
      batteryLevel: map['battery_level'] != null
          ? int.tryParse(map['battery_level'].toString())
          : null,
      isSynced: (map['is_synced'] == 1 || map['is_synced'] == true),
      retryCount: (map['retry_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())?.toUtc() ??
              DateTime.now().toUtc()
          : DateTime.now().toUtc(),
    );
  }

  /// Converts the entity into the JSON payload format expected by the backend API.
  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'battery_level': batteryLevel,
    };
  }

  /// Creates a copy of this instance with updated fields.
  LocationPoint copyWith({
    String? id,
    String? userId,
    String? trackingSessionId,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    int? batteryLevel,
    bool? isSynced,
    int? retryCount,
    DateTime? createdAt,
  }) {
    return LocationPoint(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trackingSessionId: trackingSessionId ?? this.trackingSessionId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isSynced: isSynced ?? this.isSynced,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
