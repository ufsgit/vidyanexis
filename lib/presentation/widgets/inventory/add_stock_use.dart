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
import 'package:vidyanexis/controller/settings_provider.dart';

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

  final ValueNotifier<Map<String, List<MapEntry<int, StockUseItems>>>>
      _groupedNotifier = ValueNotifier({});

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

  void _exportCheckedItems(StockUseProvider provider, bool isAdvanced) {
    final checkedItems =
        provider.stockUseItems.where((item) => item.isChecked).toList();

    if (checkedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected to export')),
      );
      return;
    }

    if (isAdvanced) {
      exportToExcel(
        headers: [
          'Item Name',
          'Category',
          'Unit',
          'Serial No',
          'Remarks',
          'Qty In',
          'Qty Out',
          'Qty Balance',
          'Quantity',
          'Amount',
        ],
        data: checkedItems.map((item) {
          return {
            'Item Name': item.itemName,
            'Category': item.categoryName,
            'Unit': item.unitName,
            'Serial No': item.serialNo,
            'Remarks': item.remarks,
            'Qty In': item.quantityIn,
            'Qty Out': item.quantityOut,
            'Qty Balance': item.quantityBalance,
            'Quantity': item.quantity,
            'Amount': item.amount,
          };
        }).toList(),
        fileName: 'Stock_Use_Checked_Items_Export',
      );
    } else {
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
  }

  void _updateFilteredList(StockUseProvider provider, bool isAdvanced) {
    final query = _searchQuery.toLowerCase();
    final items = provider.stockUseItems;

    final Map<String, List<MapEntry<int, StockUseItems>>> grouped = {};

    for (int i = 0; i < items.length; i++) {
      final item = items[i];

      // Apply search filter
      if (query.isNotEmpty) {
        bool matches = item.itemName.toLowerCase().contains(query) ||
            item.categoryName.toLowerCase().contains(query) ||
            item.unitName.toLowerCase().contains(query);

        if (isAdvanced) {
          matches = matches ||
              item.serialNo.toLowerCase().contains(query) ||
              item.remarks.toLowerCase().contains(query);
        }

        if (!matches) continue;
      }

      final category =
          item.categoryName.isEmpty ? 'Uncategorized' : item.categoryName;

      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(MapEntry(i, item));
    }

    // Optional: sort categories alphabetically
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    _groupedNotifier.value = sorted;
  }

  void _onSearchChanged(
      String value, StockUseProvider provider, bool isAdvanced) {
    _searchQuery = value.trim();
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _updateFilteredList(provider, isAdvanced);
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
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        _updateFilteredList(
            expenseProvider, settingsProvider.c9xchecklist == 1);
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
    _groupedNotifier.dispose();
    _isLoadingItems.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<StockUseProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool isAdvanced = settingsProvider.c9xchecklist == 1;
    final bool isWeb = AppStyles.isWebScreen(context);

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
          width: isWeb ? 1100 : double.infinity,
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

                      // ── Basic Info ───────────────────────────────────────
                      if (isWeb)
                        // NEW: single row on web
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    expenseProvider.suDateController.text =
                                        DateFormat('dd MMM yyyy')
                                            .format(picked);
                                  }
                                },
                                readOnly: true,
                                height: 56,
                                controller: expenseProvider.suDateController,
                                hintText: 'Date',
                                suffixIcon: const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 20),
                                labelText: '',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: CustomTextField(
                                readOnly: false,
                                height: 56,
                                controller:
                                    expenseProvider.suDescriptionController,
                                hintText: 'Description',
                                labelText: '',
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: customerDetailsProvider
                                        .selectedStockStatus ??
                                    'Pending',
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Pending', child: Text('Pending')),
                                  DropdownMenuItem(
                                      value: 'Approved',
                                      child: Text('Approved')),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    customerDetailsProvider
                                        .updateStockStatus(newValue);
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
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                        color: Color(0xFF3B82F6)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        // OLD layout (or advanced on mobile)
                        Column(
                          children: [
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
                              suffixIcon: const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 20),
                              labelText: '',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              readOnly: false,
                              height: 56,
                              controller:
                                  expenseProvider.suDescriptionController,
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
                                  customerDetailsProvider
                                      .updateStockStatus(newValue);
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
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF3B82F6)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                              ),
                            ),
                          ],
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
                        onChanged: (value) => _onSearchChanged(
                            value, expenseProvider, isAdvanced),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: isAdvanced
                              ? 'Search by item, category, unit, serial or remarks...'
                              : 'Search by item, category or unit...',
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
                            valueListenable: _groupedNotifier,
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
                                  _updateFilteredList(
                                      expenseProvider, isAdvanced);
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

                      // Items list
                      ValueListenableBuilder<
                          Map<String, List<MapEntry<int, StockUseItems>>>>(
                        valueListenable: _groupedNotifier,
                        builder: (context, groupedItems, _) {
                          if (groupedItems.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
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

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupedItems.length,
                            itemBuilder: (context, categoryIndex) {
                              final category =
                                  groupedItems.keys.elementAt(categoryIndex);
                              final entries = groupedItems[category]!;

                              return Container(
                                margin: EdgeInsets.only(
                                  bottom:
                                      categoryIndex == groupedItems.length - 1
                                          ? 0
                                          : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category Header
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Color(0xFFE2E8F0)),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              category,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF3B82F6),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '${entries.length} item${entries.length > 1 ? 's' : ''}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Items
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 8),
                                      child: Column(
                                        children: entries.map((entry) {
                                          final originalIndex = entry.key;
                                          final item = entry.value;

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10),
                                            child: isAdvanced
                                                ? _AdvancedItemTile(
                                                    item: item,
                                                    isWeb: isWeb,
                                                    onCheckChanged: (value) {
                                                      expenseProvider
                                                          .toggleItemCheck(
                                                              originalIndex,
                                                              value ?? false);
                                                      _updateFilteredList(
                                                          expenseProvider,
                                                          true);
                                                    },
                                                    onQuantityChanged: (value) {
                                                      expenseProvider
                                                          .updateItemQuantity(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onSerialNoChanged: (value) {
                                                      expenseProvider
                                                          .updateItemSerialNo(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onRemarksChanged: (value) {
                                                      expenseProvider
                                                          .updateItemRemarks(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onQtyInChanged: (value) {
                                                      expenseProvider
                                                          .updateItemQtyIn(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onQtyOutChanged: (value) {
                                                      expenseProvider
                                                          .updateItemQtyOut(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onQtyBalanceChanged:
                                                        (value) {
                                                      expenseProvider
                                                          .updateItemQtyBalance(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onDelete: () {
                                                      expenseProvider
                                                          .deleteStockUseItem(
                                                              originalIndex);
                                                      _updateFilteredList(
                                                          expenseProvider,
                                                          true);
                                                    },
                                                  )
                                                : _ItemTile(
                                                    item: item,
                                                    onCheckChanged: (value) {
                                                      expenseProvider
                                                          .toggleItemCheck(
                                                              originalIndex,
                                                              value ?? false);
                                                      _updateFilteredList(
                                                          expenseProvider,
                                                          false);
                                                    },
                                                    onQuantityChanged: (value) {
                                                      expenseProvider
                                                          .updateItemQuantity(
                                                              originalIndex,
                                                              value);
                                                    },
                                                    onDelete: () {
                                                      expenseProvider
                                                          .deleteStockUseItem(
                                                              originalIndex);
                                                      _updateFilteredList(
                                                          expenseProvider,
                                                          false);
                                                    },
                                                  ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20 : 12,
                  vertical: 16,
                ),
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
                  mainAxisAlignment:
                      isWeb ? MainAxisAlignment.end : MainAxisAlignment.center,
                  children: [
                    ResponsiveButtonWrapper(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: isWeb ? 16 : 8,
                          ),
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
                    const SizedBox(width: 8),
                    ResponsiveButtonWrapper(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _exportCheckedItems(expenseProvider, isAdvanced),
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
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: isWeb ? 16 : 6,
                          ),
                          side: BorderSide(color: AppColors.secondaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          padding: EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: isWeb ? 16 : 8,
                          ),
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 22),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${item.total}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Qty: ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(
                        width: 65,
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 6),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4)),
                            isDense: true,
                          ),
                          onChanged: onQuantityChanged,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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

class _AdvancedItemTile extends StatefulWidget {
  final StockUseItems item;
  final bool isWeb;
  final ValueChanged<bool?> onCheckChanged;
  final ValueChanged<String> onQuantityChanged;
  final ValueChanged<String> onSerialNoChanged;
  final ValueChanged<String> onRemarksChanged;
  final ValueChanged<String> onQtyInChanged;
  final ValueChanged<String> onQtyOutChanged;
  final ValueChanged<String> onQtyBalanceChanged;
  final VoidCallback onDelete;

  const _AdvancedItemTile({
    required this.item,
    required this.isWeb,
    required this.onCheckChanged,
    required this.onQuantityChanged,
    required this.onSerialNoChanged,
    required this.onRemarksChanged,
    required this.onQtyInChanged,
    required this.onQtyOutChanged,
    required this.onQtyBalanceChanged,
    required this.onDelete,
  });

  @override
  State<_AdvancedItemTile> createState() => _AdvancedItemTileState();
}

class _AdvancedItemTileState extends State<_AdvancedItemTile> {
  late TextEditingController _serialController;
  late TextEditingController _remarksController;
  late TextEditingController _qtyInController;
  late TextEditingController _qtyOutController;
  late TextEditingController _balanceController;
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _serialController = TextEditingController(text: widget.item.serialNo);
    _remarksController = TextEditingController(text: widget.item.remarks);
    _qtyInController = TextEditingController(
        text: widget.item.quantityIn == 0
            ? ''
            : widget.item.quantityIn.toString());
    _qtyOutController = TextEditingController(
        text: widget.item.quantityOut == 0
            ? ''
            : widget.item.quantityOut.toString());
    _balanceController = TextEditingController(
        text: widget.item.quantityBalance == 0
            ? ''
            : widget.item.quantityBalance.toString());
    _qtyController = TextEditingController(
        text: widget.item.quantity == 0 ? '' : widget.item.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant _AdvancedItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update controllers when the underlying data really changed from outside
    // (e.g. after loading edit data). Never while the user is typing.
    if (oldWidget.item.itemId != widget.item.itemId) {
      _serialController.text = widget.item.serialNo;
      _remarksController.text = widget.item.remarks;
      _qtyInController.text =
          widget.item.quantityIn == 0 ? '' : widget.item.quantityIn.toString();
      _qtyOutController.text = widget.item.quantityOut == 0
          ? ''
          : widget.item.quantityOut.toString();
      _balanceController.text = widget.item.quantityBalance == 0
          ? ''
          : widget.item.quantityBalance.toString();
      _qtyController.text =
          widget.item.quantity == 0 ? '' : widget.item.quantity.toString();
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _remarksController.dispose();
    _qtyInController.dispose();
    _qtyOutController.dispose();
    _balanceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      filled: readOnly,
      fillColor: readOnly ? const Color(0xFFF8FAFC) : null,
      isDense: true,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF64748B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final item = widget.item;

    // ────────────────────────── MOBILE ──────────────────────────
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isChecked ? const Color(0xFFF0F7FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: item.isChecked
                ? const Color(0xFF3B82F6)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: item.isChecked,
                    onChanged: widget.onCheckChanged,
                    activeColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 6),
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
                      if (item.unitName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.unitName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 22),
                  onPressed: widget.onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Serial No
            TextFormField(
              controller: _serialController,
              onChanged: widget.onSerialNoChanged,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: _fieldDecoration(
                label: 'Serial No',
                hint: 'Enter serial number',
              ),
            ),
            const SizedBox(height: 12),

            // Remarks
            TextFormField(
              controller: _remarksController,
              onChanged: widget.onRemarksChanged,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: _fieldDecoration(
                label: 'Remarks',
                hint: 'Any notes…',
              ),
            ),
            const SizedBox(height: 12),

            // Qty In / Qty Out
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyInController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    onChanged: widget.onQtyInChanged,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: _fieldDecoration(label: 'Qty In'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _qtyOutController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    onChanged: widget.onQtyOutChanged,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: _fieldDecoration(label: 'Qty Out'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Balance + Quantity
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _balanceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    onChanged: widget.onQtyBalanceChanged,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: _fieldDecoration(label: 'Balance'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    onChanged: widget.onQuantityChanged,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: _fieldDecoration(label: 'Count'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ────────────────────────── WEB ──────────────────────────
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: item.isChecked ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isChecked
              ? const Color(0xFF3B82F6)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: item.isChecked,
                  onChanged: widget.onCheckChanged,
                  activeColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.itemName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (item.unitName.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.unitName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444), size: 22),
                onPressed: widget.onDelete,
                tooltip: 'Remove item',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Fields
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _serialController,
                  onChanged: widget.onSerialNoChanged,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: _fieldDecoration(
                    label: 'Serial No',
                    hint: 'Enter serial number',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: TextFormField(
                  controller: _remarksController,
                  onChanged: widget.onRemarksChanged,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                  decoration: _fieldDecoration(
                    label: 'Remarks',
                    hint: 'Any notes…',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _qtyInController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: widget.onQtyInChanged,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _fieldDecoration(label: 'Qty In'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _qtyOutController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: widget.onQtyOutChanged,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _fieldDecoration(label: 'Qty Out'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _balanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: widget.onQtyBalanceChanged,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _fieldDecoration(label: 'Balance'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  onChanged: widget.onQuantityChanged,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  decoration: _fieldDecoration(label: 'Count'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
