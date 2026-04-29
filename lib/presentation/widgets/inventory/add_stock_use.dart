import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stock_use_provider.dart';
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
    if (!expenseProvider.stockUseItems.any((item) => item.isChecked)) {
      return 'Please select at least one item';
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
                initialValue:
                    customerDetailsProvider.selectedStockStatus ?? 'Pending',
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
              // Header for Grid
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                decoration: BoxDecoration(
                  color: AppColors.appViolet,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 40, child: Text('')), // Checkbox column
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Item Name',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Qty',
                        style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                        width: 40,
                        child: Text(
                          'Act',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
              // Grid Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expenseProvider.stockUseItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = expenseProvider.stockUseItems[index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    color: Colors.white,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Checkbox(
                            value: item.isChecked,
                            onChanged: (value) {
                              expenseProvider.toggleItemCheck(
                                  index, value ?? false);
                            },
                            activeColor: AppColors.appViolet,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: () {
                              expenseProvider
                                  .populateStockUseFieldsForEditing(index);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  item.categoryName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 35,
                            child: TextFormField(
                              initialValue: item.quantity.toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                expenseProvider.updateItemQuantity(
                                    index, value);
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () {
                              expenseProvider.deleteStockUseItem(index);
                            },
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
