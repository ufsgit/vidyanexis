import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/controller/models/Sales_model.dart';
import 'package:vidyanexis/controller/models/sales_item_model.dart';
import 'package:vidyanexis/presentation/widgets/inventory/purchase_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../controller/expense_provider.dart';
import '../../../controller/settings_provider.dart';
import 'lead_autocomplete_widget.dart';
import '../home/custom_dropdown_widget.dart';

class SalesWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final SalesModel? data;

  const SalesWidget(
      {super.key, required this.isEdit, required this.editId, this.data});

  @override
  State<SalesWidget> createState() => _SalesWidgetState();
}

class _SalesWidgetState extends State<SalesWidget> {
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
      await settingsProvider.searchInventoryCustomerApi('', context);

      final expenseProvider =
          Provider.of<ExpenseProvider>(listen: false, context);
      await expenseProvider.searchItemListSales(context);

      if (widget.isEdit && widget.data != null) {
        print('=== EDIT MODE ===');
        print('Edit ID: ${widget.editId}');

        // Clear first
        expenseProvider.resetSalesItems();
        expenseProvider.clearSalesItemFields();
        expenseProvider.resetSalesValues();

        // Fetch sales details for this specific sales record
        await expenseProvider.searchSalesDetails(widget.editId, context);

        print('Sales Details Count: ${expenseProvider.salesDetails.length}');
        print('Sales Details Data: ${expenseProvider.salesDetails}');

        // Set the customer ID and populate address
        expenseProvider.setSelectedSalesCustomerId(widget.data!.customerId);
        int customerId = widget.data?.customerId ?? 0;

        final selectedCustomer =
            settingsProvider.searchInventoryCustomer.firstWhere(
          (item) => item.customerId == customerId,
        );

        expenseProvider.addressSalesController.text =
            selectedCustomer.address.isEmpty
                ? widget.data!.address
                : selectedCustomer.address;
        expenseProvider.invoiceNOSalesControler.text = widget.data!.invoiceNo;
        expenseProvider.invoiceDateSalesController.text =
            formatPurchaseDate(widget.data!.salesDate);
        expenseProvider.descriptionSalesController.text =
            widget.data!.description;

        // Load sales items from salesDetails
        if (expenseProvider.salesDetails.isNotEmpty) {
          expenseProvider.salesItems = expenseProvider.salesDetails.map((item) {
            print('Mapping item: ${item.itemName}');
            return SalesItemModel(
              itemId: item.itemId,
              stockId: item.stockId,
              itemName: item.itemName,
              categoryId: item.categoryId,
              categoryName: item.categoryName,
              unitId: item.unitId,
              unitName: item.unitName,
              quantity: item.quantity,
              price: item.price,
              amount: item.amount,
              discount: item.discount,
              discountPercentage: item.discountPercentage,
              netValue: item.netValue,
              cgst: item.cgst,
              sgst: item.sgst,
              gst: item.gst,
              igst: item.igst,
              gstAmount: item.gstAmount,
              cgstAmount: item.cgstAmount,
              sgstAmount: item.sgstAmount,
              igstAmount: item.igstAmount,
              totalAmount: item.totalAmount,
              hsnCode: item.hsnCode,
            );
          }).toList();

          print(
              'Sales Items Count after mapping: ${expenseProvider.salesItems.length}');

          // Calculate totals after loading items
          expenseProvider.calculateSalesGrandTotal();

          print('Grand Total: ${expenseProvider.finalGrandTotal}');
        } else {
          print('WARNING: salesDetails is empty!');
        }
      } else {
        print('=== ADD MODE ===');
        // Clear everything for new entry
        expenseProvider.clearItemAdd();
        expenseProvider.clearItemFields();
        expenseProvider.clearSalesItemFields();
        expenseProvider.resetSalesEditState();
        expenseProvider.resetSalesItems();
        expenseProvider.resetSalesValues();
        expenseProvider.invoiceDateSalesController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     final settingsProvider =
  //     Provider.of<SettingsProvider>(listen: false, context);
  //     await settingsProvider.searchInventoryCustomerApi('', context);
  //
  //     final expenseProvider =
  //     Provider.of<ExpenseProvider>(listen: false, context);
  //     await expenseProvider.searchItemListPurchase(context);
  //     expenseProvider.resetSalesItems();
  //     expenseProvider.clearSalesItemFields();
  //     expenseProvider.resetSalesValues();
  //
  //     if (widget.isEdit && widget.data != null) {
  //       // Set the customer ID and populate address
  //       expenseProvider.setSelectedSalesCustomerId(widget.data!.customerId);
  //       int customerId = widget.data?.customerId ?? 0;
  //
  //       final selectedCustomer = settingsProvider.searchInventoryCustomer.firstWhere(
  //             (item) => item.customerId == customerId,
  //       );
  //
  //       expenseProvider.addressSalesController.text = selectedCustomer.address;
  //       expenseProvider.invoiceNOSalesControler.text = widget.data!.invoiceNo;
  //       expenseProvider.invoiceDateSalesController.text =
  //           formatPurchaseDate(widget.data!.salesDate);
  //       expenseProvider.descriptionSalesController.text = widget.data!.description;
  //
  //       // Load sales items here if you have a separate API for sales details
  //       // For now using purchaseDetails as placeholder
  //       expenseProvider.salesItems = expenseProvider.purchaseDetails
  //           .map((item) => SalesItemModel(
  //         itemId: item.itemId,
  //         itemName: item.itemName,
  //         categoryId: item.categoryId,
  //         categoryName: item.categoryName,
  //         unitId: item.unitId,
  //         unitName: item.unitName,
  //         quantity: item.quantity,
  //         price: item.price,
  //         amount: item.amount,
  //         discount: item.discount,
  //         discountPercentage: item.discountPercentage,
  //         netValue: item.netValue,
  //         cgst: item.cgst,
  //         sgst: item.sgst,
  //         gst: item.gst,
  //         igst: item.igst,
  //         gstAmount: item.gstAmount,
  //         cgstAmount: item.cgstAmount,
  //         sgstAmount: item.sgstAmount,
  //         igstAmount: item.igstAmount,
  //         totalAmount: item.totalAmount,
  //         hsnCode: item.hsnCode,
  //       ))
  //           .toList();
  //
  //       expenseProvider.grandTotal =
  //           double.tryParse(widget.data!.totalAmount) ?? 0.0;
  //       expenseProvider.totalDiscount =
  //           double.tryParse(widget.data!.totalDiscount) ?? 0.0;
  //       expenseProvider.totalTaxableAmount =
  //           double.tryParse(widget.data!.taxableAmount) ?? 0.0;
  //       expenseProvider.totalCGST =
  //           double.tryParse(widget.data!.totalCgst) ?? 0.0;
  //       expenseProvider.totalSGST =
  //           double.tryParse(widget.data!.totalSgst) ?? 0.0;
  //       expenseProvider.totalGST =
  //           (double.tryParse(widget.data!.totalSgst) ?? 0.0) +
  //               (double.tryParse(widget.data!.totalCgst) ?? 0.0);
  //       expenseProvider.finalGrandTotal =
  //           double.tryParse(widget.data!.netTotal) ?? 0.0;
  //     }else{
  //       expenseProvider.clearItemAdd();
  //       expenseProvider.clearItemFields();
  //       expenseProvider.clearSalesItemFields();
  //       expenseProvider.resetSalesEditState();
  //       expenseProvider.resetSalesItems();
  //       expenseProvider.resetSalesValues();
  //
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            expenseProvider.resetSalesValues();
            expenseProvider.resetSalesItems();
            expenseProvider.clearSalesItemFields();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        title: Text(
          widget.isEdit ? 'Edit Sales' : 'Add Sales',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppStyles.isWebScreen(context) ? 24 : 16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBasicInfoColumn(expenseProvider, settingsProvider),
                      const SizedBox(height: 24),

                      // Item Form Section - Using the same layout as Purchase
                      _buildItemFormSection(expenseProvider),

                      const SizedBox(height: 20),

                      // Item List Section
                      if (expenseProvider.salesItems.isNotEmpty) ...[
                        _buildItemListSection(expenseProvider),
                        const SizedBox(height: 20),
                      ],

                      _buildSectionTitle('Additional Details'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: CustomTextField(
                          controller: expenseProvider.descriptionSalesController,
                          height: 56,
                          hintText: 'Notes / Description',
                          labelText: '',
                          keyboardType: TextInputType.multiline,
                          minLines: 2,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(expenseProvider),
    );
  }

  Widget _buildItemFormSection(ExpenseProvider expenseProvider) {
    bool isWeb = AppStyles.isWebScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Add Item'),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWeb) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildItemDropdown(expenseProvider),
                    ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _buildCategoryField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildUnitField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildHSNField(expenseProvider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildPriceField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildQuantityField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildDiscountPercentField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildDiscountAmountField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildAmountField(expenseProvider),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildNetValueField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildCGSTField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildSGSTField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildGSTField(expenseProvider),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildTotalAmountField(expenseProvider),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  flex: 5,
                  child: SizedBox(),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _handleAddItem(expenseProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Icon(
                      expenseProvider.editSalesItemIndex != null
                          ? Icons.check_circle_outline
                          : Icons.add_rounded,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Mobile stacked grid view
            Row(
              children: [
                Expanded(child: _buildItemDropdown(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildUnitField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildHSNField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPriceField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildQuantityField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDiscountPercentField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildDiscountAmountField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildAmountField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildNetValueField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCGSTField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildSGSTField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildGSTField(expenseProvider)),
                const SizedBox(width: 12),
                Expanded(child: _buildTotalAmountField(expenseProvider)),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _handleAddItem(expenseProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Icon(
                    expenseProvider.editSalesItemIndex != null
                        ? Icons.check_circle_outline
                        : Icons.add_rounded,
                    size: 24,
                  ),
                ),
              ),
            ),
            ],
          ],
        ),
      ),
    ],
  );
}

