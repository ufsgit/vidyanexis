import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class BomItemCardWidget extends StatelessWidget {
  final String itemName;
  final String quantity;
  final String make;
  final String distributor;
  final String comments;
  final String uom;
  final String? price;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BomItemCardWidget({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.make,
    required this.distributor,
    required this.comments,
    this.uom = '',
    this.price,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        itemName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    if (price != null)
                      Text(
                        '₹$price',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Quantity', '$quantity ${uom.isNotEmpty ? uom : ''}'),
                const SizedBox(height: 8),
                _buildInfoRow('Make', make.isNotEmpty ? make : '-'),
                const SizedBox(height: 8),
                _buildInfoRow('Distributor', distributor.isNotEmpty ? distributor : '-'),
                const SizedBox(height: 8),
                _buildInfoRow('Comments', comments.isNotEmpty ? comments : '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
