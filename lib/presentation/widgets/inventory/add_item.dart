import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/expense_provider.dart';
import 'package:techtify/controller/models/item_list_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_field.dart';

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
    if (expenseProvider.itemUnitPriceController.text.trim().isEmpty) {
      return 'Please enter Unit Price';
    }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      expenseProvider.clearItemAdd();
      settingsProvider.searchCategoryApi('', context);
      settingsProvider.searchUnitApi('', context);
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
        expenseProvider.setItemCategory(widget.item!.categoryId);
        expenseProvider.setItemUnit(widget.item!.unitId);
        expenseProvider
            .toggleCheckbox(widget.item!.serviceCheckbox == 1 ? true : false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final provider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Item' : 'Add Item',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // expenseProvider.statusController.clear();
              // expenseProvider.folloupController.clear();
              // expenseProvider.isRegisterController.clear();
              // expenseProvider.setSelectedColor(null);
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
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.itemNameController,
                      hintText: 'Item Name*',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
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
                        controller: expenseProvider.itemCategoryController,
                        onItemSelected: (selectedId) {
                          expenseProvider.setItemCategory(selectedId);
                        },
                      ),
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
                    child: Container(
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
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.itemUnitPriceController,
                      hintText: 'Unit Price*',
                      labelText: '',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                    ),
                  ),
                ],
              ),
              //
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.itemHSNController,
                      hintText: 'HSN Code',
                      labelText: '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Spacer(),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text("Is Service"),
                        SizedBox(
                          width: 5,
                        ),
                        Checkbox(
                          value: expenseProvider.isChecked == 1,
                          onChanged: (bool? value) {
                            expenseProvider.toggleCheckbox(value ?? false);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.cgstController,
                      hintText: 'CGST %*',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (p0) {
                        int gst = (int.tryParse(
                                    expenseProvider.cgstController.text) ??
                                0) +
                            (int.tryParse(
                                    expenseProvider.sgstController.text) ??
                                0);
                        expenseProvider.igstController.text = gst.toString();
                        expenseProvider.gstController.text = gst.toString();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: false,
                      height: 54,
                      controller: expenseProvider.sgstController,
                      hintText: 'SGST %*',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (p0) {
                        int gst = (int.tryParse(
                                    expenseProvider.cgstController.text) ??
                                0) +
                            (int.tryParse(
                                    expenseProvider.sgstController.text) ??
                                0);
                        expenseProvider.igstController.text = gst.toString();
                        expenseProvider.gstController.text = gst.toString();
                      },
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
                      readOnly: true,
                      height: 54,
                      controller: expenseProvider.igstController,
                      hintText: 'IGST %*',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      readOnly: true,
                      height: 54,
                      controller: expenseProvider.gstController,
                      hintText: 'GST %*',
                      labelText: '',
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Material',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
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
                            controller: expenseProvider.itemMaterialController,
                            hintText: 'Item Material Name',
                            labelText: '',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller: expenseProvider.itemQuantityController,
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
                    const SizedBox(
                      height: 15,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        expenseProvider.addOrEditItem(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add item'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.primaryBlue, // Change foreground color
                        backgroundColor:
                            Colors.white, // Change background color
                        side: BorderSide(
                            color:
                                AppColors.primaryBlue), // Change border color
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
                    const SizedBox(
                      height: 15,
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenseProvider.items.length,
                      itemBuilder: (context, index) {
                        final item = expenseProvider.items[index];
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
                                  item.itemMaterialName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Quantity: ${item.quantity}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 5),
                              TextButton(
                                onPressed: () => expenseProvider
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
                                    expenseProvider.deleteItem(index),
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
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      actions: [
        CustomElevatedButton(
          buttonText: 'Cancel',
          onPressed: () {
            // expenseProvider.statusController.clear();
            // expenseProvider.folloupController.clear();
            // expenseProvider.isRegisterController.clear();
            // expenseProvider.setSelectedColor(null);
            expenseProvider.clearItemAdd();
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

            expenseProvider.saveItem(widget.editId, context);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
