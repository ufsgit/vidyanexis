import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controller/models/bill_of_material_model.dart';
import '../../../controller/customer_details_provider.dart';
import 'package:provider/provider.dart';

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
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
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
    return GestureDetector(
      onTap: onEdit,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// DELETE BUTTON
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                  "${context.read<CustomerDetailsProvider>().getQuotationFieldName(12, 'Quantity')} : ${item.quantity} ${item.uom}"),
              Text(
                "${context.read<CustomerDetailsProvider>().getQuotationFieldName(11, 'Specification')} : ${item.brand.isNotEmpty ? item.brand : '-'}",
              ),
              Text(
                "${context.read<CustomerDetailsProvider>().getQuotationFieldName(13, 'Manufacturer')} : ${(item.distributor?.isNotEmpty ?? false) ? item.distributor : '-'}",
              ),

              Text(
                "${context.read<CustomerDetailsProvider>().getQuotationFieldName(14, 'Comments')} : ${(item.comments?.isNotEmpty ?? false) ? item.comments : '-'}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
