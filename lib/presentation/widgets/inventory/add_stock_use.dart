import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stock_use_provider.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import '../../../constants/app_colors.dart';
import '../../../controller/customer_details_provider.dart';
import '../../../controller/models/stock_model.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/common/responsive_button_wrapper.dart';
import '../home/custom_button_widget.dart';
import '../home/custom_dropdown_widget.dart';
import '../home/custom_text_field.dart';

class AddStockUseWidget extends StatefulWidget {
  final bool isEdit;
  final StockUseModel? stockUse;
  final int editId;
  final int customerId;

  const AddStockUseWidget({
    super.key,
    required this.isEdit,
    this.stockUse,
    required this.editId,
    required this.customerId,
  });

  @override
  State<AddStockUseWidget> createState() => _AddStockUseWidgetState();
}

class _AddStockUseWidgetState extends State<AddStockUseWidget> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final ValueNotifier<List<MapEntry<int, StockUseItems>>> _filteredNotifier =
      ValueNotifier([]);

  final ValueNotifier<bool> _isLoadingItems = ValueNotifier(true);

  String _searchQuery = '';

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
            style: const TextStyle(color: Colors.black87, fontSize: 16),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  void _exportCheckedItems(StockUseProvider provider) {
    final checkedItems =
        provider.stockUseItems.where((item) => item.isChecked).toList();

    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected to export')),
      );
      return;
    }

    exportToExcel(
      headers: ['Item Name', 'Category', 'Unit', 'Quantity', 'Amount'],
      data: checkedItems.map((item) {
        return {
          'Item Name': item.itemName,
          'Category': item.categoryName,
          'Unit': item.unitName,
          'Quantity': item.quantity,
          'Amount': item.amount,
        };
      }).toList(),
      fileName: 'Stock_Use_Checked_Items_Export',
    );
  }

  void _updateFilteredList(StockUseProvider provider) {
    final query = _searchQuery.toLowerCase();
    final items = provider.stockUseItems;
    final List<MapEntry<int, StockUseItems>> result = [];

    if (query.isEmpty) {
      for (int i = 0; i < items.length; i++) {
        result.add(MapEntry(i, items[i]));
      }
    } else {
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        if (item.itemName.toLowerCase().contains(query) ||
            item.categoryName.toLowerCase().contains(query) ||
            item.unitName.toLowerCase().contains(query)) {
          result.add(MapEntry(i, item));
        }
      }
    }
    _filteredNotifier.value = result;
  }

  void _onSearchChanged(String value, StockUseProvider provider) {
    _searchQuery = value.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _updateFilteredList(provider);
    });
  }

  Future<void> _loadData() async {
    final expenseProvider =
        Provider.of<StockUseProvider>(context, listen: false);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    try {
      // Load items
      await expenseProvider.searchItemListStock(context);

      if (widget.isEdit) {
        await expenseProvider.getStockUseDetails(
          context: context,
          masterId: widget.editId.toString(),
        );

        // Set form fields (safe even if widget is still mounted)
        if (mounted) {
          expenseProvider.suDateController.text = widget.stockUse!.date;
          expenseProvider.suDescriptionController.text =
              widget.stockUse!.description;
          customerDetailsProvider
              .updateStockStatus(widget.stockUse!.stockStatus ?? 'Pending');
        }
      } else {
        expenseProvider.clearStockUseForm();
        customerDetailsProvider.updateStockStatus('Pending');
      }

      if (mounted) {
        _updateFilteredList(expenseProvider);
      }
    } catch (e) {
      debugPrint('Error loading stock use data: $e');
    } finally {
      if (mounted) {
        _isLoadingItems.value = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Pre-fill date/description immediately for edit mode (no waiting)
    if (widget.isEdit && widget.stockUse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final expenseProvider =
            Provider.of<StockUseProvider>(context, listen: false);
        final customerDetailsProvider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);

        expenseProvider.suDateController.text = widget.stockUse!.date;
        expenseProvider.suDescriptionController.text =
            widget.stockUse!.description;
        customerDetailsProvider
            .updateStockStatus(widget.stockUse!.stockStatus ?? 'Pending');
      });
    }

    // Load data in background – page opens instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _filteredNotifier.dispose();
    _isLoadingItems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<StockUseProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          widget.isEdit ? 'Edit Check list' : 'Add Check list',
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
        child: SizedBox(
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
                            expenseProvider.suDateController.text =
                                DateFormat('dd MMM yyyy').format(picked);
                          }
                        },
                        readOnly: true,
                        height: 56,
                        controller: expenseProvider.suDateController,
                        hintText: 'Date',
                        suffixIcon:
                            const Icon(Icons.calendar_today_rounded, size: 20),
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
                        initialValue:
                            customerDetailsProvider.selectedStockStatus ??
                                'Pending',
                        items: const [
                          DropdownMenuItem(
                              value: 'Pending', child: Text('Pending')),
                          DropdownMenuItem(
                              value: 'Approved', child: Text('Approved')),
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
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Items header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Items'),
                          Consumer<StockUseProvider>(
                            builder: (context, provider, _) {
                              final count = provider.stockUseItems
                                  .where((item) => item.isChecked)
                                  .length;
                              return Text(
                                '$count Selected',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryBlue,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Search
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            _onSearchChanged(value, expenseProvider),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by item, category or unit...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF64748B),
                            size: 22,
                          ),
                          suffixIcon: ValueListenableBuilder(
                            valueListenable: _filteredNotifier,
                            builder: (context, _, __) {
                              if (_searchQuery.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    size: 20, color: Color(0xFF64748B)),
                                onPressed: () {
                                  _searchController.clear();
                                  _debounce?.cancel();
                                  _searchQuery = '';
                                  _updateFilteredList(expenseProvider);
                                },
                              );
                            },
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Color(0xFF3B82F6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Items list / loading indicator
                      ValueListenableBuilder<bool>(
                        valueListenable: _isLoadingItems,
                        builder: (context, isLoading, _) {
                          if (isLoading) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Color(0xFF3B82F6),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Loading items...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ValueListenableBuilder<
                              List<MapEntry<int, StockUseItems>>>(
                            valueListenable: _filteredNotifier,
                            builder: (context, filteredEntries, _) {
                              if (filteredEntries.isEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                    child: Text(
                                      _searchQuery.isEmpty
                                          ? 'No items available'
                                          : 'No items match your search',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredEntries.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = filteredEntries[index];
                                  final originalIndex = entry.key;
                                  final item = entry.value;

                                  return _ItemTile(
                                    item: item,
                                    onCheckChanged: (value) {
                                      expenseProvider.toggleItemCheck(
                                          originalIndex, value ?? false);
                                      _updateFilteredList(expenseProvider);
                                    },
                                    onQuantityChanged: (value) {
                                      expenseProvider.updateItemQuantity(
                                          originalIndex, value);
                                    },
                                    onDelete: () {
                                      expenseProvider
                                          .deleteStockUseItem(originalIndex);
                                      _updateFilteredList(expenseProvider);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Bottom buttons
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
                    const SizedBox(width: 12),
                    ResponsiveButtonWrapper(
                      child: OutlinedButton.icon(
                        onPressed: () => _exportCheckedItems(expenseProvider),
                        icon:
                            const Icon(Icons.file_download_outlined, size: 18),
                        label: Text(
                          'Export',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.secondaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ResponsiveButtonWrapper(
                      child: ElevatedButton(
                        onPressed: () async {
                          final validationError =
                              validateInputs(context, expenseProvider);
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

class _ItemTile extends StatelessWidget {
  final StockUseItems item;
  final ValueChanged<bool?> onCheckChanged;
  final ValueChanged<String> onQuantityChanged;
  final VoidCallback onDelete;

  const _ItemTile({
    required this.item,
    required this.onCheckChanged,
    required this.onQuantityChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isChecked ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: item.isChecked
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: item.isChecked,
              onChanged: onCheckChanged,
              activeColor: const Color(0xFF3B82F6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
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
                const SizedBox(height: 2),
                Text(
                  [
                    if (item.categoryName.isNotEmpty) item.categoryName,
                    if (item.unitName.isNotEmpty) item.unitName,
                  ].join(' • '),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Total: ${item.total}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                isDense: true,
              ),
              onChanged: onQuantityChanged,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFEF4444), size: 22),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}