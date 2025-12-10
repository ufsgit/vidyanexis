import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';

import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

class QuotationCreationWidget extends StatelessWidget {
  bool isEdit;
  String customerId;
  String quotationId;
  QuotationCreationWidget(
      {super.key,
      required this.quotationId,
      required this.isEdit,
      required this.customerId});

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    // String? _validateTotal() {
    //   int advance =
    //       int.tryParse(customerDetailsProvider.advanceController.text) ?? 0;
    //   int delivery =
    //       int.tryParse(customerDetailsProvider.deliveryController.text) ?? 0;
    //   int completion =
    //       int.tryParse(customerDetailsProvider.workCompletionController.text) ??
    //           0;

    //   int total = advance + delivery + completion;

    //   if (total < 100) {
    //     return "Total percentage must be exactly 100%. It's currently less than 100%.";
    //   } else if (total > 100) {
    //     return "Total percentage must be exactly 100%. It's currently more than 100%.";
    //   }
    //   return null; // Valid total
    // }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            isEdit ? 'Edit Quotation' : 'Add Quotation',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
              onPressed: () {
                customerDetailsProvider.clearQuotationDetails();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: AppStyles.isWebScreen(context)
              ? MediaQuery.of(context).size.width / 2
              : MediaQuery.of(context).size.width,
          // height: MediaQuery.sizeOf(context).height / 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //basic details
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Basic details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: true,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.qproductnameController,
                          hintText: 'Product name*',
                          labelText: '',
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value:
                              customerDetailsProvider.selectedQuotationStatus ??
                                  1,
                          items: const [
                            DropdownMenuItem<int>(
                              value: 1,
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem<int>(
                              value: 3,
                              child: Text('Rejected'),
                            ),
                            DropdownMenuItem<int>(
                              value: 2,
                              child: Text('Approved'),
                            ),
                          ],
                          // items: dropDownProvider.amcStatus
                          //     .map((status) => DropdownMenuItem<int>(
                          //           value: status.amcStatusId,
                          //           child: Text(
                          //             status.amcStatusName,
                          //             style: TextStyle(fontSize: 14),
                          //           ),
                          //         ))
                          //     .toList(),
                          onChanged: (int? newValue) {
                            // if (newValue != null) {
                            //   final selectedAmcStatus = dropDownProvider.amcStatus
                            //       .firstWhere((task) => task.amcStatusId == newValue);
                            //   customerDetailsProvider.updateQuotationStatus(
                            //       newValue, selectedAmcStatus.amcStatusName);
                            // }
                            if (newValue != null) {
                              customerDetailsProvider
                                  .updateQuotationStatus(newValue);
                            }
                          },
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, // Custom font size
                            fontWeight: FontWeight.w600, // Custom font weight
                            color: AppColors
                                .textBlack, // Custom color for selected item
                          ),
                          decoration: InputDecoration(
                            label: RichText(
                              text: TextSpan(
                                text: 'Choose Status',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey3,
                                ),
                                children: const <TextSpan>[
                                  TextSpan(
                                    text: ' *', // The asterisk part
                                    style: TextStyle(
                                        color: Colors
                                            .red), // Red color for asterisk
                                  ),
                                ],
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior
                                .auto, // Always show the label
                            floatingLabelStyle: GoogleFonts.plusJakartaSans(
                              fontSize:
                                  16, // Slightly smaller size for floating label
                              fontWeight: FontWeight.w500,
                              color: AppColors
                                  .textGrey1, // Color for floating label
                            ),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              borderSide: BorderSide(
                                color: AppColors.textGrey2, // Border color
                                width: 1, // Border width
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              borderSide: BorderSide(
                                color: AppColors.textGrey2, // Border color
                                width: 1, // Border width
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              borderSide: BorderSide(
                                color: AppColors.textGrey2, // Border color
                                width: 1, // Border width
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 12),
                          ),
                          isDense: true,
                          iconSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Financials ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '*',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemNameController,
                                    hintText: 'Item Name',
                                    labelText: '',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemPriceController,
                                    onChanged: (p0) {
                                      // Calculate total amount and GST when price changes
                                      customerDetailsProvider
                                          .calculateTotalAmount();
                                    },
                                    hintText: 'Price',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
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
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemQuantityController,
                                    onChanged: (value) {
                                      // Calculate total amount when quantity changes
                                      customerDetailsProvider
                                          .calculateTotalAmount();
                                    },
                                    hintText: 'Quantity',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemUnitController,
                                    hintText: 'Unit',
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
                                    controller: customerDetailsProvider
                                        .itemGstPercentController,
                                    onChanged: (value) {
                                      // Calculate GST when GST% changes
                                      customerDetailsProvider
                                          .calculateTotalAmount();
                                    },
                                    hintText: 'GST %',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: true,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemGstController,
                                    hintText: 'GST',
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
                                    controller: customerDetailsProvider
                                        .itemAdCessController,
                                    hintText: 'AdCESS',
                                    labelText: '',
                                    onChanged: (value) {
                                      // Calculate GST when GST% changes
                                      customerDetailsProvider
                                          .calculateTotalAmount();
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: true,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .itemTotalController,
                                    hintText: 'Amount',
                                    labelText: '',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: CustomTextField(
                            //         readOnly: false,
                            //         height: 54,
                            //         controller: customerDetailsProvider
                            //             .itemMrpController,
                            //         hintText: 'MRP',
                            //         labelText: '',
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly
                            //         ],
                            //       ),
                            //     ),
                            //     const SizedBox(width: 16),
                            //     Expanded(
                            //       child: CustomTextField(
                            //         readOnly: false,
                            //         height: 54,
                            //         controller: customerDetailsProvider
                            //             .itemPriceController,
                            //         onChanged: (p0) {
                            //           int total = 0;

                            //           final itemPrice = int.tryParse(
                            //               customerDetailsProvider
                            //                   .itemPriceController.text);
                            //           final itemQuantity = int.tryParse(
                            //               customerDetailsProvider
                            //                   .itemQuantityController.text);

                            //           if (itemPrice != null &&
                            //               itemQuantity != null) {
                            //             total = itemPrice * itemQuantity;
                            //           } else {
                            //             print(
                            //                 "Invalid input for price or quantity");
                            //           }
                            //           customerDetailsProvider
                            //               .itemTotalController
                            //               .text = total.toString();
                            //         },
                            //         hintText: 'Price',
                            //         labelText: '',
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 16),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       child: CustomTextField(
                            //         readOnly: false,
                            //         height: 54,
                            //         controller: customerDetailsProvider
                            //             .itemQuantityController,
                            //         hintText: 'Quantity',
                            //         labelText: '',
                            //         onChanged: (p0) {
                            //           int total = 0;

                            //           final itemPrice = int.tryParse(
                            //               customerDetailsProvider
                            //                   .itemPriceController.text);
                            //           final itemQuantity = int.tryParse(
                            //               customerDetailsProvider
                            //                   .itemQuantityController.text);

                            //           if (itemPrice != null &&
                            //               itemQuantity != null) {
                            //             total = itemPrice * itemQuantity;
                            //           } else {
                            //             print(
                            //                 "Invalid input for price or quantity");
                            //           }
                            //           customerDetailsProvider
                            //               .itemTotalController
                            //               .text = total.toString();
                            //         },
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly
                            //         ],
                            //       ),
                            //     ),
                            //     const SizedBox(width: 16),
                            //     Expanded(
                            //       child: CustomTextField(
                            //         readOnly: true,
                            //         height: 54,
                            //         controller: customerDetailsProvider
                            //             .itemTotalController,
                            //         hintText: 'Total',
                            //         labelText: '',
                            //         inputFormatters: [
                            //           FilteringTextInputFormatter.digitsOnly
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                customerDetailsProvider.addOrEditItem(context);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add item'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors
                                    .primaryBlue, // Change foreground color
                                backgroundColor:
                                    Colors.white, // Change background color
                                side: BorderSide(
                                    color: AppColors
                                        .primaryBlue), // Change border color
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Add border radius
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppStyles.isWebScreen(context)
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        customerDetailsProvider.items.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          customerDetailsProvider.items[index];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.ItemName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'Quantity: ${item.Quantity}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'Unit Price: ₹${item.UnitPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'GST: ₹${item.GST.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Text(
                                              'Total: ₹${item.Amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            TextButton(
                                              onPressed: () =>
                                                  customerDetailsProvider
                                                      .populateItemFieldsForEditing(
                                                          index),
                                              child: Text(
                                                'Edit',
                                                style: TextStyle(
                                                  color: Colors.blue[400],
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  customerDetailsProvider
                                                      .deleteItem(index),
                                              child: Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red[400],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        customerDetailsProvider.items.length,
                                    itemBuilder: (context, index) {
                                      final item =
                                          customerDetailsProvider.items[index];
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.ItemName,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Quantity: ${item.Quantity}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Total: ₹${item.Amount.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      customerDetailsProvider
                                                          .populateItemFieldsForEditing(
                                                              index),
                                                  icon: Icon(Icons.edit,
                                                      size: 18,
                                                      color: Colors.blue[400]),
                                                  label: Text(
                                                    'Edit',
                                                    style: TextStyle(
                                                      color: Colors.blue[400],
                                                    ),
                                                  ),
                                                ),
                                                TextButton.icon(
                                                  onPressed: () =>
                                                      customerDetailsProvider
                                                          .deleteItem(index),
                                                  icon: Icon(Icons.delete,
                                                      size: 18,
                                                      color: Colors.red[400]),
                                                  label: Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red[400],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                            // if (customerDetailsProvider.items.isNotEmpty)
                            //   Row(
                            //     mainAxisAlignment:
                            //         AppStyles.isWebScreen(context)
                            //             ? MainAxisAlignment.end
                            //             : MainAxisAlignment.start,
                            //     children: [
                            //       Text(
                            //         AppStyles.isWebScreen(context)
                            //             ? 'Subsidy Amount:   '
                            //             : 'Subsidy \n Amount:   ',
                            //         style: TextStyle(
                            //             fontWeight: FontWeight.bold,
                            //             color: Colors.black,
                            //             fontSize: 16),
                            //       ),
                            //       Container(
                            //         width: 140,
                            //         padding: const EdgeInsets.symmetric(
                            //             horizontal: 8.0, vertical: 0),
                            //         decoration: BoxDecoration(
                            //           color: Colors.white,
                            //           borderRadius: BorderRadius.circular(10),
                            //         ),
                            //         child: TextField(
                            //           controller: customerDetailsProvider
                            //               .qsubsidyAmountController,
                            //           onChanged: (p0) {
                            //             if (customerDetailsProvider
                            //                 .qsubsidyAmountController
                            //                 .text
                            //                 .isEmpty) {
                            //               customerDetailsProvider
                            //                   .qsubsidyAmountController
                            //                   .text = '0';
                            //             }
                            //             customerDetailsProvider.updateTotal();
                            //           },
                            //           decoration: const InputDecoration(
                            //               border: InputBorder.none,
                            //               contentPadding: EdgeInsets.zero,
                            //               hintText: '₹'),
                            //           inputFormatters: [
                            //             FilteringTextInputFormatter.allow(
                            //                 RegExp(r'^\d*\.?\d{0,2}')),
                            //           ],
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            if (customerDetailsProvider.items.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    AppStyles.isWebScreen(context)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Taxable amount:  ₹ ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: customerDetailsProvider
                                          .gstTaxableAmountController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border if needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (customerDetailsProvider.items.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    AppStyles.isWebScreen(context)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tax amount:  ₹ ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: customerDetailsProvider
                                          .totalGstAmountController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border if needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (customerDetailsProvider.items.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    AppStyles.isWebScreen(context)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ad. CESS :  ₹ ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: customerDetailsProvider
                                          .totalAdCESSController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border if needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (customerDetailsProvider.items.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    AppStyles.isWebScreen(context)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sub Total:  ₹ ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: customerDetailsProvider
                                          .subtotalController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border if needed
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (customerDetailsProvider.items.isNotEmpty)
                              Row(
                                mainAxisAlignment:
                                    AppStyles.isWebScreen(context)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total:  ₹ ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 130,
                                    child: TextField(
                                      controller: customerDetailsProvider
                                          .totalController,
                                      readOnly: true,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16),
                                      decoration: const InputDecoration(
                                        border: InputBorder
                                            .none, // Remove the border if needed
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
                ],
              ),
              //additional expenses
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Additional Expenses',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: false,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          height: 54,
                          controller:
                              customerDetailsProvider.systemPriceController,
                          hintText: 'System price excluding KSEB paper work',
                          labelText: '',
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: customerDetailsProvider
                              .additionalStructureController,
                          hintText: 'Additional Structure Work',
                          labelText: '',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.feasibilityFeeController,
                          hintText: 'Fee in KSEB for Feasibility study',
                          labelText: '',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.registrationFeeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          hintText:
                              'Registration Fee in KSEB-1000/- per kW (80% of amount will refund)',
                          labelText: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              //terms
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Terms and Conditions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: false,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller:
                        customerDetailsProvider.qtermsConditionsController,
                    hintText: 'Terms and Conditions',
                    labelText: '',
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              //terms
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Warranty',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: false,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  CustomTextField(
                    readOnly: false,
                    height: 54,
                    controller: customerDetailsProvider.qwarrentyController,
                    hintText: 'Warranty',
                    labelText: '',
                    minLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Payment Terms',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: false,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: customerDetailsProvider.advanceController,
                          hintText: 'Advance in %',
                          labelText: '',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          // onChanged: (value) => _validateTotal(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.deliveryController,
                          hintText: 'On Material delivery(%)',
                          labelText: '',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          // onChanged: (value) => _validateTotal(),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.workCompletionController,
                          hintText: 'On Work completion(%)',
                          labelText: '',
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          // onChanged: (value) => _validateTotal(),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  )
                ],
              ),
              // ExpansionTile(
              //   shape: const RoundedRectangleBorder(
              //     borderRadius: BorderRadius.zero,
              //   ),
              //   title: Text(
              //     'Production Chart',
              //     style: GoogleFonts.plusJakartaSans(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w500,
              //       color: AppColors.textGrey1,
              //     ),
              //   ),
              //   tilePadding: EdgeInsets.zero,
              //   initiallyExpanded: false,
              //   children: [
              //     const SizedBox(
              //       height: 5,
              //     ),
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       children: [
              //         Container(
              //           decoration: BoxDecoration(
              //             color: const Color(0xFFF6F7F9),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           padding: const EdgeInsets.all(16.0),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Row(
              //                 children: [
              //                   Expanded(
              //                     child: CustomTextField(
              //                       readOnly: false,
              //                       height: 54,
              //                       controller: customerDetailsProvider
              //                           .unitProductionChartController,
              //                       hintText: 'Unit Production Total',
              //                       labelText: '',
              //                     ),
              //                   ),
              //                   const SizedBox(width: 16.0),
              //                   Expanded(
              //                     child: CustomTextField(
              //                       readOnly: false,
              //                       height: 54,
              //                       controller:
              //                           customerDetailsProvider.dailyController,
              //                       hintText: 'Daily',
              //                       labelText: '',
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 16),
              //               Row(
              //                 children: [
              //                   Expanded(
              //                     child: CustomTextField(
              //                       readOnly: false,
              //                       height: 54,
              //                       controller: customerDetailsProvider
              //                           .monthlyController,
              //                       hintText: 'Monthly',
              //                       labelText: '',
              //                       inputFormatters: [
              //                         FilteringTextInputFormatter.digitsOnly
              //                       ],
              //                     ),
              //                   ),
              //                   const SizedBox(width: 16.0),
              //                   Expanded(
              //                     child: CustomTextField(
              //                       readOnly: false,
              //                       height: 54,
              //                       controller: customerDetailsProvider
              //                           .remarksController,
              //                       hintText: 'Remarks',
              //                       labelText: '',
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 16),
              //               OutlinedButton.icon(
              //                 onPressed: customerDetailsProvider
              //                     .addOrEditProductionChart,
              //                 icon: const Icon(Icons.add),
              //                 label: const Text('Add Production Chart'),
              //                 style: OutlinedButton.styleFrom(
              //                   foregroundColor: AppColors
              //                       .primaryBlue, // Change foreground color
              //                   backgroundColor:
              //                       Colors.white, // Change background color
              //                   side: BorderSide(
              //                       color: AppColors
              //                           .primaryBlue), // Change border color
              //                   padding: const EdgeInsets.symmetric(
              //                     horizontal: 10,
              //                     vertical: 0,
              //                   ),
              //                   shape: RoundedRectangleBorder(
              //                     borderRadius: BorderRadius.circular(
              //                         8), // Add border radius
              //                   ),
              //                 ),
              //               ),
              //               const SizedBox(height: 16),
              //               if (customerDetailsProvider
              //                   .productionItems.isNotEmpty)
              //                 AppStyles.isWebScreen(context)
              //                     ? Container(
              //                         padding: const EdgeInsets.symmetric(
              //                             horizontal: 10, vertical: 5),
              //                         decoration: BoxDecoration(
              //                           color: Colors.white,
              //                           borderRadius: BorderRadius.circular(20),
              //                         ),
              //                         child: Column(
              //                           children: [
              //                             Row(
              //                               children: [
              //                                 SizedBox(
              //                                   width: 40,
              //                                   child: Text(
              //                                     'Sl No',
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 const SizedBox(
              //                                   width: 8,
              //                                 ),
              //                                 Expanded(
              //                                   flex: 2,
              //                                   child: Text(
              //                                     'Unit Production Total',
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 Expanded(
              //                                   child: Text(
              //                                     'Daily',
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 Expanded(
              //                                   child: Text(
              //                                     'Monthly',
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 Expanded(
              //                                   flex: 2,
              //                                   child: Text(
              //                                     'Remarks',
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                                 Expanded(
              //                                   flex: 2,
              //                                   child: Text(
              //                                     'Actions',
              //                                     textAlign: TextAlign.center,
              //                                     style: GoogleFonts
              //                                         .plusJakartaSans(
              //                                       fontWeight: FontWeight.w600,
              //                                       fontSize: 14,
              //                                     ),
              //                                   ),
              //                                 ),
              //                               ],
              //                             ),
              //                             const SizedBox(
              //                               height: 10,
              //                             ),
              //                             ListView.builder(
              //                               shrinkWrap: true,
              //                               physics:
              //                                   const NeverScrollableScrollPhysics(),
              //                               itemCount: customerDetailsProvider
              //                                   .productionItems.length,
              //                               itemBuilder: (context, index) {
              //                                 final item =
              //                                     customerDetailsProvider
              //                                         .productionItems[index];
              //                                 return Row(
              //                                   children: [
              //                                     SizedBox(
              //                                       width: 40,
              //                                       child: Center(
              //                                         child: Text(
              //                                           (index + 1).toString(),
              //                                           style: GoogleFonts
              //                                               .plusJakartaSans(
              //                                                   fontSize: 14),
              //                                         ),
              //                                       ),
              //                                     ),
              //                                     const SizedBox(
              //                                       width: 8,
              //                                     ),
              //                                     Expanded(
              //                                       flex: 2,
              //                                       child: Text(
              //                                         item.unitProduction,
              //                                         style: GoogleFonts
              //                                             .plusJakartaSans(
              //                                                 fontSize: 14),
              //                                       ),
              //                                     ),
              //                                     Expanded(
              //                                       child: Text(
              //                                         item.dailyTotal,
              //                                         style: GoogleFonts
              //                                             .plusJakartaSans(
              //                                                 fontSize: 14),
              //                                       ),
              //                                     ),
              //                                     Expanded(
              //                                       child: Text(
              //                                         item.monthlyTotal
              //                                             .toString(),
              //                                         style: GoogleFonts
              //                                             .plusJakartaSans(
              //                                                 fontSize: 14),
              //                                       ),
              //                                     ),
              //                                     Expanded(
              //                                       flex: 2,
              //                                       child: Text(
              //                                         item.remark,
              //                                         style: GoogleFonts
              //                                             .plusJakartaSans(
              //                                                 fontSize: 14),
              //                                       ),
              //                                     ),
              //                                     Expanded(
              //                                       flex: 1,
              //                                       child: TextButton(
              //                                         onPressed: () =>
              //                                             customerDetailsProvider
              //                                                 .populateProductionFieldsForEditing(
              //                                                     index),
              //                                         child: Text(
              //                                           'Edit',
              //                                           style: TextStyle(
              //                                             color:
              //                                                 Colors.blue[400],
              //                                           ),
              //                                         ),
              //                                       ),
              //                                     ),
              //                                     Expanded(
              //                                       flex: 1,
              //                                       child: TextButton(
              //                                         onPressed: () =>
              //                                             customerDetailsProvider
              //                                                 .deleteProduction(
              //                                                     index),
              //                                         child: Text(
              //                                           'Delete',
              //                                           style: TextStyle(
              //                                             color:
              //                                                 Colors.red[400],
              //                                           ),
              //                                         ),
              //                                       ),
              //                                     ),
              //                                   ],
              //                                 );
              //                               },
              //                             ),
              //                           ],
              //                         ),
              //                       )
              //                     : Container(
              //                         // padding: const EdgeInsets.all(12),
              //                         // decoration: BoxDecoration(
              //                         //   color: AppColors.scaffoldColor,
              //                         //   borderRadius: BorderRadius.circular(20),
              //                         // ),
              //                         child: Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           children: [
              //                             Text(
              //                               'Production Chart Items',
              //                               style: GoogleFonts.plusJakartaSans(
              //                                 fontSize: 18,
              //                                 fontWeight: FontWeight.w600,
              //                               ),
              //                             ),
              //                             const SizedBox(height: 12),
              //                             ListView.builder(
              //                               shrinkWrap: true,
              //                               physics:
              //                                   const NeverScrollableScrollPhysics(),
              //                               itemCount: customerDetailsProvider
              //                                   .bomItems.length,
              //                               itemBuilder: (context, index) {
              //                                 final item =
              //                                     customerDetailsProvider
              //                                         .productionItems[index];
              //                                 return Card(
              //                                   color: Colors.white,
              //                                   margin: const EdgeInsets.only(
              //                                       bottom: 12),
              //                                   elevation: 2,
              //                                   shape: RoundedRectangleBorder(
              //                                     borderRadius:
              //                                         BorderRadius.circular(12),
              //                                   ),
              //                                   child: Padding(
              //                                     padding:
              //                                         const EdgeInsets.all(16),
              //                                     child: Column(
              //                                       crossAxisAlignment:
              //                                           CrossAxisAlignment
              //                                               .start,
              //                                       children: [
              //                                         _buildInfoRow(
              //                                             'Unit Production Total',
              //                                             item.unitProduction),
              //                                         const SizedBox(height: 8),
              //                                         Row(
              //                                           children: [
              //                                             Expanded(
              //                                               child: _buildInfoRow(
              //                                                   'Daily',
              //                                                   item.dailyTotal),
              //                                             ),
              //                                             Expanded(
              //                                               child:
              //                                                   _buildInfoRow(
              //                                                 'Monthly',
              //                                                 item.monthlyTotal
              //                                                     .toString(),
              //                                               ),
              //                                             ),
              //                                           ],
              //                                         ),
              //                                         const SizedBox(height: 8),
              //                                         Row(
              //                                           children: [
              //                                             Expanded(
              //                                               child: _buildInfoRow(
              //                                                   'Description',
              //                                                   item.remark),
              //                                             ),
              //                                             const SizedBox(
              //                                                 width: 8),
              //                                           ],
              //                                         ),
              //                                         Row(
              //                                           children: [
              //                                             Expanded(
              //                                               child: TextButton(
              //                                                 onPressed: () =>
              //                                                     customerDetailsProvider
              //                                                         .populateProductionFieldsForEditing(
              //                                                             index),
              //                                                 child: Text(
              //                                                   'Edit',
              //                                                   style:
              //                                                       TextStyle(
              //                                                     color: Colors
              //                                                             .blue[
              //                                                         400],
              //                                                   ),
              //                                                 ),
              //                                               ),
              //                                             ),
              //                                             Expanded(
              //                                               child: TextButton(
              //                                                 onPressed: () =>
              //                                                     customerDetailsProvider
              //                                                         .deleteProduction(
              //                                                             index),
              //                                                 child: Text(
              //                                                   'Delete',
              //                                                   style:
              //                                                       TextStyle(
              //                                                     color: Colors
              //                                                         .red[400],
              //                                                   ),
              //                                                 ),
              //                                               ),
              //                                             ),
              //                                           ],
              //                                         ),
              //                                       ],
              //                                     ),
              //                                   ),
              //                                 );
              //                               },
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              //bill of details
              ExpansionTile(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                title: Text(
                  'Technical Specification',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                tilePadding: EdgeInsets.zero,
                initiallyExpanded: false,
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .billdescriptionController,
                                    hintText: 'Item name',
                                    labelText: '',
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .billmakeController,
                                    hintText: 'Make',
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
                                    controller: customerDetailsProvider
                                        .billquantityController,
                                    hintText: 'Quantity',
                                    labelText: '',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: false,
                                    height: 54,
                                    controller: customerDetailsProvider
                                        .billdistributorController,
                                    hintText: 'Distributor',
                                    labelText: '',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              readOnly: false,
                              height: 54,
                              controller:
                                  customerDetailsProvider.billinvoiceController,
                              hintText: 'Invoice No',
                              labelText: '',
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed:
                                  customerDetailsProvider.addOrEditBOMItem,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Material'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors
                                    .primaryBlue, // Change foreground color
                                backgroundColor:
                                    Colors.white, // Change background color
                                side: BorderSide(
                                    color: AppColors
                                        .primaryBlue), // Change border color
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Add border radius
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (customerDetailsProvider.bomItems.isNotEmpty)
                              AppStyles.isWebScreen(context)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                child: Text(
                                                  'Sl No',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Items',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Make',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Quantity',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Invoice No',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Distributor',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Actions',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: customerDetailsProvider
                                                .bomItems.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  customerDetailsProvider
                                                      .bomItems[index];
                                              return Row(
                                                children: [
                                                  SizedBox(
                                                    width: 40,
                                                    child: Center(
                                                      child: Text(
                                                        (index + 1).toString(),
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                                fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      item.itemsAndDescription,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      item.make,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      item.quantity.toString(),
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      item.invoiceNo,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      item.distributor,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          customerDetailsProvider
                                                              .populateBOMFieldsForEditing(
                                                                  index),
                                                      child: Text(
                                                        'Edit',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[400],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: TextButton(
                                                      onPressed: () =>
                                                          customerDetailsProvider
                                                              .deleteBOMItem(
                                                                  index),
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.red[400],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      // padding: const EdgeInsets.all(12),
                                      // decoration: BoxDecoration(
                                      //   color: AppColors.scaffoldColor,
                                      //   borderRadius: BorderRadius.circular(20),
                                      // ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'BOM Items',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: customerDetailsProvider
                                                .bomItems.length,
                                            itemBuilder: (context, index) {
                                              final item =
                                                  customerDetailsProvider
                                                      .bomItems[index];
                                              return Card(
                                                color: Colors.white,
                                                margin: const EdgeInsets.only(
                                                    bottom: 12),
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      _buildInfoRow('Item',
                                                          item.itemsAndDescription),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                _buildInfoRow(
                                                                    'Make',
                                                                    item.make),
                                                          ),
                                                          Expanded(
                                                            child:
                                                                _buildInfoRow(
                                                              'Quantity',
                                                              item.quantity
                                                                  .toString(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: _buildInfoRow(
                                                                'Invoice No',
                                                                item.invoiceNo),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: _buildInfoRow(
                                                                'Distributor',
                                                                item.distributor),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: TextButton(
                                                              onPressed: () =>
                                                                  customerDetailsProvider
                                                                      .populateBOMFieldsForEditing(
                                                                          index),
                                                              child: Text(
                                                                'Edit',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .blue[
                                                                      400],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: TextButton(
                                                              onPressed: () =>
                                                                  customerDetailsProvider
                                                                      .deleteBOMItem(
                                                                          index),
                                                              child: Text(
                                                                'Delete',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red[400],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            customerDetailsProvider.clearQuotationDetails();
            Navigator.of(context).pop();
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            if (customerDetailsProvider.qproductnameController.text.isEmpty) {
              _showValidationDialog(
                  context, 'Cannot Save', 'Product name is required');
              return;
            }

            if (customerDetailsProvider.items.isEmpty) {
              _showValidationDialog(context, 'Cannot Save', 'No items added');
              return;
            }

            // String? validationMessage = _validateTotal();
            // if (validationMessage == null) {
            // Save if total is exactly 100%
            customerDetailsProvider.saveQuotation(
                quotationId, customerId, context, isEdit);
            // }
            //  else {
            //   // Show alert dialog for incorrect total
            //   showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return AlertDialog(
            //         title: Text(
            //           'Invalid Total Percentage',
            //           style: TextStyle(
            //             color: AppColors.appViolet,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         content: Text(
            //           validationMessage,
            //           style: TextStyle(
            //             color: Colors.black87,
            //             fontSize: 16,
            //           ),
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         actions: [
            //           TextButton(
            //             onPressed: () {
            //               Navigator.pop(context);
            //             },
            //             child: Text(
            //               'OK',
            //               style: TextStyle(
            //                 color: AppColors.appViolet,
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 16,
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     },
            //   );
            // }
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showValidationDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
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
}
