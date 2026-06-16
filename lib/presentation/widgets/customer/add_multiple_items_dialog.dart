import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/added_multi_item.dart';
import 'package:vidyanexis/controller/models/item_settings_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddMultipleItemsDialog extends StatefulWidget {
  final bool isEdit;
  final List<AddedMultiItem>? initialItems;

  const AddMultipleItemsDialog({
    super.key,
    this.isEdit = false,
    this.initialItems,
  });

  @override
  State<AddMultipleItemsDialog> createState() => _AddMultipleItemsDialogState();
}

class _AddMultipleItemsDialogState extends State<AddMultipleItemsDialog> {
  int? _selectedItemId;
  String _selectedItemName = '';
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  final Map<String, TextEditingController> _priceMaterialControllers = {};
  final Map<String, TextEditingController> _qtyMaterialControllers = {};

  List<AddedMultiItem> _addedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialItems != null) {
      _addedItems = List.from(widget.initialItems!);
    }
  }

  Future<void> _addItem() async {
    if (_selectedItemId == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an item and enter quantity')));
      return;
    }

    double? mainQty = double.tryParse(_quantityController.text);
    if (mainQty == null || mainQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid quantity')));
      return;
    }

    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.getItemMaterialList(_selectedItemId!, context);

    final materials = expenseProvider.items.map((mat) {
      return ItemSettings(
        subItemId: mat.subItemId,
        itemMaterialId: mat.itemMaterialId,
        itemMaterialName: mat.itemMaterialName,
        quantity: mat.quantity * mainQty,
        price: mat.price,
        deleteStatus: mat.deleteStatus,
        specification: mat.specification,
        manufacture: mat.manufacture,
        unit: mat.unit,
        priceFrom: mat.priceFrom,
        priceTo: mat.priceTo,
        amount: mat.price * mat.quantity,
      );
    }).toList();

    setState(() {
      _addedItems.add(AddedMultiItem(
        itemId: _selectedItemId!,
        itemName: _selectedItemName,
        quantity: mainQty,
        materials: materials,
      ));

      _selectedItemId = null;
      _selectedItemName = '';
      _quantityController.text = '1';
    });
  }

  void _updateMainItemQuantity(int index, double newMainQty) {
    if (newMainQty <= 0) return;
    setState(() {
      final item = _addedItems[index];
      final oldQty = item.quantity;
      item.quantity = newMainQty;

      for (var mat in item.materials) {
        mat.quantity = (mat.quantity / oldQty) * newMainQty;
        mat.amount = mat.price * mat.quantity;
      }
    });
  }

  void _updateMaterialQuantity(int itemIndex, int matIndex, double newQty) {
    if (newQty <= 0) return;
    setState(() {
      _addedItems[itemIndex].materials[matIndex].quantity = newQty;
      _addedItems[itemIndex].materials[matIndex].amount =
          newQty * _addedItems[itemIndex].materials[matIndex].price;
    });
  }

  void _updateMaterialPrice(int itemIndex, int matIndex, double newPrice) {
    if (newPrice < 0) return;
    setState(() {
      _addedItems[itemIndex].materials[matIndex].price = newPrice;
      _addedItems[itemIndex].materials[matIndex].amount =
          newPrice * _addedItems[itemIndex].materials[matIndex].quantity;
    });
  }

  void _removeItem(int index) {
    setState(() => _addedItems.removeAt(index));
  }

  Future<void> _saveAndClose() async {
    if (_addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    final customerProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    final List<Map<String, dynamic>> itemsForApi = _addedItems.map((item) {
      return item.toJson(); // Use toJson from model
    }).toList();

    customerProvider.addMultiItems(itemsForApi);

    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    await customerDetailsProvider.fetchAndSetMaterialsForMultipleItems(
        itemsForApi, expenseProvider, context);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.93,
        constraints: const BoxConstraints(maxHeight: 780),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withAlpha(80),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Add Items',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CommonDropdown(
                      hintText: "Select Item",
                      items: expenseProvider.itemList
                          .map((e) =>
                              DropdownItem<int>(id: e.itemId, name: e.itemName))
                          .toList(),
                      onItemSelected: (id) {
                        final selected = expenseProvider.itemList
                            .firstWhere((e) => e.itemId == id);
                        setState(() {
                          _selectedItemId = selected.itemId;
                          _selectedItemName = selected.itemName;
                        });
                      },
                      selectedValue: _selectedItemId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    child: CustomTextField(
                      controller: _quantityController,
                      hintText: "Quantity",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                  Text('${_addedItems.length} item(s)',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            Expanded(
              child: _addedItems.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("No items yet",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _addedItems.length,
                      itemBuilder: (context, itemIndex) {
                        final item = _addedItems[itemIndex];
                        final mainQtyController = TextEditingController(
                            text: item.quantity.toStringAsFixed(0));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          clipBehavior:
                              Clip.antiAlias, // Important for clean corners
                          child: Column(
                            children: [
                              // Main Item Header (Blue accent)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withAlpha(50),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.itemName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 110,
                                      child: TextField(
                                        controller: mainQtyController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Qty',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onSubmitted: (val) {
                                          final qty = double.tryParse(val);
                                          if (qty != null) {
                                            _updateMainItemQuantity(
                                                itemIndex, qty);
                                          }
                                        },
                                        onChanged: (val) {
                                          final qty = double.tryParse(val);
                                          if (qty != null) {
                                            _updateMainItemQuantity(
                                                itemIndex, qty);
                                          }
                                        },
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}'))
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _removeItem(itemIndex),
                                    ),
                                  ],
                                ),
                              ),

                              // Materials Section (Grey background) - Full rounded bottom
                              if (item.materials.isNotEmpty)
                                Container(
                                  color: Colors.grey[100],
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Materials',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ...item.materials
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final matIndex = entry.key;
                                        final mat = entry.value;

                                        // Create unique key for each material
                                        final priceKey =
                                            '${itemIndex}_${matIndex}_price';
                                        final qtyKey =
                                            '${itemIndex}_${matIndex}_qty';

                                        // Reuse or create controller once
                                        final matPriceCtrl =
                                            _priceMaterialControllers
                                                .putIfAbsent(
                                                    priceKey,
                                                    () => TextEditingController(
                                                        text: mat.price
                                                            .toStringAsFixed(
                                                                2)));

                                        final matQtyCtrl =
                                            _qtyMaterialControllers.putIfAbsent(
                                                qtyKey,
                                                () => TextEditingController(
                                                    text: mat.quantity
                                                        .toStringAsFixed(2)));
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 12),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey.shade200),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    mat.itemMaterialName,
                                                    style: const TextStyle(
                                                        fontSize: 14.5),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 180,
                                                  child: TextField(
                                                    controller: matPriceCtrl,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      labelText: 'Price',
                                                      isDense: true,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 8),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onSubmitted: (val) {
                                                      final price =
                                                          double.tryParse(val);
                                                      if (price != null) {
                                                        _updateMaterialPrice(
                                                            itemIndex,
                                                            matIndex,
                                                            price);
                                                      }
                                                    },
                                                    onChanged: (val) {
                                                      final price =
                                                          double.tryParse(val);
                                                      if (price != null) {
                                                        _updateMaterialPrice(
                                                            itemIndex,
                                                            matIndex,
                                                            price);
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+\.?\d{0,2}'))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 90,
                                                  child: TextField(
                                                    controller: matQtyCtrl,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    decoration: InputDecoration(
                                                      labelText: 'Qty',
                                                      isDense: true,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 8),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onSubmitted: (val) {
                                                      final qty =
                                                          double.tryParse(val);
                                                      if (qty != null) {
                                                        _updateMaterialQuantity(
                                                            itemIndex,
                                                            matIndex,
                                                            qty);
                                                      }
                                                    },
                                                    onChanged: (val) {
                                                      final qty =
                                                          double.tryParse(val);
                                                      if (qty != null) {
                                                        _updateMaterialQuantity(
                                                            itemIndex,
                                                            matIndex,
                                                            qty);
                                                      }
                                                    },
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+\.?\d{0,2}'))
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                SizedBox(
                                                  width: 100,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Text(
                                                        'Amount',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.grey),
                                                      ),
                                                      Text(
                                                        (mat.amount)
                                                            .toStringAsFixed(2),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .primaryBlue,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                        widget.isEdit ? 'Update Items' : 'Save New Items',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
