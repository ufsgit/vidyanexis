import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class AddMultipleItemsDialog extends StatefulWidget {
  const AddMultipleItemsDialog({Key? key}) : super(key: key);

  @override
  State<AddMultipleItemsDialog> createState() => _AddMultipleItemsDialogState();
}

class _AddMultipleItemsDialogState extends State<AddMultipleItemsDialog> {
  int? _selectedItemId;
  String _selectedItemName = '';
  final TextEditingController _quantityController = TextEditingController(text: '1');
  
  // Local list to hold added items
  final List<Map<String, dynamic>> _addedItems = [];

  void _addItem() {
    if (_selectedItemId == null || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item and enter quantity')),
      );
      return;
    }

    double? qty = double.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    setState(() {
      _addedItems.add({
        'itemId': _selectedItemId,
        'itemName': _selectedItemName,
        'quantity': qty,
      });
      _selectedItemId = null;
      _selectedItemName = '';
      _quantityController.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _addedItems.removeAt(index);
    });
  }

  Future<void> _saveAndClose() async {
    if (_addedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    await customerDetailsProvider.fetchAndSetMaterialsForMultipleItems(
        _addedItems, expenseProvider, context);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Materials',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CommonDropdown(
                    hintText: "Select Item",
                    items: expenseProvider.itemList
                        .map((status) => DropdownItem<int>(
                              id: status.itemId,
                              name: status.itemName,
                            ))
                        .toList(),
                    onItemSelected: (selectedItem) {
                      final selectedData = expenseProvider.itemList
                          .firstWhere((item) => item.itemId == selectedItem);
                      setState(() {
                        _selectedItemId = selectedData.itemId;
                        _selectedItemName = selectedData.itemName;
                      });
                    },
                    selectedValue: _selectedItemId,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    controller: _quantityController,
                    hintText: "Qty",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _addedItems.isEmpty
                  ? const Center(child: Text("No items added yet."))
                  : ListView.builder(
                      itemCount: _addedItems.length,
                      itemBuilder: (context, index) {
                        final item = _addedItems[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(item['itemName']),
                            subtitle: Text("Quantity: ${item['quantity']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveAndClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
