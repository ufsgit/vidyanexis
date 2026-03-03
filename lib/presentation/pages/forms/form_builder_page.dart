import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import '../../../controller/form_builder_provider.dart';
import '../../widgets/home/custom_button_widget.dart';
import '../../widgets/home/custom_text_field.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/home/custom_dropdown_widget.dart';

class FormBuilderPage extends StatefulWidget {
  const FormBuilderPage({super.key});

  @override
  State<FormBuilderPage> createState() => _FormBuilderPageState();
}

class _FormBuilderPageState extends State<FormBuilderPage> {
  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildFormNameField(FormBuilderProvider provider) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: provider.formNameController,
            hintText: 'Form Name',
            labelText: 'Form Name',
            height: 48,
            onChanged: provider.setFormName,
          ),
        ),
      ],
    );
  }

  Widget _buildAddFieldSection(FormBuilderProvider provider) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: provider.fieldNameController,
            hintText: 'Field Name',
            labelText: 'Field Name',
            height: 48,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CommonDropdown<FieldType>(
            hintText: 'Field Type',
            items: FieldType.values
                .map((type) => DropdownItem<FieldType>(
                      id: type,
                      name: type.name[0].toUpperCase() + type.name.substring(1),
                    ))
                .toList(),
            selectedValue: provider.selectedType,
            onItemSelected: provider.setSelectedType,
          ),
        ),
        const SizedBox(width: 16),
        CustomElevatedButton(
          buttonText: provider.editingIndex == null ? 'Add' : 'Update',
          prefixIcon: Icons.add,
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
          radius: 16,
          onPressed: provider.addOrEditField,
        ),
      ],
    );
  }

  Widget _buildDropdownValueSection(FormBuilderProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: provider.dropdownValueController,
                hintText: 'Dropdown Value',
                labelText: 'Dropdown Value',
                height: 48,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (provider.dropdownValueController.text.isNotEmpty) {
                  provider
                      .addDropdownValue(provider.dropdownValueController.text);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.dropdownValues
              .map((val) => Chip(
                    label: Text(val),
                    onDeleted: () => provider.removeDropdownValue(val),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFieldTable(FormBuilderProvider provider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: DataTable(
          headingRowColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              return AppColors.bluebutton.withOpacity(0.1);
            },
          ),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 56,
          columnSpacing: 24,
          columns: const [
            DataColumn(
                label: Text('Field',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Delete',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Edit',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: List.generate(
              provider.fields.length,
              (i) => DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.hovered)) {
                          return AppColors.bluebutton.withOpacity(0.08);
                        }
                        return null;
                      },
                    ),
                    cells: [
                      DataCell(Text(provider.fields[i].label)),
                      DataCell(Text(
                          provider.fields[i].type.name[0].toUpperCase() +
                              provider.fields[i].type.name.substring(1))),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete_forever_rounded,
                            color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () => provider.deleteFieldAt(i),
                      )),
                      DataCell(IconButton(
                        icon: const Icon(Icons.edit_note_rounded,
                            color: Colors.blueAccent),
                        tooltip: 'Edit',
                        onPressed: () => provider.startEditingField(i),
                      )),
                    ],
                  )),
        ),
      ),
    );
  }

  Widget _buildSaveButton(FormBuilderProvider provider) {
    return CustomElevatedButton(
      buttonText: 'Save',
      prefixIcon: Icons.save,
      backgroundColor: AppColors.bluebutton,
      borderColor: AppColors.bluebutton,
      textColor: AppColors.whiteColor,
      radius: 16,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form Saved!')),
        );
        provider.clearAll();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FormBuilderProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Forms')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormNameField(provider),
              const SizedBox(height: 24),
              _buildAddFieldSection(provider),
              if (provider.selectedType == FieldType.dropdown)
                _buildDropdownValueSection(provider),
              const SizedBox(height: 24),
              if (provider.fields.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Field List',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                _buildFieldTable(provider),
              ],
              const SizedBox(height: 32),
              Center(child: _buildSaveButton(provider)),
            ],
          ),
        ),
      ),
    );
  }
}
