import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CardItemWidget extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final List<CardDetailItem> details;
  final VoidCallback onEdit;

  const CardItemWidget({
    super.key,
    required this.title,
    required this.actions,
    required this.details,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  Row(children: actions),
                ],
              ),
              if (details.isNotEmpty) const SizedBox(height: 12),

              // Details Stacked
              ...details.expand((detail) => [
                    _buildStackedDetail(detail.label, detail.value),
                    if (detail != details.last) const SizedBox(height: 8),
                  ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedDetail(String label, String value) {
    if (value.isEmpty || value == '-') return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
        ),
      ],
    );
  }
}

class CardDetailItem {
  final String label;
  final String value;

  CardDetailItem({required this.label, required this.value});
}
