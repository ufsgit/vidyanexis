import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/bill_of_material_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

class BomItemCard extends StatefulWidget {
  final BillOfMaterialItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BomItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<BomItemCard> createState() => _BomItemCardState();
}

class _BomItemCardState extends State<BomItemCard> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _qtyController =
        TextEditingController(text: widget.item.quantity.toString());
    _priceController =
        TextEditingController(text: widget.item.price.toString());
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BomItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the item instance changed (e.g., edited via the dialog and replaced in the list),
    // update the controller's text to reflect the new quantity.
    if (widget.item != oldWidget.item) {
      if (_qtyController.text != widget.item.quantity.toString()) {
        _qtyController.text = widget.item.quantity.toString();
      }
      if (_priceController.text != widget.item.price.toString()) {
        _priceController.text = widget.item.price.toString();
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
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
                widget.onDelete();
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final companyQuotationItems =
        settingsProvider.companyDetails.first.quotationItemValue == 1;
    return GestureDetector(
      onTap: widget.onEdit,
      child: Container(
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
                  Expanded(
                    child: Text(
                      widget.item.description,
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
              if (companyQuotationItems) ...[
                // Quantity row (editable)
                _buildEditableQuantityRow(
                  provider.getQuotationFieldName(12, 'Quantity'),
                  _qtyController,
                ),
                SizedBox(height: 8),
                _buildDetailRow(
                  provider.getQuotationFieldName(17, 'Unit'),
                  widget.item.uom,
                ),
              ] else ...[
                // Quantity row
                _buildDetailRow(
                  provider.getQuotationFieldName(12, 'Quantity'),
                  '${widget.item.quantity} ${widget.item.uom}',
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              _buildDetailRow(
                provider.getQuotationFieldName(11, 'Specification'),
                widget.item.brand.isNotEmpty ? widget.item.brand : '-',
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                provider.getQuotationFieldName(13, 'Manufacturer'),
                (widget.item.distributor?.isNotEmpty ?? false)
                    ? widget.item.distributor!
                    : '-',
              ),
              if (companyQuotationItems) ...[
                const SizedBox(height: 8),
                _buildEditablePriceRow(
                  provider.getQuotationFieldName(15, 'Price'),
                  _priceController,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  provider.getQuotationFieldName(16, 'Amount'),
                  (widget.item.amount?.isNotEmpty ?? false)
                      ? widget.item.amount!
                      : '-',
                ),
              ] else ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  provider.getQuotationFieldName(14, 'Comments'),
                  (widget.item.comments?.isNotEmpty ?? false)
                      ? widget.item.comments!
                      : '-',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build an editable quantity row
  Widget _buildEditableQuantityRow(
      String label, TextEditingController controller) {
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
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack.withValues(alpha: 0.8),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
            ],
            onChanged: (value) {
              final newQty = double.tryParse(value) ?? 0.0;
              setState(() {
                widget.item.quantity = newQty.toString();
              });
              final provider = context.read<CustomerDetailsProvider>();
              provider.billquantityController.text = widget.item.quantity;
              provider.billpriceController.text = widget.item.price ?? '0';
              provider.seteditBillOfMaterialsIndex(
                  provider.billOfMaterialsItems.indexOf(widget.item));
              provider.companyQuotationItemsCalulate(context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditablePriceRow(
      String label, TextEditingController controller) {
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
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack.withValues(alpha: 0.8),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
            ],
            onChanged: (value) {
              final newPrice = double.tryParse(value) ?? 0.0;
              setState(() {
                widget.item.price = newPrice.toString();
              });
              final provider = context.read<CustomerDetailsProvider>();
              provider.billquantityController.text = widget.item.quantity;
              provider.billpriceController.text = widget.item.price ?? '0';
              provider.seteditBillOfMaterialsIndex(
                  provider.billOfMaterialsItems.indexOf(widget.item));
              provider.companyQuotationItemsCalulate(context);
            },
          ),
        ),
      ],
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
