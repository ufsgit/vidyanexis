import 'package:flutter/material.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';

/// A screen for editing an existing quotation.
/// It wraps the [QuotationCreationWidget] in a full-screen layout.
class EditQuotationScreen extends StatelessWidget {
  final String customerId;
  final String quotationId;

  const EditQuotationScreen({
    super.key,
    required this.customerId,
    required this.quotationId,
  });

  @override
  Widget build(BuildContext context) {
    return QuotationCreationWidget(
      customerId: customerId,
      quotationId: quotationId,
      isEdit: true,
    );
  }
}
