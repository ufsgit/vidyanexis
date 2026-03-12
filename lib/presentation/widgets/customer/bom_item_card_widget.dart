import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BomItemCardWidget extends StatelessWidget {
  final String itemName;
  final String quantity;
  final String make;
  final String distributor;
  final String comments;
  final String uom;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BomItemCardWidget({
    Key? key,
    required this.itemName,
    required this.quantity,
    required this.make,
    required this.distributor,
    required this.comments,
    this.uom = '',
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Quantity', '$quantity ${uom.isNotEmpty ? uom : ''}'),
                const SizedBox(height: 6),
                _buildInfoRow('Make', make.isNotEmpty ? make : '-'),
                const SizedBox(height: 6),
                _buildInfoRow(
                    'Distributor', distributor.isNotEmpty ? distributor : '-'),
                const SizedBox(height: 6),
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
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          ' :  ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
