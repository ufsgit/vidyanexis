import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';

class AddCommercialCustomFieldsDialog extends StatefulWidget {
  const AddCommercialCustomFieldsDialog({super.key});

  @override
  State<AddCommercialCustomFieldsDialog> createState() =>
      _AddCommercialCustomFieldsDialogState();
}

class _AddCommercialCustomFieldsDialogState
    extends State<AddCommercialCustomFieldsDialog> {
  int? _selectedFieldId;
  List<CustomFieldByStatusId> _addedFields = [];

  @override
  void initState() {
    super.initState();
    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    _addedFields = List.from(provider.selectedCommercialFields);
  }

  void _addField() {
    if (_selectedFieldId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a commercial field to add')),
      );
      return;
    }

    // Removed the check that prevents adding a field if it's already added.
    // The user can now add multiple instances of the same field.

    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    final selectedField = provider.commercialCustomFields
        .firstWhere((f) => f.customFieldId == _selectedFieldId);

    setState(() {
      _addedFields.add(selectedField);
      _selectedFieldId = null;
    });
  }

  void _removeField(int index) {
    setState(() {
      _addedFields.removeAt(index);
    });
  }

  void _saveAndClose() {
    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    List<CustomFieldByStatusId> finalSelected = [];
    int minVirtualId = -1000;
    
    // Find the minimum virtual ID used so far to avoid collisions
    provider.virtualToRealCommercialFieldId.keys.forEach((vId) {
      if (vId < minVirtualId) minVirtualId = vId;
    });
    int virtualIdCounter = minVirtualId - 1;

    for (var field in _addedFields) {
      if (field.customFieldId != null && field.customFieldId! < 0) {
         // It already has a virtual ID (was added previously). Keep it!
         finalSelected.add(field);
      } else {
         // It is a new field (real ID > 0). Assign a new virtual ID.
         final clonedField = CustomFieldByStatusId.fromJson(field.toJson());
         clonedField.isChecked = 1;
         
         final vId = virtualIdCounter--;
         provider.virtualToRealCommercialFieldId[vId] = field.customFieldId!;
         clonedField.customFieldId = vId;
         
         finalSelected.add(clonedField);
      }
    }
    
    provider.selectedCommercialFields = finalSelected;
    
    provider.notifyListeners();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CustomerDetailsProvider>(context);

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
                  const Icon(Icons.playlist_add,
                      color: AppColors.primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  const Text('Add Commercial',
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

            // Dropdown + Add button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: CommonDropdown(
                      hintText: "Select Commercial Field",
                      items: provider.commercialCustomFields
                          .map((e) => DropdownItem(
                              id: e.customFieldId, name: e.customFieldName ?? ''))
                          .toList(),
                      onItemSelected: (id) {
                        setState(() {
                          _selectedFieldId = id;
                        });
                      },
                      selectedValue: _selectedFieldId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _addField,
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Selected Fields',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  Text('${_addedFields.length} field(s)',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            // Items List
            Expanded(
              child: _addedFields.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.list_alt,
                              size: 60, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("No fields selected",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _addedFields.length,
                      itemBuilder: (context, index) {
                        final field = _addedFields[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(
                              field.customFieldName ?? 'Unknown Field',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _removeField(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
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
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