  Widget _buildItemDropdown(ExpenseProvider expenseProvider) {
    return CommonDropdown(
      hintText: "Item*",
      items: expenseProvider.itemListSales
          .where((element) => element.primaryCheckBox == 0)
          .map((status) => DropdownItem<int>(
                id: status.itemId,
                name: status.itemName,
              ))
          .toList(),
      controller: expenseProvider.itemNameSalesController,
      onItemSelected: (selectedItem) {
        final selectedData = expenseProvider.itemListSales
            .firstWhere((item) => item.itemId == selectedItem);
        expenseProvider.setSelectedPurchaseItemId(selectedItem);

        // Update category controller
        expenseProvider.categorySalesController.text =
            selectedData.categoryName.toString();

        expenseProvider.unitSalesController.text = selectedData.unitName;
        expenseProvider.selectedCategoryId = selectedData.categoryId;
        expenseProvider.selectedUnitId = selectedData.unitId;
        expenseProvider.priceSalesController.text = selectedData.unitPrice;
        expenseProvider.updateSalesCalculations();
        expenseProvider.cgstPerSalesController.text = selectedData.cgst;
        expenseProvider.sgstPerSalesController.text = selectedData.sgst;
        expenseProvider.igstPerSalesController.text = selectedData.igst;
        expenseProvider.gstPerSalesController.text = selectedData.gst;
        expenseProvider.hsnSalesController.text = selectedData.hsnCode;
      },
      selectedValue: expenseProvider.itemDrop,
    );
  }

