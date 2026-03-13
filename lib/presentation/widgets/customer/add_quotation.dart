import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/bom_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/edit_bom_item_dialog.dart';

class QuotationCreationWidget extends StatefulWidget {
  bool isEdit;
  String customerId;
  String quotationId;
  QuotationCreationWidget(
      {super.key,
      required this.quotationId,
      required this.isEdit,
      required this.customerId});

  @override
  State<QuotationCreationWidget> createState() =>
      _QuotationCreationWidgetState();
}

class _QuotationCreationWidgetState extends State<QuotationCreationWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      // Always clear first to ensure a clean state
      customerDetailsProvider.clearQuotationDetails();

      settingsProvider.searchBranch(context);
      customerDetailsProvider.getQuotationTypes(context);

      // Fetch custom field definitions for quotations
      await customerDetailsProvider.getCustomFieldsByQuotationId(context);
      await customerDetailsProvider.getQuotationFieldsApi();

      if (widget.isEdit) {
        // Fetch existing quotation details if editing
        await customerDetailsProvider.getQuatationListByMasterId(
            widget.quotationId, context);

        if (customerDetailsProvider.quotationListByMaster.isNotEmpty) {
          final quotation = customerDetailsProvider.quotationListByMaster.first;
          customerDetailsProvider.populateAllQuotationFields(
              quotation, widget.customerId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            customerDetailsProvider.clearQuotationDetails();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.isEdit ? 'Edit Quotation' : 'Add Quotation',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              color: Colors.white,
              width: AppStyles.isWebScreen(context)
                  ? MediaQuery.of(context).size.width / 2
                  : MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    CommonDropdown(
                      hintText: 'Branch',
                      items: settingsProvider.branchModel
                          .map((branch) => DropdownItem<int>(
                                id: branch.branchId ?? 0,
                                name: branch.branchName ?? '',
                              ))
                          .toList(),
                      onItemSelected: (value) {
                        customerDetailsProvider.selectedBranchId = value;
                      },
                      selectedValue: customerDetailsProvider.selectedBranchId,
                    ),
                    const SizedBox(
                      height: 16,
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
                            value: (customerDetailsProvider
                                            .selectedQuotationStatus !=
                                        null &&
                                    [1, 2, 3].contains(customerDetailsProvider
                                        .selectedQuotationStatus))
                                ? customerDetailsProvider
                                    .selectedQuotationStatus
                                : 1,
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
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                                borderSide: BorderSide(
                                  color: AppColors.textGrey2, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                                borderSide: BorderSide(
                                  color: AppColors.textGrey2, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
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
                    Row(children: [
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.qvalidityController,
                          hintText: 'Validity',
                          labelText: '',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller:
                              customerDetailsProvider.qtendorNumberController,
                          hintText: 'Tendor Number',
                          labelText: '',
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider
                          .quotationDescriptionController,
                      hintText: 'Description',
                      labelText: '',
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider
                          .quotationDescription2Controller,
                      hintText: 'Description 2',
                      labelText: '',
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider
                          .quotationDescription3Controller,
                      hintText: 'Description 3',
                      labelText: '',
                      minLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CommonDropdown(
                      hintText: 'Quotation Type*',
                      items: customerDetailsProvider.quotationTypeData
                          .map((status) => DropdownItem<int>(
                                id: status.quotationTypeId,
                                name: status.quotationTypeName,
                              ))
                          .toList(),
                      onItemSelected: (value) {
                        customerDetailsProvider.selectedQuotationType = value;
                        final selectedItem = customerDetailsProvider
                            .quotationTypeData
                            .firstWhere(
                          (status) => status.quotationTypeId == value,
                        );
                        customerDetailsProvider.quotationTypeController.text =
                            selectedItem.quotationTypeName;
                      },
                      selectedValue:
                          customerDetailsProvider.selectedQuotationType,
                    ),
                    const SizedBox(height: 16),
                    if (customerDetailsProvider
                        .customFieldQuotation.isNotEmpty) ...[
                      CustomFieldSectionWidget(
                        key: customFieldQuotationKey,
                        customFields:
                            customerDetailsProvider.customFieldQuotation,
                        initialFieldValues:
                            customerDetailsProvider.customFieldQuotation
                                .map((e) => FieldValueModel(
                                      customFieldId: e.customFieldId,
                                      value: e.datavalue,
                                    ))
                                .toList(),
                        controllerKey: 'quotation',
                      ),
                      const SizedBox(height: 16),
                    ],
                    loadFromCustomField(context),
                    const SizedBox(height: 16),
                    if (customerDetailsProvider.selectedQuotationType == 1) ...[
                      residentialItemWidget(context),
                    ],
                    if (customerDetailsProvider.selectedQuotationType == 2) ...[
                      commercialItemWidget(context),
                    ],
                  ],
                ),

                if (customerDetailsProvider.selectedQuotationType == 2)
                  //solar pv system specification
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: Text(
                      'Solar PV System Specification',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: false,
                    children: [
                      solarPvSystemSpecificationWidget(context),
                    ],
                  ),

                if (customerDetailsProvider.selectedQuotationType == 2)
                  //scope of work
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: Text(
                      'Scope of Work',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: false,
                    children: [
                      scopeOfWorkWidget(context),
                    ],
                  ),

                if (customerDetailsProvider.selectedQuotationType == 2)
                  //cable details
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: Text(
                      'Cable Details',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: false,
                    children: [
                      cableDetailsWidget(context),
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
                            controller: customerDetailsProvider
                                .feasibilityFeeController,
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
                            controller: customerDetailsProvider
                                .registrationFeeController,
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
                    SizedBox(
                      child: TextFormField(
                        controller: customerDetailsProvider.qwarrentyController,
                        readOnly: false,
                        minLines: 12,
                        maxLines: 12,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            hintText: 'Warranty',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                              borderSide: BorderSide(
                                color: AppColors.textGrey2, // Border color
                                width: 1, // Border width
                              ),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto),
                      ),
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
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller:
                                customerDetailsProvider.advanceController,
                            hintText:
                                customerDetailsProvider.selectedQuotationType ==
                                        1
                                    ? 'Advance payment up on conformation'
                                    : 'Advance Against Purchase Order %',
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
                            hintText: customerDetailsProvider
                                        .selectedQuotationType ==
                                    1
                                ? 'Upon the material ready for dispatch'
                                : 'On readiness of major material at our warehouse before dispatch along with 100% taxes and against proforma invoice % ',
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
                            controller: customerDetailsProvider
                                .workCompletionController,
                            hintText:
                                customerDetailsProvider.selectedQuotationType ==
                                        1
                                    ? 'Installation Completion'
                                    : 'After project completion %',
                            labelText: '',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            // onChanged: (value) => _validateTotal(),
                          ),
                        ),
                        const SizedBox(width: 16),
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
                                customerDetailsProvider.paymentTermsController,
                            hintText: 'Payment Terms',
                            labelText: '',
                            // onChanged: (value) => _validateTotal(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller:
                                customerDetailsProvider.incoTermsController,
                            hintText: 'Inco Terms',
                            labelText: '',
                            // onChanged: (value) => _validateTotal(),
                          ),
                        )
                      ],
                    ),
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
                //                                   .billOfMaterialsItems.length,
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
                    'Bill of Materials',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey1,
                    ),
                  ),
                  tilePadding: EdgeInsets.zero,
                  initiallyExpanded: false,
                  children: [
                    billofMaterialsWidget(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
              const SizedBox(width: 12),
              CustomElevatedButton(
                buttonText: 'Save',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  if (customerDetailsProvider
                      .qproductnameController.text.isEmpty) {
                    _showValidationDialog(
                        context, 'Cannot Save', 'Product name is required');
                    return;
                  }

                  if (customerDetailsProvider.items.isEmpty &&
                      customerDetailsProvider.commercialItems.isEmpty &&
                      customerDetailsProvider.billOfMaterialsItems.isEmpty) {
                    _showValidationDialog(
                        context, 'Cannot Save', 'No items added');
                    return;
                  }

                  try {
                    customerDetailsProvider.saveQuotation(widget.quotationId,
                        widget.customerId, context, widget.isEdit);
                  } catch (e) {
                    _showValidationDialog(context, 'Save Failed', e.toString());
                    print(e);
                  }
                },
                backgroundColor: AppColors.appViolet,
                borderColor: AppColors.appViolet,
                textColor: AppColors.whiteColor,
              ),
            ],
          ),
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

  Widget residentialItemWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
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
                      text: 'Residential ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                    TextSpan(
                      text: '',
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
                      controller: customerDetailsProvider.itemNameController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          1, 'Item Name'),
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
                      controller: customerDetailsProvider.itemMrpController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          2, 'As Per Standerd Warranty'),
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: customerDetailsProvider.itemUnitController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          3, 'As Per Standerds'),
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
                      controller: customerDetailsProvider.itemPriceController,
                      onChanged: (p0) {
                        // Calculate total amount and GST when price changes
                        customerDetailsProvider.calculateTotalAmount();
                      },
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          4, 'Price'),
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
                      readOnly: false,
                      height: 54,
                      controller:
                          customerDetailsProvider.itemQuantityController,
                      onChanged: (value) {
                        // Calculate total amount when quantity changes
                        customerDetailsProvider.calculateTotalAmount();
                      },
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          5, 'Quantity'),
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      controller:
                          customerDetailsProvider.itemGstPercentController,
                      onChanged: (value) {
                        // Calculate GST when GST% changes
                        customerDetailsProvider.calculateTotalAmount();
                      },
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          6, 'gst %'),
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
                      controller: customerDetailsProvider.itemGstController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          7, 'GST'),
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
                      controller: customerDetailsProvider.itemAdCessController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          8, 'Other Tax'),
                      labelText: '',
                      onChanged: (value) {
                        // Calculate GST when GST% changes
                        customerDetailsProvider.calculateTotalAmount();
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
                      controller: customerDetailsProvider.itemTotalController,
                      hintText: customerDetailsProvider.getQuotationFieldName(
                          9, 'Amount'),
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
                  foregroundColor:
                      AppColors.primaryBlue, // Change foreground color
                  backgroundColor: Colors.white, // Change background color
                  side: BorderSide(
                      color: AppColors.primaryBlue), // Change border color
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Add border radius
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerDetailsProvider.items.length,
                itemBuilder: (context, index) {
                  final item = customerDetailsProvider.items[index];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quantity: ${item.Quantity}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Unit Price: ₹${item.UnitPrice.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'GST: ₹${item.GST.toStringAsFixed(2)}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Total: ₹${item.Amount.toStringAsFixed(2)}',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        TextButton(
                          onPressed: () => customerDetailsProvider
                              .populateItemFieldsForEditing(index),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.blue[400],
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              customerDetailsProvider.deleteItem(index),
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
              ),

              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
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
                        controller: customerDetailsProvider.subtotalController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
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
                        controller:
                            customerDetailsProvider.gstTaxableAmountController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'CGST amount:  ₹ ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller:
                            customerDetailsProvider.totalCgstAmountController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'SGST amount:  ₹ ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller:
                            customerDetailsProvider.totalSgstAmountController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'GST amount:  ₹ ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller:
                            customerDetailsProvider.totalGstAmountController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'Other Tax:  ₹ ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 130,
                      child: TextField(
                        controller:
                            customerDetailsProvider.totalAdCESSController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'Discount:   ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller:
                            customerDetailsProvider.qsubsidyAmountController,
                        onChanged: (p0) {
                          if (customerDetailsProvider
                              .qsubsidyAmountController.text.isEmpty) {
                            customerDetailsProvider
                                .qsubsidyAmountController.text = '0';
                          }
                          customerDetailsProvider.updateTotal();
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '₹'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Charges:   ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16),
                    ),
                    Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller:
                            customerDetailsProvider.shippingChargesController,
                        onChanged: (p0) {
                          if (customerDetailsProvider
                              .shippingChargesController.text.isEmpty) {
                            customerDetailsProvider
                                .shippingChargesController.text = '0';
                          }
                          customerDetailsProvider.updateTotal();
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '₹'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
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
                        controller: customerDetailsProvider.totalController,
                        readOnly: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 16),
                        decoration: const InputDecoration(
                          border:
                              InputBorder.none, // Remove the border if needed
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget commercialItemWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Container(
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
                  text: 'Commercial ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
                TextSpan(
                  text: '',
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
                  controller:
                      customerDetailsProvider.commercialDescriptionController,
                  readOnly: false,
                  keyboardType: TextInputType.multiline,
                  height: 54,
                  hintText: 'Description',
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
                  controller:
                      customerDetailsProvider.commercialDCCapacityController,
                  readOnly: false,
                  height: 54,
                  hintText: 'Solar Plant DC Capacity',
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.commercialACCapacityController,
                  readOnly: false,
                  height: 54,
                  hintText: 'Solar Plant AC Capacity',
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
                  controller:
                      customerDetailsProvider.commercialUnitPriceController,
                  readOnly: false,
                  height: 54,
                  hintText: 'Unit Price',
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.commercialTotalController,
                  readOnly: false,
                  height: 54,
                  hintText: 'Total',
                  labelText: '',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              customerDetailsProvider.addOrEditCommercialItem(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue, // Change foreground color
              backgroundColor: Colors.white, // Change background color
              side: BorderSide(
                  color: AppColors.primaryBlue), // Change border color
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Add border radius
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customerDetailsProvider.commercialItems.length,
            itemBuilder: (context, index) {
              final item = customerDetailsProvider.commercialItems[index];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.description ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AC Capacity: ${item.acCapacity}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'DC Capacity: ${item.dcCapacity}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Unit Price: ₹${item.unitPrice}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Total: ₹${item.total}',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    TextButton(
                      onPressed: () => customerDetailsProvider
                          .populateCommercialItemFieldsForEditing(index),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.blue[400],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          customerDetailsProvider.deleteCommercialItem(index),
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
          ),
          if (customerDetailsProvider.commercialItems.isNotEmpty)
            Row(
              mainAxisAlignment: AppStyles.isWebScreen(context)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Text(
                  'Total amount:  ₹ ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                ),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: customerDetailsProvider.totalController,
                    readOnly: true,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none, // Remove the border if needed
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget cableDetailsWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.cableStructureController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Structure',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.cableTypeController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Type',
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
                controller:
                    customerDetailsProvider.cableShortCircuitTempController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Short circuit temperature range',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.cableStandardController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Standard',
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
                controller:
                    customerDetailsProvider.cableConductorClassController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Conductor Class',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.cableMaterialController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Material',
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
                controller: customerDetailsProvider.cableProtectionController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Protection',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.cableWarrantyController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Warranty',
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
                controller:
                    customerDetailsProvider.cableTensileStrengthController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Tensile strength',
                labelText: '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget scopeOfWorkWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.designAndEngineeringController,
                  readOnly: false,
                  keyboardType: TextInputType.multiline,
                  height: 54,
                  hintText: 'Design and Engineering',
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
                  controller: customerDetailsProvider.a3SScopeController,
                  readOnly: false,
                  height: 54,
                  hintText: 'A3S Scope',
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.clientScopeController,
                  readOnly: false,
                  height: 54,
                  hintText: 'Client Scope',
                  labelText: '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              customerDetailsProvider.addOrEditScopeOfWorkItem(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue, // Change foreground color
              backgroundColor: Colors.white, // Change background color
              side: BorderSide(
                  color: AppColors.primaryBlue), // Change border color
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Add border radius
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customerDetailsProvider.scopeOfWorkItems.length,
            itemBuilder: (context, index) {
              final item = customerDetailsProvider.scopeOfWorkItems[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.designAndEngineering ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${item.a3SScope}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '${item.clientScope}',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 15),
                    const SizedBox(width: 5),
                    TextButton(
                      onPressed: () => customerDetailsProvider
                          .populateScopeOfWorkItemFieldsForEditing(index),
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.blue[400],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          customerDetailsProvider.deleteScopeOfWorkItem(index),
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
          ),
        ],
      ),
    );
  }

  Widget solarPvSystemSpecificationWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.plantCapacityController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Plant Capacity',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller:
                    customerDetailsProvider.moduleTechnologiesController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Module Technologies',
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
                controller: customerDetailsProvider
                    .mountingStructureTechnologiesController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Mounting Structure Technologies',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.projectSchemeController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Project Scheme',
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
                controller: customerDetailsProvider.powerEvacuationController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Power Evacuation',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.areaApproximateController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Area (Approximate)',
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
                controller: customerDetailsProvider
                    .solarPlantOutputConnectionController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Solar Plant output Connection ',
                labelText: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: customerDetailsProvider.schemeController,
                readOnly: false,
                keyboardType: TextInputType.text,
                height: 54,
                hintText: 'Scheme',
                labelText: '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget billofMaterialsWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
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
            icon: const Icon(Icons.add),
            label: const Text('Add Material'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
                itemCount: customerDetailsProvider.billOfMaterialsItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item =
                      customerDetailsProvider.billOfMaterialsItems[index];

                  return BomItemCard(
                    item: item,
                    onDelete: () {
                      customerDetailsProvider.deleteBillOfMaterialsItem(index);
                    },
                    onEdit: () {
                      customerDetailsProvider
                          .populateBOMFieldsForEditing(index);
                      showDialog(
                        context: context,
                        builder: (context) => EditBomItemDialog(
                          index: index,
                          isEdit: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget loadFromCustomField(BuildContext context) {
    final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(
      context,
      listen: false,
    );
    return CustomElevatedButton(
      onPressed: () async {
        await customerDetailsProvider.loadQuotationFromCustomFields(
            context, "view_in_quotation");
        if (customerDetailsProvider.quotationListByMaster.isNotEmpty) {
          final quotation = customerDetailsProvider.quotationListByMaster.first;
          customerDetailsProvider.populateAllQuotationFields(
              quotation, widget.customerId);
        }
      },
      buttonText: 'Load Quotation',
      backgroundColor: Colors.blue,
      borderColor: Colors.blue,
      textColor: Colors.white,
    );
  }
}
