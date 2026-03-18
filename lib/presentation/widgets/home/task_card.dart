import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/chat_launcher.dart';

class TaskCard extends StatelessWidget {
  final TaskReportModel task;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(BuildContext, TaskReportModel) showStatusUpdate;

  const TaskCard({
    super.key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    required this.showStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String statusName) {
      statusName = statusName.toUpperCase();
      if (statusName.contains('FOLLOW-UP')) return Colors.blue;
      if (statusName.contains('NEW')) return Colors.green;
      if (statusName.contains('AMC')) return Colors.grey;
      if (statusName.contains('HOT')) return Colors.red;
      // Default to task.colorCode if available, else primaryBlue
      return task.colorCode ?? AppColors.primaryBlue;
    }

    final statusColor = getStatusColor(task.taskStatusName);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIRST LINE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.customerName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          task.taskDate.toFormattedDate(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textGrey3,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // SECOND LINE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTypeName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // STATUS BADGE
                    GestureDetector(
                      onTap: () => showStatusUpdate(context, task),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          task.taskStatusName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) ...[
                  Text(
                    "Description",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (task.nextFollowupDate != null &&
                    task.nextFollowupDate!.isNotEmpty) ...[
                  Text(
                    "Next Follow-up",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.nextFollowupDate!.toFormattedDate(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildChatDropdown(context),
                    const SizedBox(width: 12),
                    _buildViewDropdown(context),
                    const SizedBox(width: 12),
                    _buildCallDropdown(context),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatDropdown(BuildContext context) {
    return CustomActionButton(
      onTap: () {
        ChatLauncher.handleChat(context, task.mobile);
      },
      imageColor: AppColors.textGreen,
      icon: FontAwesomeIcons.whatsapp,
      text: 'Chat',
    );
  }

  Widget _buildViewDropdown(BuildContext context) {
    return CustomActionButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPagePhone(
              taskId: task.taskId.toString(),
              taskMasterId: task.taskMasterId.toString(),
              customerId: task.customerId.toString(),
            ),
          ),
        );
      },
      imageColor: AppColors.appViolet,
      icon: Icons.visibility_outlined,
      text: 'View',
    );
  }

  Widget _buildCallDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'Call') {
          final Uri phoneUri = Uri(scheme: 'tel', path: task.mobile);
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          }
        } else if (value == 'Copy') {
          Clipboard.setData(ClipboardData(text: task.mobile));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number copied to clipboard')),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Call', child: Text('Call')),
        const PopupMenuItem(value: 'Copy', child: Text('Copy Number')),
      ],
      child: CustomActionButton(
        imageColor: AppColors.bluebutton,
        icon: Icons.call,
        text: 'Call',
      ),
    );
  }
}
