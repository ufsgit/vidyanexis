import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/location_tracking_provider.dart';
import 'package:vidyanexis/presentation/widgets/location/location_tracking_status_card.dart';

/// Dedicated management page for User/Employee Location Tracking.
class LocationTrackingPage extends StatelessWidget {
  static const String route = '/location-tracking';

  const LocationTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Duty Location Tracking',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textBlack,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.textBlack),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Consumer<LocationTrackingProvider>(
        builder: (context, provider, _) {
          final lastLocation = provider.lastLocation;
          final timeFormat = DateFormat('yyyy-MM-dd hh:mm:ss a');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Status Overview Card
                const LocationTrackingStatusCard(),

                const SizedBox(height: 20),

                // Detailed Session & Telemetry Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session & Telemetry Details',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 12),

                      _buildDetailRow(
                        'Tracking Session ID',
                        provider.trackingSessionId ?? 'No active session',
                      ),
                      _buildDetailRow(
                        'Engine Status',
                        provider.status.name.toUpperCase(),
                      ),
                      if (lastLocation != null) ...[
                        _buildDetailRow(
                          'Last Coordinates',
                          '${lastLocation.latitude.toStringAsFixed(6)}, ${lastLocation.longitude.toStringAsFixed(6)}',
                        ),
                        _buildDetailRow(
                          'GPS Accuracy',
                          '±${lastLocation.accuracy.toStringAsFixed(1)} meters',
                        ),
                        _buildDetailRow(
                          'Altitude',
                          '${lastLocation.altitude.toStringAsFixed(1)} m',
                        ),
                        _buildDetailRow(
                          'Speed',
                          '${(lastLocation.speed * 3.6).toStringAsFixed(1)} km/h',
                        ),
                        _buildDetailRow(
                          'Captured At',
                          timeFormat.format(lastLocation.timestamp.toLocal()),
                        ),
                        if (lastLocation.batteryLevel != null)
                          _buildDetailRow(
                            'Battery Level',
                            '${lastLocation.batteryLevel}%',
                          ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Offline Queue & Resilience Information Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.offline_pin_rounded, color: AppColors.techityfyGrey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Offline-First System Architecture',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'GPS points are permanently stored on your device SQLite database before network upload. '
                        'If connectivity is lost, locations safely accumulate locally and automatically synchronize '
                        'when network access is restored.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: AppColors.textGrey3,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending Offline Records:',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: provider.pendingLocationCount > 0
                                  ? AppColors.textRed.withValues(alpha: 0.1)
                                  : AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${provider.pendingLocationCount} points',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: provider.pendingLocationCount > 0
                                  ? AppColors.textRed
                                  : AppColors.statusGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.textGrey3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.textBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
