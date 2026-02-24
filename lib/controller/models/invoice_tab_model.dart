class InvoiceTabModel {
  final String invoiceMasterId;
  final String invoiceDate;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final String shippingAddress;
  final String subtotal;
  final String totalDiscount;
  final String netTotal;
  final String totalCgst;
  final String totalSgst;
  final String totalGst;
  final String roundOff;
  final String totalAmount;
  final String description;
  final int quotationNo;
  final String quotationName;
  final String ewayInvoiceNo;
  final String modeOfPayment;
  final String referenceNo;
  final String buyerOrderNo;
  final String dispatchedDocumentNo;
  final String othetReference;

  final String deliveryNoteDate;
  final String dated;

  final String dispatchedThrough;
  final String destination;
  final String billOfLading;
  final String motorVehicleNo;
  final String referenceDate;
  final String termsOfDelivery;
  final List<InvoiceItemModel> invoiceItems;

  InvoiceTabModel({
    required this.othetReference,
    required this.dated,
    required this.invoiceMasterId,
    required this.invoiceDate,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.shippingAddress,
    required this.subtotal,
    required this.totalDiscount,
    required this.netTotal,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalGst,
    required this.roundOff,
    required this.totalAmount,
    required this.description,
    required this.invoiceItems,
    required this.quotationNo,
    required this.quotationName,
    required this.ewayInvoiceNo,
    required this.modeOfPayment,
    required this.referenceNo,
    required this.buyerOrderNo,
    required this.dispatchedDocumentNo,
    required this.deliveryNoteDate,
    required this.dispatchedThrough,
    required this.destination,
    required this.billOfLading,
    required this.motorVehicleNo,
    required this.referenceDate,
    required this.termsOfDelivery,
  });

  factory InvoiceTabModel.fromJson(Map<String, dynamic> json) {
    return InvoiceTabModel(
      othetReference: json['other_reference']?.toString() ?? "",
      dated: json['Dated']?.toString() ?? "",
      invoiceMasterId: json['invoice_master_id']?.toString() ?? "0",
      invoiceDate: json['invoice_date']?.toString() ?? "",
      invoiceNumber: json['invoice_no']?.toString() ?? "0",
      customerId: json['customer_id']?.toString() ?? "0",
      customerName: json['customer_name']?.toString() ?? "",
      shippingAddress: json['shipping_address']?.toString() ?? "",
      subtotal: json['subtotal']?.toString() ?? "0",
      totalDiscount: json['total_discount']?.toString() ?? "0",
      netTotal: json['net_total']?.toString() ?? "0",
      totalCgst: json['total_cgst']?.toString() ?? "0",
      totalSgst: json['total_sgst']?.toString() ?? "0",
      totalGst: json['total_gst']?.toString() ?? "0",
      roundOff: json['round_off']?.toString() ?? "0",
      totalAmount: json['total_amount']?.toString() ?? "0",
      description: json['description']?.toString() ?? "",
      quotationNo: json['Quotation_No_Id'] ?? 0,
      quotationName: json['Quotation_No_Name']?.toString() ?? "",
      ewayInvoiceNo: json['eway_invoice_no']?.toString() ?? "",
      modeOfPayment: json['mode_of_payment']?.toString() ?? "",
      referenceNo: json['reference_no']?.toString() ?? "",
      buyerOrderNo: json['buyer_order_no']?.toString() ?? "",
      dispatchedDocumentNo: json['dispatched_document_no']?.toString() ?? "",
      deliveryNoteDate: json['delivery_note_date']?.toString() ?? "",
      dispatchedThrough: json['dispatched_through']?.toString() ?? "",
      destination: json['destination']?.toString() ?? "",
      billOfLading: json['bill_of_lading']?.toString() ?? "",
      motorVehicleNo: json['motor_vehicle_no']?.toString() ?? "",
      referenceDate: json['reference_date']?.toString() ?? "",
      termsOfDelivery: json['terms_of_delivery']?.toString() ?? "",
      invoiceItems: (json['invoice_details'] as List<dynamic>?)
              ?.map((item) => InvoiceItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class InvoiceItemModel {
  final String itemName;
  // final int itemId;
  final String hsnCode;
  final String gst;
  final String cgst;
  final String sgst;
  final String rate;
  final String quantity;
  final String amount;
  final String discount;
  final String taxableAmount;
  final String cgstAmount;
  final String sgstAmount;
  final String gstAmount;
  final String totalAmount;
  // final int stockId;
  final int invoiceDetailsId;

  InvoiceItemModel({
    required this.itemName,
    // required this.itemId,
    required this.hsnCode,
    required this.gst,
    required this.cgst,
    required this.sgst,
    required this.rate,
    required this.quantity,
    required this.amount,
    required this.discount,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.gstAmount,
    required this.totalAmount,
    // required this.stockId,
    required this.invoiceDetailsId,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      itemName: json['item_name']?.toString() ?? "",
      // itemId: json['item_id'] ?? 0,
      // stockId: json['Stock_Id'] ?? 0,
      invoiceDetailsId: json['invoice_details_id'] ?? 0,
      hsnCode: json['hsn_code']?.toString() ?? "",
      gst: json['gst']?.toString() ?? "0",
      cgst: json['cgst']?.toString() ?? "0",
      sgst: json['sgst']?.toString() ?? "0",
      rate: json['rate']?.toString() ?? "0",
      quantity: json['quantity']?.toString() ?? "0",
      amount: json['amount']?.toString() ?? "0",
      discount: json['discount']?.toString() ?? "0",
      taxableAmount: json['taxable_amount']?.toString() ?? "0",
      cgstAmount: json['cgst_amount']?.toString() ?? "0",
      sgstAmount: json['sgst_amount']?.toString() ?? "0",
      gstAmount: json['gst_amount']?.toString() ?? "0",
      totalAmount: json['total_amount']?.toString() ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      // 'item_id': itemId,
      // 'Stock_Id': stockId,
      'invoice_details_id': invoiceDetailsId,
      'hsn_code': hsnCode,
      'gst': gst,
      'cgst': cgst,
      'sgst': sgst,
      'rate': rate,
      'quantity': quantity,
      'amount': amount,
      'discount': discount,
      'taxable_amount': taxableAmount,
      'cgst_amount': cgstAmount,
      'sgst_amount': sgstAmount,
      'gst_amount': gstAmount,
      'total_amount': totalAmount,
    };
  }
}
