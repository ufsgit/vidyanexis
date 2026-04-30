import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/bill_of_material_model.dart';

class BomItemCard extends StatelessWidget {
  final BillOfMaterialItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BomItemCard({
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
            'Are you sure you want to delete this material?',
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
    final provider = context.read<CustomerDetailsProvider>();
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
              // Header: Title and Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context);
                    },
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
              ),
              const SizedBox(height: 12),

              // Details
              _buildDetailRow(
                provider.getQuotationFieldName(12, 'Quantity'),
                '${item.quantity} ${item.uom}',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                provider.getQuotationFieldName(11, 'Specification'),
                item.brand.isNotEmpty ? item.brand : '-',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                provider.getQuotationFieldName(13, 'Manufacturer'),
                (item.distributor?.isNotEmpty ?? false)
                    ? item.distributor!
                    : '-',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                provider.getQuotationFieldName(14, 'Comments'),
                (item.comments?.isNotEmpty ?? false) ? item.comments! : '-',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label :',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
