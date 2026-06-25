import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddItemWidget extends StatefulWidget {
  final bool isEdit;
  final ItemListModel? item;
  final int editId;

  const AddItemWidget({
    super.key,
    required this.isEdit,
    this.item,
    required this.editId,
  });

  @override
  State<AddItemWidget> createState() => _AddItemWidgetState();
}

class _AddItemWidgetState extends State<AddItemWidget> {
  String? validateInputs(
      BuildContext context, ExpenseProvider expenseProvider) {
    if (expenseProvider.itemNameController.text.trim().isEmpty) {
      return 'Please enter Item name';
    }
    if (expenseProvider.itemCategoryController.text.trim().isEmpty) {
      return 'Please select Category';
    }
    if (expenseProvider.itemUnitController.text.trim().isEmpty) {
      return 'Please select Unit';
    }
    // if (expenseProvider.itemUnitPriceController.text.trim().isEmpty) {
    //   return 'Please enter Unit Price';
    // }
    if (expenseProvider.cgstController.text.trim().isEmpty) {
      return 'Please enter CGST %';
    }
    if (expenseProvider.sgstController.text.trim().isEmpty) {
      return 'Please enter SGST %';
    }
    if (expenseProvider.igstController.text.trim().isEmpty) {
      return 'Please enter IGST %';
    }
    if (expenseProvider.gstController.text.trim().isEmpty) {
      return 'Please enter GST %';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      expenseProvider.clearItemAdd();
      expenseProvider.togglePrimaryCheckbox(false);

      settingsProvider.searchCategoryApi('', context);
      settingsProvider.searchUnitApi('', context);
      // expenseProvider.searchItemDropdownList(context: context);
      expenseProvider.searchItemTypeDropdownList(context: context);
      expenseProvider.cgstController.text = "9";
      expenseProvider.sgstController.text = "9";
      expenseProvider.igstController.text = "18";
      expenseProvider.gstController.text = "18";
      if (widget.isEdit) {
        expenseProvider.itemNameController.text = widget.item!.itemName;
        expenseProvider.itemCategoryController.text = widget.item!.categoryName;
        expenseProvider.itemUnitController.text = widget.item!.unitName;
        expenseProvider.itemUnitPriceController.text = widget.item!.unitPrice;
        expenseProvider.cgstController.text = widget.item!.cgst;
        expenseProvider.sgstController.text = widget.item!.sgst;
        expenseProvider.igstController.text = widget.item!.igst;
        expenseProvider.gstController.text = widget.item!.gst;
        expenseProvider.itemHSNController.text = widget.item!.hsnCode;
        expenseProvider.priceRangeFromController.text = widget.item!.priceFrom;
        expenseProvider.priceRangeToController.text = widget.item!.priceTo;
        expenseProvider.setItemCategory(widget.item!.categoryId);
        expenseProvider.setItemUnit(widget.item!.unitId);
        expenseProvider
            .toggleCheckbox(widget.item!.serviceCheckbox == 1 ? true : false);
        expenseProvider.selectedItemTypeId =
            widget.item!.primaryCheckBox; // for item type
        expenseProvider.searchItemDropdownList(
            context: context, itemTypeId: expenseProvider.selectedItemTypeId);
        // expenseProvider.togglePrimaryCheckbox(
        //     widget.item!.primaryCheckBox == 1 ? true : false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final provider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Item' : 'Add Item',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlue800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: AppStyles.isWebScreen(context) ? 800 : double.infinity,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 16),
                      CustomTextField(
                        readOnly: false,
                        height: 56,
                        controller: expenseProvider.itemNameController,
                        hintText: 'Item Name*',
                        labelText: '',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CommonDropdown<int>(
                              hintText: 'Category*',
                              selectedValue: widget.isEdit
                                  ? expenseProvider.selectedItemCategory
                                  : null,
                              items: provider.searchCategory
                                  .map((status) => DropdownItem<int>(
                                        id: status.categoryId,
                                        name: status.categoryName ?? '',
                                      ))
                                  .toList(),
                              controller:
                                  expenseProvider.itemCategoryController,
                              onItemSelected: (selectedId) {
                                expenseProvider.setItemCategory(selectedId);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CommonDropdown<int>(
                              hintText: 'Unit*',
                              selectedValue: widget.isEdit
                                  ? expenseProvider.selectedItemUnit
                                  : null,
                              items: provider.searchUnit
                                  .map((status) => DropdownItem<int>(
                                        id: status.unitId,
                                        name: status.unitName ?? '',
                                      ))
                                  .toList(),
                              controller: expenseProvider.itemUnitController,
                              onItemSelected: (selectedId) {
                                expenseProvider.setItemUnit(selectedId);
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
                              readOnly: false,
                              height: 56,
                              controller:
                                  expenseProvider.itemUnitPriceController,
                              hintText: 'Unit Price*',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller: expenseProvider.itemHSNController,
                              hintText: 'Make',
                              labelText: '',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Tax Information'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller: expenseProvider.cgstController,
                              hintText: 'CGST %*',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (p0) {
                                int gst = (int.tryParse(expenseProvider
                                            .cgstController.text) ??
                                        0) +
                                    (int.tryParse(expenseProvider
                                            .sgstController.text) ??
                                        0);
                                expenseProvider.igstController.text =
                                    gst.toString();
                                expenseProvider.gstController.text =
                                    gst.toString();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller: expenseProvider.sgstController,
                              hintText: 'SGST %*',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (p0) {
                                int gst = (int.tryParse(expenseProvider
                                            .cgstController.text) ??
                                        0) +
                                    (int.tryParse(expenseProvider
                                            .sgstController.text) ??
                                        0);
                                expenseProvider.igstController.text =
                                    gst.toString();
                                expenseProvider.gstController.text =
                                    gst.toString();
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
                              readOnly: true,
                              height: 56,
                              controller: expenseProvider.igstController,
                              hintText: 'IGST %*',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              readOnly: true,
                              height: 56,
                              controller: expenseProvider.gstController,
                              hintText: 'GST %*',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Price Range'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller:
                                  expenseProvider.priceRangeFromController,
                              hintText: 'From Price',
                              labelText: '',
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller:
                                  expenseProvider.priceRangeToController,
                              hintText: 'To Price',
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
                      // CheckboxListTile(
                      //   title: Text(
                      //     'Add Item Materials',
                      //     style: GoogleFonts.plusJakartaSans(
                      //       fontSize: 16,
                      //       fontWeight: FontWeight.w700,
                      //       color: const Color(0xFF1E293B),
                      //     ),
                      //   ),
                      //   value: expenseProvider.isPrimaryItem == 1,
                      //   checkColor: Colors.white,
                      //   contentPadding: EdgeInsets.zero,
                      //   onChanged: (p0) {
                      //     expenseProvider.togglePrimaryCheckbox(p0 ?? false);
                      //   },
                      // ),
                      CommonDropdown(
                        hintText: "Select Item Type",
                        items: expenseProvider.itemTypeDropdownList
                            .map((status) => DropdownItem<int>(
                                  id: status.itemTypeId,
                                  name: status.itemTypeName,
                                ))
                            .toList(),
                        controller: expenseProvider.itemTypeController,
                        onItemSelected: (selectedItem) {
                          final selectedData =
                              expenseProvider.itemTypeDropdownList.firstWhere(
                                  (item) => item.itemTypeId == selectedItem);
                          expenseProvider.selectedItemTypeId =
                              selectedData.itemTypeId;
                          expenseProvider.searchItemDropdownList(
                              context: context, itemTypeId: selectedItem);
                        },
                        selectedValue: expenseProvider.selectedItemTypeId,
                      ),
                      //show only for primary and secondary
                      if (expenseProvider.selectedItemTypeId != 0 &&
                          expenseProvider.selectedItemTypeId != 3) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('Item Material'),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFFCBD5E1), width: 1.0),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Expanded(
                                  //   child: CustomTextField(
                                  //     readOnly: false,
                                  //     height: 56,
                                  //     controller: expenseProvider
                                  //         .itemMaterialController,
                                  //     hintText: 'Item Material',
                                  //     labelText: '',
                                  //   ),
                                  // ),
                                  Expanded(
                                    child: CommonDropdown(
                                      hintText: "Select Material",
                                      items: expenseProvider.itemDropdownList
                                          .map((status) => DropdownItem<int>(
                                                id: status.itemId,
                                                name: status.itemName,
                                              ))
                                          .toList(),
                                      controller: expenseProvider
                                          .itemMaterialController,
                                      onItemSelected: (selectedItem) {
                                        final selectedData = expenseProvider
                                            .itemDropdownList
                                            .firstWhere((item) =>
                                                item.itemId == selectedItem);
                                        expenseProvider
                                            .setSubId(selectedData.itemId);
                                      },
                                      selectedValue: expenseProvider.subItemId,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller:
                                          expenseProvider.itemPriceController,
                                      hintText: 'Price',
                                      labelText: '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .itemMaterialSpecificationController,
                                      hintText: 'Specification',
                                      labelText: '',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .itemMaterialManufactureController,
                                      hintText: 'Manufacturer',
                                      labelText: '',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .itemMaterialUnitController,
                                      hintText: 'Unit',
                                      labelText: '',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .itemQuantityController,
                                      hintText: 'Quantity',
                                      labelText: '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              CheckboxListTile(
                                title: const Text(''),
                                value: expenseProvider.isQuantity,
                                onChanged: (value) {
                                  expenseProvider.isQuantity = value ?? false;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildSectionTitle('Price Range'),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .materialPriceFromController,
                                      hintText: 'From Price',
                                      labelText: '',
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d{0,2}')),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: CustomTextField(
                                      readOnly: false,
                                      height: 56,
                                      controller: expenseProvider
                                          .materialPriceToController,
                                      hintText: 'To Price',
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
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      expenseProvider.addOrEditItem(context),
                                  icon: const Icon(Icons.add_rounded, size: 20),
                                  label: const Text('Add Material'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                              if (expenseProvider.items.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const Divider(
                                    height: 1, color: Color(0xFFE2E8F0)),
                                const SizedBox(height: 16),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: expenseProvider.items.length,
                                  itemBuilder: (context, index) {
                                    final item = expenseProvider.items[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.itemMaterialName,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        const Color(0xFF1E293B),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Qty: ${item.quantity}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 12,
                                                    color:
                                                        const Color(0xFF64748B),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Price Range: ₹${item.priceFrom.isEmpty ? "0" : item.priceFrom} - ₹${item.priceTo.isEmpty ? "0" : item.priceTo}',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 12,
                                                    color:
                                                        const Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Color(0xFF3B82F6)),
                                            onPressed: () => expenseProvider
                                                .populateItemFieldsForEditing(
                                                    index),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 20,
                                                color: Color(0xFFEF4444)),
                                            onPressed: () => expenseProvider
                                                .deleteItem(index),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              Container(
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
                child: Row(
                  mainAxisAlignment: AppStyles.isWebScreen(context)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.center,
                  children: [
                    ResponsiveButtonWrapper(
                      child: OutlinedButton(
                        onPressed: () {
                          expenseProvider.clearItemAdd();
                          expenseProvider.togglePrimaryCheckbox(false);
                          Navigator.pop(context);
                        },
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
                          final validationError =
                              validateInputs(context, expenseProvider);
                          if (validationError != null) {
                            showErrorDialog(context, validationError);
                            return;
                          }
                          expenseProvider.saveItem(widget.editId, context);
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
              ),
            ],
          ),
        ),
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
}
