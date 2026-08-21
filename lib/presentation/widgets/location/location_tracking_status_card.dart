import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/location_tracking_provider.dart';
import 'package:vidyanexis/helpers/location_tracking_service.dart';

/// Reusable status card displaying real-time duty location tracking metrics and controls.
class LocationTrackingStatusCard extends StatelessWidget {
  final VoidCallback? onCardTap;

  const LocationTrackingStatusCard({
    super.key,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationTrackingProvider>(
      builder: (context, provider, _) {
        final isTracking = provider.isTracking;
        final isOnline = provider.isOnline;
        final isSyncing = provider.isSyncing;
        final status = provider.status;
        final pendingCount = provider.pendingLocationCount;
        final lastLocation = provider.lastLocation;
        final lastSyncTime = provider.lastSyncTime;

        final timeFormat = DateFormat('hh:mm a');

        // Status badge configuration
        Color statusBadgeColor;
        Color statusTextColor;
        String statusText;

        if (status == TrackingStatus.active) {
          statusBadgeColor = const Color(0xFFE8F5E9);
          statusTextColor = const Color(0xFF2E7D32);
          statusText = isSyncing ? 'Syncing' : 'Active';
        } else if (status == TrackingStatus.starting) {
          statusBadgeColor = const Color(0xFFE3F2FD);
          statusTextColor = const Color(0xFF1565C0);
          statusText = 'Starting...';
        } else if (status == TrackingStatus.permissionRequired ||
            status == TrackingStatus.permissionDenied ||
            status == TrackingStatus.permissionPermanentlyDenied) {
          statusBadgeColor = const Color(0xFFFFEBEE);
          statusTextColor = const Color(0xFFC62828);
          statusText = 'Permission Needed';
        } else if (status == TrackingStatus.serviceDisabled) {
          statusBadgeColor = const Color(0xFFFFF3E0);
          statusTextColor = const Color(0xFFE65100);
          statusText = 'GPS Disabled';
        } else {
          statusBadgeColor = const Color(0xFFECEFF1);
          statusTextColor = const Color(0xFF455A64);
          statusText = 'Stopped';
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTracking ? AppColors.techityfyGrey.withValues(alpha: 0.2) : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onCardTap,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title and Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isTracking
                                    ? AppColors.techityfyGrey.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.my_location_rounded,
                                size: 20,
                                color: isTracking ? AppColors.techityfyGrey : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Location Tracking',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBadgeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: statusTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                statusText,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 14),

                    // Diagnostics Row: GPS & Network
                    Row(
                      children: [
                        Expanded(
                          child: _buildDiagnosticItem(
                            icon: Icons.gps_fixed_rounded,
                            label: 'GPS',
                            value: (status == TrackingStatus.serviceDisabled) ? 'Disabled' : 'Active',
                            isActive: status != TrackingStatus.serviceDisabled,
                          ),
                        ),
                        Container(height: 32, width: 1, color: Colors.grey.shade200),
                        Expanded(
                          child: _buildDiagnosticItem(
                            icon: isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                            label: 'Network',
                            value: isOnline ? 'Connected' : 'Offline',
                            isActive: isOnline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Timestamps & Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Last Location',
                            value: lastLocation != null
                                ? timeFormat.format(lastLocation.timestamp.toLocal())
                                : 'No data',
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Last Sync',
                            value: lastSyncTime != null
                                ? timeFormat.format(lastSyncTime.toLocal())
                                : 'Pending',
                          ),
                        ),
                        Expanded(
                          child: _buildMetricItem(
                            label: 'Pending',
                            value: '$pendingCount',
                            highlight: pendingCount > 0,
                          ),
                        ),
                      ],
                    ),

                    if (provider.errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        provider.errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Action Controls
                    Row(
                      children: [
                        if (status == TrackingStatus.permissionRequired ||
                            status == TrackingStatus.permissionDenied ||
                            status == TrackingStatus.permissionPermanentlyDenied) ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => provider.requestPermission(context),
                              icon: const Icon(Icons.security_rounded, size: 16),
                              label: const Text('Grant Permission'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textRed,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ] else if (isTracking) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => provider.stopTracking(),
                              icon: const Icon(Icons.stop_rounded, size: 16, color: AppColors.btnRed),
                              label: Text(
                                'Stop Tracking',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppColors.btnRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.btnRed),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => provider.startTracking(context),
                              icon: const Icon(Icons.play_arrow_rounded, size: 16),
                              label: Text(
                                'Start Tracking',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.techityfyGrey,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 10),
                          IconButton.filledTonal(
                            tooltip: 'Sync Now',
                            onPressed: isSyncing ? null : () => provider.syncNow(),
                            icon: isSyncing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.sync_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.lightBlueColor,
                              foregroundColor: AppColors.textBlue800,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiagnosticItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isActive,
  }) {
    final activeColor = isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: activeColor),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textGrey3,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: activeColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textGrey3,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: highlight ? AppColors.textRed : AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}
