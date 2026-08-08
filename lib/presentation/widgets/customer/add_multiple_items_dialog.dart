import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/added_multi_item.dart';
import 'package:vidyanexis/controller/models/item_list_model.dart';
import 'package:vidyanexis/controller/models/item_settings_model.dart';
import 'package:vidyanexis/presentation/widgets/home/auto_complete_textfield_search.dart';
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
  final TextEditingController _itemNameController = TextEditingController();
  FocusNode itemNode = FocusNode();

  // Controllers
  final Map<int, TextEditingController> _mainQtyControllers = {};
  final Map<int, TextEditingController> _mainMakeControllers = {};
  final Map<int, TextEditingController> _mainNameControllers = {};
  final Map<String, TextEditingController> _materialPriceControllers = {};
  final Map<String, TextEditingController> _materialQtyControllers = {};
  final Map<String, TextEditingController> _materialNameControllers = {};
  final Map<String, bool> _materialChecked = {}; // New: Checkbox state
  final Map<String, bool> _materialShowQtyChecked = {};

  List<AddedMultiItem> _addedItems = [];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialItems != null) {
      _addedItems = List.from(widget.initialItems!);
      _initializeControllersForEdit();
    }
  }

  void _initializeControllersForEdit() {
    for (int i = 0; i < _addedItems.length; i++) {
      final item = _addedItems[i];
      _mainQtyControllers[i] =
          TextEditingController(text: item.quantity.toStringAsFixed(0));
      _mainMakeControllers[i] = TextEditingController(text: item.make);
      _mainNameControllers[i] = TextEditingController(text: item.itemName);

      for (int j = 0; j < item.materials.length; j++) {
        final mat = item.materials[j];
        final key = '${i}_$j';
        _materialPriceControllers[key] =
            TextEditingController(text: mat.price.toStringAsFixed(2));
        _materialQtyControllers[key] =
            TextEditingController(text: mat.quantity.toStringAsFixed(2));
        _materialNameControllers[key] =
            TextEditingController(text: mat.itemMaterialName);
        _materialChecked[key] = mat.includeInTotal == '1' ? true : false;
        _materialShowQtyChecked[key] = mat.showQuantity == '1' ? true : false;
      }
    }
  }

  @override
  void dispose() {
    for (var c in _mainQtyControllers.values) {
      c.dispose();
    }
    for (var c in _mainMakeControllers.values) {
      c.dispose();
    }
    for (var c in _mainNameControllers.values) {
      c.dispose();
    }
    for (var c in _materialPriceControllers.values) {
      c.dispose();
    }
    for (var c in _materialQtyControllers.values) {
      c.dispose();
    }
    _quantityController.dispose();
    for (var c in _materialNameControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ================== Controller Getters ==================
  TextEditingController _getMainQtyController(int index, double value) {
    return _mainQtyControllers.putIfAbsent(
        index, () => TextEditingController(text: value.toStringAsFixed(0)));
  }

  TextEditingController _getMainMakeController(int index, String value) {
    return _mainMakeControllers.putIfAbsent(
        index, () => TextEditingController(text: value));
  }

  TextEditingController _getMainNameController(int index, String value) {
    return _mainNameControllers.putIfAbsent(
        index, () => TextEditingController(text: value));
  }

  TextEditingController _getMaterialPriceController(
      int itemIndex, int matIndex, double value) {
    final key = '${itemIndex}_$matIndex';
    return _materialPriceControllers.putIfAbsent(
        key, () => TextEditingController(text: value.toStringAsFixed(2)));
  }

  TextEditingController _getMaterialQtyController(
      int itemIndex, int matIndex, double value) {
    final key = '${itemIndex}_$matIndex';
    return _materialQtyControllers.putIfAbsent(
        key, () => TextEditingController(text: value.toStringAsFixed(2)));
  }

  TextEditingController _getMaterialNameController(
    int itemIndex,
    int matIndex,
    String value,
  ) {
    final key = '${itemIndex}_$matIndex';
    return _materialNameControllers.putIfAbsent(
      key,
      () => TextEditingController(text: value),
    );
  }

  bool _getMaterialChecked(int itemIndex, int matIndex) {
    final key = '${itemIndex}_$matIndex';

    if (_materialChecked.containsKey(key)) {
      return _materialChecked[key]!;
    }

    final mat = _addedItems[itemIndex].materials[matIndex];
    final checked = mat.includeInTotal == '1';
    _materialChecked[key] = checked;
    return checked;
  }

  bool _getMaterialShowQtyChecked(int itemIndex, int matIndex) {
    final key = '${itemIndex}_$matIndex';

    if (_materialShowQtyChecked.containsKey(key)) {
      return _materialShowQtyChecked[key]!;
    }

    final mat = _addedItems[itemIndex].materials[matIndex];
    final checked = mat.showQuantity == '1';
    _materialShowQtyChecked[key] = checked;
    return checked;
  }

  // ================== Update Methods ==================
  void _updateMainItemQuantity(int index, String val) {
    final qty = double.tryParse(val) ?? 0.0;
    if (qty <= 0) return;

    setState(() {
      final item = _addedItems[index];
      final oldQty = item.quantity;
      item.quantity = qty;

      // Update materials proportionally
      for (int matIndex = 0; matIndex < item.materials.length; matIndex++) {
        final mat = item.materials[matIndex];
        mat.quantity = (mat.quantity / oldQty) * qty;
        mat.amount = mat.price * mat.quantity;

        // Sync only material controllers
        final key = '${index}_$matIndex';
        _materialQtyControllers[key]?.text = mat.quantity.toStringAsFixed(2);
      }
      // Do NOT sync main controller here → prevents typing issue
    });
  }

  void _updateMainItemMake(int index, String val) {
    setState(() {
      final item = _addedItems[index];
      item.make = val;
    });
  }

  void _updateMainItemName(int index, String val) {
    setState(() {
      final item = _addedItems[index];
      item.itemName = val;
    });
  }

  void _updateMaterialPrice(int itemIndex, int matIndex, String val) {
    final price = double.tryParse(val) ?? 0.0;
    if (price < 0) return;

    setState(() {
      final mat = _addedItems[itemIndex].materials[matIndex];
      mat.price = price;
      mat.amount = price * mat.quantity;
    });
  }

  void _updateMaterialQuantity(int itemIndex, int matIndex, String val) {
    final qty = double.tryParse(val) ?? 0.0;
    if (qty < 0) return;

    setState(() {
      final mat = _addedItems[itemIndex].materials[matIndex];
      mat.quantity = qty;
      mat.amount = qty * mat.price;
    });
  }

  void _updateMaterialName(
    int itemIndex,
    int matIndex,
    String value,
  ) {
    setState(() {
      _addedItems[itemIndex].materials[matIndex].itemMaterialName = value;
    });
  }

  void _updateMaterialChecked(int itemIndex, int matIndex, bool? value) {
    final key = '${itemIndex}_$matIndex';
    setState(() {
      _materialChecked[key] = value ?? true;
      // Update model
      _addedItems[itemIndex].materials[matIndex].includeInTotal =
          value == true ? '1' : '0';
    });
  }

  void _updateMaterialShowQtyChecked(int itemIndex, int matIndex, bool? value) {
    final key = '${itemIndex}_$matIndex';
    setState(() {
      _materialShowQtyChecked[key] = value ?? false;
      _addedItems[itemIndex].materials[matIndex].showQuantity =
          value == true ? '1' : '0';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _mainQtyControllers.remove(index);
      _mainMakeControllers.remove(index);
      _mainNameControllers.remove(index);
      final item = _addedItems[index];
      for (int matIndex = 0; matIndex < item.materials.length; matIndex++) {
        final key = '${index}_$matIndex';
        _materialPriceControllers.remove(key);
        _materialQtyControllers.remove(key);
      }
      _addedItems.removeAt(index);
    });
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
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    await expenseProvider.getItemMultipleMaterialList(
        _selectedItemId!, context);

    if (expenseProvider.multiItems.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No items found')));
      return;
    }

    customerDetailsProvider.aggregatedPriceFrom =
        double.tryParse(expenseProvider.multiItems.first.priceFrom) ?? 0;
    customerDetailsProvider.aggregatedPriceTo =
        double.tryParse(expenseProvider.multiItems.first.priceTo) ?? 0;

    setState(() {
      for (final mainItem in expenseProvider.multiItems) {
        final materials = mainItem.multiItemMaterials.map((mat) {
          final scaledQty = mat.quantity * mainQty;
          return ItemSettings(
            subItemId: mat.subItemId,
            itemMaterialId: mat.itemMaterialId,
            itemMaterialName: mat.itemMaterialName,
            quantity: scaledQty,
            price: mat.price,
            deleteStatus: mat.deleteStatus,
            specification: mat.specification,
            manufacture: mat.manufacture,
            unit: mat.unit,
            priceFrom: mat.priceFrom,
            priceTo: mat.priceTo,
            amount: mat.price * scaledQty,
            includeInTotal: mat.includeInTotal,
            itemTypeId: mat.itemTypeId,
            showQuantity: mat.showQuantity,
          );
        }).toList();

        _addedItems.add(AddedMultiItem(
          itemId: mainItem.itemId,
          itemName: mainItem.itemName,
          quantity: mainQty,
          make: mainItem.hsnCode,
          unitName: mainItem.unitName,
          materials: materials,
          itemTypeId: mainItem.primaryCheckBox.toString(),
        ));
      }

      _selectedItemId = null;
      _selectedItemName = '';
      _quantityController.text = '1';
      _itemNameController.clear();
    });
  }

  Future<void> _saveAndClose() async {
    if (_addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final List<Map<String, dynamic>> itemsForApi =
        _addedItems.map((item) => item.toJson()).toList();
    customerDetailsProvider.addMultiItems(itemsForApi);
    customerDetailsProvider.mutipleItemsTotalAmount = grandTotal;

    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    await customerDetailsProvider.fetchAndSetMaterialsForMultipleItems(
        itemsForApi, expenseProvider, context);

    if (mounted) Navigator.of(context).pop();
  }

  double get grandTotal {
    double total = 0;

    for (final item in _addedItems) {
      for (final mat in item.materials) {
        total += mat.amount;
      }
    }

    return total;
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
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                  const Text('Add Items',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Add new item row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: CustomAutocompleteSearch<ItemListModel>(
                      focusNode: itemNode,
                      showOptionsOnTap: true,
                      maxHeight: 300,
                      optionsViewOpenDirection: OptionsViewOpenDirection.down,
                      items: expenseProvider.itemList,
                      displayStringFunction: (staff) =>
                          "${staff.itemName}\n${staff.itemDescription}",
                      defaultText: _selectedItemName,
                      controller: _itemNameController,
                      labelText: 'Select Item',
                      suffixIcon: const Icon(Icons.search),
                      onSelected: (ItemListModel items) {
                        final selected = expenseProvider.itemList
                            .firstWhere((e) => e.itemId == items.itemId);
                        setState(() {
                          _selectedItemId = selected.itemId;
                          _selectedItemName = selected.itemName;
                          _itemNameController.text = selected.itemName;
                        });
                      },
                      onChanged: (value) {},
                      onSearch: (query) async {},
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
                            RegExp(r'^\d+\.?\d{0,2}')),
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

            // Items List Header
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Items',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              // Main Item Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withAlpha(50)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: _getMainNameController(
                                            itemIndex, item.itemName),
                                        textAlign: TextAlign.left,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onChanged: (val) =>
                                            _updateMainItemName(itemIndex, val),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _getMainMakeController(
                                            itemIndex, item.make),
                                        textAlign: TextAlign.left,
                                        decoration: InputDecoration(
                                          labelText: 'Make',
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onChanged: (val) =>
                                            _updateMainItemMake(itemIndex, val),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(
                                      width: 90,
                                      child: TextField(
                                        controller: _getMainQtyController(
                                            itemIndex, item.quantity),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          labelText: 'Qty',
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 8),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}')),
                                        ],
                                        onChanged: (val) =>
                                            _updateMainItemQuantity(
                                                itemIndex, val),
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

                              // Materials
                              if (item.materials.isNotEmpty)
                                Container(
                                  color: Colors.grey[100],
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(
                                        child: Text(
                                          'Materials',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15.5),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ...item.materials
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final matIndex = entry.key;
                                        final mat = entry.value;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
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
                                                  child: TextField(
                                                    controller:
                                                        _getMaterialNameController(
                                                      itemIndex,
                                                      matIndex,
                                                      mat.itemMaterialName,
                                                    ),
                                                    minLines: 1,
                                                    maxLines: null,
                                                    decoration: InputDecoration(
                                                      labelText: 'Material',
                                                      isDense: true,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 10,
                                                        vertical: 14,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    onChanged: (val) {
                                                      _updateMaterialName(
                                                        itemIndex,
                                                        matIndex,
                                                        val,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 80,
                                                  child: TextField(
                                                    controller:
                                                        _getMaterialQtyController(
                                                            itemIndex,
                                                            matIndex,
                                                            mat.quantity),
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
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
                                                                      .circular(
                                                                          8)),
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+\.?\d{0,2}')),
                                                    ],
                                                    onChanged: (val) =>
                                                        _updateMaterialQuantity(
                                                            itemIndex,
                                                            matIndex,
                                                            val),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 100,
                                                  child: TextField(
                                                    controller:
                                                        _getMaterialPriceController(
                                                            itemIndex,
                                                            matIndex,
                                                            mat.price),
                                                    keyboardType:
                                                        const TextInputType
                                                            .numberWithOptions(
                                                            decimal: true),
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
                                                                      .circular(
                                                                          8)),
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+\.?\d{0,2}')),
                                                    ],
                                                    onChanged: (val) =>
                                                        _updateMaterialPrice(
                                                            itemIndex,
                                                            matIndex,
                                                            val),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: "Show in Print",
                                                  child: SizedBox(
                                                    width: 40,
                                                    child: Checkbox(
                                                      value:
                                                          _getMaterialChecked(
                                                              itemIndex,
                                                              matIndex),
                                                      onChanged: (val) =>
                                                          _updateMaterialChecked(
                                                              itemIndex,
                                                              matIndex,
                                                              val),
                                                      activeColor:
                                                          AppColors.primaryBlue,
                                                    ),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message:
                                                      "Quantity as Required",
                                                  child: SizedBox(
                                                    width: 40,
                                                    child: Checkbox(
                                                      value:
                                                          _getMaterialShowQtyChecked(
                                                              itemIndex,
                                                              matIndex),
                                                      onChanged: (val) =>
                                                          _updateMaterialShowQtyChecked(
                                                              itemIndex,
                                                              matIndex,
                                                              val),
                                                      activeColor:
                                                          AppColors.primaryBlue,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 90,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      const Text('Amount',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  Colors.grey)),
                                                      Text(
                                                        mat.amount
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

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  Text(
                    'Total : ₹${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
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
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
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
