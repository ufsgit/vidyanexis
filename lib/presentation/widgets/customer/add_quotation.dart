import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
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
  bool isDuplicate;
  QuotationCreationWidget(
      {super.key,
      required this.quotationId,
      required this.isEdit,
      this.isDuplicate = false,
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
      Loader.showLoader(context);
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

      await settingsProvider.searchBranch(context);
      await customerDetailsProvider.getQuotationTypes(context);

      if (!widget.isEdit) {
        if (settingsProvider.branchModel.isNotEmpty) {
          customerDetailsProvider.selectedBranchId =
              settingsProvider.branchModel.first.branchId;
        }

        if (customerDetailsProvider.quotationTypeData.isNotEmpty) {
          final residentialType = customerDetailsProvider.quotationTypeData
              .where((element) => element.quotationTypeName
                  .toLowerCase()
                  .contains('residential'))
              .firstOrNull;
          if (residentialType != null) {
            customerDetailsProvider.selectedQuotationType =
                residentialType.quotationTypeId;
            customerDetailsProvider.quotationTypeController.text =
                residentialType.quotationTypeName;
          }
        }
      }

      await customerDetailsProvider.getProfitList(context);

      // Fetch custom field definitions for quotations
      // await customerDetailsProvider.getCustomFieldsByQuotationId(context);
      await customerDetailsProvider.getCommercialCustomFieldsApi(context);

      settingsProvider.clearTermsFields();
      await settingsProvider.getTermsAndWarranty(context);
      customerDetailsProvider.qtermsConditionsController.text =
          settingsProvider.termsText;
      customerDetailsProvider.qwarrentyController.text =
          settingsProvider.warrantyText;
      customerDetailsProvider.quotationDescriptionController.text =
          settingsProvider.description1Text;
      customerDetailsProvider.quotationDescription2Controller.text =
          settingsProvider.description2Text;
      customerDetailsProvider.quotationDescription3Controller.text =
          settingsProvider.description3Text;
      customerDetailsProvider.advanceController.text =
          settingsProvider.advancePercentageText;
      customerDetailsProvider.deliveryController.text =
          settingsProvider.onMaterialDeliveryPercentageText;
      customerDetailsProvider.workCompletionController.text =
          settingsProvider.onWorkCompletionPercentageText;

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
      customerDetailsProvider.getCustomFieldsByQuotationId(context);
      await customerDetailsProvider.getQuotationFieldsApi();
      if (mounted) {
        Loader.stopLoader(context);
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
                  if (customerDetailsProvider.isQuotationFieldVisible(55))
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            55, 'Basic details'),
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
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(24)) ...[
                          CommonDropdown(
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(24, 'Branch'),
                            items: settingsProvider.branchModel
                                .map((branch) => DropdownItem<int>(
                                      id: branch.branchId ?? 0,
                                      name: branch.branchName ?? '',
                                    ))
                                .toList(),
                            onItemSelected: (value) {
                              customerDetailsProvider.selectedBranchId = value;
                            },
                            selectedValue:
                                customerDetailsProvider.selectedBranchId,
                          ),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(25)) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextField(
                            readOnly: true,
                            height: 54,
                            controller:
                                customerDetailsProvider.qEntryDateController,
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(25, 'Entry Date'),
                            labelText: '',
                            onTap: () async {
                              DateTime initialDate = DateTime.now();
                              if (customerDetailsProvider
                                  .qEntryDateController.text.isNotEmpty) {
                                final parsed = DateTime.tryParse(
                                        customerDetailsProvider
                                            .qEntryDateController.text) ??
                                    DateFormat('yyyy-MM-dd').tryParse(
                                        customerDetailsProvider
                                            .qEntryDateController.text) ??
                                    DateFormat('dd-MM-yyyy').tryParse(
                                        customerDetailsProvider
                                            .qEntryDateController.text) ??
                                    DateFormat('dd/MM/yyyy').tryParse(
                                        customerDetailsProvider
                                            .qEntryDateController.text);
                                if (parsed != null) {
                                  initialDate = parsed;
                                }
                              }
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                customerDetailsProvider
                                        .qEntryDateController.text =
                                    DateFormat('yyyy-MM-dd').format(pickedDate);
                              }
                            },
                            suffixIcon:
                                const Icon(Icons.calendar_today, size: 20),
                          ),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(26)) ...[
                          const SizedBox(
                            height: 16,
                          ),
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller:
                                customerDetailsProvider.qproductnameController,
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(26, 'Product name*'),
                            labelText: '',
                          ),
                        ],
                        const SizedBox(height: 16.0),
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(27)) ...[
                          DropdownButtonFormField<int>(
                            initialValue: (customerDetailsProvider
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
                            onChanged: (int? newValue) {
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
                                  text: customerDetailsProvider
                                      .getQuotationFieldName(
                                          27, 'Choose Status'),
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
                        ],
                        Row(
                          children: [
                            if (customerDetailsProvider
                                .isQuotationFieldVisible(28)) ...[
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .qvalidityController,
                                  hintText: customerDetailsProvider
                                      .getQuotationFieldName(28, 'Validity'),
                                  labelText: '',
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (customerDetailsProvider
                                .isQuotationFieldVisible(29)) ...[
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .qtendorNumberController,
                                  hintText: customerDetailsProvider
                                      .getQuotationFieldName(
                                          29, 'Tendor Number'),
                                  labelText: '',
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(30)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .quotationDescriptionController,
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(30, 'Description'),
                            labelText: '',
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(31)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .quotationDescription2Controller,
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(31, 'Description 2'),
                            labelText: '',
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(32)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .quotationDescription3Controller,
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(32, 'Description 3'),
                            labelText: '',
                            minLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(33)) ...[
                          CommonDropdown(
                            hintText: customerDetailsProvider
                                .getQuotationFieldName(33, 'Quotation Type*'),
                            items: [
                              DropdownItem<int>(id: 0, name: 'All'),
                              ...customerDetailsProvider.quotationTypeData.map(
                                (status) => DropdownItem<int>(
                                  id: status.quotationTypeId,
                                  name: status.quotationTypeName,
                                ),
                              ),
                            ],
                            onItemSelected: (value) {
                              customerDetailsProvider.selectedQuotationType =
                                  value;

                              // Simple handling for All vs others
                              if (value == 0) {
                                customerDetailsProvider
                                    .quotationTypeController.text = 'All';
                              } else {
                                final selectedItem = customerDetailsProvider
                                    .quotationTypeData
                                    .firstWhere((status) =>
                                        status.quotationTypeId == value);
                                customerDetailsProvider.quotationTypeController
                                    .text = selectedItem.quotationTypeName;
                              }

                              customerDetailsProvider
                                  .getCustomFieldsByQuotationId(context);
                              customerDetailsProvider.getQuotationFieldsApi();
                            },
                            selectedValue:
                                customerDetailsProvider.selectedQuotationType,
                          ),
                        ],
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          multiItemsWidget(context),
                          const SizedBox(height: 16),
                          if (customerDetailsProvider
                              .multiItems.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.3)),
                              ),
                              child: Text(
                                "Total Amount : ${customerDetailsProvider.mutipleItemsTotalAmount}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        if (customerDetailsProvider
                            .customFieldQuotation.isNotEmpty) ...[
                          Builder(
                            builder: (context) {
                              final nonCommercialFields =
                                  customerDetailsProvider.customFieldQuotation
                                      .where((e) => e.isCommercial != 1)
                                      .toList();
                              if (nonCommercialFields.isEmpty)
                                return const SizedBox.shrink();
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
                                    onFieldValuesChanged: (values) {
                                      for (final fv in values) {
                                        final match =
                                            nonCommercialFields.firstWhere(
                                          (e) =>
                                              e.customFieldId ==
                                              fv.customFieldId,
                                          orElse: () => CustomFieldByStatusId(),
                                        );
                                        if (match.customFieldId != null) {
                                          match.datavalue = fv.value;
                                        }
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            },
                          ),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(36)) ...[
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 200,
                              child: loadFromCustomField(context),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (settingsProvider.companyDetails.isNotEmpty &&
                            settingsProvider
                                    .companyDetails.first.commercialProposal ==
                                1)
                          const Column(
                            children: [
                              CommercialCustomFieldsTableWidget(),
                              SizedBox(height: 16),
                            ],
                          ),
                        if (customerDetailsProvider.isResidential) ...[
                          residentialItemWidget(context),
                        ],
                        if (customerDetailsProvider.isCommercial) ...[
                          commercialItemWidget(context),
                        ],
                      ],
                    ),

                  if (customerDetailsProvider.isQuotationFieldVisible(57))
                    //solar pv system specification
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            57, 'Solar PV System Specification'),
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

                  if (customerDetailsProvider.isQuotationFieldVisible(66))
                    //scope of work
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            66, 'Scope of Work'),
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

                  if (customerDetailsProvider.isQuotationFieldVisible(70))
                    //cable details
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            70, 'Cable Details'),
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
                  if (customerDetailsProvider.isQuotationFieldVisible(53)) ...[
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                          53,
                          'Additional Expenses',
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey1,
                        ),
                      ),
                      tilePadding: EdgeInsets.zero,
                      initiallyExpanded: false,
                      children: [
                        const SizedBox(height: 16),
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(37)) ...[
                          CustomTextField(
                            readOnly: false,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            height: 54,
                            controller:
                                customerDetailsProvider.systemPriceController,
                            hintText:
                                customerDetailsProvider.getQuotationFieldName(
                                    37,
                                    'System price excluding KSEB paper work'),
                            labelText: '',
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(38)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .additionalStructureController,
                            hintText:
                                customerDetailsProvider.getQuotationFieldName(
                                    38, 'Additional Paper Work'),
                            labelText: '',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(39)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .feasibilityFeeController,
                            hintText:
                                customerDetailsProvider.getQuotationFieldName(
                                    39, 'Fee in KSEB for Feasibility study'),
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
                        ],
                        if (customerDetailsProvider
                            .isQuotationFieldVisible(40)) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .registrationFeeController,
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
                                40,
                                'Registration Fee in KSEB - 1000/- per kW (80% refundable)'),
                            labelText: '',
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (settingsProvider.menuIsViewMap[154] == 1) ...[
                          CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: customerDetailsProvider
                                .feasibilityFeeThreeController,
                            hintText: customerDetailsProvider.getQuotationFieldName(
                                41,
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
                                42,
                                'Registration Fee in KSEB - 1000/- per kW (80% refundable) Three phase'),
                            labelText: '',
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ],
                  //terms
                  if (customerDetailsProvider.isQuotationFieldVisible(43))
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            43, 'Terms and Conditions'),
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
                          controller: customerDetailsProvider
                              .qtermsConditionsController,
                          hintText:
                              customerDetailsProvider.getQuotationFieldName(
                                  43, 'Terms and Conditions'),
                          labelText: '',
                          minLines: 4,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  //warranty
                  if (customerDetailsProvider.isQuotationFieldVisible(44))
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            44, 'Warranty'),
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
                                hintText: customerDetailsProvider
                                    .getQuotationFieldName(44, 'Warranty'),
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

                  //Payment terms
                  if (customerDetailsProvider.isQuotationFieldVisible(48))
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            48, 'Payment Terms'),
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
                        if (customerDetailsProvider
                                .isQuotationFieldVisible(45) ||
                            customerDetailsProvider
                                .isQuotationFieldVisible(84)) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller:
                                      customerDetailsProvider.advanceController,
                                  hintText: customerDetailsProvider
                                          .isResidential
                                      ? customerDetailsProvider
                                          .getQuotationFieldName(84,
                                              'Advance payment up on conformation')
                                      : customerDetailsProvider
                                          .getQuotationFieldName(45,
                                              'Advance Against Purchase Order %'),
                                  labelText: '',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                                .isQuotationFieldVisible(46) ||
                            customerDetailsProvider
                                .isQuotationFieldVisible(85)) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .deliveryController,
                                  hintText: customerDetailsProvider
                                          .isResidential
                                      ? customerDetailsProvider
                                          .getQuotationFieldName(85,
                                              'Upon the material ready for dispatch')
                                      : customerDetailsProvider
                                          .getQuotationFieldName(46,
                                              'On readiness of major material at our warehouse before dispatch along with 100% taxes and against proforma invoice %'),
                                  labelText: '',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (customerDetailsProvider
                                .isQuotationFieldVisible(47) ||
                            customerDetailsProvider
                                .isQuotationFieldVisible(86)) ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .workCompletionController,
                                  hintText: customerDetailsProvider
                                          .isResidential
                                      ? customerDetailsProvider
                                          .getQuotationFieldName(
                                              86, 'Installation Completion')
                                      : customerDetailsProvider
                                          .getQuotationFieldName(
                                              47, 'After project completion %'),
                                  labelText: '',
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            if (customerDetailsProvider
                                .isQuotationFieldVisible(87)) ...[
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .paymentTermsController,
                                  hintText: customerDetailsProvider
                                      .getQuotationFieldName(
                                          87, 'Payment Term'),
                                  labelText: '',
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (customerDetailsProvider
                                .isQuotationFieldVisible(49)) ...[
                              Expanded(
                                child: CustomTextField(
                                  readOnly: false,
                                  height: 54,
                                  controller: customerDetailsProvider
                                      .incoTermsController,
                                  hintText: customerDetailsProvider
                                      .getQuotationFieldName(49, 'Inco Terms'),
                                  labelText: '',
                                ),
                              ),
                            ],
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
                  if (customerDetailsProvider.isQuotationFieldVisible(56) &&
                      companyQuotationItems == false)
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            56, 'Bill of Materials'),
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
                  //Structure of Material
                  if (customerDetailsProvider.isQuotationFieldVisible(54))
                    ExpansionTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: Text(
                        customerDetailsProvider.getQuotationFieldName(
                            54, 'Structure Materials'),
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

                  bool isCommercialProposal =
                      settingsProvider.companyDetails.isNotEmpty &&
                          settingsProvider
                                  .companyDetails.first.commercialProposal ==
                              1;

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
                            widget.isDuplicate == true
                                ? "0"
                                : widget.quotationId,
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
                    label: const Text('Add Item1'),
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  customerDetailsProvider.isQuotationFieldVisible(34)) ...[
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customerDetailsProvider.isPercentage
                              ? '${customerDetailsProvider.getQuotationFieldName(34, 'Profit')} %'
                              : customerDetailsProvider.getQuotationFieldName(
                                  34, 'Profit'),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 16),
                        ),
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
                        controller: customerDetailsProvider.profitController,
                        onChanged: (value) {
                          customerDetailsProvider.updateTotal();
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal &&
                  customerDetailsProvider.isQuotationFieldVisible(80))
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      '${customerDetailsProvider.getQuotationFieldName(80, 'CGST Amount')}:  ₹ ',
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal &&
                  customerDetailsProvider.isQuotationFieldVisible(81))
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      '${customerDetailsProvider.getQuotationFieldName(81, 'SGST Amount')}:  ₹ ',
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal &&
                  customerDetailsProvider.isQuotationFieldVisible(82))
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      '${customerDetailsProvider.getQuotationFieldName(82, 'GST Amount')}:  ₹ ',
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty ||
                  customerDetailsProvider.selectedCommercialFields.isNotEmpty)
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal &&
                  customerDetailsProvider.isQuotationFieldVisible(83))
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      '${customerDetailsProvider.getQuotationFieldName(83, 'Shipping Charges')}:   ',
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
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
                Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Roundoff:   ',
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
                        controller: customerDetailsProvider.roundoffController,
                        onChanged: (p0) {
                          customerDetailsProvider.updateTotal();
                        },
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: '₹'),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*\.?\d{0,2}')),
                        ],
                      ),
                    ),
                  ],
                ),
              if (customerDetailsProvider.items.isNotEmpty &&
                  !isCommercialProposal)
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
              label: const Text('Add item3'),
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
            if (customerDetailsProvider.isQuotationFieldVisible(71)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableStructureController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      71, 'Structure'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(72)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableTypeController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText:
                      customerDetailsProvider.getQuotationFieldName(72, 'Type'),
                  labelText: '',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(73)) ...[
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.cableShortCircuitTempController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      73, 'Short circuit temperature range'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(74)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableStandardController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      74, 'Standard'),
                  labelText: '',
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(75)) ...[
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.cableConductorClassController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      75, 'Conductor Class'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(76)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableMaterialController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      76, 'Material'),
                  labelText: '',
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(77)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableProtectionController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      77, 'Protection'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(78)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.cableWarrantyController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      78, 'Warranty'),
                  labelText: '',
                ),
              ),
            ]
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(79)) ...[
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.cableTensileStrengthController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      79, 'Tensile strength'),
                  labelText: '',
                ),
              ),
            ]
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
              if (customerDetailsProvider.isQuotationFieldVisible(67)) ...[
                Expanded(
                  child: CustomTextField(
                    controller:
                        customerDetailsProvider.designAndEngineeringController,
                    readOnly: false,
                    keyboardType: TextInputType.multiline,
                    height: 54,
                    hintText: customerDetailsProvider.getQuotationFieldName(
                        67, 'Design and Engineering'),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (customerDetailsProvider.isQuotationFieldVisible(68)) ...[
                Expanded(
                  child: CustomTextField(
                    controller: customerDetailsProvider.a3SScopeController,
                    readOnly: false,
                    height: 54,
                    hintText: customerDetailsProvider.getQuotationFieldName(
                        68, 'A3S Scope'),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 16),
              ],
              if (customerDetailsProvider.isQuotationFieldVisible(69)) ...[
                Expanded(
                  child: CustomTextField(
                    controller: customerDetailsProvider.clientScopeController,
                    readOnly: false,
                    height: 54,
                    hintText: customerDetailsProvider.getQuotationFieldName(
                        69, 'Client Scope'),
                    labelText: '',
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              customerDetailsProvider.addOrEditScopeOfWorkItem(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add item2'),
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
            if (customerDetailsProvider.isQuotationFieldVisible(58)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.plantCapacityController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      58, 'Plant Capacity'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(59)) ...[
              Expanded(
                child: CustomTextField(
                  controller:
                      customerDetailsProvider.moduleTechnologiesController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      59, 'Module Technologies'),
                  labelText: '',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(60)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider
                      .mountingStructureTechnologiesController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      60, 'Mounting Structure Technologies'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(61)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.projectSchemeController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      61, 'Project Scheme'),
                  labelText: '',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(62)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.powerEvacuationController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      62, 'Power Evacuation'),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(63)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.areaApproximateController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      63, 'Area (Approximate)'),
                  labelText: '',
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (customerDetailsProvider.isQuotationFieldVisible(64)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider
                      .solarPlantOutputConnectionController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      64, 'Solar Plant output Connection '),
                  labelText: '',
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (customerDetailsProvider.isQuotationFieldVisible(65)) ...[
              Expanded(
                child: CustomTextField(
                  controller: customerDetailsProvider.schemeController,
                  readOnly: false,
                  keyboardType: TextInputType.text,
                  height: 54,
                  hintText: customerDetailsProvider.getQuotationFieldName(
                      65, 'Scheme'),
                  labelText: '',
                ),
              ),
            ],
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
                text: customerDetailsProvider.getQuotationFieldName(
                    54, 'Structure Materials'),
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
      buttonText:
          customerDetailsProvider.getQuotationFieldName(36, 'Load Quotation'),
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
