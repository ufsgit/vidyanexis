import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/customer/expanded_text_widget.dart';

class TaskCardMobileWidget extends StatelessWidget {
  final String taskTypeName;
  final String taskStatusName;
  final String enquiryForName;
  final String description;
  final String taskDate;
  final String taskTime;
  final String entryDate;
  final Color statusColor;
  final Color textBlack;
  final Color textGrey3;
  final Widget? taskTypeIcon;

  const TaskCardMobileWidget({
    super.key,
    required this.taskTypeName,
    required this.taskStatusName,
    required this.enquiryForName,
    required this.description,
    required this.taskDate,
    required this.taskTime,
    required this.entryDate,
    this.statusColor = Colors.purple,
    this.textBlack = Colors.black,
    this.textGrey3 = Colors.grey,
    this.taskTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 22,
                  width: 3,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 16,
                  width: 16,
                  child: taskTypeIcon ?? const SizedBox(),
                ),
                const SizedBox(width: 4),
                Text(
                  taskTypeName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textBlack,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: statusColor.withOpacity(.1),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      child: Text(
                        taskStatusName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (enquiryForName.isNotEmpty) ...[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  enquiryForName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appViolet,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Align(
              alignment: Alignment.topLeft,
              child: ExpandableText(
                text: description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textBlack,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: textGrey3,
                ),
                const SizedBox(width: 4),
                Text(
                  '$taskDate • $taskTime',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: textGrey3,
                  ),
                  children: [
                    const TextSpan(text: 'Created on '),
                    TextSpan(
                      text: entryDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textGrey3,
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
