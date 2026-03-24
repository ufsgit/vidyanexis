import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stock_use_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/bom_item_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/edit_bom_item_dialog.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/customer_details_provider.dart';
import '../../../controller/models/stock_model.dart';
import '../home/custom_button_widget.dart';
import '../home/custom_dropdown_widget.dart';
import '../home/custom_text_field.dart';

class AddStockUseWidget extends StatefulWidget {
  final bool isEdit;
  final StockUseModel? stockUse;
  final int editId;
  final int customerId;

  const AddStockUseWidget(
      {super.key,
      required this.isEdit,
      this.stockUse,
      required this.editId,
      required this.customerId});

  @override
  State<AddStockUseWidget> createState() => _AddStockUseWidgetState();
}

class _AddStockUseWidgetState extends State<AddStockUseWidget> {
  String? validateInputs(
      BuildContext context, StockUseProvider expenseProvider) {
    if (expenseProvider.stockUseItems.isEmpty) {
      return 'Please Add Item';
    }
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<StockUseProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);

      expenseProvider.searchItemListStock(context);

      if (widget.isEdit) {
        // Load stock use details including technical specification
        await expenseProvider.getStockUseDetails(
            context: context, masterId: widget.editId.toString());

        // Set the date and description
        expenseProvider.suDateController.text = widget.stockUse!.date;
        expenseProvider.suDescriptionController.text =
            widget.stockUse!.description;

        // Set the stock status from the existing data
        customerDetailsProvider
            .updateStockStatus(widget.stockUse!.stockStatus ?? 'Pending');

        print(
            "Loaded ${customerDetailsProvider.billOfMaterialsItems.length} BOM items for editing");
        print("Stock Status: ${widget.stockUse!.stockStatus}");
      } else {
        // Clear everything for new entry
        expenseProvider.suDateController.clear();
        expenseProvider.suDescriptionController.clear();
        expenseProvider.stockUseItems.clear();
        expenseProvider.resetStockUseForm();

        // Clear BOM items
        customerDetailsProvider.billOfMaterialsItems.clear();
        customerDetailsProvider.clearBOMFields();

        // Reset stock status to default for new entry
        customerDetailsProvider.updateStockStatus('Pending');
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final expenseProvider =
  //     Provider.of<StockUseProvider>(context, listen: false);
  //     final customerDetailsProvider =
  //     Provider.of<CustomerDetailsProvider>(context, listen: false);
  //
  //     expenseProvider.searchItemListStock(context);
  //
  //     if (widget.isEdit) {
  //       // Load stock use details including technical specification
  //       await expenseProvider.getStockUseDetails(
  //           context: context,
  //           masterId: widget.editId.toString()
  //       );
  //
  //       // Set the date and description
  //       expenseProvider.suDateController.text = widget.stockUse!.date;
  //       expenseProvider.suDescriptionController.text = widget.stockUse!.description;
  //
  //       // Note: stockUseItems and billOfMaterialsItems are already loaded in getStockUseDetails
  //       print("Loaded ${customerDetailsProvider.billOfMaterialsItems.length} BOM items for editing");
  //     } else {
  //       // Clear everything for new entry
  //       expenseProvider.suDateController.clear();
  //       expenseProvider.suDescriptionController.clear();
  //       expenseProvider.stockUseItems.clear();
  //       expenseProvider.resetStockUseForm();
  //
  //       // Clear BOM items
  //       customerDetailsProvider.billOfMaterialsItems.clear();
  //       customerDetailsProvider.clearBOMFields();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<StockUseProvider>(context);
    // final provider = Provider.of<SettingsProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Stock Use' : 'Add Stock Use',
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
        width: MediaQuery.sizeOf(context).width / 2,
        // height: MediaQuery.sizeOf(context).height / 4,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              CustomTextField(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    expenseProvider.suDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: expenseProvider.suDateController,
                hintText: 'Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      expenseProvider.suDateController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                ),
                labelText: '',
              ),
              const SizedBox(height: 10),
              CustomTextField(
                readOnly: false,
                height: 54,
                controller: expenseProvider.suDescriptionController,
                hintText: 'Description',
                labelText: '',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: customerDetailsProvider.selectedStockStatus ?? 'Pending',
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Approved',
                    child: Text('Approved'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    customerDetailsProvider.updateStockStatus(newValue);
                  }
                },
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, // Custom font size
                  fontWeight: FontWeight.w600, // Custom font weight
                  color: AppColors.textBlack, // Custom color for selected item
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
                              color: Colors.red), // Red color for asterisk
                        ),
                      ],
                    ),
                  ),
                  floatingLabelBehavior:
                      FloatingLabelBehavior.auto, // Always show the label
                  floatingLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16, // Slightly smaller size for floating label
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1, // Color for floating label
                  ),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    borderSide: BorderSide(
                      color: AppColors.textGrey2, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                ),
                isDense: true,
                iconSize: 18,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CommonDropdown(
                            hintText: "Item*",
                            items: expenseProvider.itemListStock
                                .map((status) => DropdownItem<int>(
                                      id: status.itemId,
                                      name: status.itemName,
                                    ))
                                .toList(),
                            controller: expenseProvider.suItemNameController,
                            onItemSelected: (selectedItem) {
                              // Find the selected item from the itemListStock
                              final selectedData =
                                  expenseProvider.itemListStock.firstWhere(
                                (item) => item.itemId == selectedItem,
                              );
                              expenseProvider
                                  .setSelectedStockUseItemId(selectedItem);
                              expenseProvider.suItemNameController.text =
                                  selectedData.itemName;
                              expenseProvider.suStockIdController.text =
                                  selectedData.stockId.toString();
                              expenseProvider.suUnitPriceController.text =
                                  selectedData.unitPrice;
                              expenseProvider.categoryPurchaseController.text =
                                  selectedData.categoryName.toString();
                              expenseProvider.selectedCategoryId =
                                  selectedData.categoryId;
                            },
                            selectedValue:
                                expenseProvider.selectedItemStockUseId,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller:
                                expenseProvider.categoryPurchaseController,
                            hintText: 'Category',
                            labelText: '',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: expenseProvider.suQuantityController,
                            hintText: 'Quantity*',
                            labelText: '',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: expenseProvider.suUnitPriceController,
                            hintText: 'Sale Rate',
                            labelText: '',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   child: CustomTextField(
                        //     readOnly: false,
                        //     height: 54,
                        //     controller: expenseProvider.suUnitPriceController,
                        //     hintText: 'Sale Rate',
                        //     labelText: '',
                        //     keyboardType: TextInputType.number,
                        //     inputFormatters: [
                        //       FilteringTextInputFormatter.digitsOnly
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            expenseProvider.addOrEditStockUseItem(context);
                            print(expenseProvider.stockUseItems
                                .map((e) => e.toJson())
                                .toList());
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
                              borderRadius:
                                  BorderRadius.circular(8), // Add border radius
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: expenseProvider.stockUseItems.length,
                      itemBuilder: (context, index) {
                        final item = expenseProvider.stockUseItems[index];
                        return Container(
                          padding: const EdgeInsets.all(5),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${item.itemName} (${item.categoryName})",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Qty: ${item.quantity.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Sale Rate: ₹${item.unitPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Amount: ₹${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  expenseProvider
                                      .populateStockUseFieldsForEditing(index);
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  expenseProvider.deleteStockUseItem(index);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
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
                // Expand automatically if there are BOM items (edit mode)
                initiallyExpanded:
                    customerDetailsProvider.billOfMaterialsItems.isNotEmpty,
                children: [
                  const SizedBox(height: 5),
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  customerDetailsProvider.clearBOMFields();
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        const EditBomItemDialog(
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
                                  side:
                                      BorderSide(color: AppColors.primaryBlue),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (customerDetailsProvider
                                .billOfMaterialsItems.isNotEmpty)
                              ListView.separated(
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
                                                  style: TextStyle(
                                                      color: Colors.red)),
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
                                        builder: (context) => EditBomItemDialog(
                                          index: index,
                                          isEdit: true,
                                        ),
                                      );
                                    },
                                  );
                                },
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
            Navigator.pop(context);
          },
          backgroundColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          textColor: AppColors.appViolet,
        ),
        CustomElevatedButton(
          buttonText: 'Save',
          onPressed: () async {
            final validationError = validateInputs(context, expenseProvider);
            if (validationError != null) {
              showErrorDialog(context, validationError);
              return;
            }

            expenseProvider.saveStockUse(
                widget.editId, widget.customerId, context);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
