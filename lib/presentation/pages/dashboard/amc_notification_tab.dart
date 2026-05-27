import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/warrenty_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/amc_notification_model.dart';


class AmcNotificationTab extends StatefulWidget {
  const AmcNotificationTab({super.key});

  @override
  State<AmcNotificationTab> createState() => _AmcNotificationTabState();
}

class _AmcNotificationTabState extends State<AmcNotificationTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<WarrentyReportProvider>(context, listen: false);
      final dropdownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      dropdownProvider.getUserDetails(context);
      provider.getAmcNotification(context);
    });
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'No Date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WarrentyReportProvider, DropDownProvider>(
      builder: (context, provider, dropdownProvider, child) {
        return Column(
          children: [
            // Summary Section
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Active Contracts",
                    value: provider.amcNotificationList.length.toString(),
                    icon: Icons.description_rounded,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Upcoming Services",
                    value: _countUpcomingServices(provider.amcNotificationList).toString(),
                    icon: Icons.event_available_rounded,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // List Section
            if (provider.isAmcNotificationLoading)
              _buildShimmerLoading()
            else if (provider.amcNotificationList.isEmpty)
              _buildEmptyState("No AMC notifications found")
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: provider.amcNotificationList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = provider.amcNotificationList[index];
                  return _buildAmcCard(item);
                },
              ),
          ],
        );
      },
    );
  }

  int _countUpcomingServices(List<AmcNotificationModel> list) {
    int count = 0;
    for (var item in list) {
      if (item.intervalDetails != null) {
        count += item.intervalDetails!.where((i) => i.completedStatus == 0).length;
      }
    }
    return count;
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmcCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: getAvatarColor(item.customerName).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(item.customerName),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getAvatarColor(item.customerName),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.customerName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 12, color: AppColors.textRed),
                          const SizedBox(width: 4),
                          Text(
                            "Expiry: ${_formatDate(item.serviceDate)}",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildDetailRow(Icons.inventory_2_outlined, "Product", item.amcProductName),
                _buildDetailRow(Icons.settings_outlined, "Service", item.serviceName),
                _buildDetailRow(Icons.person_outline_rounded, "Staff", item.staffName),
              ],
            ),
          ),

          // Intervals Section
          if (item.intervalDetails != null && item.intervalDetails!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, 
                        size: 14, color: AppColors.textGrey3),
                      const SizedBox(width: 6),
                      Text(
                        "Service Intervals",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.intervalDetails!.map<Widget>((interval) {
                      bool isCompleted = interval.completedStatus == 1;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isCompleted 
                              ? const Color(0xFF34C759).withOpacity(0.3)
                              : const Color(0xFFFB923C).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isCompleted ? Icons.check_circle_rounded : Icons.schedule_rounded,
                              size: 14,
                              color: isCompleted ? const Color(0xFF34C759) : const Color(0xFFFB923C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(interval.intervalDate),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textGrey3),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey3,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: List.generate(3, (index) => Container(
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
        ),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      )),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_edu_rounded, size: 64, color: AppColors.textGrey2.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey3,
            ),
          ),
        ],
      ),
    );
  }
}
