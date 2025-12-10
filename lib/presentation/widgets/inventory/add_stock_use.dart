import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/stock_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddStockUseWidget extends StatefulWidget {
  final bool isEdit;
  final StockUseModel? stockUse;
  final int editId;

  const AddStockUseWidget({
    super.key,
    required this.isEdit,
    this.stockUse,
    required this.editId,
  });

  @override
  State<AddStockUseWidget> createState() => _AddStockUseWidgetState();
}

class _AddStockUseWidgetState extends State<AddStockUseWidget> {
  String? validateInputs(
      BuildContext context, ExpenseProvider expenseProvider) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.searchItemListStock(context);
      if (widget.isEdit) {
        expenseProvider.suDateController.text = widget.stockUse!.date;
        expenseProvider.suDescriptionController.text =
            widget.stockUse!.description;
        expenseProvider.suDateController.text = widget.stockUse!.date;
        expenseProvider.stockUseItems = widget.stockUse!.items;
      } else {
        expenseProvider.suDateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());

        expenseProvider.suDescriptionController.clear();
        expenseProvider.suDateController.clear();
        expenseProvider.stockUseItems.clear();
        expenseProvider.resetStockUseForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    // final provider = Provider.of<SettingsProvider>(context);

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
                            readOnly: true,
                            height: 54,
                            controller: expenseProvider.suUnitPriceController,
                            hintText: 'Sale Rate',
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
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.itemName + " (${item.categoryName})",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Qty: ${item.quantity.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Sale Rate: ₹${item.unitPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                'Amount: ₹${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 15),
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

            expenseProvider.saveStockUse(widget.editId, context);
          },
          backgroundColor: AppColors.appViolet,
          borderColor: AppColors.appViolet,
          textColor: AppColors.whiteColor,
        ),
      ],
    );
  }
}
