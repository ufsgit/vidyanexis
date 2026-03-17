import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/scope_of_work_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/card_item_widget.dart';

class ScopeOfWorkCard extends StatelessWidget {
  final ScopeOfWorkModel item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ScopeOfWorkCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this scope of work item?',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardItemWidget(
      title: item.designAndEngineering ?? '',
      onEdit: onEdit,
      actions: [
        GestureDetector(
          onTap: onEdit,
          child: Text(
            'Edit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.bluebutton,
            ),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => _showDeleteConfirmation(context),
          child: Text(
            'Delete',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textRed,
            ),
          ),
        ),
      ],
      details: [
        CardDetailItem(
          label: 'A3S Scope',
          value: item.a3SScope ?? '',
        ),
        CardDetailItem(
          label: 'Client Scope',
          value: item.clientScope ?? '',
        ),
      ],
    );
  }
}
