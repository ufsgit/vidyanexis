import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/invoice_tab_provider.dart';
import 'package:vidyanexis/controller/models/invoice_tab_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddInvoiceTab extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final String customerId;

  const AddInvoiceTab({
    super.key,
    required this.isEdit,
    required this.editId,
    required this.customerId,
  });

  @override
  State<AddInvoiceTab> createState() => _AddInvoiceTabState();
}

class _AddInvoiceTabState extends State<AddInvoiceTab> {
  String? validateInputs(
      BuildContext context, InvoiceTabProvider invoiceTabProvider) {
    return null;
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String maxQuantity = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final invoiceTabProvider =
          Provider.of<InvoiceTabProvider>(listen: false, context);
      invoiceTabProvider.resetInvoiceItems();
      invoiceTabProvider.clearInvoiceItemFields();
      invoiceTabProvider.resetInvoiceValues();
      invoiceTabProvider.gstPerInvoiceController.text = '18.00';
      invoiceTabProvider.searchItemListPurchase(context);

      if (widget.isEdit) {
        await invoiceTabProvider.getInvoiceDetails(widget.editId, context);
        final invoice = invoiceTabProvider.invoiceDetails[0];

        // Set all field values from the invoice data
        invoiceTabProvider.addressInvoiceController.text =
            invoice.shippingAddress;
        invoiceTabProvider.invoiceNoInvoiceController.text =
            invoice.invoiceNumber;
        invoiceTabProvider.invoiceDateInvoiceController.text =
            formatInvoiceDate(invoice.invoiceDate);
        if (invoice.deliveryNoteDate.isNotEmpty &&
            invoice.deliveryNoteDate != '') {
          invoiceTabProvider.deliveryNoteDateController.text =
              formatInvoiceDate(invoice.deliveryNoteDate);
        }
        if (invoice.dated.isNotEmpty && invoice.dated != '') {
          invoiceTabProvider.datedController.text =
              formatInvoiceDate(invoice.dated);
        }
        if (invoice.referenceDate.isNotEmpty && invoice.referenceDate != '') {
          invoiceTabProvider.referenceDateController.text =
              formatInvoiceDate(invoice.referenceDate);
        }

        invoiceTabProvider.descriptionInvoiceController.text =
            invoice.description;
        invoiceTabProvider.invoiceItem = invoice.invoiceItems;
        invoiceTabProvider.grandTotal =
            double.tryParse(invoice.subtotal) ?? 0.0;
        invoiceTabProvider.totalDiscount =
            double.tryParse(invoice.totalDiscount) ?? 0.0;
        invoiceTabProvider.totalTaxableAmount =
            double.tryParse(invoice.netTotal) ?? 0.0;
        invoiceTabProvider.totalCGST =
            double.tryParse(invoice.totalCgst) ?? 0.0;
        invoiceTabProvider.totalSGST =
            double.tryParse(invoice.totalSgst) ?? 0.0;
        invoiceTabProvider.totalGST = double.tryParse(invoice.totalGst) ?? 0.0;
        invoiceTabProvider.finalGrandTotal =
            double.tryParse(invoice.totalAmount) ?? 0.0;
        invoiceTabProvider.quotationNoController.text = invoice.quotationName;
        invoiceTabProvider.setSelectedQuotationNoId(invoice.quotationNo);

        // Set the new fields from the response
        invoiceTabProvider.ewayInvoiceNoController.text = invoice.ewayInvoiceNo;
        invoiceTabProvider.modeOfPaymentController.text = invoice.modeOfPayment;
        invoiceTabProvider.referenceNoController.text = invoice.referenceNo;
        invoiceTabProvider.buyerOrderNoController.text = invoice.buyerOrderNo;
        invoiceTabProvider.dispatchedDocumentNoController.text =
            invoice.dispatchedDocumentNo;
        invoiceTabProvider.otherReferenceController.text =
            invoice.othetReference;
        invoiceTabProvider.dispatchedThroughController.text =
            invoice.dispatchedThrough;
        invoiceTabProvider.destinationController.text = invoice.destination;
        invoiceTabProvider.billOfLadingController.text = invoice.billOfLading;
        invoiceTabProvider.motorVehicleNoController.text =
            invoice.motorVehicleNo;
        invoiceTabProvider.referenceDateController.text = invoice.referenceDate;
        invoiceTabProvider.termsOfDeliveryController.text =
            invoice.termsOfDelivery;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceTabProvider>(
        builder: (context, invoiceTabProvider, child) {
      final isWeb = AppStyles.isWebScreen(context);
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              widget.isEdit ? 'Edit Invoice' : 'Add Invoice',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            )
          ],
        ),
        content: Container(
          color: Colors.white,
          width: isWeb
              ? MediaQuery.sizeOf(context).width / 2
              : MediaQuery.sizeOf(context).width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 16 : 4),
                  child: isWeb
                      ? _buildWebForm(context, invoiceTabProvider)
                      : _buildMobileForm(context, invoiceTabProvider),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CustomElevatedButton(
            buttonText: 'Cancel',
            onPressed: () {
              invoiceTabProvider.resetInvoiceValues();
              invoiceTabProvider.resetInvoiceItems();
              invoiceTabProvider.clearInvoiceItemFields();
              Navigator.pop(context);
            },
            backgroundColor: AppColors.whiteColor,
            borderColor: AppColors.appViolet,
            textColor: AppColors.appViolet,
          ),
          CustomElevatedButton(
            buttonText: 'Save',
            onPressed: () async {
              // Validate input
              if (invoiceTabProvider
                      .invoiceDateInvoiceController.text.isEmpty ||
                  invoiceTabProvider.invoiceNoInvoiceController.text.isEmpty ||
                  invoiceTabProvider.invoiceItem.isEmpty) {
                showErrorDialog(context,
                    'Please fill all required fields and add at least one item');
                return;
              }

              var data = {
                "invoice_master_id": widget.editId,
                "invoice_number":
                    invoiceTabProvider.invoiceNoInvoiceController.text,
                "invoice_date": invoiceTabProvider
                    .invoiceDateInvoiceController.text
                    .toyyyymmdd(),
                "customer_id": widget.customerId,
                "shipping_address":
                    invoiceTabProvider.addressInvoiceController.text,
                "subtotal": invoiceTabProvider.grandTotal.toStringAsFixed(2),
                "total_discount":
                    invoiceTabProvider.totalDiscount.toStringAsFixed(2),
                "net_total":
                    invoiceTabProvider.totalTaxableAmount.toStringAsFixed(2),
                "total_cgst": invoiceTabProvider.totalCGST.toStringAsFixed(2),
                "total_sgst": invoiceTabProvider.totalSGST.toStringAsFixed(2),
                "total_gst": invoiceTabProvider.totalGST.toStringAsFixed(2),
                "round_off":
                    (invoiceTabProvider.finalGrandTotal.roundToDouble() -
                            invoiceTabProvider.finalGrandTotal)
                        .toStringAsFixed(2),
                "total_amount":
                    invoiceTabProvider.finalGrandTotal.roundToDouble(),
                "description":
                    invoiceTabProvider.descriptionInvoiceController.text,
                "invoice_details": invoiceTabProvider.invoiceItem
                    .map((item) => item.toJson())
                    .toList(),
                // "Quotation_No_Id": invoiceTabProvider.quotationNoId ?? 0,
                // "Quotation_No_Name":
                //     invoiceTabProvider.quotationNoController.text,
                // // Add additional fields to the data object
                "eway_invoice_no":
                    invoiceTabProvider.ewayInvoiceNoController.text,
                "mode_of_payment":
                    invoiceTabProvider.modeOfPaymentController.text,
                "reference_no": invoiceTabProvider.referenceNoController.text,
                "buyer_order_no":
                    invoiceTabProvider.buyerOrderNoController.text,
                "dispatched_document_no":
                    invoiceTabProvider.dispatchedDocumentNoController.text,
                "Other_Reference":
                    invoiceTabProvider.otherReferenceController.text,
                "delivery_note_date": invoiceTabProvider
                    .deliveryNoteDateController.text
                    .toyyyymmdd(),
                "Dated": invoiceTabProvider.datedController.text.toyyyymmdd(),
                "dispatched_through":
                    invoiceTabProvider.dispatchedThroughController.text,
                "destination": invoiceTabProvider.destinationController.text,
                "bill_of_lading":
                    invoiceTabProvider.billOfLadingController.text,
                "motor_vehicle_no":
                    invoiceTabProvider.motorVehicleNoController.text,
                "reference_date": invoiceTabProvider
                    .referenceDateController.text
                    .toyyyymmdd(),
                "terms_of_delivery":
                    invoiceTabProvider.termsOfDeliveryController.text,
              };
              log(data.toString());
              invoiceTabProvider.saveInvoiceTab(
                  customerId: widget.customerId, context: context, data: data);
            },
            backgroundColor: AppColors.appViolet,
            borderColor: AppColors.appViolet,
            textColor: AppColors.whiteColor,
          ),
        ],
      );
    });
  }

  Widget _buildWebForm(
      BuildContext context, InvoiceTabProvider invoiceTabProvider) {
    return Column(
      children: [
        // CustomTextField(
        //   readOnly: true,
        //   height: 54,
        //   controller: invoiceTabProvider.invoiceNoInvoiceController,
        //   hintText: 'Invoice No',
        //   labelText: '',
        //   keyboardType: TextInputType.text,
        //   focusNode: FocusNode(),
        // ),
        // const SizedBox(height: 16),

        // // Additional fields from mobile form
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                height: 54,
                controller: invoiceTabProvider.invoiceNoInvoiceController,
                hintText: 'Invoice No*',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.ewayInvoiceNoController,
                hintText: 'E-way Invoice No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.modeOfPaymentController,
                hintText: 'Mode of payment',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.referenceNoController,
                hintText: 'Reference No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.addressInvoiceController,
                hintText: 'Shipping Address',
                labelText: '',
                keyboardType: TextInputType.multiline,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.buyerOrderNoController,
                hintText: 'Buyer order No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.dispatchedDocumentNoController,
                hintText: 'Dispatched Document No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));
                  if (picked != null) {
                    invoiceTabProvider.deliveryNoteDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: invoiceTabProvider.deliveryNoteDateController,
                hintText: 'Delivery Note Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (picked != null) {
                      invoiceTabProvider.deliveryNoteDateController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.otherReferenceController,
                hintText: 'Other Reference',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));
                  if (picked != null) {
                    invoiceTabProvider.datedController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: invoiceTabProvider.datedController,
                hintText: 'Dated',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (picked != null) {
                      invoiceTabProvider.datedController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.dispatchedThroughController,
                hintText: 'Dispatched Through',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.destinationController,
                hintText: 'Destination',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.billOfLadingController,
                hintText: 'Bill of Lading/LR-RR No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.motorVehicleNoController,
                hintText: 'Motor vehicle No',
                labelText: '',
                keyboardType: TextInputType.text,
                focusNode: FocusNode(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));
                  if (picked != null) {
                    invoiceTabProvider.referenceDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: invoiceTabProvider.referenceDateController,
                hintText: 'Reference Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (picked != null) {
                      invoiceTabProvider.referenceDateController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101));
                  if (picked != null) {
                    invoiceTabProvider.invoiceDateInvoiceController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: invoiceTabProvider.invoiceDateInvoiceController,
                hintText: 'Invoice Date*',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if (picked != null) {
                      invoiceTabProvider.invoiceDateInvoiceController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          readOnly: false,
          height: 54,
          minLines: 2,
          controller: invoiceTabProvider.termsOfDeliveryController,
          hintText: 'Terms Of Delivery',
          labelText: '',
          keyboardType: TextInputType.multiline,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 20),

        // Item Details Section (same as before)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: invoiceTabProvider.itemNameInvoiceController,
                      hintText: 'Item*',
                      labelText: '',
                    ),
                    //  CommonDropdown(
                    //   hintText: "Item*",
                    //   items: invoiceTabProvider.itemListPurchase
                    //       .where((element) => element.primaryCheckBox == 0)
                    //       .map((status) => DropdownItem<int>(
                    //             id: status.itemId,
                    //             name: status.itemName,
                    //           ))
                    //       .toList(),
                    //   controller: invoiceTabProvider.itemNameInvoiceController,
                    //   onItemSelected: (selectedItem) {
                    //     final selectedData = invoiceTabProvider.itemListPurchase
                    //         .firstWhere((item) => item.itemId == selectedItem);
                    //     invoiceTabProvider
                    //         .setSelectedPurchaseItemId(selectedItem);
                    //     invoiceTabProvider.priceInvoiceController.text =
                    //         selectedData.unitPrice;
                    //     invoiceTabProvider.cgstPerInvoiceController.text =
                    //         selectedData.cgst;
                    //     invoiceTabProvider.sgstPerInvoiceController.text =
                    //         selectedData.sgst;
                    //     invoiceTabProvider.igstPerInvoiceController.text =
                    //         selectedData.igst;
                    //     invoiceTabProvider.gstPerInvoiceController.text =
                    //         selectedData.gst;
                    //     invoiceTabProvider.hsnInvoiceController.text =
                    //         selectedData.hsnCode;
                    //     invoiceTabProvider
                    //         .setSelectedStockId(selectedData.stockId);
                    //     maxQuantity = selectedData.quantity;
                    //     invoiceTabProvider.updateCalculations();
                    //   },
                    //   selectedValue: invoiceTabProvider.itemId,
                    // ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: invoiceTabProvider.hsnInvoiceController,
                      hintText: 'HSN Code',
                      labelText: '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.priceInvoiceController,
                      hintText: 'Unit Price*',
                      labelText: '',
                      focusNode: FocusNode(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        invoiceTabProvider.updateCalculations();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.quantityInvoiceController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      hintText: 'Quantity*',
                      labelText: "Max $maxQuantity",
                      focusNode: FocusNode(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        invoiceTabProvider.updateCalculations();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.amountInvoiceController,
                      keyboardType: TextInputType.number,
                      hintText: 'Amount',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.discountInvoiceController,
                      hintText: 'Discount Amount', // Changed from 'Discount %'
                      labelText: '',
                      focusNode: FocusNode(),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      onChanged: (value) {
                        invoiceTabProvider.updateCalculations();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.netValueInvoiceController,
                      hintText: 'Net Value (After Discount)',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.gstPerInvoiceController,
                      hintText: 'GST %',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                      ],
                      onChanged: (value) {
                        if (invoiceTabProvider
                            .gstPerInvoiceController.text.isEmpty) {
                          invoiceTabProvider.gstPerInvoiceController.text = '0';
                        }
                        invoiceTabProvider.updateCalculations();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.cgstPerInvoiceController,
                      hintText: 'CGST %',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.sgstPerInvoiceController,
                      hintText: 'SGST %',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.cgstInvoiceController,
                      hintText: 'CGST Amount',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.sgstInvoiceController,
                      hintText: 'SGST Amount',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller: invoiceTabProvider.gstInvoiceController,
                      hintText: 'GST Amount',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      height: 54,
                      controller:
                          invoiceTabProvider.totalAmountInvoiceController,
                      hintText: 'Total Amount',
                      labelText: '',
                      focusNode: FocusNode(),
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomElevatedButton(
                    buttonText: 'Add Item',
                    onPressed: () {
                      if (invoiceTabProvider.itemNameInvoiceController.text.isEmpty ||
                          invoiceTabProvider
                              .quantityInvoiceController.text.isEmpty ||
                          invoiceTabProvider
                              .priceInvoiceController.text.isEmpty) {
                        showErrorDialog(
                            context, 'Please fill in all required fields');
                        return;
                      }
                      final invoiceItem = InvoiceItemModel(
                        itemName:
                            invoiceTabProvider.itemNameInvoiceController.text,
                        hsnCode: invoiceTabProvider.hsnInvoiceController.text,
                        gst: invoiceTabProvider.gstPerInvoiceController.text,
                        cgst: invoiceTabProvider.cgstPerInvoiceController.text,
                        sgst: invoiceTabProvider.sgstPerInvoiceController.text,
                        rate: invoiceTabProvider.priceInvoiceController.text,
                        quantity:
                            invoiceTabProvider.quantityInvoiceController.text,
                        amount: invoiceTabProvider.amountInvoiceController.text,
                        discount: invoiceTabProvider.discountInvoiceController
                            .text, // Now this is the amount
                        taxableAmount:
                            invoiceTabProvider.netValueInvoiceController.text,
                        cgstAmount:
                            invoiceTabProvider.cgstInvoiceController.text,
                        sgstAmount:
                            invoiceTabProvider.sgstInvoiceController.text,
                        gstAmount: invoiceTabProvider.gstInvoiceController.text,
                        totalAmount: invoiceTabProvider
                            .totalAmountInvoiceController.text,
                        invoiceDetailsId:
                            invoiceTabProvider.invoiceDetailsId ?? 0,
                      );
                      invoiceTabProvider.addOrUpdateInvoiceItem(invoiceItem);
                      invoiceTabProvider.clearInvoiceItemFields();
                      invoiceTabProvider.calculateGrandTotal();
                    },
                    backgroundColor: AppColors.appViolet,
                    borderColor: AppColors.appViolet,
                    textColor: AppColors.whiteColor,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (invoiceTabProvider.invoiceItem.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Added Items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.appViolet.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${invoiceTabProvider.invoiceItem.length} items',
                          style: TextStyle(
                            color: AppColors.appViolet,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: invoiceTabProvider.invoiceItem
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'HSN: ${item.hsnCode}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} x ₹${item.rate}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Discount: ₹${item.discount}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'CGST: ₹${item.cgstAmount}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'SGST: ₹${item.sgstAmount}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total GST: ₹${item.gstAmount}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${item.totalAmount}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: Colors.green,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue, size: 20),
                                      onPressed: () {
                                        invoiceTabProvider
                                            .editInvoiceItem(index);
                                        invoiceTabProvider.updateCalculations();
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        invoiceTabProvider
                                            .removeInvoiceItem(index);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _SummaryItem(
                                label: 'Total Amount',
                                value:
                                    '₹${invoiceTabProvider.grandTotal.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total Discount',
                                value:
                                    '₹${invoiceTabProvider.totalDiscount.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Round off',
                                value:
                                    '₹${(invoiceTabProvider.grandTotal - invoiceTabProvider.totalDiscount).toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total Taxable Amount',
                                value:
                                    '₹${invoiceTabProvider.totalTaxableAmount.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total CGST',
                                value:
                                    '₹${invoiceTabProvider.totalCGST.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total SGST',
                                value:
                                    '₹${invoiceTabProvider.totalSGST.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total GST',
                                value:
                                    '₹${invoiceTabProvider.totalGST.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.appViolet.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${invoiceTabProvider.finalGrandTotal.roundToDouble().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.appViolet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        CustomTextField(
          height: 54,
          controller: invoiceTabProvider.descriptionInvoiceController,
          hintText: 'Description',
          labelText: '',
          focusNode: FocusNode(),
          keyboardType: TextInputType.multiline,
          minLines: 2,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMobileForm(
      BuildContext context, InvoiceTabProvider invoiceTabProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CommonDropdown(
        //   hintText: "Quotation No",
        //   items: invoiceTabProvider.quotaionNoData
        //       .map((status) => DropdownItem<int>(
        //             id: status.quotationMasterId,
        //             name: status.quotationNo,
        //           ))
        //       .toList(),
        //   controller: invoiceTabProvider.quotationNoController,
        //   onItemSelected: (selectedItem) {
        //     final selectedData = invoiceTabProvider.quotaionNoData
        //         .firstWhere((item) => item.quotationMasterId == selectedItem);
        //     invoiceTabProvider.setSelectedQuotationNoId(selectedItem);
        //     invoiceTabProvider.quotationNoController.text =
        //         selectedData.quotationNo;
        //     invoiceTabProvider.getItemsFromQuotation(selectedItem.toString());
        //   },
        //   selectedValue: invoiceTabProvider.quotationNoId,
        // ),
        // const SizedBox(height: 12),
        CustomTextField(
          height: 54,
          controller: invoiceTabProvider.invoiceNoInvoiceController,
          hintText: 'Invoice No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.ewayInvoiceNoController,
          hintText: 'E-way Invoice No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.modeOfPaymentController,
          hintText: 'Mode of payment',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.referenceNoController,
          hintText: 'Reference No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.addressInvoiceController,
          hintText: 'Shipping Address',
          labelText: '',
          keyboardType: TextInputType.multiline,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.buyerOrderNoController,
          hintText: 'Buyer order No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.dispatchedDocumentNoController,
          hintText: 'Dispatched Document No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.otherReferenceController,
          hintText: 'Other Reference',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));
            if (picked != null) {
              invoiceTabProvider.deliveryNoteDateController.text =
                  DateFormat('dd MMM yyyy').format(picked);
            }
          },
          readOnly: true,
          height: 54,
          controller: invoiceTabProvider.deliveryNoteDateController,
          hintText: 'Delivery Note Date',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (picked != null) {
                invoiceTabProvider.deliveryNoteDateController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
          ),
          labelText: '',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));
            if (picked != null) {
              invoiceTabProvider.datedController.text =
                  DateFormat('dd MMM yyyy').format(picked);
            }
          },
          readOnly: true,
          height: 54,
          controller: invoiceTabProvider.datedController,
          hintText: 'Dated',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (picked != null) {
                invoiceTabProvider.datedController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
          ),
          labelText: '',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.dispatchedThroughController,
          hintText: 'Dispatched Through',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.destinationController,
          hintText: 'Destination',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.billOfLadingController,
          hintText: 'Bill of Lading/LR-RR No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          controller: invoiceTabProvider.motorVehicleNoController,
          hintText: 'Motor vehicle No',
          labelText: '',
          keyboardType: TextInputType.text,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));
            if (picked != null) {
              invoiceTabProvider.referenceDateController.text =
                  DateFormat('dd MMM yyyy').format(picked);
            }
          },
          readOnly: true,
          height: 54,
          controller: invoiceTabProvider.referenceDateController,
          hintText: 'Reference Date',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (picked != null) {
                invoiceTabProvider.referenceDateController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
          ),
          labelText: '',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101));
            if (picked != null) {
              invoiceTabProvider.invoiceDateInvoiceController.text =
                  DateFormat('dd MMM yyyy').format(picked);
            }
          },
          readOnly: true,
          height: 54,
          controller: invoiceTabProvider.invoiceDateInvoiceController,
          hintText: 'Invoice Date*',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101));
              if (picked != null) {
                invoiceTabProvider.invoiceDateInvoiceController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
          ),
          labelText: '',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          readOnly: false,
          height: 54,
          minLines: 2,
          controller: invoiceTabProvider.termsOfDeliveryController,
          hintText: 'Terms Of Delivery',
          labelText: '',
          keyboardType: TextInputType.multiline,
          focusNode: FocusNode(),
        ),
        const SizedBox(height: 20),
        // Item Form Section (stacked vertically)
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Item Details',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              CommonDropdown(
                hintText: "Item*",
                items: invoiceTabProvider.itemListPurchase
                    .where((element) => element.primaryCheckBox == 0)
                    .map((status) => DropdownItem<int>(
                          id: status.itemId,
                          name: status.itemName,
                        ))
                    .toList(),
                controller: invoiceTabProvider.itemNameInvoiceController,
                onItemSelected: (selectedItem) {
                  final selectedData = invoiceTabProvider.itemListPurchase
                      .firstWhere((item) => item.itemId == selectedItem);
                  invoiceTabProvider.setSelectedPurchaseItemId(selectedItem);
                  invoiceTabProvider.priceInvoiceController.text =
                      selectedData.unitPrice;
                  invoiceTabProvider.cgstPerInvoiceController.text =
                      selectedData.cgst;
                  invoiceTabProvider.sgstPerInvoiceController.text =
                      selectedData.sgst;
                  invoiceTabProvider.igstPerInvoiceController.text =
                      selectedData.igst;
                  invoiceTabProvider.gstPerInvoiceController.text =
                      selectedData.gst;
                  invoiceTabProvider.hsnInvoiceController.text =
                      selectedData.hsnCode;
                  invoiceTabProvider.setSelectedStockId(selectedData.stockId);
                  maxQuantity = selectedData.quantity;
                  invoiceTabProvider.updateCalculations();
                },
                selectedValue: invoiceTabProvider.itemId,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: invoiceTabProvider.hsnInvoiceController,
                hintText: 'HSN Code',
                labelText: '',
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.priceInvoiceController,
                hintText: 'Unit Price*',
                labelText: '',
                focusNode: FocusNode(),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  invoiceTabProvider.updateCalculations();
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.quantityInvoiceController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                hintText: 'Quantity*',
                labelText: "Max $maxQuantity",
                focusNode: FocusNode(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  invoiceTabProvider.updateCalculations();
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.amountInvoiceController,
                keyboardType: TextInputType.number,
                hintText: 'Amount',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
              ),
              const SizedBox(height: 8),
              // NEW: Discount Percentage Field
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.discountInvoiceController,
                hintText: 'Discount %',
                labelText: '',
                focusNode: FocusNode(),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                ],
                onChanged: (value) {
                  invoiceTabProvider.updateCalculations();
                },
              ),
              const SizedBox(height: 8),
              // NEW: Net Value (Taxable Amount after discount)
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.netValueInvoiceController,
                hintText: 'Net Value (After Discount)',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
              ),
              const SizedBox(height: 8),
              // NEW: CGST Percentage
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.cgstPerInvoiceController,
                hintText: 'CGST %',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true, // Auto-calculated from GST%
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              // NEW: SGST Percentage
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.sgstPerInvoiceController,
                hintText: 'SGST %',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true, // Auto-calculated from GST%
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.gstPerInvoiceController,
                hintText: 'GST %',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                ],
                onChanged: (value) {
                  if (invoiceTabProvider.gstPerInvoiceController.text.isEmpty) {
                    invoiceTabProvider.gstPerInvoiceController.text = '0';
                  }
                  invoiceTabProvider.updateCalculations();
                },
              ),
              const SizedBox(height: 8),
              // NEW: CGST Amount
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.cgstInvoiceController,
                hintText: 'CGST Amount',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              // NEW: SGST Amount
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.sgstInvoiceController,
                hintText: 'SGST Amount',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.gstInvoiceController,
                hintText: 'Total GST Amount',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              CustomTextField(
                height: 54,
                controller: invoiceTabProvider.totalAmountInvoiceController,
                hintText: 'Total Amount',
                labelText: '',
                focusNode: FocusNode(),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      buttonText: 'Add Item',
                      onPressed: () {
                        if (invoiceTabProvider.itemNameInvoiceController.text.isEmpty ||
                            invoiceTabProvider
                                .quantityInvoiceController.text.isEmpty ||
                            invoiceTabProvider
                                .priceInvoiceController.text.isEmpty) {
                          showErrorDialog(
                              context, 'Please fill in all required fields');
                          return;
                        }
                        final invoiceItem = InvoiceItemModel(
                          // itemId: invoiceTabProvider.itemId ?? 0,
                          itemName:
                              invoiceTabProvider.itemNameInvoiceController.text,
                          hsnCode: invoiceTabProvider.hsnInvoiceController.text,
                          gst: invoiceTabProvider.gstPerInvoiceController.text,
                          cgst:
                              invoiceTabProvider.cgstPerInvoiceController.text,
                          sgst:
                              invoiceTabProvider.sgstPerInvoiceController.text,
                          rate: invoiceTabProvider.priceInvoiceController.text,
                          quantity:
                              invoiceTabProvider.quantityInvoiceController.text,
                          amount:
                              invoiceTabProvider.amountInvoiceController.text,
                          discount: invoiceTabProvider
                              .discountAmountInvoiceController.text,
                          taxableAmount:
                              invoiceTabProvider.netValueInvoiceController.text,
                          cgstAmount:
                              invoiceTabProvider.cgstInvoiceController.text,
                          sgstAmount:
                              invoiceTabProvider.sgstInvoiceController.text,
                          gstAmount:
                              invoiceTabProvider.gstInvoiceController.text,
                          totalAmount: invoiceTabProvider
                              .totalAmountInvoiceController.text,
                          // stockId: invoiceTabProvider.stockId ?? 0,
                          invoiceDetailsId:
                              invoiceTabProvider.invoiceDetailsId ?? 0,
                        );
                        invoiceTabProvider.addOrUpdateInvoiceItem(invoiceItem);
                        invoiceTabProvider.clearInvoiceItemFields();
                        invoiceTabProvider.calculateGrandTotal();
                      },
                      backgroundColor: AppColors.appViolet,
                      borderColor: AppColors.appViolet,
                      textColor: AppColors.whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (invoiceTabProvider.invoiceItem.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Added Items',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.appViolet.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${invoiceTabProvider.invoiceItem.length} items',
                          style: TextStyle(
                            color: AppColors.appViolet,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: invoiceTabProvider.invoiceItem
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      var item = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'HSN: ${item.hsnCode}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${item.quantity} x ₹${item.rate}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Discount: ₹${item.discount}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'CGST: ₹${item.cgstAmount}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SGST: ₹${item.sgstAmount}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Total GST: ₹${item.gstAmount}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.totalAmount}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue, size: 20),
                                        onPressed: () {
                                          invoiceTabProvider
                                              .editInvoiceItem(index);
                                          invoiceTabProvider
                                              .updateCalculations();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade700,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          invoiceTabProvider
                                              .removeInvoiceItem(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _SummaryItem(
                                label: 'Total Amount',
                                value:
                                    '₹${invoiceTabProvider.grandTotal.toStringAsFixed(2)}',
                              ),
                              // NEW: Total Discount
                              _SummaryItem(
                                label: 'Total Discount',
                                value:
                                    '₹${invoiceTabProvider.totalDiscount.toStringAsFixed(2)}',
                              ),
                              // NEW: Net Amount (After Discount)
                              _SummaryItem(
                                label: 'Net Amount',
                                value:
                                    '₹${(invoiceTabProvider.grandTotal - invoiceTabProvider.totalDiscount).toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total Taxable Amount',
                                value:
                                    '₹${invoiceTabProvider.totalTaxableAmount.toStringAsFixed(2)}',
                              ),
                              // NEW: Total CGST
                              _SummaryItem(
                                label: 'Total CGST',
                                value:
                                    '₹${invoiceTabProvider.totalCGST.toStringAsFixed(2)}',
                              ),
                              // NEW: Total SGST
                              _SummaryItem(
                                label: 'Total SGST',
                                value:
                                    '₹${invoiceTabProvider.totalSGST.toStringAsFixed(2)}',
                              ),
                              _SummaryItem(
                                label: 'Total GST',
                                value:
                                    '₹${invoiceTabProvider.totalGST.toStringAsFixed(2)}',
                              ),
                              // NEW: Round Off
                              _SummaryItem(
                                label: 'Round Off',
                                value:
                                    '₹${(invoiceTabProvider.finalGrandTotal.roundToDouble() - invoiceTabProvider.finalGrandTotal).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.appViolet.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${invoiceTabProvider.finalGrandTotal.roundToDouble().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.appViolet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        CustomTextField(
          height: 54,
          controller: invoiceTabProvider.descriptionInvoiceController,
          hintText: 'Description',
          labelText: '',
          focusNode: FocusNode(),
          keyboardType: TextInputType.multiline,
          minLines: 2,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

String formatInvoiceDate(String InvoiceDate) {
  DateTime parsedDate = DateTime.parse(InvoiceDate);
  return DateFormat('dd MMM yyyy').format(parsedDate);
}

// Helper widget for summary items
class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
