import 'package:vidyanexis/constants/location_tracking_constants.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/model/location/location_point.dart';
import 'package:vidyanexis/model/location/tracking_session_model.dart';

/// Backend API integration layer for user/employee location tracking.
class LocationApiService {
  /// Initiates a new tracking session on the backend.
  static Future<TrackingSessionResponse> startTrackingSession({
    required DateTime startedAt,
  }) async {
    final payload = {
      'started_at': startedAt.toUtc().toIso8601String(),
    };

    LocationTrackingConstants.log('Calling API: startTrackingSession ($payload)');

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.trackingStart,
        bodyData: payload,
      );

      if (response != null && response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final parsed = TrackingSessionResponse.fromJson(response.data as Map<String, dynamic>);
        LocationTrackingConstants.log('startTrackingSession success: session=${parsed.trackingSessionId}');
        return parsed;
      } else {
        LocationTrackingConstants.log('startTrackingSession failed: statusCode=${response?.statusCode}');
        return TrackingSessionResponse(
          success: false,
          message: 'Server returned status code: ${response?.statusCode}',
        );
      }
    } catch (e) {
      LocationTrackingConstants.log('startTrackingSession exception: $e');
      return TrackingSessionResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Concludes an active tracking session on the backend.
  static Future<TrackingSessionResponse> stopTrackingSession({
    required String trackingSessionId,
    required DateTime stoppedAt,
  }) async {
    final payload = {
      'tracking_session_id': trackingSessionId,
      'stopped_at': stoppedAt.toUtc().toIso8601String(),
    };

    LocationTrackingConstants.log('Calling API: stopTrackingSession ($payload)');

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.trackingStop,
        bodyData: payload,
      );

      if (response != null && response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final parsed = TrackingSessionResponse.fromJson(response.data as Map<String, dynamic>);
        LocationTrackingConstants.log('stopTrackingSession success: session=${parsed.trackingSessionId}');
        return parsed;
      } else {
        LocationTrackingConstants.log('stopTrackingSession failed: statusCode=${response?.statusCode}');
        return TrackingSessionResponse(
          success: false,
          message: 'Server returned status code: ${response?.statusCode}',
        );
      }
    } catch (e) {
      LocationTrackingConstants.log('stopTrackingSession exception: $e');
      return TrackingSessionResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Uploads a batch of location points to the backend.
  static Future<LocationBatchUploadResponse> uploadLocationBatch({
    required String trackingSessionId,
    required List<LocationPoint> locations,
  }) async {
    if (locations.isEmpty) {
      return LocationBatchUploadResponse(
        success: true,
        acceptedIds: [],
        failedIds: [],
      );
    }

    final payload = {
      'tracking_session_id': trackingSessionId,
      'locations': locations.map((loc) => loc.toApiJson()).toList(),
    };

    LocationTrackingConstants.log('Calling API: uploadLocationBatch (count=${locations.length}, session=$trackingSessionId)');

    try {
      final response = await HttpRequest.httpPostRequest(
        endPoint: HttpUrls.trackBatch,
        bodyData: payload,
      );

      if (response != null && response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final parsed = LocationBatchUploadResponse.fromJson(response.data as Map<String, dynamic>);
        LocationTrackingConstants.log('uploadLocationBatch success: accepted=${parsed.acceptedIds.length}, failed=${parsed.failedIds.length}');
        return parsed;
      } else {
        LocationTrackingConstants.log('uploadLocationBatch failed: statusCode=${response?.statusCode}');
        return LocationBatchUploadResponse(
          success: false,
          acceptedIds: [],
          failedIds: locations.map((e) => e.id).toList(),
          message: 'Server returned status code: ${response?.statusCode}',
        );
      }
    } catch (e) {
      LocationTrackingConstants.log('uploadLocationBatch exception: $e');
      return LocationBatchUploadResponse(
        success: false,
        acceptedIds: [],
        failedIds: locations.map((e) => e.id).toList(),
        message: e.toString(),
      );
    }
  }
}
