import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/expense_provider.dart';
import 'package:techtify/controller/models/purchase_item_model.dart';
import 'package:techtify/controller/models/purchase_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
import 'package:techtify/utils/extensions.dart';

class PurchaseWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;
  PurchaseModel? data;

  PurchaseWidget({
    super.key,
    required this.isEdit,
    required this.editId,
    this.data,
  });

  @override
  State<PurchaseWidget> createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  String? validateInputs(
      BuildContext context, SettingsProvider settingsProvider) {
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
      final settingsProvider =
          Provider.of<SettingsProvider>(listen: false, context);
      await settingsProvider.searchSupplierApi('', context);
      final expenseProvider =
          Provider.of<ExpenseProvider>(listen: false, context);
      await expenseProvider.searchItemListPurchase(context);
      expenseProvider.resetPurchaseItems();
      expenseProvider.clearPurchaseItemFields();
      expenseProvider.resetPurchaseValues();

      // Reset the purchase items list when opening the dialog
      if (!widget.isEdit) {
      } else {
        if (widget.data != null) {
          // Set the supplier ID and populate address
          expenseProvider.setSelectedSupplierId(widget.data!.supplierId);
          int supplierId = widget.data?.supplierId ?? 0;

          final selectedSupplier = settingsProvider.searchSupplier.firstWhere(
            (item) => item.supplierId == supplierId,
          );

          expenseProvider.addressPurchaseController.text =
              selectedSupplier.address;
          expenseProvider.invoiceNoPurchaseController.text =
              widget.data!.invoiceNo;
          expenseProvider.invoiceDatePurchaseController.text =
              formatPurchaseDate(widget.data!.purchaseDate);
          expenseProvider.descriptionPurchaseController.text =
              widget.data!.descriptions;
          expenseProvider.purchaseItems = expenseProvider.purchaseDetails;
          expenseProvider.grandTotal =
              double.tryParse(widget.data!.totalAmount) ?? 0.0;
          expenseProvider.totalDiscount =
              double.tryParse(widget.data!.totalDiscount) ?? 0.0;
          expenseProvider.totalTaxableAmount =
              double.tryParse(widget.data!.taxableAmount) ?? 0.0;
          expenseProvider.totalCGST =
              double.tryParse(widget.data!.totalCgst) ?? 0.0;
          expenseProvider.totalSGST =
              double.tryParse(widget.data!.totalSgst) ?? 0.0;
          expenseProvider.totalGST =
              (double.tryParse(widget.data!.totalSgst) ?? 0.0) +
                  (double.tryParse(widget.data!.totalCgst) ?? 0.0);
          expenseProvider.finalGrandTotal =
              double.tryParse(widget.data!.netTotal) ?? 0.0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DropDownProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              widget.isEdit ? 'Edit Purchase' : 'Add Purchase',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                expenseProvider.resetPurchaseValues();
                expenseProvider.resetPurchaseItems();
                expenseProvider.clearPurchaseItemFields();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            )
          ],
        ),
        content: Container(
          color: Colors.white,
          width: MediaQuery.sizeOf(context).width / 2,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CommonDropdown<int>(
                              hintText: 'Select Supplier*',
                              items: settingsProvider.searchSupplier
                                  .map((status) => DropdownItem<int>(
                                        id: status.supplierId,
                                        name: status.supplierName,
                                      ))
                                  .toList(),
                              controller: TextEditingController(),
                              onItemSelected: (selectedId) {
                                final selectedPerson =
                                    settingsProvider.searchSupplier.firstWhere(
                                  (item) => item.supplierId == selectedId,
                                );
                                expenseProvider.addressPurchaseController.text =
                                    selectedPerson.address;
                                expenseProvider
                                    .setSelectedSupplierId(selectedId);
                              },
                              selectedValue: expenseProvider.selectedSupplierId,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: CustomTextField(
                              height: 54,
                              controller:
                                  expenseProvider.invoiceNoPurchaseController,
                              hintText: 'Invoice No*',
                              labelText: '',
                              focusNode: FocusNode(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              readOnly: true,
                              height: 54,
                              controller:
                                  expenseProvider.addressPurchaseController,
                              hintText: 'Address',
                              labelText: '',
                              focusNode: FocusNode(),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: CustomTextField(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101));
                                if (picked != null) {
                                  expenseProvider
                                          .invoiceDatePurchaseController.text =
                                      DateFormat('dd MMM yyyy').format(picked);
                                }
                              },
                              readOnly: true,
                              height: 54,
                              controller:
                                  expenseProvider.invoiceDatePurchaseController,
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
                                    expenseProvider
                                            .invoiceDatePurchaseController
                                            .text =
                                        DateFormat('dd MMM yyyy')
                                            .format(picked);
                                  }
                                },
                              ),
                              labelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 32,
                      ),

                      // Item Form Section
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
                                  child: CommonDropdown(
                                    hintText: "Item*",
                                    items: expenseProvider.itemListPurchase
                                        .map((status) => DropdownItem<int>(
                                              id: status.itemId,
                                              name: status.itemName,
                                            ))
                                        .toList(),
                                    controller: expenseProvider
                                        .itemNamePurchaseController,
                                    onItemSelected: (selectedItem) {
                                      final selectedData = expenseProvider
                                          .itemListPurchase
                                          .firstWhere((item) =>
                                              item.itemId == selectedItem);
                                      expenseProvider.setSelectedPurchaseItemId(
                                          selectedItem);
                                      expenseProvider
                                              .categoryPurchaseController.text =
                                          selectedData.categoryName.toString();
                                      expenseProvider.unitPurchaseController
                                          .text = selectedData.unitName;
                                      expenseProvider.selectedCategoryId =
                                          selectedData.categoryId;
                                      expenseProvider.selectedUnitId =
                                          selectedData.unitId;
                                      expenseProvider.pricePurchaseController
                                          .text = selectedData.unitPrice;
                                      expenseProvider.updateCalculations();
                                      expenseProvider.cgstPerPurchaseController
                                          .text = selectedData.cgst;
                                      expenseProvider.sgstPerPurchaseController
                                          .text = selectedData.sgst;
                                      expenseProvider.igstPerPurchaseController
                                          .text = selectedData.igst;
                                      expenseProvider.gstPerPurchaseController
                                          .text = selectedData.gst;
                                      expenseProvider.hsnPurchaseController
                                          .text = selectedData.hsnCode;
                                    },
                                    selectedValue: expenseProvider.itemDrop,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller: expenseProvider
                                        .categoryPurchaseController,
                                    hintText: 'Category',
                                    readOnly: true,
                                    labelText: '',
                                    focusNode: FocusNode(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller:
                                        expenseProvider.unitPurchaseController,
                                    hintText: 'Unit',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    readOnly: true,
                                    height: 54,
                                    controller:
                                        expenseProvider.hsnPurchaseController,
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
                                    controller:
                                        expenseProvider.pricePurchaseController,
                                    hintText: 'Unit Price',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    onChanged: (value) {
                                      expenseProvider.updateCalculations();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller: expenseProvider
                                        .amountPurchaseController,
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
                                    controller: expenseProvider
                                        .discountPurchaseController,
                                    hintText: 'Discount %',
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d{0,2}(\.\d{0,2})?$')),
                                    ],
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      expenseProvider.updateCalculations();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller: expenseProvider
                                        .discountAmountPurchaseController,
                                    hintText: 'Discount Amount',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    keyboardType: TextInputType.number,
                                    readOnly: true,
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
                                    controller: expenseProvider
                                        .netValuePurchaseController,
                                    hintText: 'Net Value',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller:
                                        expenseProvider.cgstPurchaseController,
                                    hintText: 'CGST',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller:
                                        expenseProvider.sgstPurchaseController,
                                    hintText: 'SGST',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    readOnly: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller:
                                        expenseProvider.gstPurchaseController,
                                    hintText: 'GST',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                //
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller: expenseProvider
                                        .quantityPurchaseController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    hintText: 'Quantity*',
                                    labelText: '',
                                    focusNode: FocusNode(),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      expenseProvider.updateCalculations();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                //
                                Expanded(
                                  child: CustomTextField(
                                    height: 54,
                                    controller: expenseProvider
                                        .totalAmountPurchaseController,
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
                                    // Validate the input
                                    if (expenseProvider.itemNamePurchaseController.text.isEmpty ||
                                        expenseProvider
                                            .quantityPurchaseController
                                            .text
                                            .isEmpty ||
                                        expenseProvider.pricePurchaseController
                                            .text.isEmpty) {
                                      showErrorDialog(context,
                                          'Please fill in all required fields');
                                      return;
                                    }

                                    // Add the item to the list
                                    final purchaseItem = PurchaseItemModel(
                                      itemId:
                                          expenseProvider.itemDrop.toString(),
                                      itemName: expenseProvider
                                          .itemNamePurchaseController.text,
                                      categoryId: expenseProvider
                                          .selectedCategoryId
                                          .toString(),
                                      categoryName: expenseProvider
                                          .categoryPurchaseController.text,
                                      unitId: expenseProvider.selectedUnitId
                                          .toString(),
                                      unitName: expenseProvider
                                          .unitPurchaseController.text,
                                      quantity: double.tryParse(expenseProvider
                                              .quantityPurchaseController
                                              .text) ??
                                          0.0,
                                      // unitPrice: double.tryParse(expenseProvider
                                      //         .pricePurchaseController.text) ??
                                      //     0.0, // Renamed to unitPrice
                                      price: double.tryParse(expenseProvider
                                              .pricePurchaseController.text) ??
                                          0.0,
                                      amount: double.tryParse(expenseProvider
                                              .amountPurchaseController.text) ??
                                          0.0,
                                      discount: double.tryParse(expenseProvider
                                                  .discountAmountPurchaseController
                                                  .text
                                                  .isEmpty
                                              ? '0'
                                              : expenseProvider
                                                  .discountAmountPurchaseController
                                                  .text) ??
                                          0.0,
                                      discountPercentage: double.tryParse(
                                              expenseProvider
                                                      .discountPurchaseController
                                                      .text
                                                      .isEmpty
                                                  ? '0'
                                                  : expenseProvider
                                                      .discountPurchaseController
                                                      .text) ??
                                          0.0,
                                      netValue: double.tryParse(expenseProvider
                                              .netValuePurchaseController
                                              .text) ??
                                          0.0,
                                      cgst: double.tryParse(expenseProvider
                                              .cgstPerPurchaseController
                                              .text) ??
                                          0.0,
                                      sgst: double.tryParse(expenseProvider
                                              .sgstPerPurchaseController
                                              .text) ??
                                          0.0,
                                      gst: double.tryParse(expenseProvider
                                              .gstPerPurchaseController.text) ??
                                          0.0,
                                      igst: double.tryParse(expenseProvider
                                              .igstPerPurchaseController
                                              .text) ??
                                          0.0,
                                      gstAmount: double.tryParse(expenseProvider
                                              .gstPurchaseController.text) ??
                                          0.0,
                                      cgstAmount: double.tryParse(
                                              expenseProvider
                                                  .cgstPurchaseController
                                                  .text) ??
                                          0.0,
                                      sgstAmount: double.tryParse(
                                              expenseProvider
                                                  .sgstPurchaseController
                                                  .text) ??
                                          0.0,
                                      igstAmount: 0.0, // Added IGST Amount
                                      totalAmount: double.tryParse(
                                              expenseProvider
                                                  .totalAmountPurchaseController
                                                  .text) ??
                                          0.0,
                                      hsnCode: expenseProvider
                                          .hsnPurchaseController.text,
                                    );

                                    expenseProvider
                                        .addOrUpdatePurchaseItem(purchaseItem);
                                    // Clear form fields for next item
                                    expenseProvider.clearPurchaseItemFields();
                                    // Update the grand total
                                    expenseProvider.calculateGrandTotal();
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
                      const SizedBox(
                        height: 20,
                      ),
                      // Item List Section
                      if (expenseProvider.purchaseItems.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with item count
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
                                        color: AppColors.appViolet
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${expenseProvider.purchaseItems.length} items',
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

                              // Items list
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: expenseProvider.purchaseItems
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
                                        border: Border.all(
                                            color: Colors.grey.shade200),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.itemName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    '${item.categoryName} (${item.unitName})',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '${item.quantity} × ₹${item.price}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'GST: ${item.gstAmount}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '₹${item.totalAmount}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              expenseProvider.editPurchaseItem(
                                                  index); // Call edit function
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red.shade700,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              expenseProvider
                                                  .removePurchaseItem(index);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              // Summary section with better organization
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
                                    // Tax details in a grid
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            _SummaryItem(
                                              label: 'Total Amount',
                                              value:
                                                  '₹${expenseProvider.grandTotal.toStringAsFixed(2)}',
                                            ),
                                            _SummaryItem(
                                              label: 'Total Discount',
                                              value:
                                                  '- ₹${expenseProvider.totalDiscount.toStringAsFixed(2)}',
                                            ),
                                            _SummaryItem(
                                              label: 'Total Taxable Amount',
                                              value:
                                                  '₹${expenseProvider.totalTaxableAmount.toStringAsFixed(2)}',
                                            ),
                                            _SummaryItem(
                                              label: 'Total GST',
                                              value:
                                                  '₹${expenseProvider.totalGST.toStringAsFixed(2)}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(color: Colors.grey),
                                    const SizedBox(height: 16),

                                    // Grand total with prominent styling
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                            color: AppColors.appViolet
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '₹${expenseProvider.finalGrandTotal.toStringAsFixed(2)}',
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

                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        height: 54,
                        controller:
                            expenseProvider.descriptionPurchaseController,
                        hintText: 'Description',
                        labelText: '',
                        focusNode: FocusNode(),
                        keyboardType: TextInputType.multiline,
                        minLines: 2,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CustomElevatedButton(
            buttonText: 'Cancel',
            onPressed: () {
              expenseProvider.resetPurchaseValues();
              expenseProvider.resetPurchaseItems();
              expenseProvider.clearPurchaseItemFields();
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
              if (expenseProvider.invoiceNoPurchaseController.text.isEmpty ||
                  expenseProvider.invoiceDatePurchaseController.text.isEmpty ||
                  expenseProvider.selectedSupplierId == null ||
                  expenseProvider.purchaseItems.isEmpty) {
                showErrorDialog(context,
                    'Please fill all required fields and add at least one item');
                return;
              }

              var data = {
                "Purchase_Master_Id": widget.editId,
                "purchase_Date": expenseProvider
                    .invoiceDatePurchaseController.text
                    .toyyyymmdd(),
                "Supplier_Id": expenseProvider.selectedSupplierId,
                "Invoice_No": expenseProvider.invoiceNoPurchaseController.text,
                "TotalAmount": expenseProvider.grandTotal.toStringAsFixed(2),
                "TaxableAmount":
                    expenseProvider.totalTaxableAmount.toStringAsFixed(2),
                "Total_CGST": expenseProvider.totalCGST.toStringAsFixed(2),
                "Total_SGST": expenseProvider.totalSGST.toStringAsFixed(2),
                "Total_IGST": 0,
                "Total_GST": expenseProvider.totalGST.toStringAsFixed(2),
                "TotalDiscount":
                    expenseProvider.totalDiscount.toStringAsFixed(2),
                "NetTotal": expenseProvider.finalGrandTotal.toStringAsFixed(2),
                "Description":
                    expenseProvider.descriptionPurchaseController.text,
                "purchase_details": expenseProvider.purchaseItems
                    .map((item) => item.toJson())
                    .toList(),
              };

              expenseProvider.savePurchase(
                  editId: int.parse(widget.editId),
                  context: context,
                  data: data);
            },
            backgroundColor: AppColors.appViolet,
            borderColor: AppColors.appViolet,
            textColor: AppColors.whiteColor,
          ),
        ],
      );
    });
  }
}

String formatPurchaseDate(String purchaseDate) {
  DateTime parsedDate = DateTime.parse(purchaseDate);
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
