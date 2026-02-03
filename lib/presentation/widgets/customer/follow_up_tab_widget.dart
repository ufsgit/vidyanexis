import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_history_model.dart';

class FollowUpTabWidget extends StatelessWidget {
  const FollowUpTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isFollowUpHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.followUpHistory.isEmpty) {
          return const Center(child: Text("No follow-up history found"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: provider.followUpHistory.length,
          itemBuilder: (context, index) {
            final followUp = provider.followUpHistory[index];
            return FollowUpHistoryItem(history: followUp);
          },
        );
      },
    );
  }
}

class FollowUpHistoryItem extends StatelessWidget {
  final FollowUpHistoryModel history;

  const FollowUpHistoryItem({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    DateTime? followUpDate = _parseDate(history.followUpDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Column
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: followUpDate != null
                ? Column(
                    children: [
                      Text(
                        DateFormat('dd').format(followUpDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(followUpDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        DateFormat('yyyy').format(followUpDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(followUpDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.05),
                //     blurRadius: 4,
                //     offset: const Offset(0, 2),
                //   ),
                // ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Assigned To
                    Row(
                      children: [
                        const Text(
                          "Assigned To ",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          history.assignedToName ?? "-",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "by",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                          history.assignedByName ?? "admin",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status and Next Follow Up
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Status",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors
                                    .lightGreen, // Assuming this color exists, or greenAccent
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                history.statusName ?? "Follow up",
                                style: TextStyle(
                                  color: AppColors.statusGreen,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Next Follow-up Date",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  _getFormattedNextFollowUpDate(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Remark
                    const Text(
                      "Remark",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      history.remarks ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedNextFollowUpDate() {
    if (history.nextFollowUpDate == null) return "-";
    final date = _parseDate(history.nextFollowUpDate);
    if (date == null)
      return history.nextFollowUpDate!; // Fallback to string if parsing fails
    return DateFormat('dd-MM-yyyy').format(date);
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      // Try ISO format (yyyy-MM-dd)
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // Try dd-MM-yyyy format
        return DateFormat('dd-MM-yyyy').parse(dateStr);
      } catch (_) {
        return null;
      }
    }
  }
}
