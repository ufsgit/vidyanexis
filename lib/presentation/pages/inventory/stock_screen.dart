import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class StockScreen extends StatefulWidget {
  final int editId;
  final bool isEdit;

  const StockScreen({
    super.key,
    required this.editId,
    required this.isEdit,
  });

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.setSearchCriteria(
        '',
        '',
        '',
        '',
      );
      customerProvider.getSearchCustomers(context);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.searchStockList(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    const double minContentWidth = 800.0;
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          // width: constraints.maxWidth < minContentWidth
          //     ? minContentWidth
          //     : constraints.maxWidth,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stock Report',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlue800),
                  ),
                  const Spacer(),
                  // Container(
                  //   width: MediaQuery.of(context).size.width / 3.5,
                  //   height: 40,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(20),
                  //     border: Border.all(color: Colors.grey[300]!),
                  //   ),
                  //   child: TextField(
                  //     controller: settingsProvider.searchDocumentTypeController,
                  //     onChanged: (query) {
                  //       print(query);
                  //       settingsProvider.searchDocumentType(query, context);
                  //     },
                  //     decoration: const InputDecoration(
                  //       hintText: 'Search here....',
                  //       prefixIcon: Icon(Icons.search),
                  //       border: InputBorder.none,
                  //       contentPadding: EdgeInsets.symmetric(
                  //         horizontal: 16,
                  //         vertical: 4,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 16),
                  CustomOutlinedSvgButton(
                    onPressed: () {
                      showAddStockSheet(context);
                      setState(() {});
                    },
                    svgPath: 'assets/images/Plus.svg',
                    label: "Add Stock",
                    breakpoint: 860,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryBlue,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: expenseProvider.stockList.length,
                itemBuilder: (c, i) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20),
                      child: Column(
                        children: [
                          if (i == 0)
                            const Row(
                              children: [
                                Expanded(
                                    child: Text(
                                  "Item Name",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )),
                                Expanded(
                                    child: Text(
                                  "Category",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )),
                                Expanded(
                                    child: Text(
                                  "Quantity",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )),
                                Expanded(
                                    child: Text(
                                  "Rate",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )),
                                Expanded(
                                    child: Text(
                                  "Total Amount",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                )),
                              ],
                            ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expenseProvider.stockList[i].itemName
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                              ),
                              Expanded(
                                  child: Text(
                                expenseProvider.stockList[i].categoryName
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              )),
                              Expanded(
                                  child: Text(
                                expenseProvider.stockList[i].quantity
                                    .toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              )),
                              Expanded(
                                  child: Text(
                                expenseProvider.stockList[i].rate.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              )),
                              Expanded(
                                  child: Text(
                                expenseProvider.stockList[i].amount.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      );
    });
  }

  showAddStockSheet(BuildContext context) {
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 1200
        ? 300.0
        : screenWidth > 600
            ? 100.0
            : 20.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, child) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        const Text(
                          'Add Stock',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonDropdown<int>(
                                    hintText: 'Choose Customer*',
                                    items: customerProvider.customerData
                                        .map((status) => DropdownItem<int>(
                                              id: status.customerId,
                                              name: status.customerName,
                                            ))
                                        .toList(),
                                    controller: expenseProvider
                                        .customerNameStockController,
                                    onItemSelected: (selectedId) {
                                      expenseProvider
                                          .setSelectedCustomerId(selectedId);
                                    },
                                    selectedValue:
                                        expenseProvider.selectedCustomerId),
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(DateTime.now()),
                                  textAlign:
                                      TextAlign.end, // Formats current date
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Fields
                        SizedBox(
                          width: double.infinity,
                          child: CommonDropdown(
                            hintText: "Item",
                            items: expenseProvider.itemList
                                .map((status) => DropdownItem<int>(
                                      id: status.itemId,
                                      name: status.itemName,
                                    ))
                                .toList(),
                            controller: expenseProvider.itemNameStockController,
                            onItemSelected: (selectedItem) {
                              // Find the selected item from the itemList
                              final selectedData =
                                  expenseProvider.itemList.firstWhere(
                                (item) => item.itemId == selectedItem,
                              );
                              expenseProvider
                                  .setSelectedStockItemId(selectedItem);
                              // Update text fields with selected item details
                              expenseProvider.selectedUnitId =
                                  selectedData.unitId;
                              expenseProvider.selectedCategoryId =
                                  selectedData.categoryId;
                              expenseProvider.itemUnitStockController.text =
                                  selectedData.unitName;
                              expenseProvider.itemCategoryStockController.text =
                                  selectedData.categoryName;
                              expenseProvider.itemGstStockontroller.text =
                                  selectedData.gst;
                            },
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: true,
                            controller: expenseProvider.itemUnitStockController,
                            hintText: "Unit",
                            labelText: "Unit",
                            height: 50,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: true,
                            controller:
                                expenseProvider.itemCategoryStockController,
                            hintText: "Category",
                            labelText: "Category",
                            height: 50,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            readOnly: true,
                            controller: expenseProvider.itemGstStockontroller,
                            hintText: "GST in percentage",
                            labelText: "GST in percentage",
                            height: 50,
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            controller: expenseProvider.itemRateStockController,
                            hintText: "Rate",
                            labelText: "Rate",
                            height: 50,
                            onChanged: (v) {
                              expenseProvider.getTotalAmount(
                                rate: expenseProvider
                                    .itemRateStockController.text,
                                quantity: expenseProvider
                                    .itemQuantityStockController.text,
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          width: double.infinity,
                          child: CustomTextField(
                            controller:
                                expenseProvider.itemQuantityStockController,
                            hintText: "Quantity",
                            labelText: "Quantity",
                            height: 50,
                            onChanged: (v) {
                              expenseProvider.getTotalAmount(
                                rate: expenseProvider
                                    .itemRateStockController.text,
                                quantity: expenseProvider
                                    .itemQuantityStockController.text,
                              );
                            },
                          ),
                        ),

                        // Total Amount
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount",
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(expenseProvider.totalStockAmount,
                                  style: const TextStyle(fontSize: 18)),
                            ],
                          ),
                        ),

                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    expenseProvider.clearStockFormFields();
                                  },
                                  child: const Text("Cancel"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    final validationError = validateInputs(
                                        context, expenseProvider);
                                    if (validationError != null) {
                                      showErrorDialog(context, validationError);
                                      return;
                                    }

                                    expenseProvider.saveStock(
                                        widget.editId, context);
                                  },
                                  child: const Text("Add"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String? validateInputs(
      BuildContext context, ExpenseProvider expenseProvider) {
    if (expenseProvider.itemNameStockController.text.trim().isEmpty) {
      return 'Please enter Item name';
    }
    if (expenseProvider.itemCategoryStockController.text.trim().isEmpty) {
      return 'Please select Category';
    }
    if (expenseProvider.itemUnitStockController.text.trim().isEmpty) {
      return 'Please select Unit';
    }
    if (expenseProvider.itemGstStockontroller.text.trim().isEmpty) {
      return 'Please enter GST %';
    }
    if (expenseProvider.itemQuantityStockController.text.trim().isEmpty) {
      return 'Please enter quantity';
    }
    if (expenseProvider.customerNameStockController.text.trim().isEmpty) {
      return 'Please enter Customer name';
    }
    if (expenseProvider.itemRateStockController.text.trim().isEmpty) {
      return 'Please enter rate';
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
}
