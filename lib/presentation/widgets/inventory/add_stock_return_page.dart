import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stockreturn_provider.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/models/stock_return_model.dart';
import '../home/custom_button_widget.dart';
import '../home/custom_dropdown_widget.dart';
import '../home/custom_text_field.dart';

class AddStockReturnPage extends StatefulWidget {
  final bool isEdit;
  final StockReturnModel? stockUse;
  final int editId;
  final int customerId;

  const AddStockReturnPage({
    super.key,
    required this.isEdit,
    this.stockUse,
    required this.editId,
    required this.customerId,
  });

  @override
  State<AddStockReturnPage> createState() => _AddStockReturnPageState();
}

class _AddStockReturnPageState extends State<AddStockReturnPage> {
  String? validateInputs(
      BuildContext context, StockreturnProvider expenseProvider) {
    if (expenseProvider.stockReturnItems.isEmpty) {
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
          Provider.of<StockreturnProvider>(context, listen: false);
      expenseProvider.searchItemListStock(context);
      if (widget.isEdit) {
        expenseProvider.returnDateController.text = widget.stockUse!.returnDate;
        expenseProvider.returnDescriptionController.text =
            widget.stockUse!.description;
        expenseProvider.stockReturnItems = widget.stockUse!.items;
      } else {
        expenseProvider.returnDateController.text =
            DateFormat('dd MMM yyyy').format(DateTime.now());

        expenseProvider.returnDescriptionController.clear();
        expenseProvider.returnDateController.clear();
        expenseProvider.stockReturnItems.clear();
        expenseProvider.resetStockReturnForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<StockreturnProvider>(context);
    // final provider = Provider.of<SettingsProvider>(context);

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Text(
            widget.isEdit ? 'Edit Stock Return' : 'Add Stock Return',
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
        width: AppStyles.isWebScreen(context)
            ? MediaQuery.sizeOf(context).width / 2
            : MediaQuery.sizeOf(context).width,
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
                    expenseProvider.returnDateController.text =
                        DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                readOnly: true,
                height: 54,
                controller: expenseProvider.returnDateController,
                hintText: 'Return Date',
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
                      expenseProvider.returnDateController.text =
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
                controller: expenseProvider.returnDescriptionController,
                hintText: 'Description ',
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
                                .where(
                                  (element) => element.primaryCheckBox == 0,
                                )
                                .map((status) => DropdownItem<int>(
                                      id: status.itemId,
                                      name: status.itemName,
                                    ))
                                .toList(),
                            controller: expenseProvider.returnItemController,
                            onItemSelected: (selectedItem) {
                              // Find the selected item from the itemListStock
                              final selectedData =
                                  expenseProvider.itemListStock.firstWhere(
                                (item) => item.itemId == selectedItem,
                              );
                              expenseProvider
                                  .setSelectedStockReturnItemId(selectedItem);
                              expenseProvider.returnItemController.text =
                                  selectedData.itemName;
                              expenseProvider.returnStockIdController.text =
                                  selectedData.stockId.toString();
                              expenseProvider.returnSaleRateController.text =
                                  selectedData.unitPrice;
                              expenseProvider.returnCategoryController.text =
                                  selectedData.categoryName.toString();
                              expenseProvider.selectedCategoryId =
                                  selectedData.categoryId;
                            },
                            selectedValue: expenseProvider.selectedItemReturnId,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            readOnly: false,
                            height: 54,
                            controller:
                                expenseProvider.returnQuantityController,
                            hintText: 'Quantity*',
                            labelText: '',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}')),
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
                            controller:
                                expenseProvider.returnCategoryController,
                            hintText: 'Category',
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
                            controller:
                                expenseProvider.returnSaleRateController,
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
                            expenseProvider.addOrEditStockReturnItem(context);
                            print(expenseProvider.stockReturnItems
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
                      itemCount: expenseProvider.stockReturnItems.length,
                      itemBuilder: (context, index) {
                        final item = expenseProvider.stockReturnItems[index];
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${item.itemName} (${item.categoryName})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Return Qty: ${item.quantity.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Sale Rate: ₹${item.unitPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Amount: ₹${item.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                onPressed: () {
                                  expenseProvider
                                      .populateStockReturnForm(index);
                                },
                                child: const Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  expenseProvider.deleteStockReturnItem(index);
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

            expenseProvider.saveStockReturn(
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