  Widget _buildCategoryField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.categorySalesController,
      hintText: 'Category',
      readOnly: true,
      labelText: '',
      focusNode: FocusNode(),
    );
  }

  Widget _buildUnitField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.unitSalesController,
      hintText: 'Unit',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildHSNField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      readOnly: false,
      height: 54,
      controller: expenseProvider.hsnSalesController,
      hintText: 'HSN Code',
      labelText: '',
    );
  }

  Widget _buildPriceField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.priceSalesController,
      hintText: 'Unit Price',
      labelText: '',
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      onChanged: (value) {
        expenseProvider.updateSalesCalculations();
      },
    );
  }

  Widget _buildAmountField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.amountSalesController,
      keyboardType: TextInputType.number,
      hintText: 'Amount',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildDiscountPercentField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.discountSalesController,
      hintText: 'Discount %',
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?$')),
      ],
      labelText: '',
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        expenseProvider.updateSalesCalculations();
      },
    );
  }

  Widget _buildDiscountAmountField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.discountAmountSalesController,
      hintText: 'Discount Amount',
      labelText: '',
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      readOnly: true,
    );
  }

  Widget _buildNetValueField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.netValueSalesController,
      hintText: 'Net Value',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildCGSTField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.cgstSalesController,
      hintText: 'CGST',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildSGSTField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.sgstSalesController,
      hintText: 'SGST',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildGSTField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.gstSalesController,
      hintText: 'GST',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  Widget _buildQuantityField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.quantitySalesController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      hintText: 'Quantity*',
      labelText: '',
      focusNode: FocusNode(),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        expenseProvider.updateSalesCalculations();
      },
    );
  }

  Widget _buildTotalAmountField(ExpenseProvider expenseProvider) {
    return CustomTextField(
      height: 54,
      controller: expenseProvider.totalAmountSalesController,
      hintText: 'Total Amount',
      labelText: '',
      focusNode: FocusNode(),
      readOnly: true,
    );
  }

  void _handleAddItem(ExpenseProvider expenseProvider) {
    // Validate the input
    if (expenseProvider.itemNameSalesController.text.isEmpty ||
        expenseProvider.quantitySalesController.text.isEmpty ||
        expenseProvider.priceSalesController.text.isEmpty) {
      showErrorDialog(context, 'Please fill in all required fields');
      return;
    }

    String stockId = '';
    try {
      final selectedItem = expenseProvider.itemListSales.firstWhere(
          (item) => item.itemId.toString() == expenseProvider.itemDrop.toString());
      stockId = selectedItem.stockId.toString();
    } catch (e) {}

    // Add the item to the list
    final salesItem = SalesItemModel(
      itemId: expenseProvider.itemDrop.toString(),
      stockId: stockId,
      itemName: expenseProvider.itemNameSalesController.text,
      categoryId: expenseProvider.selectedCategoryId.toString(),
      categoryName: expenseProvider.categorySalesController.text,
      unitId: expenseProvider.selectedUnitId.toString(),
      unitName: expenseProvider.unitSalesController.text,
      quantity:
          double.tryParse(expenseProvider.quantitySalesController.text) ?? 0.0,
      price: double.tryParse(expenseProvider.priceSalesController.text) ?? 0.0,
      amount:
          double.tryParse(expenseProvider.amountSalesController.text) ?? 0.0,
      discount: double.tryParse(
              expenseProvider.discountAmountSalesController.text.isEmpty
                  ? '0'
                  : expenseProvider.discountAmountSalesController.text) ??
          0.0,
      discountPercentage: double.tryParse(
              expenseProvider.discountSalesController.text.isEmpty
                  ? '0'
                  : expenseProvider.discountSalesController.text) ??
          0.0,
      netValue:
          double.tryParse(expenseProvider.netValueSalesController.text) ?? 0.0,
      cgst: double.tryParse(expenseProvider.cgstPerSalesController.text) ?? 0.0,
      sgst: double.tryParse(expenseProvider.sgstPerSalesController.text) ?? 0.0,
      gst: double.tryParse(expenseProvider.gstPerSalesController.text) ?? 0.0,
      igst: double.tryParse(expenseProvider.igstPerSalesController.text) ?? 0.0,
      gstAmount:
          double.tryParse(expenseProvider.gstSalesController.text) ?? 0.0,
      cgstAmount:
          double.tryParse(expenseProvider.cgstSalesController.text) ?? 0.0,
      sgstAmount:
          double.tryParse(expenseProvider.sgstSalesController.text) ?? 0.0,
      igstAmount: 0.0,
      totalAmount:
          double.tryParse(expenseProvider.totalAmountSalesController.text) ??
              0.0,
      hsnCode: expenseProvider.hsnSalesController.text,
    );

    expenseProvider.addOrUpdateSalesItem(salesItem);
    expenseProvider.clearSalesItemFields();
    expenseProvider.calculateSalesGrandTotal();
  }

  Widget _buildItemListSection(ExpenseProvider expenseProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.appViolet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${expenseProvider.salesItems.length} items',
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

          // Items List
          AppStyles.isWebScreen(context)
              ? _buildWebItemsList(expenseProvider)
              : _buildMobileItemsList(expenseProvider),

          // Summary Section
          _buildSummarySection(expenseProvider),
        ],
      ),
    );
  }

  Widget _buildWebItemsList(ExpenseProvider expenseProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: expenseProvider.salesItems.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // 1. Item Name
                Expanded(
                  flex: 4,
                  child: Text(
                    item.itemName,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 2. Category & Unit
                Expanded(
                  flex: 3,
                  child: Text(
                    '${item.categoryName} (${item.unitName})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 3. Price
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 4. Quantity
                Expanded(
                  flex: 2,
                  child: Text(
                    '${item.quantity} Qty',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 5. GST
                Expanded(
                  flex: 2,
                  child: Text(
                    'GST: ₹${item.gstAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 6. Total Amount
                Expanded(
                  flex: 3,
                  child: Text(
                    '₹${item.totalAmount.toStringAsFixed(2)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 7. Actions (Edit / Delete)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    expenseProvider.editSalesItem(index);
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    expenseProvider.removeSalesItem(index);
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileItemsList(ExpenseProvider expenseProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: expenseProvider.salesItems.asMap().entries.map((entry) {
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${item.categoryName} (${item.unitName})',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.quantity} × ₹${item.price}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'GST: ${item.gstAmount}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${item.totalAmount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        expenseProvider.editSalesItem(index);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      onPressed: () {
                        expenseProvider.removeSalesItem(index);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySection(ExpenseProvider expenseProvider) {
    return Container(
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
                    value: '₹${expenseProvider.grandTotal.toStringAsFixed(2)}',
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
                    value: '₹${expenseProvider.totalGST.toStringAsFixed(2)}',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildBasicInfoColumn(
      ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    bool isWeb = AppStyles.isWebScreen(context);

    Widget content;
    if (isWeb) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: settingsProvider.leadInSales == 1
                ? LeadAutocompleteWidget(
                    labelText: 'Select Lead*',
                    initialValue: widget.isEdit && widget.data != null
                        ? widget.data!.customerName
                        : null,
                    onSelected: (model) {
                      expenseProvider.addressSalesController.text =
                          model.address;
                      expenseProvider
                          .setSelectedSalesCustomerId(model.customerId);
                    },
                  )
                : CommonDropdown<int>(
                    hintText: 'Select Customer*',
                    items: settingsProvider.searchInventoryCustomer
                        .map((status) => DropdownItem<int>(
                              id: status.customerId,
                              name: status.customerName,
                            ))
                        .toList(),
                    controller: TextEditingController(),
                    onItemSelected: (selectedId) {
                      final selectedPerson = settingsProvider
                          .searchInventoryCustomer
                          .firstWhere(
                        (item) => item.customerId == selectedId,
                      );
                      expenseProvider.addressSalesController.text =
                          selectedPerson.address;
                      expenseProvider
                          .setSelectedSalesCustomerId(selectedId);
                    },
                    selectedValue:
                        expenseProvider.selectedSalesCustomerId,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: CustomTextField(
              controller: expenseProvider.addressSalesController,
              height: 52,
              hintText: 'Address',
              labelText: '',
              readOnly: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomTextField(
              controller: expenseProvider.invoiceNOSalesControler,
              height: 52,
              hintText: 'Invoice No*',
              labelText: '',
              readOnly: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomTextField(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  expenseProvider.invoiceDateSalesController.text =
                      DateFormat('dd MMM yyyy').format(picked);
                }
              },
              controller: expenseProvider.invoiceDateSalesController,
              height: 52,
              hintText: 'Invoice Date*',
              labelText: '',
              readOnly: true,
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
            ),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          settingsProvider.leadInSales == 1
              ? LeadAutocompleteWidget(
                  labelText: 'Select Lead*',
                  initialValue: widget.isEdit && widget.data != null
                      ? widget.data!.customerName
                      : null,
                  onSelected: (model) {
                    expenseProvider.addressSalesController.text =
                        model.address;
                    expenseProvider
                        .setSelectedSalesCustomerId(model.customerId);
                  },
                )
              : CommonDropdown<int>(
                  hintText: 'Select Customer*',
                  items: settingsProvider.searchInventoryCustomer
                      .map((status) => DropdownItem<int>(
                            id: status.customerId,
                            name: status.customerName,
                          ))
                      .toList(),
                  controller: TextEditingController(),
                  onItemSelected: (selectedId) {
                    final selectedPerson = settingsProvider
                        .searchInventoryCustomer
                        .firstWhere(
                      (item) => item.customerId == selectedId,
                    );
                    expenseProvider.addressSalesController.text =
                        selectedPerson.address;
                    expenseProvider
                        .setSelectedSalesCustomerId(selectedId);
                  },
                  selectedValue:
                      expenseProvider.selectedSalesCustomerId,
                ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: expenseProvider.addressSalesController,
            height: 52,
            hintText: 'Address',
            labelText: '',
            readOnly: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: expenseProvider.invoiceNOSalesControler,
            height: 52,
            hintText: 'Invoice No*',
            labelText: '',
            readOnly: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                expenseProvider.invoiceDateSalesController.text =
                    DateFormat('dd MMM yyyy').format(picked);
              }
            },
            controller: expenseProvider.invoiceDateSalesController,
            height: 52,
            hintText: 'Invoice Date*',
            labelText: '',
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information'),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildBottomBar(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Text(
                '₹${expenseProvider.finalGrandTotal.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: AppStyles.isWebScreen(context) ? MainAxisAlignment.end : MainAxisAlignment.center,
            children: [
              ResponsiveButtonWrapper(
                child: OutlinedButton(
                  onPressed: () {
                    expenseProvider.resetSalesValues();
                    expenseProvider.resetSalesItems();
                    expenseProvider.clearSalesItemFields();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ResponsiveButtonWrapper(
                child: ElevatedButton(
                  onPressed: () async {
                    // Debug: Print current state
                    print(
                        'Sales Items count: ${expenseProvider.salesItems.length}');
                    print(
                        'Customer ID: ${expenseProvider.selectedSalesCustomerId}');
                    print(
                        'Invoice No: ${expenseProvider.invoiceNOSalesControler.text}');
                    print(
                        'Invoice Date: ${expenseProvider.invoiceDateSalesController.text}');

                    // Validate input
                    if (expenseProvider.invoiceNOSalesControler.text.isEmpty ||
                        expenseProvider.invoiceDateSalesController.text.isEmpty ||
                        expenseProvider.selectedSalesCustomerId == null ||
                        expenseProvider.salesItems.isEmpty) {
                      String errorMessage =
                          'Please fill all required fields and add at least one item\n\n';
                      if (expenseProvider.invoiceNOSalesControler.text.isEmpty) {
                        errorMessage += '• Invoice No is required\n';
                      }
                      if (expenseProvider.invoiceDateSalesController.text.isEmpty) {
                        errorMessage += '• Invoice Date is required\n';
                      }
                      if (expenseProvider.selectedSalesCustomerId == null) {
                        errorMessage += '• Customer is required\n';
                      }
                      if (expenseProvider.salesItems.isEmpty) {
                        errorMessage += '• At least one item is required\n';
                      }

                      showErrorDialog(context, errorMessage.trim());
                      return;
                    }

                    var data = {
                      "Sales_Master_Id": widget.editId,
                      "Sales_Date": expenseProvider.invoiceDateSalesController.text.toyyyymmdd(),
                      "Customer_Id": expenseProvider.selectedSalesCustomerId,
                      "Invoice_No": expenseProvider.invoiceNOSalesControler.text,
                      "TotalAmount": expenseProvider.grandTotal.toStringAsFixed(2),
                      "TaxableAmount": expenseProvider.totalTaxableAmount.toStringAsFixed(2),
                      "Total_CGST": expenseProvider.totalCGST.toStringAsFixed(2),
                      "Total_SGST": expenseProvider.totalSGST.toStringAsFixed(2),
                      "Total_IGST": 0,
                      "Total_GST": expenseProvider.totalGST.toStringAsFixed(2),
                      "TotalDiscount": expenseProvider.totalDiscount.toStringAsFixed(2),
                      "NetTotal": expenseProvider.finalGrandTotal.toStringAsFixed(2),
                      "Description": expenseProvider.descriptionSalesController.text,
                      "sales_details": expenseProvider.salesItems.map((item) => item.toJson()).toList(),
                    };

                    print('Data to be sent: $data');

                    expenseProvider.saveSales(
                        editId: int.parse(widget.editId),
                        context: context,
                        data: data);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
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
