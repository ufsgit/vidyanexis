import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/commercial_item_model.dart';

class CommercialItemCard extends StatefulWidget {
  final CommercialItemModel item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final bool showActions;

  const CommercialItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
    this.showActions = true,
  });

  @override
  State<CommercialItemCard> createState() => _CommercialItemCardState();
}

class _CommercialItemCardState extends State<CommercialItemCard> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);

    final cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
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
                if (provider.isQuotationFieldVisible(1))
                Expanded(
                  child: Text(
                    widget.item.description ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                if (widget.showActions)
                  GestureDetector(
                    onTap: widget.onDelete,
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
            if (provider.isQuotationFieldVisible(5))
            _buildDetailRow('Quantity', widget.item.unitPrice ?? '-'),
            const SizedBox(height: 8),
            if (provider.isQuotationFieldVisible(2))
            _buildDetailRow('Specification', widget.item.acCapacity ?? '-'),
            const SizedBox(height: 8),
            if (provider.isQuotationFieldVisible(3))
            _buildDetailRow('Manufacturer', widget.item.dcCapacity ?? '-'),
            const SizedBox(height: 8),
            if (provider.isQuotationFieldVisible(9))
            _buildDetailRow('Comments', widget.item.total ?? '-'),
          ],
        ),
      ),
    );

    if (widget.showActions) {
      return GestureDetector(
        onTap: widget.onEdit,
        child: cardContent,
      );
    } else {
      return cardContent;
    }
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
