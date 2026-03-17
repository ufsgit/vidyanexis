import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/item_model.dart';

class QuotationItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const QuotationItemCard({
    super.key,
    required this.item,
    required this.onDelete,
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
              // Header: Title and Delete Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.ItemName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onDelete,
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
              _buildDetailRow('Quantity', '${item.Quantity} ${item.Unit}'),
              const SizedBox(height: 8),
              _buildDetailRow('Unit Price', '₹${item.UnitPrice.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildDetailRow('GST', '₹${item.GST.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildDetailRow('Total', '₹${item.Amount.toStringAsFixed(2)}'),
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
