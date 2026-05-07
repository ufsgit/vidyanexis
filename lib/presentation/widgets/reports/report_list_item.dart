import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class ReportListItem extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onSubtitleTap;
  final String title;
  final String subtitle;
  final String? status;
  final Color statusColor;
  final String description;
  final String? bottomLeftText;
  final IconData? bottomLeftIcon;
  final String? bottomRightText;
  final String? trailingText;
  final VoidCallback? onDelete;
  final EdgeInsetsGeometry? padding;

  const ReportListItem({
    super.key,
    this.onTap,
    this.onSubtitleTap,
    required this.title,
    required this.subtitle,
    this.status,
    required this.statusColor,
    required this.description,
    this.bottomLeftText,
    this.bottomLeftIcon,
    this.bottomRightText,
    this.trailingText,
    this.onDelete,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        decoration: BoxDecoration(color: AppColors.whiteColor),
        child: Padding(
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 42,
                    width: 3,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                          ),
                        ),
                        InkWell(
                          onTap: onSubtitleTap,
                          child: Text(
                            subtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status != null && status!.isNotEmpty)
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: statusColor.withAlpha(25),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          child: Text(
                            status!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (trailingText != null)
                    Text(
                      trailingText!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
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
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (bottomLeftText != null && bottomLeftText!.isNotEmpty)
                    Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldColor,
                        border: Border.all(color: AppColors.grey),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          children: [
                            if (bottomLeftIcon != null)
                              Icon(
                                bottomLeftIcon,
                                size: 16,
                                color: AppColors.textGrey3,
                              ),
                            if (bottomLeftIcon != null)
                              const SizedBox(width: 4),
                            Text(
                              bottomLeftText!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (bottomRightText != null && bottomRightText!.isNotEmpty)
                    Text(
                      bottomRightText!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey3,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
