import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/purchase_item_model.dart';
import 'package:vidyanexis/controller/models/purchase_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import 'package:vidyanexis/utils/extensions.dart';

class PurchaseWidget extends StatefulWidget {
  final bool isEdit;
  final String editId;
  final PurchaseModel? data;

  const PurchaseWidget({
    super.key,
    required this.isEdit,
    required this.editId,
    this.data,
  });

  @override
  State<PurchaseWidget> createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cannot save',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.appViolet,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: GoogleFonts.plusJakartaSans(
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
          Provider.of<SettingsProvider>(context, listen: false);
      await settingsProvider.searchSupplierApi('', context);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      await expenseProvider.searchItemListPurchase(context);

      expenseProvider.resetPurchaseItems();
      expenseProvider.clearPurchaseItemFields();
      expenseProvider.resetPurchaseValues();

      if (widget.isEdit && widget.data != null) {
        expenseProvider.setSelectedSupplierId(widget.data!.supplierId);
        expenseProvider.invoiceNoPurchaseController.text =
            widget.data!.invoiceNo;
        expenseProvider.invoiceDatePurchaseController.text =
            formatPurchaseDate(widget.data!.purchaseDate);
        expenseProvider.descriptionPurchaseController.text =
            widget.data!.descriptions;

        final selectedPerson = settingsProvider.searchSupplier.firstWhere(
          (item) => item.supplierId == widget.data!.supplierId,
          orElse: () => settingsProvider.searchSupplier.first,
        );
        expenseProvider.addressPurchaseController.text = selectedPerson.address;

        // Fetch purchase details
        await expenseProvider.searchPurchaseDetails(widget.editId, context);

        expenseProvider.purchaseItems.clear();
        for (var item in expenseProvider.purchaseDetails) {
          expenseProvider.purchaseItems.add(item);
        }
        expenseProvider.calculateGrandTotal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExpenseProvider, SettingsProvider>(
      builder: (context, expenseProvider, settingsProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              widget.isEdit ? 'Edit Purchase' : 'Add Purchase',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBasicInfoColumn(
                              expenseProvider, settingsProvider),
                          const SizedBox(height: 24),
                          _buildAddItemColumn(expenseProvider),
                          if (expenseProvider.purchaseItems.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildSectionTitle(
                                    'Added Items (${expenseProvider.purchaseItems.length})'),
                                TextButton.icon(
                                  onPressed: () {
                                    expenseProvider.purchaseItems.clear();
                                    expenseProvider.calculateGrandTotal();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.clear_all,
                                      color: Colors.red),
                                  label: Text('Clear All',
                                      style: GoogleFonts.plusJakartaSans(
                                          color: Colors.red)),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildAddedItemsList(expenseProvider),
                          ],
                          const SizedBox(height: 24),
                          _buildSectionTitle('Additional Details'),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: const Color(0xFFCBD5E1), width: 1.0),
                            ),
                            child: CustomTextField(
                              controller:
                                  expenseProvider.descriptionPurchaseController,
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
                  _buildBottomBar(expenseProvider),
                ],
              ),
            ),
          ),
        );
      },
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
                expenseProvider.setSelectedSupplierId(selectedId);
              },
              selectedValue: expenseProvider.selectedSupplierId,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: CustomTextField(
              readOnly: true,
              height: 52,
              controller: expenseProvider.addressPurchaseController,
              hintText: 'Address',
              labelText: '',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: CustomTextField(
              height: 52,
              controller: expenseProvider.invoiceNoPurchaseController,
              hintText: 'Invoice No*',
              labelText: '',
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
                  expenseProvider.invoiceDatePurchaseController.text =
                      DateFormat('dd MMM yyyy').format(picked);
                }
              },
              readOnly: true,
              height: 52,
              controller: expenseProvider.invoiceDatePurchaseController,
              hintText: 'Invoice Date*',
              suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
              labelText: '',
            ),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          CommonDropdown<int>(
            hintText: 'Select Supplier*',
            items: settingsProvider.searchSupplier
                .map((status) => DropdownItem<int>(
                      id: status.supplierId,
                      name: status.supplierName,
                    ))
                .toList(),
            controller: TextEditingController(),
            onItemSelected: (selectedId) {
              final selectedPerson = settingsProvider.searchSupplier.firstWhere(
                (item) => item.supplierId == selectedId,
              );
              expenseProvider.addressPurchaseController.text =
                  selectedPerson.address;
              expenseProvider.setSelectedSupplierId(selectedId);
            },
            selectedValue: expenseProvider.selectedSupplierId,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            readOnly: true,
            height: 52,
            controller: expenseProvider.addressPurchaseController,
            hintText: 'Address',
            labelText: '',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  height: 52,
                  controller: expenseProvider.invoiceNoPurchaseController,
                  hintText: 'Invoice No*',
                  labelText: '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      expenseProvider.invoiceDatePurchaseController.text =
                          DateFormat('dd MMM yyyy').format(picked);
                    }
                  },
                  readOnly: true,
                  height: 52,
                  controller: expenseProvider.invoiceDatePurchaseController,
                  hintText: 'Invoice Date*',
                  suffixIcon:
                      const Icon(Icons.calendar_today_rounded, size: 20),
                  labelText: '',
                ),
              ),
            ],
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isWeb ? Colors.white : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            boxShadow: isWeb
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ],
    );
  }

  Widget _buildAddItemColumn(ExpenseProvider expenseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Add Item'),
        const SizedBox(height: 12),
        _buildItemForm(expenseProvider),
      ],
    );
  }

  void _addOrUpdateItem(ExpenseProvider expenseProvider) {
    if (expenseProvider.itemNamePurchaseController.text.isEmpty ||
        expenseProvider.quantityPurchaseController.text.isEmpty ||
        expenseProvider.pricePurchaseController.text.isEmpty) {
      showErrorDialog(context,
          'Please fill in all required fields (Item, Unit Price, Qty)');
      return;
    }
    final purchaseItem = PurchaseItemModel(
      itemId: expenseProvider.itemDrop.toString(),
      itemName: expenseProvider.itemNamePurchaseController.text,
      categoryId: expenseProvider.selectedCategoryId.toString(),
      categoryName: expenseProvider.categoryPurchaseController.text,
      unitId: expenseProvider.selectedUnitId.toString(),
      unitName: expenseProvider.unitPurchaseController.text,
      quantity:
          double.tryParse(expenseProvider.quantityPurchaseController.text) ??
              0.0,
      price:
          double.tryParse(expenseProvider.pricePurchaseController.text) ?? 0.0,
      amount:
          double.tryParse(expenseProvider.amountPurchaseController.text) ?? 0.0,
      discount: double.tryParse(
              expenseProvider.discountAmountPurchaseController.text.isEmpty
                  ? '0'
                  : expenseProvider.discountAmountPurchaseController.text) ??
          0.0,
      discountPercentage: double.tryParse(
              expenseProvider.discountPurchaseController.text.isEmpty
                  ? '0'
                  : expenseProvider.discountPurchaseController.text) ??
          0.0,
      netValue:
          double.tryParse(expenseProvider.netValuePurchaseController.text) ??
              0.0,
      cgst: double.tryParse(expenseProvider.cgstPerPurchaseController.text) ??
          0.0,
      sgst: double.tryParse(expenseProvider.sgstPerPurchaseController.text) ??
          0.0,
      gst:
          double.tryParse(expenseProvider.gstPerPurchaseController.text) ?? 0.0,
      igst: double.tryParse(expenseProvider.igstPerPurchaseController.text) ??
          0.0,
      gstAmount:
          double.tryParse(expenseProvider.gstPurchaseController.text) ?? 0.0,
      cgstAmount:
          double.tryParse(expenseProvider.cgstPurchaseController.text) ?? 0.0,
      sgstAmount:
          double.tryParse(expenseProvider.sgstPurchaseController.text) ?? 0.0,
      igstAmount: 0.0,
      totalAmount:
          double.tryParse(expenseProvider.totalAmountPurchaseController.text) ??
              0.0,
      hsnCode: expenseProvider.hsnPurchaseController.text,
      description: '',
      model: '',
      brand: '',
      unitDiscount: 0.0,
    );
    expenseProvider.addOrUpdatePurchaseItem(purchaseItem);
    expenseProvider.clearPurchaseItemFields();
    expenseProvider.calculateGrandTotal();
    setState(() {});
  }

  Widget _buildItemForm(ExpenseProvider expenseProvider) {
    bool isWeb = AppStyles.isWebScreen(context);

    if (isWeb) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Item dropdown, Category, Unit, HSN Code
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CommonDropdown(
                    hintText: "Item*",
                    items: expenseProvider.itemListPurchase
                        .map((status) => DropdownItem<int>(
                              id: status.itemId,
                              name: status.itemName,
                            ))
                        .toList(),
                    controller: expenseProvider.itemNamePurchaseController,
                    onItemSelected: (selectedItem) {
                      final selectedData =
                          expenseProvider.itemListPurchase.firstWhere(
                        (item) => item.itemId == selectedItem,
                      );
                      expenseProvider.setSelectedPurchaseItemId(selectedItem);
                      expenseProvider.categoryPurchaseController.text =
                          selectedData.categoryName.toString();
                      expenseProvider.unitPurchaseController.text =
                          selectedData.unitName;
                      expenseProvider.selectedCategoryId =
                          selectedData.categoryId;
                      expenseProvider.selectedUnitId = selectedData.unitId;
                      expenseProvider.pricePurchaseController.text =
                          selectedData.unitPrice;
                      expenseProvider.cgstPerPurchaseController.text =
                          selectedData.cgst;
                      expenseProvider.sgstPerPurchaseController.text =
                          selectedData.sgst;
                      expenseProvider.igstPerPurchaseController.text =
                          selectedData.igst;
                      expenseProvider.gstPerPurchaseController.text =
                          selectedData.gst;
                      expenseProvider.hsnPurchaseController.text =
                          selectedData.hsnCode;
                      expenseProvider.updateCalculations();
                    },
                    selectedValue: expenseProvider.itemDrop,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.categoryPurchaseController,
                    hintText: 'Category',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.unitPurchaseController,
                    hintText: 'Unit',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.hsnPurchaseController,
                    hintText: 'HSN Code',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Unit Price, Amount, Discount %, Discount Amount
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.pricePurchaseController,
                    hintText: 'Unit Price',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.amountPurchaseController,
                    hintText: 'Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.discountPurchaseController,
                    hintText: 'Discount %',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    height: 52,
                    controller:
                        expenseProvider.discountAmountPurchaseController,
                    hintText: 'Discount Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 3: Net Value, CGST, SGST, GST
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.netValuePurchaseController,
                    hintText: 'Net Value',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.cgstPurchaseController,
                    hintText: 'CGST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.sgstPurchaseController,
                    hintText: 'SGST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.gstPurchaseController,
                    hintText: 'GST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 4: Quantity*, Total Amount, Add/Update button
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.quantityPurchaseController,
                    hintText: 'Quantity *',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.totalAmountPurchaseController,
                    hintText: 'Total Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  flex: 7,
                  child: SizedBox(),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 52,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _addOrUpdateItem(expenseProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: Icon(
                      expenseProvider.editItemIndex != null
                          ? Icons.check_circle_outline
                          : Icons.add_rounded,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Mobile responsive stacked version
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        ),
        child: Column(
          children: [
            // Item dropdown
            CommonDropdown(
              hintText: "Item*",
              items: expenseProvider.itemListPurchase
                  .map((status) => DropdownItem<int>(
                        id: status.itemId,
                        name: status.itemName,
                      ))
                  .toList(),
              controller: expenseProvider.itemNamePurchaseController,
              onItemSelected: (selectedItem) {
                final selectedData =
                    expenseProvider.itemListPurchase.firstWhere(
                  (item) => item.itemId == selectedItem,
                );
                expenseProvider.setSelectedPurchaseItemId(selectedItem);
                expenseProvider.categoryPurchaseController.text =
                    selectedData.categoryName.toString();
                expenseProvider.unitPurchaseController.text =
                    selectedData.unitName;
                expenseProvider.selectedCategoryId = selectedData.categoryId;
                expenseProvider.selectedUnitId = selectedData.unitId;
                expenseProvider.pricePurchaseController.text =
                    selectedData.unitPrice;
                expenseProvider.cgstPerPurchaseController.text =
                    selectedData.cgst;
                expenseProvider.sgstPerPurchaseController.text =
                    selectedData.sgst;
                expenseProvider.igstPerPurchaseController.text =
                    selectedData.igst;
                expenseProvider.gstPerPurchaseController.text =
                    selectedData.gst;
                expenseProvider.hsnPurchaseController.text =
                    selectedData.hsnCode;
                expenseProvider.updateCalculations();
              },
              selectedValue: expenseProvider.itemDrop,
            ),
            const SizedBox(height: 12),
            // Row: Category, Unit, HSN Code
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.categoryPurchaseController,
                    hintText: 'Category',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.unitPurchaseController,
                    hintText: 'Unit',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.hsnPurchaseController,
                    hintText: 'HSN Code',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row: Unit Price, Amount
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.pricePurchaseController,
                    hintText: 'Unit Price',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.amountPurchaseController,
                    hintText: 'Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row: Discount %, Discount Amount
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.discountPurchaseController,
                    hintText: 'Discount %',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller:
                        expenseProvider.discountAmountPurchaseController,
                    hintText: 'Discount Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row: Net Value, CGST, SGST, GST
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.netValuePurchaseController,
                    hintText: 'Net Value',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.cgstPurchaseController,
                    hintText: 'CGST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.sgstPurchaseController,
                    hintText: 'SGST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.gstPurchaseController,
                    hintText: 'GST',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row: Quantity*, Total Amount
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.quantityPurchaseController,
                    hintText: 'Quantity *',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => expenseProvider.updateCalculations(),
                    labelText: '',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    height: 52,
                    controller: expenseProvider.totalAmountPurchaseController,
                    hintText: 'Total Amount',
                    readOnly: true,
                    labelText: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _addOrUpdateItem(expenseProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    elevation: 0,
                  ),
                  child: Icon(
                    expenseProvider.editItemIndex != null
                        ? Icons.check_circle_outline
                        : Icons.add_rounded,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAddedItemsList(ExpenseProvider expenseProvider) {
    bool isWeb = AppStyles.isWebScreen(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenseProvider.purchaseItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = expenseProvider.purchaseItems[index];

        if (isWeb) {
          // Web View - Single horizontal row
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
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
                    '${item.categoryName} • ${item.unitName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 3. Brand & Model & Description
                Expanded(
                  flex: 4,
                  child: Text(
                    '${(item.description ?? '').isNotEmpty ? 'Desc: ${item.description}' : ''}'
                    '${(item.brand ?? '').isNotEmpty ? ' • Brand: ${item.brand}' : ''}'
                    '${(item.model ?? '').isNotEmpty ? ' • Model: ${item.model}' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // 4. Rate
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
                // 5. Quantity
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
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    expenseProvider.editPurchaseItem(index);
                    setState(() {});
                  },
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    expenseProvider.purchaseItems.removeAt(index);
                    expenseProvider.calculateGrandTotal();
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        } else {
          // Mobile View - original stacked version
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.categoryName} • ${item.unitName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      if ((item.description ?? '').isNotEmpty ||
                          (item.brand ?? '').isNotEmpty ||
                          (item.model ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${(item.description ?? '').isNotEmpty ? 'Desc: ${item.description}' : ''}'
                          '${(item.brand ?? '').isNotEmpty ? ' • Brand: ${item.brand}' : ''}'
                          '${(item.model ?? '').isNotEmpty ? ' • Model: ${item.model}' : ''}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${item.quantity} Qty',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 20),
                  onPressed: () {
                    expenseProvider.editPurchaseItem(index);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                  onPressed: () {
                    expenseProvider.purchaseItems.removeAt(index);
                    expenseProvider.calculateGrandTotal();
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        }
      },
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
            mainAxisAlignment: AppStyles.isWebScreen(context)
                ? MainAxisAlignment.end
                : MainAxisAlignment.center,
            children: [
              ResponsiveButtonWrapper(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
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
                    if (expenseProvider.selectedSupplierId == null ||
                        expenseProvider
                            .invoiceNoPurchaseController.text.isEmpty ||
                        expenseProvider.purchaseItems.isEmpty) {
                      showErrorDialog(context,
                          'Please fill in all required fields and add at least one item');
                      return;
                    }

                    var data = {
                      "Purchase_Master_Id": widget.editId,
                      "Purchase_Date": expenseProvider
                          .invoiceDatePurchaseController.text
                          .toyyyymmdd(),
                      "Supplier_Id": expenseProvider.selectedSupplierId,
                      "Invoice_No":
                          expenseProvider.invoiceNoPurchaseController.text,
                      "TotalAmount":
                          expenseProvider.grandTotal.toStringAsFixed(2),
                      "TaxableAmount":
                          expenseProvider.totalTaxableAmount.toStringAsFixed(2),
                      "Total_CGST":
                          expenseProvider.totalCGST.toStringAsFixed(2),
                      "Total_SGST":
                          expenseProvider.totalSGST.toStringAsFixed(2),
                      "Total_IGST": 0,
                      "Total_GST": expenseProvider.totalGST.toStringAsFixed(2),
                      "TotalDiscount":
                          expenseProvider.totalDiscount.toStringAsFixed(2),
                      "NetTotal":
                          expenseProvider.finalGrandTotal.toStringAsFixed(2),
                      "descriptions":
                          expenseProvider.descriptionPurchaseController.text,
                      "purchase_details": expenseProvider.purchaseItems
                          .map((item) => item.toJson())
                          .toList(),
                    };

                    expenseProvider.savePurchase(
                      editId: int.parse(widget.editId),
                      context: context,
                      data: data,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
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

String formatPurchaseDate(String purchaseDate) {
  try {
    DateTime parsedDate = DateTime.parse(purchaseDate);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (e) {
    return purchaseDate;
  }
}
