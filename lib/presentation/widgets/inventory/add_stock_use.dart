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

      // Load ALL items first
      await expenseProvider.searchItemListStock(context);

      if (widget.isEdit) {
        // Load specific details and merge with ALL items
        await expenseProvider.getStockUseDetails(
            context: context, masterId: widget.editId.toString());

        // Set the date and description
        expenseProvider.suDateController.text = widget.stockUse!.date;
        expenseProvider.suDescriptionController.text =
            widget.stockUse!.description;

        // Set the stock status from the existing data
        customerDetailsProvider
            .updateStockStatus(widget.stockUse!.stockStatus ?? 'Pending');
      } else {
        expenseProvider.clearStockUseForm();
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
    final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Stock Use' : 'Add Stock Use',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlue800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
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
                    height: 56,
                    controller: expenseProvider.suDateController,
                    hintText: 'Date',
                    suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: expenseProvider.suDescriptionController,
                    hintText: 'Description',
                    labelText: '',
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: customerDetailsProvider.selectedStockStatus ?? 'Pending',
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Items'),
                      Text(
                        '${expenseProvider.stockUseItems.where((item) => item.isChecked).length} Selected',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenseProvider.stockUseItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = expenseProvider.stockUseItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isChecked ? const Color(0xFFF0F7FF) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: item.isChecked ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: item.isChecked,
                                onChanged: (value) {
                                  expenseProvider.toggleItemCheck(index, value ?? false);
                                },
                                activeColor: const Color(0xFF3B82F6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.itemName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.categoryName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 70,
                              child: TextFormField(
                                initialValue: item.quantity.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Qty',
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  expenseProvider.updateItemQuantity(index, value);
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                              onPressed: () {
                                expenseProvider.deleteStockUseItem(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final validationError = validateInputs(context, expenseProvider);
                      if (validationError != null) {
                        showErrorDialog(context, validationError);
                        return;
                      }
                      expenseProvider.saveStockUse(
                        widget.editId,
                        widget.customerId,
                        context,
                      );
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
}
