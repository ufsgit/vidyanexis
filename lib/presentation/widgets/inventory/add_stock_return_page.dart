import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stockreturn_provider.dart';

import '../../../constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import '../../../controller/models/stock_return_model.dart';
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
    if (!expenseProvider.stockReturnItems.any((item) => item.isChecked)) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<StockreturnProvider>(context, listen: false);

      // Load ALL items first
      await expenseProvider.searchItemListStock(context);

      if (widget.isEdit) {
        // Load specific details and merge with ALL items
        await expenseProvider.getStockReturnDetails(
            context: context, masterId: widget.editId.toString());
        expenseProvider.returnDateController.text = widget.stockUse!.returnDate;
        expenseProvider.returnDescriptionController.text =
            widget.stockUse!.description;
      } else {
        expenseProvider.clearStockReturnForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<StockreturnProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Stock Return' : 'Add Stock Return',
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
                    height: 56,
                    controller: expenseProvider.returnDateController,
                    hintText: 'Return Date',
                    suffixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                    labelText: '',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    readOnly: false,
                    height: 56,
                    controller: expenseProvider.returnDescriptionController,
                    hintText: 'Description',
                    labelText: '',
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Items'),
                      Text(
                        '${expenseProvider.stockReturnItems.where((item) => item.isChecked).length} Selected',
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
                    itemCount: expenseProvider.stockReturnItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = expenseProvider.stockReturnItems[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isChecked ? const Color(0xFFF0F7FF) : Colors.white,
                          borderRadius: BorderRadius.circular(4),
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
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
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
                                expenseProvider.deleteStockReturnItem(index);
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
              mainAxisAlignment: AppStyles.isWebScreen(context) ? MainAxisAlignment.end : MainAxisAlignment.center,
              children: [
                ResponsiveButtonWrapper(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                      final validationError = validateInputs(context, expenseProvider);
                      if (validationError != null) {
                        showErrorDialog(context, validationError);
                        return;
                      }
                      expenseProvider.saveStockReturn(
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
