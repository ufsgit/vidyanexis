import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/customer/custom_app_bar_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_textfield_widget_mobile.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/customer_details_provider.dart';
import '../../widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/bom_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/edit_bom_item_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_item_card.dart';
import 'package:vidyanexis/controller/settings_provider.dart';



class AddQuotationWidgetMobile extends StatefulWidget {
  const AddQuotationWidgetMobile(
      {super.key,
      this.isEdit = false,
      required this.customerId,
      required this.quotationId});
  final bool isEdit;
  final String customerId;
  final String quotationId;

  @override
  State<AddQuotationWidgetMobile> createState() =>
      _AddQuotationWidgetMobileState();
}

class _AddQuotationWidgetMobileState extends State<AddQuotationWidgetMobile> {
  late FocusNode statusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    statusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getCustomFieldsByQuotationId(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    if (customerDetailsProvider.qsubsidyAmountController.text.isEmpty) {
      customerDetailsProvider.qsubsidyAmountController.text = "0";
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarWidget(
        title: widget.isEdit ? 'Edit Quotation' : 'Add Quotation',
        onLeadingPressed: () {
          customerDetailsProvider.clearQuotationDetails();
          Navigator.pop(context);
        },
        onSavePressed: () async {
          if (customerDetailsProvider
                  .qsubsidyAmountController.text.isNotEmpty &&
              customerDetailsProvider.qproductnameController.text.isNotEmpty) {
            final responseData = await customerDetailsProvider.saveQuotation(
                widget.quotationId, widget.customerId, context, widget.isEdit);

            if (responseData != null) {
              // Extract quotation master id from response
              String masterId = '';
              if (responseData is Map &&
                  responseData.containsKey('Quotation_Master_Id')) {
                masterId = responseData['Quotation_Master_Id'].toString();
              } else if (responseData is List &&
                  responseData.isNotEmpty &&
                  responseData[0] is Map &&
                  responseData[0].containsKey('Quotation_Master_Id')) {
                masterId = responseData[0]['Quotation_Master_Id'].toString();
              }

              if (masterId.isEmpty || masterId == '0') {
                masterId = widget.quotationId;
              }

              if (context.mounted) {
                _showPrintQuotationDialog(context, masterId);
              }
            }
          } else {
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
                  content: const Text(
                    'Missing Details',
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
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: MultipleExpansionCard(
              initialExpanded: const {0: true},
              titles: [
                Text(
                  'Basic details',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                Text(
                  'Additional expense',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                Text(
                  'Terms and Conditions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                Text(
                  'Warranty',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                Text(
                  'Payment Terms',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                // Text(
                //   'Production Chart',
                //   style: GoogleFonts.plusJakartaSans(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.textBlack,
                //   ),
                // ),
                Text(
                  'Bill of Materials',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
              ],
              childrens: [
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      readOnly: false,
                      controller:
                          customerDetailsProvider.qproductnameController,
                      labelText: 'Product name',
                    ),
                    const SizedBox(height: 16.0),
                    CustomAutocomplete<Map<String, dynamic>>(
                      focusNode: statusNode,
                      showOptionsOnTap: true,
                      maxHeight: 300,
                      optionsViewOpenDirection: OptionsViewOpenDirection.down,
                      items: const [
                        {'id': 1, 'name': 'Pending'},
                        {'id': 3, 'name': 'Rejected'},
                        {'id': 2, 'name': 'Approved'},
                      ],
                      displayStringFunction: (item) => item['name'],
                      defaultText: getStatusNameById(
                          customerDetailsProvider.selectedQuotationStatus ?? 1),
                      labelText: 'Status',
                      controller:
                          customerDetailsProvider.quotationStatusController,
                      onSelected: (Map<String, dynamic> selectedStatus) {
                        customerDetailsProvider
                            .updateQuotationStatus(selectedStatus['id']);
                        customerDetailsProvider.quotationStatusController.text =
                            getStatusNameById(customerDetailsProvider
                                    .selectedQuotationStatus ??
                                1);
                      },
                      onChanged: (value) {},
                    ),
                    if (customerDetailsProvider
                        .customFieldQuotation.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      CustomFieldSectionWidget(
                        key: customFieldQuotationKey,
                        customFields:
                            customerDetailsProvider.customFieldQuotation,
                        controllerKey: 'quotation',
                      ),
                    ],
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
                               CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller:
                                    customerDetailsProvider.itemNameController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(1, 'Item Name'),
                              ),
                              const SizedBox(height: 16),
                               CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller:
                                    customerDetailsProvider.itemMrpController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(2, 'As Per Standerd Warranty'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller:
                                    customerDetailsProvider.itemUnitController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(
                                        3, 'As Per Standerds'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller:
                                    customerDetailsProvider.itemPriceController,
                                onChanged: (p0) {
                                  // Calculate total amount and GST when price changes
                                  customerDetailsProvider
                                      .calculateTotalAmount();
                                },
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(4, 'Price'),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller: customerDetailsProvider
                                    .itemQuantityController,
                                onChanged: (value) {
                                  // Calculate total amount when quantity changes
                                  customerDetailsProvider
                                      .calculateTotalAmount();
                                },
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(5, 'Quantity'),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                              const SizedBox(height: 16),
                               CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller: customerDetailsProvider
                                    .itemGstPercentController,
                                onChanged: (value) {
                                  // Calculate GST when GST% changes
                                  customerDetailsProvider
                                      .calculateTotalAmount();
                                },
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(6, 'gst %'),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: true,
                                controller:
                                    customerDetailsProvider.itemGstController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(
                                        7, 'GST'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: false,
                                controller: customerDetailsProvider
                                    .itemAdCessController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(8, 'Other Tax'),
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
                              const SizedBox(height: 16),
                              CustomTextfieldWidgetMobile(
                                readOnly: true,
                                controller:
                                    customerDetailsProvider.itemTotalController,
                                labelText: customerDetailsProvider
                                    .getQuotationFieldName(9, 'Amount'),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  customerDetailsProvider
                                      .addOrEditItem(context);
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
                                        final item = customerDetailsProvider
                                            .items[index];
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Qty: ${item.Quantity} ${item.Unit}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Price: ₹${item.UnitPrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'GST: ₹${item.GST.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
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
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount:
                                          customerDetailsProvider.items.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 12),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      itemBuilder: (context, index) {
                                        final item = customerDetailsProvider
                                            .items[index];
                                        return QuotationItemCard(
                                          item: item,
                                          onEdit: () {
                                            customerDetailsProvider
                                                .populateItemFieldsForEditing(
                                                    index);
                                          },
                                          onDelete: () {
                                            customerDetailsProvider
                                                .deleteItem(index);
                                          },
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
                              //       const Text(
                              //         'Sub Total:  ₹ ',
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.black,
                              //             fontSize: 16),
                              //       ),
                              //       SizedBox(
                              //         width: 130,
                              //         child: TextField(
                              //           controller: customerDetailsProvider
                              //               .subtotalController,
                              //           readOnly: true,
                              //           style: const TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               color: Colors.black54,
                              //               fontSize: 16),
                              //           decoration: const InputDecoration(
                              //             border: InputBorder
                              //                 .none, // Remove the border if needed
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
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
                              //             FilteringTextInputFormatter.digitsOnly
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
                                    const Text(
                                      'Taxable Amount:  ₹ ',
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
                                    const Text(
                                      'Tax Amount:  ₹ ',
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
                                      'Ad. CESS:  ₹ ',
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
//additional expense
                Column(
                  children: [
                    const SizedBox(height: 16),
                    CustomTextfieldWidgetMobile(
                      readOnly: false,
                      keyBoardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: customerDetailsProvider.systemPriceController,
                      labelText: 'System price excluding KSEB paper work',
                    ),
                    const SizedBox(height: 16),
                    CustomTextfieldWidgetMobile(
                      readOnly: false,
                      keyBoardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller:
                          customerDetailsProvider.additionalStructureController,
                      labelText: 'Additional Structure Work',
                    ),
                    const SizedBox(height: 16),
                    CustomTextfieldWidgetMobile(
                      readOnly: false,
                      keyBoardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller:
                          customerDetailsProvider.feasibilityFeeController,
                      labelText: 'Fee in KSEB for Feasibility study',
                    ),
                    const SizedBox(height: 16),
                    CustomTextfieldWidgetMobile(
                      readOnly: false,
                      keyBoardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller:
                          customerDetailsProvider.registrationFeeController,
                      labelText:
                          'Registration Fee in KSEB – 1000/- per kW (80% refundable)',
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      readOnly: false,
                      controller:
                          customerDetailsProvider.qtermsConditionsController,
                      labelText: 'Terms and Conditions',
                      minLines: 4,
                      maxLines: 5,
                      keyBoardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                //terms
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    CustomTextfieldWidgetMobile(
                      focusNode: FocusNode(),
                      readOnly: false,
                      controller: customerDetailsProvider.qwarrentyController,
                      labelText: 'Warranty',
                      minLines: 4,
                      maxLines: 5,
                      keyBoardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextfieldWidgetMobile(
                            readOnly: false,
                            controller:
                                customerDetailsProvider.advanceController,
                            labelText: 'Advance in %',
                            keyBoardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            // onChanged: (value) => _validateTotal(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextfieldWidgetMobile(
                            readOnly: false,
                            controller:
                                customerDetailsProvider.deliveryController,
                            labelText: 'On Material delivery(%)',
                            keyBoardType: TextInputType.number,
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
                          child: CustomTextfieldWidgetMobile(
                            readOnly: false,
                            controller: customerDetailsProvider
                                .workCompletionController,
                            labelText: 'On Work completion(%)',
                            keyBoardType: TextInputType.number,
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
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.stretch,
                //   children: [
                //     Container(
                //       decoration: BoxDecoration(
                //         color: const Color(0xFFF6F7F9),
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //       padding: const EdgeInsets.all(16.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Row(
                //             children: [
                //               Expanded(
                //                 child: CustomTextfieldWidgetMobile(
                //                   readOnly: false,
                //                   controller: customerDetailsProvider
                //                       .unitProductionChartController,
                //                   labelText: 'Unit Production Total',
                //                 ),
                //               ),
                //               const SizedBox(width: 16.0),
                //               Expanded(
                //                 child: CustomTextfieldWidgetMobile(
                //                   readOnly: false,
                //                   controller:
                //                       customerDetailsProvider.dailyController,
                //                   labelText: 'Daily',
                //                 ),
                //               ),
                //             ],
                //           ),
                //           const SizedBox(height: 16),
                //           Row(
                //             children: [
                //               Expanded(
                //                 child: CustomTextfieldWidgetMobile(
                //                   readOnly: false,
                //                   controller:
                //                       customerDetailsProvider.monthlyController,
                //                   labelText: 'Monthly',
                //                   inputFormatters: [
                //                     FilteringTextInputFormatter.digitsOnly
                //                   ],
                //                 ),
                //               ),
                //               const SizedBox(width: 16.0),
                //               Expanded(
                //                 child: CustomTextfieldWidgetMobile(
                //                   readOnly: false,
                //                   controller:
                //                       customerDetailsProvider.remarksController,
                //                   labelText: 'Remarks',
                //                 ),
                //               ),
                //             ],
                //           ),
                //           const SizedBox(height: 16),
                //           OutlinedButton.icon(
                //             onPressed: customerDetailsProvider
                //                 .addOrEditProductionChart,
                //             icon: const Icon(Icons.add),
                //             label: const Text('Add Production Chart'),
                //             style: OutlinedButton.styleFrom(
                //               foregroundColor: AppColors
                //                   .primaryBlue, // Change foreground color
                //               backgroundColor:
                //                   Colors.white, // Change background color
                //               side: BorderSide(
                //                   color: AppColors
                //                       .primaryBlue), // Change border color
                //               padding: const EdgeInsets.symmetric(
                //                 horizontal: 10,
                //                 vertical: 0,
                //               ),
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(
                //                     8), // Add border radius
                //               ),
                //             ),
                //           ),
                //           const SizedBox(height: 16),
                //           if (customerDetailsProvider
                //               .productionItems.isNotEmpty)
                //             AppStyles.isWebScreen(context)
                //                 ? Container(
                //                     padding: const EdgeInsets.symmetric(
                //                         horizontal: 10, vertical: 5),
                //                     decoration: BoxDecoration(
                //                       color: Colors.white,
                //                       borderRadius: BorderRadius.circular(20),
                //                     ),
                //                     child: Column(
                //                       children: [
                //                         Row(
                //                           children: [
                //                             SizedBox(
                //                               width: 40,
                //                               child: Text(
                //                                 'Sl No',
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                             const SizedBox(
                //                               width: 8,
                //                             ),
                //                             Expanded(
                //                               flex: 2,
                //                               child: Text(
                //                                 'Unit Production Total',
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                             Expanded(
                //                               child: Text(
                //                                 'Daily',
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                             Expanded(
                //                               child: Text(
                //                                 'Monthly',
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                             Expanded(
                //                               flex: 2,
                //                               child: Text(
                //                                 'Remarks',
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                             Expanded(
                //                               flex: 2,
                //                               child: Text(
                //                                 'Actions',
                //                                 textAlign: TextAlign.center,
                //                                 style:
                //                                     GoogleFonts.plusJakartaSans(
                //                                   fontWeight: FontWeight.w600,
                //                                   fontSize: 14,
                //                                 ),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         const SizedBox(
                //                           height: 10,
                //                         ),
                //                         ListView.builder(
                //                           shrinkWrap: true,
                //                           physics:
                //                               const NeverScrollableScrollPhysics(),
                //                           itemCount: customerDetailsProvider
                //                               .productionItems.length,
                //                           itemBuilder: (context, index) {
                //                             final item = customerDetailsProvider
                //                                 .productionItems[index];
                //                             return Row(
                //                               children: [
                //                                 SizedBox(
                //                                   width: 40,
                //                                   child: Center(
                //                                     child: Text(
                //                                       (index + 1).toString(),
                //                                       style: GoogleFonts
                //                                           .plusJakartaSans(
                //                                               fontSize: 14),
                //                                     ),
                //                                   ),
                //                                 ),
                //                                 const SizedBox(
                //                                   width: 8,
                //                                 ),
                //                                 Expanded(
                //                                   flex: 2,
                //                                   child: Text(
                //                                     item.unitProduction,
                //                                     style: GoogleFonts
                //                                         .plusJakartaSans(
                //                                             fontSize: 14),
                //                                   ),
                //                                 ),
                //                                 Expanded(
                //                                   child: Text(
                //                                     item.dailyTotal,
                //                                     style: GoogleFonts
                //                                         .plusJakartaSans(
                //                                             fontSize: 14),
                //                                   ),
                //                                 ),
                //                                 Expanded(
                //                                   child: Text(
                //                                     item.monthlyTotal
                //                                         .toString(),
                //                                     style: GoogleFonts
                //                                         .plusJakartaSans(
                //                                             fontSize: 14),
                //                                   ),
                //                                 ),
                //                                 Expanded(
                //                                   flex: 2,
                //                                   child: Text(
                //                                     item.remark,
                //                                     style: GoogleFonts
                //                                         .plusJakartaSans(
                //                                             fontSize: 14),
                //                                   ),
                //                                 ),
                //                                 Expanded(
                //                                   flex: 1,
                //                                   child: TextButton(
                //                                     onPressed: () =>
                //                                         customerDetailsProvider
                //                                             .populateProductionFieldsForEditing(
                //                                                 index),
                //                                     child: Text(
                //                                       'Edit',
                //                                       style: TextStyle(
                //                                         color: Colors.blue[400],
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 ),
                //                                 Expanded(
                //                                   flex: 1,
                //                                   child: TextButton(
                //                                     onPressed: () =>
                //                                         customerDetailsProvider
                //                                             .deleteProduction(
                //                                                 index),
                //                                     child: Text(
                //                                       'Delete',
                //                                       style: TextStyle(
                //                                         color: Colors.red[400],
                //                                       ),
                //                                     ),
                //                                   ),
                //                                 ),
                //                               ],
                //                             );
                //                           },
                //                         ),
                //                       ],
                //                     ),
                //                   )
                //                 : Container(
                //                     // padding: const EdgeInsets.all(12),
                //                     // decoration: BoxDecoration(
                //                     //   color: AppColors.scaffoldColor,
                //                     //   borderRadius: BorderRadius.circular(20),
                //                     // ),
                //                     child: Column(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.start,
                //                       children: [
                //                         Text(
                //                           'Production Chart Items',
                //                           style: GoogleFonts.plusJakartaSans(
                //                             fontSize: 18,
                //                             fontWeight: FontWeight.w600,
                //                           ),
                //                         ),
                //                         const SizedBox(height: 12),
                //                         ListView.builder(
                //                           shrinkWrap: true,
                //                           physics:
                //                               const NeverScrollableScrollPhysics(),
                //                           itemCount: customerDetailsProvider
                //                               .billOfMaterialsItems.length,
                //                           itemBuilder: (context, index) {
                //                             final item = customerDetailsProvider
                //                                 .productionItems[index];
                //                             return Card(
                //                               color: Colors.white,
                //                               margin: const EdgeInsets.only(
                //                                   bottom: 12),
                //                               elevation: 2,
                //                               shape: RoundedRectangleBorder(
                //                                 borderRadius:
                //                                     BorderRadius.circular(12),
                //                               ),
                //                               child: Padding(
                //                                 padding:
                //                                     const EdgeInsets.all(16),
                //                                 child: Column(
                //                                   crossAxisAlignment:
                //                                       CrossAxisAlignment.start,
                //                                   children: [
                //                                     _buildInfoRow(
                //                                         'Unit Production Total',
                //                                         item.unitProduction),
                //                                     const SizedBox(height: 8),
                //                                     Row(
                //                                       children: [
                //                                         Expanded(
                //                                           child: _buildInfoRow(
                //                                               'Daily',
                //                                               item.dailyTotal),
                //                                         ),
                //                                         Expanded(
                //                                           child: _buildInfoRow(
                //                                             'Monthly',
                //                                             item.monthlyTotal
                //                                                 .toString(),
                //                                           ),
                //                                         ),
                //                                       ],
                //                                     ),
                //                                     const SizedBox(height: 8),
                //                                     Row(
                //                                       children: [
                //                                         Expanded(
                //                                           child: _buildInfoRow(
                //                                               'Description',
                //                                               item.remark),
                //                                         ),
                //                                         const SizedBox(
                //                                             width: 8),
                //                                       ],
                //                                     ),
                //                                     Row(
                //                                       children: [
                //                                         Expanded(
                //                                           child: TextButton(
                //                                             onPressed: () =>
                //                                                 customerDetailsProvider
                //                                                     .populateProductionFieldsForEditing(
                //                                                         index),
                //                                             child: Text(
                //                                               'Edit',
                //                                               style: TextStyle(
                //                                                 color: Colors
                //                                                     .blue[400],
                //                                               ),
                //                                             ),
                //                                           ),
                //                                         ),
                //                                         Expanded(
                //                                           child: TextButton(
                //                                             onPressed: () =>
                //                                                 customerDetailsProvider
                //                                                     .deleteProduction(
                //                                                         index),
                //                                             child: Text(
                //                                               'Delete',
                //                                               style: TextStyle(
                //                                                 color: Colors
                //                                                     .red[400],
                //                                               ),
                //                                             ),
                //                                           ),
                //                                         ),
                //                                       ],
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                             );
                //                           },
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //         ],
                //       ),
                //     ),
                //   ],
                // ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 32,
                        child: CustomElevatedButton(
                            buttonText: 'Add Material',
                            radius: 8,
                            onPressed: () {
                              customerDetailsProvider.clearBOMFields();
                              showDialog(
                                context: context,
                                builder: (context) => const EditBomItemDialog(
                                  index: -1,
                                  isEdit: false,
                                ),
                              );
                            },
                            backgroundColor: AppColors.whiteColor,
                            borderColor: AppColors.bluebutton,
                            textColor: AppColors.bluebutton),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (customerDetailsProvider.billOfMaterialsItems.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffF8FAFC),
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: customerDetailsProvider
                                .billOfMaterialsItems.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = customerDetailsProvider
                                  .billOfMaterialsItems[index];

                              return BomItemCard(
                                item: item,
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete Material"),
                                      content: const Text(
                                          "Are you sure you want to delete this item?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            customerDetailsProvider
                                                .deleteBillOfMaterialsItem(
                                                    index);
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onEdit: () {
                                  customerDetailsProvider
                                      .populateBOMFieldsForEditing(index);
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        EditBomItemDialog(index: index),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                )
              ],
            )),
      ),
    );
  }
  void _showPrintQuotationDialog(BuildContext context, String masterId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Print Quotation',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
              'Quotation saved successfully. Do you want to print the quotation?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final customerDetailsProvider =
                    Provider.of<CustomerDetailsProvider>(context,
                        listen: false);
                final settingsProvider =
                    Provider.of<SettingsProvider>(context, listen: false);

                // Check permission for printing (menuId 32 or 55)
                bool hasPrintPermission =
                    (settingsProvider.menuIsViewMap[32] == 1 ||
                        settingsProvider.menuIsViewMap[55] == 1);

                if (hasPrintPermission) {
                  try {
                    await customerDetailsProvider.getQuotationMasterPdf(
                        masterId, context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Printing failed. Please try again.')),
                      );
                    }
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('You do not have permission to print.')),
                    );
                  }
                }
              },
              child: Text(
                'Yes',
                style: TextStyle(
                  color: AppColors.appViolet,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class MultipleExpansionCard extends StatefulWidget {
  const MultipleExpansionCard(
      {super.key,
      required this.titles,
      required this.childrens,
      this.initialExpanded = const {0: false}});
  final List<Widget> titles;
  final List<Widget> childrens;
  final Map<int, bool> initialExpanded;
  @override
  State<MultipleExpansionCard> createState() => _MultipleExpansionCardState();
}

class _MultipleExpansionCardState extends State<MultipleExpansionCard> {
  int? expandedIndex;
  List<ExpansibleController> controllers = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllers = List.generate(
        widget.childrens.length, (index) => ExpansibleController());
    for (int index in widget.initialExpanded.keys) {
      if (widget.initialExpanded[index] == true) {
        expandedIndex = index;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.titles.length != widget.childrens.length) {
      throw Exception([
        'titles length and childrens length must be equal condition is not true'
      ]);
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.childrens.length,
      itemBuilder: (context, index) {
        return ExpansionTile(
            backgroundColor: AppColors.whiteColor,
            tilePadding: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            key: Key(index.toString()),
            controller: controllers[index],
            title: widget.titles[index],
            initiallyExpanded: expandedIndex == index,
            collapsedBackgroundColor: AppColors.whiteColor,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                for (int i = 0; i < controllers.length; i++) {
                  if (i != index) {
                    controllers[i].collapse();
                  }
                }
                setState(() {
                  expandedIndex = index;
                });
              } else {
                setState(() {
                  expandedIndex = null;
                });
              }
            },
            children: [widget.childrens[index]]);
      },
    );
  }
}

class ScrollableMultipleExpansionCard extends StatefulWidget {
  const ScrollableMultipleExpansionCard({
    super.key,
    required this.titles,
    required this.childrens,
    this.initialExpanded = const {0: false},
    this.activeColor = const Color(0xFF2196F3),
    this.showScrollArrows = true,
    this.controllersCallback,
    this.onTabToggle,
  });

  final List<Widget> titles;
  final List<Widget> childrens;
  final Map<int, bool> initialExpanded;
  final Color activeColor;
  final bool showScrollArrows;
  final Function(List<ExpansibleController>)? controllersCallback;
  final Function(int)? onTabToggle;

  @override
  State<ScrollableMultipleExpansionCard> createState() =>
      _ScrollableMultipleExpansionCardState();
}

class _ScrollableMultipleExpansionCardState
    extends State<ScrollableMultipleExpansionCard> {
  // Changed from int? to Set<int> to track multiple expanded indices
  Set<int> expandedIndices = {};
  List<ExpansibleController> controllers = [];
  final ScrollController _scrollController = ScrollController();
  final ScrollController _headerScrollController = ScrollController();
  final List<GlobalKey> _tileKeys = [];
  final bool _isProcessingClick = false;

  @override
  void initState() {
    super.initState();

    controllers = List.generate(
        widget.childrens.length, (index) => ExpansibleController());

    if (widget.controllersCallback != null) {
      widget.controllersCallback!(controllers);
    }
    _tileKeys
        .addAll(List.generate(widget.childrens.length, (index) => GlobalKey()));

    // Collect all indices that should be initially expanded
    for (int index in widget.initialExpanded.keys) {
      if (widget.initialExpanded[index] == true) {
        expandedIndices.add(index);
      }
    }

    _configureScrollBehavior();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Expand all tiles that should be initially expanded
      for (int i = 0; i < controllers.length; i++) {
        if (expandedIndices.contains(i)) {
          controllers[i].expand();
        } else {
          controllers[i].collapse();
        }
      }
    });
  }

  void _configureScrollBehavior() {
    _headerScrollController.addListener(() {
      if (_headerScrollController.hasClients) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.titles.length != widget.childrens.length) {
      throw Exception([
        'titles length and childrens length must be equal condition is not true'
      ]);
    }

    return Column(
      children: [
        // Expansion tiles
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.childrens.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                if (widget.onTabToggle != null) {
                  widget.onTabToggle!(index);
                }
              },
              child: ExpansionTile(
                backgroundColor: AppColors.whiteColor,
                collapsedBackgroundColor: AppColors.whiteColor,
                key: _tileKeys[index],
                tilePadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                controller: controllers[index],
                title: widget.titles[index],
                // Check if this index is in the expanded set
                initiallyExpanded: expandedIndices.contains(index),
                onExpansionChanged: (isExpanded) {
                  if (widget.onTabToggle != null && !_isProcessingClick) {
                    widget.onTabToggle!(index);
                  }
                },
                children: [widget.childrens[index]],
              ),
            );
          },
        ),
      ],
    );
  }

}

String getStatusNameById(int statusId) {
  switch (statusId) {
    case 1:
      return 'Pending';
    case 2:
      return 'Approved';
    case 3:
      return 'Rejected';
    default:
      return 'Pending';
  }
}
