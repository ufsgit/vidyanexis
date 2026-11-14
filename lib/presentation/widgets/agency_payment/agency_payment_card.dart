import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/agency_payment_provider.dart';
import 'package:vidyanexis/controller/models/agency_payment_model.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';

class AgencyPaymentCard extends StatelessWidget {
  final AgencyPaymentModel payment;
  final VoidCallback? onDelete;

  const AgencyPaymentCard({
    super.key,
    required this.payment,
    this.onDelete,
  });

  void _handleDelete(BuildContext context) {
    if (onDelete != null) {
      onDelete!();
      return;
    }
    showConfirmationDialog(
      context: context,
      title: 'Delete Agency Payment',
      content: 'Are you sure you want to delete this agency payment?',
      confirmButtonText: 'Delete',
      confirmButtonColor: Colors.red,
      onCancel: () {
        Navigator.of(context).pop();
      },
      onConfirm: () async {
        final provider =
            Provider.of<AgencyPaymentProvider>(context, listen: false);
        await provider.deleteAgencyPayment(context, payment.agencyPaymentId);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (payment.agencyPaymentId != 0)
                  Text(
                    "Payment ID : #${payment.agencyPaymentId}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.normal,
                      color: AppColors.textGrey3,
                      fontSize: 13,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Tooltip(
                  message: 'Delete',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleDelete(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                          color: Colors.red[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Enquiry Source / Agency Name as Title
            Text(
              payment.enquirySourceName.isNotEmpty
                  ? payment.enquirySourceName
                  : 'Agency Payment',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            // Amount
            Row(
              children: [
                Text(
                  'Amount:',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  NumberFormat.currency(
                    locale: 'en_IN',
                    symbol: '₹ ',
                    decimalDigits: 2,
                  ).format(payment.amount),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
            ),
            // Payment Date
            if (payment.paymentDate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Payment Date:',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    payment.paymentDate,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ],
            // Remark
            if (payment.remark.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remark:',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[600],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      payment.remark,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

