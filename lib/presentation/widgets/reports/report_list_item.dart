import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class ReportListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onSubtitleTap;
  final String title;
  final String subtitle;
  final String? id;
  final String? status;
  final Color statusColor;
  final String? description;
  final String? bottomLeftText;
  final IconData? bottomLeftIcon;
  final String? bottomRightText;
  final String? trailingText;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final EdgeInsetsGeometry? padding;
  final bool showArrow;

  const ReportListItem({
    super.key,
    this.onTap,
    this.onSubtitleTap,
    required this.title,
    required this.subtitle,
    this.id,
    this.status,
    required this.statusColor,
    this.description,
    this.bottomLeftText,
    this.bottomLeftIcon,
    this.bottomRightText,
    this.trailingText,
    this.onDelete,
    this.onEdit,
    this.padding,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
        ),
        child: Column(
          children: [
            Padding(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (id != null && id!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  'ID $id',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textGrey3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              children: [
                                if (status != null && status!.isNotEmpty)
                                  TextSpan(
                                    text: status,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                    ),
                                  ),
                                if (subtitle.isNotEmpty)
                                  TextSpan(
                                    text: status != null && status!.isNotEmpty
                                        ? ' , $subtitle'
                                        : subtitle,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          if (description != null &&
                              description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey4,
                              ),
                            ),
                          ],
                          if (bottomLeftText != null &&
                              bottomLeftText!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (bottomLeftIcon != null)
                                  Icon(
                                    bottomLeftIcon,
                                    size: 14,
                                    color: AppColors.textGrey3,
                                  ),
                                if (bottomLeftIcon != null)
                                  const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    bottomLeftText!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textGrey4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (bottomRightText != null &&
                            bottomRightText!.isNotEmpty)
                          Text(
                            bottomRightText!,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppColors.statusGreen,
                            ),
                          ),
                        const Spacer(),
                        if (showArrow)
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: AppColors.textGrey3,
                            size: 20,
                          ),
                        if (onEdit != null || onDelete != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEdit != null)
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined,
                                      color: AppColors.primaryBlue, size: 20),
                                  onPressed: onEdit,
                                  visualDensity: VisualDensity.compact,
                                ),
                              if (onDelete != null)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: AppColors.textRed, size: 20),
                                  onPressed: onDelete,
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
