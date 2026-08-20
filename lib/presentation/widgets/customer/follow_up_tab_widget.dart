import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/edit_remark_dialog.dart';

class FollowUpTabWidget extends StatelessWidget {
  final String? customerId;
  const FollowUpTabWidget({super.key, this.customerId});

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

        return Container(
          margin: const EdgeInsets.only(top: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine card width based on screen width for responsive grid
              double cardWidth = constraints.maxWidth;
              if (constraints.maxWidth > 1200) {
                cardWidth = (constraints.maxWidth - 64) / 3; // 3 columns
              } else if (constraints.maxWidth > 800) {
                cardWidth = (constraints.maxWidth - 48) / 2; // 2 columns
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: provider.followUpHistory.map((history) {
                    return SizedBox(
                      width: cardWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE9EDF1)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Date & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.history,
                                          size: 16,
                                          color: AppColors.primaryBlue),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _formatDate(history.followUpDate ?? ''),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    history.statusName ?? 'Follow up',
                                    style: TextStyle(
                                      color: AppColors.statusGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child:
                                  Divider(color: Color(0xFFE9EDF1), height: 1),
                            ),
                            // Middle Row: Assignment & Next Follow up
                            Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                _buildInfoColumn('Assigned To',
                                    _buildUserCell(history.assignedToName)),
                                _buildInfoColumn('Assigned By',
                                    _buildUserCell(history.assignedByName)),
                                _buildInfoColumn(
                                  'Next Follow-up',
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.event,
                                          size: 16, color: Colors.blueGrey),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDate(
                                            history.nextFollowUpDate ?? ''),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (history.remarks != null &&
                                history.remarks!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFE9EDF1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Remarks',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            EditRemarkDialog.show(
                                              context,
                                              customerId: customerId ?? '',
                                              followUpId:
                                                  history.followUpId ?? '',
                                              initialRemark:
                                                  history.remarks ?? '',
                                              statusName: history.statusName,
                                              toUserName:
                                                  history.assignedToName,
                                              followUpDate:
                                                  history.nextFollowUpDate,
                                            );
                                          },
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryBlue
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.edit_outlined,
                                                  size: 12,
                                                  color: AppColors.primaryBlue,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Edit',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.primaryBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      history.remarks!,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildUserCell(String? userName) {
    if (userName == null || userName.isEmpty || userName == 'null') {
      return const Text("-",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 4,
          backgroundColor: getAvatarColor(userName),
          child: Text(
            userName[0].toUpperCase(),
            style: const TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          userName,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      // Clean the input (handles "00:00:00.000" case)
      String cleaned = dateStr
          .replaceFirst(RegExp(r'00:00:00\.000\s*'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), ' ');

      final dateTime = DateTime.parse(cleaned);

      // 12-hour format with AM/PM
      return DateFormat('dd MMM yyyy hh:mm:ss a').format(dateTime);
    } catch (e) {
      return dateStr; // fallback
    }
  }
}
