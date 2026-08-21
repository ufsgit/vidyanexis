/// Response model for tracking session start/stop operations.
class TrackingSessionResponse {
  final bool success;
  final String? trackingSessionId;
  final DateTime? startedAt;
  final DateTime? stoppedAt;
  final String? message;

  TrackingSessionResponse({
    required this.success,
    this.trackingSessionId,
    this.startedAt,
    this.stoppedAt,
    this.message,
  });

  factory TrackingSessionResponse.fromJson(Map<String, dynamic> json) {
    return TrackingSessionResponse(
      success: json['success'] == true || json['status'] == true || json['status'] == 1,
      trackingSessionId: json['tracking_session_id']?.toString() ??
          json['trackingSessionId']?.toString() ??
          json['session_id']?.toString(),
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      stoppedAt: json['stopped_at'] != null
          ? DateTime.tryParse(json['stopped_at'].toString())
          : null,
      message: json['message']?.toString(),
    );
  }
}

/// Response model for batch location uploads.
class LocationBatchUploadResponse {
  final bool success;
  final List<String> acceptedIds;
  final List<String> failedIds;
  final String? message;

  LocationBatchUploadResponse({
    required this.success,
    required this.acceptedIds,
    required this.failedIds,
    this.message,
  });

  factory LocationBatchUploadResponse.fromJson(Map<String, dynamic> json) {
    final rawAccepted = json['accepted_ids'] ?? json['acceptedIds'] ?? [];
    final rawFailed = json['failed_ids'] ?? json['failedIds'] ?? [];

    List<String> parsedAccepted = [];
    if (rawAccepted is List) {
      parsedAccepted = rawAccepted.map((e) => e.toString()).toList();
    }

    List<String> parsedFailed = [];
    if (rawFailed is List) {
      parsedFailed = rawFailed.map((e) => e.toString()).toList();
    }

    return LocationBatchUploadResponse(
      success: json['success'] == true || json['status'] == true || json['status'] == 1,
      acceptedIds: parsedAccepted,
      failedIds: parsedFailed,
      message: json['message']?.toString(),
    );
  }
}
