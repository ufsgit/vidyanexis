import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class EditBomItemDialog extends StatefulWidget {
  final int index;
  final bool isEdit;

  const EditBomItemDialog({
    super.key,
    required this.index,
    this.isEdit = true,
  });

  @override
  State<EditBomItemDialog> createState() => _EditBomItemDialogState();
}

class _EditBomItemDialogState extends State<EditBomItemDialog> {
  // Tracks the selected item id & name when dropdown mode is active
  int? _selectedItemId;
  String _selectedItemName = '';

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    // Pre-populate selected item id when editing
    if (widget.isEdit) {
      if (provider.selectedBomItemId != 0) {
        _selectedItemId = provider.selectedBomItemId;
        _selectedItemName = provider.selectedBomItemName;
      } else if (provider.billdistributorController.text.isNotEmpty) {
        try {
          final match = expenseProvider.itemList.firstWhere(
            (item) =>
                item.itemName.trim().toLowerCase() ==
                provider.billdistributorController.text.trim().toLowerCase(),
          );
          _selectedItemId = match.itemId;
          _selectedItemName = match.itemName;
          provider.selectedBomItemId = match.itemId;
          provider.selectedBomItemName = match.itemName;
        } catch (_) {}
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load items list if permission 60 is active and list is empty
      if (settingsProvider.itemDropdownInQuotation == 1 &&
          expenseProvider.itemList.isEmpty) {
        expenseProvider.searchItemList(context: context, isFilter: false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final companyQuotationItems =
        settingsProvider.companyDetails.isNotEmpty &&
            settingsProvider.companyDetails.first.quotationItemValue == 1;

    // permission 60 == 1 → Manufacturer field is a dropdown from items list
    final bool useItemDropdown = settingsProvider.itemDropdownInQuotation == 1;

    // Auto-resolve selected item when itemList loads asynchronously for editing
    if (useItemDropdown &&
        _selectedItemId == null &&
        provider.billdistributorController.text.isNotEmpty &&
        expenseProvider.itemList.isNotEmpty) {
      try {
        final match = expenseProvider.itemList.firstWhere(
          (item) =>
              item.itemName.trim().toLowerCase() ==
              provider.billdistributorController.text.trim().toLowerCase(),
        );
        _selectedItemId = match.itemId;
        _selectedItemName = match.itemName;
        provider.selectedBomItemId = match.itemId;
        provider.selectedBomItemName = match.itemName;
      } catch (_) {}
    }

    // Find the selected unit ID based on the text in the controller
    int? selectedUnitId;
    if (provider.billuomController.text.isNotEmpty) {
      try {
        selectedUnitId = settingsProvider.searchUnit
            .firstWhere(
              (u) => u.unitName == provider.billuomController.text,
            )
            .unitId;
      } catch (e) {
        // Unit not found in the list
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEdit ? 'Edit Material' : 'Add Material',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Equipment field
              if (provider.isQuotationFieldVisible(10)) ...[
                CustomTextField(
                  controller: provider.billdescriptionController,
                  labelText: provider.getQuotationFieldName(10, 'Equipment'),
                  hintText: provider.getQuotationFieldName(10, 'Equipment'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 16),
              ],

              // Specification field
              if (provider.isQuotationFieldVisible(11)) ...[
                CustomTextField(
                  controller: provider.billmakeController,
                  labelText: provider.getQuotationFieldName(11, 'Specification'),
                  hintText: provider.getQuotationFieldName(11, 'Specification'),
                  height: 54,
                  borderRadius: 12,
                  borderColor: const Color(0xFFD0D5DD),
                  focusedBorderColor: AppColors.bluebutton,
                ),
                const SizedBox(height: 16),
              ],

              // Quantity field
              Row(
                children: [
                  if (provider.isQuotationFieldVisible(12)) ...[
                    Expanded(
                      child: CustomTextField(
                        controller: provider.billquantityController,
                        labelText:
                            provider.getQuotationFieldName(12, 'Quantity'),
                        hintText:
                            provider.getQuotationFieldName(12, 'Quantity'),
                        height: 54,
                        borderRadius: 12,
                        borderColor: const Color(0xFFD0D5DD),
                        focusedBorderColor: AppColors.bluebutton,
                        onChanged: (value) {
                          if (companyQuotationItems) {
                            provider.companyQuotationItemsCalulate(context);
                          }
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Manufacturer — dropdown when permission 60 == 1, else text field
              if (provider.isQuotationFieldVisible(13)) ...[
                if (useItemDropdown) ...[
                  // DROPDOWN from items API
                  CommonDropdown<int>(
                    hintText:
                        provider.getQuotationFieldName(13, 'Manufacturer'),
                    items: expenseProvider.itemList
                        .map((item) => DropdownItem<int>(
                              id: item.itemId,
                              name: item.itemName,
                            ))
                        .toList(),
                    selectedValue: _selectedItemId,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                    onItemSelected: (int selectedId) {
                      final selected = expenseProvider.itemList.firstWhere(
                        (item) => item.itemId == selectedId,
                        orElse: () => expenseProvider.itemList.first,
                      );
                      setState(() {
                        _selectedItemId = selectedId;
                        _selectedItemName = selected.itemName;
                      });
                      // Also write to the text controller so the value
                      // is visible and available if needed
                      provider.billdistributorController.text =
                          selected.itemName;
                      // Store in provider for save
                      provider.selectedBomItemId = selectedId;
                      provider.selectedBomItemName = selected.itemName;
                    },
                  ),
                ] else ...[
                  // PLAIN TEXT FIELD (permission 60 == 0)
                  CustomTextField(
                    controller: provider.billdistributorController,
                    labelText:
                        provider.getQuotationFieldName(13, 'Manufacturer'),
                    hintText:
                        provider.getQuotationFieldName(13, 'Manufacturer'),
                    height: 54,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Price / Amount / Unit (only when companyQuotationItems == true)
              if (companyQuotationItems) ...[
                if (provider.isQuotationFieldVisible(17)) ...[
                  CustomTextField(
                    controller: provider.billuomController,
                    labelText: provider.getQuotationFieldName(17, 'Unit'),
                    hintText: provider.getQuotationFieldName(17, 'Unit'),
                    height: 54,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                  ),
                  const SizedBox(height: 16),
                ],
                if (provider.isQuotationFieldVisible(15)) ...[
                  CustomTextField(
                    controller: provider.billpriceController,
                    labelText: provider.getQuotationFieldName(15, 'Price'),
                    hintText: provider.getQuotationFieldName(15, 'Price'),
                    height: 54,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      if (companyQuotationItems) {
                        provider.companyQuotationItemsCalulate(context);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                if (provider.isQuotationFieldVisible(16)) ...[
                  CustomTextField(
                    controller: provider.billamountController,
                    labelText: provider.getQuotationFieldName(16, 'Amount'),
                    hintText: provider.getQuotationFieldName(16, 'Amount'),
                    height: 54,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                    readOnly: true,
                  ),
                ],
              ] else ...[
                if (provider.isQuotationFieldVisible(14)) ...[
                  CustomTextField(
                    controller: provider.billinvoiceController,
                    labelText: provider.getQuotationFieldName(14, 'Comments'),
                    hintText: provider.getQuotationFieldName(14, 'Comments'),
                    height: 54,
                    borderRadius: 12,
                    borderColor: const Color(0xFFD0D5DD),
                    focusedBorderColor: AppColors.bluebutton,
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.isEdit) ...[
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Delete',
                        onPressed: () =>
                            _showDeleteConfirmation(context, provider),
                        backgroundColor: Colors.white,
                        borderColor: Colors.red[400]!,
                        textColor: Colors.red[400]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomElevatedButton(
                      buttonText: 'Save',
                      onPressed: () {
                        // Set item id & name for Bill of Materials
                        if (_selectedItemId != null && _selectedItemId != 0) {
                          provider.selectedBomItemId = _selectedItemId!;
                          provider.selectedBomItemName = _selectedItemName;
                        } else if (provider.billdistributorController.text.isNotEmpty) {
                          try {
                            final match = expenseProvider.itemList.firstWhere(
                              (item) =>
                                  item.itemName.trim().toLowerCase() ==
                                  provider.billdistributorController.text.trim().toLowerCase(),
                            );
                            provider.selectedBomItemId = match.itemId;
                            provider.selectedBomItemName = match.itemName;
                          } catch (_) {
                            provider.selectedBomItemId = 0;
                            provider.selectedBomItemName =
                                provider.billdistributorController.text.trim();
                          }
                        } else {
                          provider.selectedBomItemId = 0;
                          provider.selectedBomItemName = '';
                        }
                        provider.addOrEditBillOfMaterialsItem();
                        if (companyQuotationItems) {
                          provider.companyQuotationItemsCalulate(context);
                        }
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.appViolet,
                      borderColor: AppColors.appViolet,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, CustomerDetailsProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete this material?',
            style: GoogleFonts.plusJakartaSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteBillOfMaterialsItem(widget.index);
                Navigator.pop(context); // Close confirm
                Navigator.pop(context); // Close dialog
              },
              child: Text(
                'Delete',
                style: GoogleFonts.plusJakartaSans(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
