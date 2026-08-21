import 'package:flutter_test/flutter_test.dart';
import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/model/location/location_point.dart';
import 'package:vidyanexis/model/location/tracking_session_model.dart';

void main() {
  group('LocationPoint Model Tests', () {
    test('Should properly instantiate LocationPoint and generate unique UUID id', () {
      final point1 = LocationPoint(
        userId: '1024',
        trackingSessionId: 'TS-001',
        latitude: 10.0159,
        longitude: 76.3419,
      );

      final point2 = LocationPoint(
        userId: '1024',
        trackingSessionId: 'TS-001',
        latitude: 10.0160,
        longitude: 76.3420,
      );

      expect(point1.id.startsWith('LOC-'), isTrue);
      expect(point2.id.startsWith('LOC-'), isTrue);
      expect(point1.id, isNot(equals(point2.id)));
      expect(point1.isSynced, isFalse);
      expect(point1.retryCount, equals(0));
    });

    test('Should convert LocationPoint to SQLite Map and reconstruct from Map', () {
      final now = DateTime.now().toUtc();
      final original = LocationPoint(
        id: 'LOC-TEST-001',
        userId: '1024',
        trackingSessionId: 'TS-SESSION-123',
        latitude: 10.0159,
        longitude: 76.3419,
        accuracy: 8.4,
        altitude: 18.2,
        speed: 3.8,
        heading: 142.0,
        timestamp: now,
        batteryLevel: 78,
        isSynced: true,
        retryCount: 2,
        createdAt: now,
      );

      final map = original.toMap();
      expect(map['id'], equals('LOC-TEST-001'));
      expect(map['user_id'], equals('1024'));
      expect(map['tracking_session_id'], equals('TS-SESSION-123'));
      expect(map['latitude'], equals(10.0159));
      expect(map['longitude'], equals(76.3419));
      expect(map['accuracy'], equals(8.4));
      expect(map['altitude'], equals(18.2));
      expect(map['speed'], equals(3.8));
      expect(map['heading'], equals(142.0));
      expect(map['battery_level'], equals(78));
      expect(map['is_synced'], equals(1));
      expect(map['retry_count'], equals(2));

      final reconstructed = LocationPoint.fromMap(map);
      expect(reconstructed.id, equals(original.id));
      expect(reconstructed.userId, equals(original.userId));
      expect(reconstructed.trackingSessionId, equals(original.trackingSessionId));
      expect(reconstructed.latitude, equals(original.latitude));
      expect(reconstructed.longitude, equals(original.longitude));
      expect(reconstructed.accuracy, equals(original.accuracy));
      expect(reconstructed.altitude, equals(original.altitude));
      expect(reconstructed.speed, equals(original.speed));
      expect(reconstructed.heading, equals(original.heading));
      expect(reconstructed.batteryLevel, equals(78));
      expect(reconstructed.isSynced, isTrue);
      expect(reconstructed.retryCount, equals(2));
    });

    test('Should convert LocationPoint to API JSON matching the backend contract', () {
      final now = DateTime.utc(2026, 8, 20, 16, 42, 31);
      final point = LocationPoint(
        id: 'LOC-001',
        userId: '1024',
        trackingSessionId: 'TS-UUID',
        latitude: 10.0159,
        longitude: 76.3419,
        accuracy: 8.4,
        altitude: 18.2,
        speed: 3.8,
        heading: 142.0,
        timestamp: now,
        batteryLevel: 78,
      );

      final apiJson = point.toApiJson();
      expect(apiJson['id'], equals('LOC-001'));
      expect(apiJson['latitude'], equals(10.0159));
      expect(apiJson['longitude'], equals(76.3419));
      expect(apiJson['accuracy'], equals(8.4));
      expect(apiJson['altitude'], equals(18.2));
      expect(apiJson['speed'], equals(3.8));
      expect(apiJson['heading'], equals(142.0));
      expect(apiJson['timestamp'], equals('2026-08-20T16:42:31.000Z'));
      expect(apiJson['battery_level'], equals(78));
    });
  });

  group('Tracking Session Models Tests', () {
    test('Should parse start/stop tracking session response', () {
      final rawJson = {
        "success": true,
        "tracking_session_id": "TS-UUID-9988",
        "started_at": "2026-08-20T09:00:00Z"
      };

      final response = TrackingSessionResponse.fromJson(rawJson);
      expect(response.success, isTrue);
      expect(response.trackingSessionId, equals('TS-UUID-9988'));
      expect(response.startedAt, equals(DateTime.parse('2026-08-20T09:00:00Z')));
    });

    test('Should parse batch upload response with accepted and failed ids', () {
      final rawJson = {
        "success": true,
        "accepted_ids": ["LOC-001", "LOC-002"],
        "failed_ids": ["LOC-003"]
      };

      final response = LocationBatchUploadResponse.fromJson(rawJson);
      expect(response.success, isTrue);
      expect(response.acceptedIds, equals(['LOC-001', 'LOC-002']));
      expect(response.failedIds, equals(['LOC-003']));
    });
  });

  group('Location Tracking Constants Tests', () {
    test('Should verify tracking interval, distance, batch size and retry configuration', () {
      expect(LocationTrackingConstants.locationInterval.inMinutes, greaterThanOrEqualTo(2));
      expect(LocationTrackingConstants.locationInterval.inMinutes, lessThanOrEqualTo(5));
      expect(LocationTrackingConstants.minimumDistance, greaterThanOrEqualTo(50.0));
      expect(LocationTrackingConstants.batchUploadSize, equals(50));
      expect(LocationTrackingConstants.retryDelays.length, greaterThanOrEqualTo(4));
      expect(LocationTrackingConstants.tableNameLocations, equals('locations'));
    });
  });
}
