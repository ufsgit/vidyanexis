import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/util_functions.dart';

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
    Color getAvatarColor(String name) {
      final colors = [
        Colors.blue.withOpacity(.75),
        Colors.purple.withOpacity(.75),
        Colors.orange.withOpacity(.75),
        Colors.teal.withOpacity(.75),
        Colors.pink.withOpacity(.75),
        Colors.indigo.withOpacity(.75),
        Colors.green.withOpacity(.75),
        Colors.deepOrange.withOpacity(.75),
        Colors.cyan.withOpacity(.75),
        Colors.brown.withOpacity(.75),
      ];
      final nameHash = name.hashCode.abs();
      return colors[nameHash % colors.length];
    }

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(color: AppColors.whiteColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 62,
                    width: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: task.colorCode?.withOpacity(.4) ??
                          getAvatarColor(task.customerName).withOpacity(.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.customerName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack),
                        ),
                        Text(
                          'ID ${task.taskId}',
                          style: TextStyle(
                            color: AppColors.textGrey3,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.taskStatusName,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: task.colorCode ?? AppColors.primaryBlue),
                        ),
                        Text(
                          '${task.taskTypeName}${task.description.isNotEmpty ? ' - ${task.description}' : ''}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGrey3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        task.taskDate.toFormattedDate(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.statusGreen,
                        ),
                      ),
                      Text(
                        task.taskTime,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                          color: AppColors.textGrey3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_outlined
                            : Icons.keyboard_arrow_down_outlined,
                        color: AppColors.textGrey3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildChatDropdown(context),
                const SizedBox(width: 15),
                CustomActionButton(
                  imageColor: AppColors.appViolet,
                  onTap: () => showStatusUpdate(context, task),
                  icon: Icons.edit_note_outlined,
                  text: 'Update',
                ),
                const SizedBox(width: 15),
                _buildCallDropdown(context),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        String formatted = formatIndianPhoneNumber(task.mobile);
        if (formatted.isNotEmpty) {
          if (value == 'WhatsApp') {
            final url = 'https://wa.me/$formatted';
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          } else if (value == 'WhatsApp Business') {
            // Try to open WhatsApp Business specifically if possible, else wa.me
            final Uri businessWhatsappUri =
                Uri.parse('whatsapp-business://send?phone=$formatted');
            final Uri webWhatsapp = Uri.parse('https://wa.me/$formatted');

            if (await canLaunchUrl(webWhatsapp)) {
              await launchUrl(webWhatsapp,
                  mode: LaunchMode.externalApplication);
            } else if (await canLaunchUrl(businessWhatsappUri)) {
              await launchUrl(businessWhatsappUri,
                  mode: LaunchMode.externalApplication);
            }
          } else if (value == 'SMS') {
            final Uri smsUri = Uri(scheme: 'sms', path: formatted);
            if (await canLaunchUrl(smsUri)) {
              await launchUrl(smsUri);
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Indian mobile number')),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'WhatsApp', child: Text('Normal WhatsApp')),
        const PopupMenuItem(
            value: 'WhatsApp Business', child: Text('WhatsApp Business')),
        const PopupMenuItem(value: 'SMS', child: Text('SMS')),
      ],
      child: CustomActionButton(
        imageColor: AppColors.textGreen,
        icon: Icons.chat_bubble_outline,
        text: 'Chat',
      ),
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
