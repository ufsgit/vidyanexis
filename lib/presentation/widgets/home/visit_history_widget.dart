import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/lead_check_in_model.dart';

class VisitHistoryWidget extends StatelessWidget {
  final List<LeadCheckIn> history;

  const VisitHistoryWidget({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.location_off_outlined,
                size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No visit history found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey3,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: history.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final visit = history[index];
        final String status = visit.checkinStatus ?? 'Unknown';
        final String checkinDate = visit.checkinDate ?? '';
        final String checkoutDate = visit.checkoutDate ?? '';
        final String address =
            visit.checkinLocation ?? visit.location ?? 'No address';
        final String userName = visit.userDetailsName ?? 'User';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (status.toLowerCase().contains('in')
                                ? Colors.green
                                : Colors.orange)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: status.toLowerCase().contains('in')
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                    Text(
                      _formatDate(checkinDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textGrey3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                if (checkoutDate.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.outbound,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            "Checked Out",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(checkoutDate),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppColors.textGrey3),
                    const SizedBox(width: 4),
                    Text(
                      "By $userName",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppColors.textGrey3,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return "";
      final DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateStr;
    }
  }
}
