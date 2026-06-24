import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_commercial_custom_fields_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_commercial_item_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_item_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_field_section_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/bom_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/edit_bom_item_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/commercial_custom_fields_table.dart';
import 'package:vidyanexis/presentation/widgets/customer/commercial_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/scope_of_work_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/structure_material_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_structure_material_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_multiple_items_dialog.dart';
import 'package:vidyanexis/http/loader.dart';

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
  bool companyQuotationItems = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.searchItemList(context: context, isFilter: false);
      companyQuotationItems =
          settingsProvider.companyDetails.first.quotationItemValue == 1;

      // Always clear first to ensure a clean state
      customerDetailsProvider.clearQuotationDetails();

      settingsProvider.searchBranch(context);
      customerDetailsProvider.getQuotationTypes(context);
      await customerDetailsProvider.getProfitList(context);

      // Fetch custom field definitions for quotations
      // await customerDetailsProvider.getCustomFieldsByQuotationId(context);
      await customerDetailsProvider.getQuotationFieldsApi();
      await customerDetailsProvider.getCommercialCustomFieldsApi(context);

      if (widget.isEdit) {
        // Fetch existing quotation details if editing
        await customerDetailsProvider.getQuatationListByMasterId(
            widget.quotationId, context);

        if (customerDetailsProvider.quotationListByMaster.isNotEmpty) {
          final quotation = customerDetailsProvider.quotationListByMaster.first;
          customerDetailsProvider.populateAllQuotationFields(
              quotation, widget.customerId);

          // Pre-populate newItemId if companyQuotationItems is active
          if (companyQuotationItems) {
            final nameOfItem = customerDetailsProvider.selectedItemName;
            if (nameOfItem.isNotEmpty) {
              try {
                final matchItem = expenseProvider.itemList.firstWhere(
                  (item) =>
                      item.itemName.toLowerCase() == nameOfItem.toLowerCase(),
                );
                customerDetailsProvider.newItemId = matchItem.itemId;
              } catch (_) {}
            }
          }
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
    final expenseProvider = Provider.of<ExpenseProvider>(context);
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
              width: MediaQuery.of(context).size.width,
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
                      CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller:
                            customerDetailsProvider.qEntryDateController,
                        hintText: 'Entry Date',
                        labelText: '',
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller:
                            customerDetailsProvider.qproductnameController,
                        hintText: 'Product name*',
                        labelText: '',
                      ),
                      const SizedBox(height: 16.0),
                      DropdownButtonFormField<int>(
                        initialValue: (customerDetailsProvider
                                        .selectedQuotationStatus !=
                                    null &&
                                [1, 2, 3].contains(customerDetailsProvider
                                    .selectedQuotationStatus))
                            ? customerDetailsProvider.selectedQuotationStatus
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
                                      color:
                                          Colors.red), // Red color for asterisk
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
                            color:
                                AppColors.textGrey1, // Color for floating label
                          ),
                          labelStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                            borderSide: BorderSide(
                              color: AppColors.textGrey2, // Border color
                              width: 1, // Border width
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
                            borderSide: BorderSide(
                              color: AppColors.textGrey2, // Border color
                              width: 1, // Border width
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(4), // Rounded corners
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
                        items: [
                          DropdownItem<int>(
                            id: 0,
                            name: 'All',
                          ),
                          ...customerDetailsProvider.quotationTypeData.map(
                            (status) => DropdownItem<int>(
                              id: status.quotationTypeId,
                              name: status.quotationTypeName,
                            ),
                          ),
                        ],
                        onItemSelected: (value) {
                          customerDetailsProvider.selectedQuotationType = value;
                          final selectedItem = customerDetailsProvider
                              .quotationTypeData
                              .firstWhere(
                            (status) => status.quotationTypeId == value,
                          );
                          customerDetailsProvider.quotationTypeController.text =
                              selectedItem.quotationTypeName;
                          customerDetailsProvider
                              .getCustomFieldsByQuotationId(context);
                        },
                        selectedValue:
                            customerDetailsProvider.selectedQuotationType,
                      ),
                      if (companyQuotationItems) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        AddMultipleItemsDialog(
                                      isEdit: true,
                                      initialItems:
                                          customerDetailsProvider.multiItems,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add,
                                    color: AppColors.primaryBlue),
                                label: const Text(
                                  'Add Material',
                                  style:
                                      TextStyle(color: AppColors.primaryBlue),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                readOnly: false,
                                height: 54,
                                controller:
                                    customerDetailsProvider.profitController,
                                hintText: customerDetailsProvider.isPercentage
                                    ? "Profit %"
                                    : "Profit",
                                labelText: '',
                                onChanged: (value) {
                                  customerDetailsProvider
                                      .recalculateCompanyQuotationItem();
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Tooltip(
                              message: "Is Percentage %",
                              child: Checkbox(
                                value: customerDetailsProvider.isPercentage,
                                onChanged: (value) {
                                  customerDetailsProvider.isPercentage =
                                      value ?? false;
                                },
                              ),
                            ),
                            // Expanded(
                            //   child: CommonDropdown<int>(
                            //     hintText: 'Profit',
                            //     items: customerDetailsProvider.profitList
                            //         .map((e) => DropdownItem<int>(
                            //             id: e.id, name: e.name))
                            //         .toList(),
                            //     onItemSelected: (value) {
                            //       final selected = customerDetailsProvider
                            //           .profitList
                            //           .firstWhere((e) => e.id == value);
                            //       customerDetailsProvider.setSelectedProfitId(
                            //           value,
                            //           name: selected.name);
                            //     },
                            //     selectedValue:
                            //         customerDetailsProvider.selectedProfitId,
                            //   ),
                            // ),
                          ],
                        ),
                        multiItemsWidget(context),
                      ],
                      const SizedBox(height: 16),
                      if (customerDetailsProvider.customFieldQuotation.isNotEmpty) ...[
                        Builder(
                          builder: (context) {
                            final nonCommercialFields = customerDetailsProvider.customFieldQuotation
                                .where((e) => e.isCommercial != 1)
                                .toList();
                            if (nonCommercialFields.isEmpty) return const SizedBox.shrink();
                            return Column(
                              children: [
                                CustomFieldSectionWidget(
                                  key: customFieldQuotationKey,
                                  customFields: nonCommercialFields,
                                  initialFieldValues: nonCommercialFields
                                      .map((e) => FieldValueModel(
                                            customFieldId: e.customFieldId,
                                            value: e.datavalue,
                                          ))
                                      .toList(),
                                  controllerKey: 'quotation',
                                  showEditButton: true,
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      ],
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: loadFromCustomField(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (settingsProvider.companyDetails.isNotEmpty && settingsProvider.companyDetails.first.commercialProposal == 1)
                        const Column(
                          children: [
                            CommercialCustomFieldsTableWidget(),
                            SizedBox(height: 16),
                          ],
                        ),
                      if (customerDetailsProvider.selectedQuotationType ==
                          1) ...[
                        residentialItemWidget(context),
                      ],
                      // if (customerDetailsProvider.selectedQuotationType ==
                      //     2) ...[
                      //   commercialItemWidget(context),
                      // ],
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
                      CustomTextField(
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
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller: customerDetailsProvider
                            .additionalStructureController,
                        hintText: 'Additional Paper Work',
                        labelText: '',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller:
                            customerDetailsProvider.feasibilityFeeController,
                        hintText: customerDetailsProvider.getQuotationFieldName(
                            19, 'Fee in KSEB for Feasibility study'),
                        labelText: '',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (p0) {
                          if (settingsProvider.additionalExpense == 1) {
                            customerDetailsProvider.updateTotal();
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: false,
                        height: 54,
                        controller:
                            customerDetailsProvider.registrationFeeController,
                        keyboardType: TextInputType.number,
                        onChanged: (p0) {
                          if (settingsProvider.additionalExpense == 1) {
                            customerDetailsProvider.updateTotal();
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        hintText: customerDetailsProvider.getQuotationFieldName(
                            18,
                            'Registration Fee in KSEB - 1000/- per kW (80% refundable)'),
                        labelText: '',
                      ),
                      const SizedBox(height: 16),
                      if (settingsProvider.menuIsViewMap[154] == 1) ...[
                        CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: customerDetailsProvider
                              .feasibilityFeeThreeController,
                          hintText: customerDetailsProvider.getQuotationFieldName(
                              21,
                              'Fee in KSEB for Feasibility study Three phase'),
                          labelText: '',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (p0) {
                            if (settingsProvider.additionalExpense == 1) {
                              customerDetailsProvider.updateTotal();
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          readOnly: false,
                          height: 54,
                          controller: customerDetailsProvider
                              .registrationFeeThreeController,
                          keyboardType: TextInputType.number,
                          onChanged: (p0) {
                            if (settingsProvider.additionalExpense == 1) {
                              customerDetailsProvider.updateTotal();
                            }
                          },
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          hintText: customerDetailsProvider.getQuotationFieldName(
                              20,
                              'Registration Fee in KSEB - 1000/- per kW (80% refundable) Three phase'),
                          labelText: '',
                        ),
                        const SizedBox(height: 16),
                      ],
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
                          controller:
                              customerDetailsProvider.qwarrentyController,
                          readOnly: false,
                          minLines: 12,
                          maxLines: 12,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              hintText: 'Warranty',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Rounded corners
                                borderSide: BorderSide(
                                  color: AppColors.textGrey2, // Border color
                                  width: 1, // Border width
                                ),
                              ),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.auto),
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
                              hintText: customerDetailsProvider
                                          .selectedQuotationType ==
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
                              hintText: customerDetailsProvider
                                          .selectedQuotationType ==
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
                              controller: customerDetailsProvider
                                  .paymentTermsController,
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
                  //             borderRadius: BorderRadius.circular(4),
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
                  //                           borderRadius: BorderRadius.circular(4),
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
                  //                         //   borderRadius: BorderRadius.circular(4),
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
                  //                                         BorderRadius.circular(4),
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
                  if (companyQuotationItems == false)
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
                  ExpansionTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    title: Text(
                      'Structure Materials',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: false,
                    children: [
                      structureMaterialsWidget(context),
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

                  if (companyQuotationItems) {
                    double priceFrom =
                        customerDetailsProvider.aggregatedPriceFrom;
                    double priceTo = customerDetailsProvider.aggregatedPriceTo;
                    if (priceFrom == 0 && priceTo == 0) {
                      try {
                        final selectedData = expenseProvider.itemList
                            .firstWhere((item) =>
                                item.itemId ==
                                customerDetailsProvider.newItemId);
                        priceFrom =
                            double.tryParse(selectedData.priceFrom) ?? 0.0;
                        priceTo = double.tryParse(selectedData.priceTo) ?? 0.0;
                      } catch (_) {}
                    }

                    double netTotal = double.tryParse(
                            customerDetailsProvider.totalController.text) ??
                        0.0;
                    // Validation: Show AlertDialog if total is out of range
                    if (netTotal < priceFrom || netTotal > priceTo) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Invalid Amount'),
                          content: Text(
                            'Total amount must be between $priceFrom and $priceTo.\n\n'
                            'Current total: ${netTotal.toStringAsFixed(2)}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return; // Important: Stop execution, do not update amount
                    }
                  }

                  if (customerDetailsProvider
                      .qproductnameController.text.isEmpty) {
                    _showValidationDialog(
                        context, 'Cannot Save', 'Product name is required');
                    return;
                  }

                  bool isCommercialProposal = settingsProvider.companyDetails.isNotEmpty &&
                      settingsProvider.companyDetails.first.commercialProposal == 1;

                  if (customerDetailsProvider.items.isEmpty &&
                      customerDetailsProvider.commercialItems.isEmpty &&
                      customerDetailsProvider.billOfMaterialsItems.isEmpty) {
                    if (!isCommercialProposal) {
                      _showValidationDialog(
                          context, 'Cannot Save', 'No items added');
                      return;
                    }
                  }

                  try {
                    final responseData =
                        await customerDetailsProvider.saveQuotation(
                            widget.quotationId,
                            widget.customerId,
                            context,
                            widget.isEdit);

                    if (responseData != null) {
                      // Extract quotation master id from response
                      String masterId = '';
                      if (responseData is Map &&
                          responseData.containsKey('Quotation_Master_Id')) {
                        masterId =
                            responseData['Quotation_Master_Id'].toString();
                      } else if (responseData is List &&
                          responseData.isNotEmpty &&
                          responseData[0] is Map &&
                          responseData[0].containsKey('Quotation_Master_Id')) {
                        masterId =
                            responseData[0]['Quotation_Master_Id'].toString();
                      }

                      if (masterId.isEmpty || masterId == '0') {
                        masterId = widget.quotationId;
                      }

                      if (context.mounted) {
                        _showPrintQuotationDialog(context, masterId);
                      }
                    }
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
            borderRadius: BorderRadius.circular(4),
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
    final settingsProvider = Provider.of<SettingsProvider>(context);
    bool isCommercialProposal = settingsProvider.companyDetails.isNotEmpty &&
        settingsProvider.companyDetails.first.commercialProposal == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(4),
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
              if (!companyQuotationItems && !isCommercialProposal)
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      customerDetailsProvider.clearItemFields();
                      showDialog(
                        context: context,
                        builder: (context) => const AddItemDialog(
                          index: -1,
                          isEdit: false,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerDetailsProvider.items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = customerDetailsProvider.items[index];
                  return QuotationItemCard(
                    showActions: !companyQuotationItems,
                    item: item,
                    onEdit: () {
                      customerDetailsProvider
                          .populateItemFieldsForEditing(index);
                      showDialog(
                        context: context,
                        builder: (context) => AddItemDialog(
                          index: index,
                          isEdit: true,
                        ),
                      );
                    },
                    onDelete: () {
                      customerDetailsProvider.deleteItem(index);
                    },
                    onMoveUp: index > 0
                        ? () => customerDetailsProvider.moveItemUp(index)
                        : null,
                    onMoveDown: index < customerDetailsProvider.items.length - 1
                        ? () => customerDetailsProvider.moveItemDown(index)
                        : null,
                  );
                },
              ),
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty || customerDetailsProvider.selectedCommercialFields.isNotEmpty)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Subsidy:   ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16),
                        ),
                        Checkbox(
                          activeColor: AppColors.appViolet,
                          value: customerDetailsProvider.isSubsidyChecked,
                          onChanged: (value) {
                            customerDetailsProvider.isSubsidyChecked =
                                value ?? false;
                          },
                        ),
                      ],
                    ),
                    Container(
                      width: 140,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: customerDetailsProvider.qDiscountController,
                        onChanged: (p0) {
                          if (customerDetailsProvider
                              .qDiscountController.text.isEmpty) {
                            customerDetailsProvider.qDiscountController.text =
                                '0';
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
              if (customerDetailsProvider.items.isNotEmpty && !isCommercialProposal)
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
        borderRadius: BorderRadius.circular(4),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (!companyQuotationItems)
            OutlinedButton.icon(
              onPressed: () {
                customerDetailsProvider.clearCommercialItemFields();
                showDialog(
                  context: context,
                  builder: (context) => const AddCommercialItemDialog(
                    index: -1,
                    isEdit: false,
                  ),
                );
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
                  borderRadius: BorderRadius.circular(4), // Add border radius
                ),
              ),
            ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customerDetailsProvider.commercialItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = customerDetailsProvider.commercialItems[index];
              return CommercialItemCard(
                showActions: !companyQuotationItems,
                item: item,
                onEdit: () {
                  customerDetailsProvider
                      .populateCommercialItemFieldsForEditing(index);
                  showDialog(
                    context: context,
                    builder: (context) => AddCommercialItemDialog(
                      index: index,
                      isEdit: true,
                    ),
                  );
                },
                onDelete: () {
                  customerDetailsProvider.deleteCommercialItem(index);
                },
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

  Widget multiItemsWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (customerDetailsProvider.multiItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "No item materials added yet",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: customerDetailsProvider.multiItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = customerDetailsProvider.multiItems[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Main Item Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Qty: ${item.quantity}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AddMultipleItemsDialog(
                                  isEdit: true,
                                  initialItems:
                                      customerDetailsProvider.multiItems,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () =>
                                customerDetailsProvider.removeMultiItem(index),
                          ),
                        ],
                      ),
                    ),

                    // Materials Section
                    if (item.materials.isNotEmpty)
                      Container(
                        color: Colors.grey[50],
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Materials',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...item.materials.map((mat) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 6, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          mat.itemMaterialName,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      Text(
                                        "${mat.price} x ${mat.quantity}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Amount : ${(mat.amount).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        if (customerDetailsProvider.multiItems.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total Amount : ${customerDetailsProvider.mutipleItemsTotalAmount}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(4), // Add border radius
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
              return ScopeOfWorkCard(
                item: item,
                onEdit: () {
                  customerDetailsProvider
                      .populateScopeOfWorkItemFieldsForEditing(index);
                },
                onDelete: () {
                  customerDetailsProvider.deleteScopeOfWorkItem(index);
                },
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
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bill of Materials ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (customerDetailsProvider.billOfMaterialsItems.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(4)),
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
                    onMoveUp: index > 0
                        ? () => customerDetailsProvider
                            .moveBillOfMaterialsItemUp(index)
                        : null,
                    onMoveDown: index <
                            customerDetailsProvider
                                    .billOfMaterialsItems.length -
                                1
                        ? () => customerDetailsProvider
                            .moveBillOfMaterialsItemDown(index)
                        : null,
                  );
                },
              ),
            ),
          ),
        if (companyQuotationItems) ...[
          SizedBox(height: 8),
          Text(
            'Total Amount: ${customerDetailsProvider.billTotalAmount.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ],
    );
  }

  Widget structureMaterialsWidget(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Structure Materials ',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGrey1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              customerDetailsProvider.clearStructureFields();
              showDialog(
                context: context,
                builder: (context) => const AddStructureMaterialDialog(
                  index: -1,
                  isEdit: false,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Structure Material'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (customerDetailsProvider.structureMaterialsItems.isNotEmpty)
          Container(
            decoration: BoxDecoration(
                color: const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(4)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    customerDetailsProvider.structureMaterialsItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item =
                      customerDetailsProvider.structureMaterialsItems[index];

                  return StructureMaterialCard(
                    item: item,
                    onDelete: () {
                      customerDetailsProvider.deleteStructureMaterial(index);
                    },
                    onEdit: () {
                      customerDetailsProvider
                          .populateStructureFieldsForEditing(index);
                      showDialog(
                        context: context,
                        builder: (context) => AddStructureMaterialDialog(
                          index: index,
                          isEdit: true,
                        ),
                      );
                    },
                    onMoveUp: index > 0
                        ? () => customerDetailsProvider
                            .moveStructureMaterialUp(index)
                        : null,
                    onMoveDown: index <
                            customerDetailsProvider
                                    .structureMaterialsItems.length -
                                1
                        ? () => customerDetailsProvider
                            .moveStructureMaterialDown(index)
                        : null,
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
        if (customerDetailsProvider.selectedQuotationType == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a Quotation Type')),
          );
          return;
        }
        await customerDetailsProvider.loadQuotationFromCustomFields(context,
            "view_in_quotation", customerDetailsProvider.selectedQuotationType);
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

  void _showPrintQuotationDialog(BuildContext context, String masterId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Saved Successfully',
            style: TextStyle(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Do you want to print the quotation?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pop(context); // Close page
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
                  await Loader.showLoader(context,
                      message: 'Generating Print...');
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
                  } finally {
                    if (context.mounted) {
                      Loader.stopLoader(context);
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
                Navigator.pop(dialogContext); // Close dialog
                if (context.mounted) {
                  Navigator.pop(context); // Close page
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
