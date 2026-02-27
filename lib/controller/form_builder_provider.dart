import 'package:flutter/material.dart';
import 'models/form_model.dart';

class FormBuilderProvider extends ChangeNotifier {
  // Controllers for form fields
  final TextEditingController formNameController = TextEditingController();
  final TextEditingController fieldNameController = TextEditingController();
  final TextEditingController dropdownValueController = TextEditingController();

  FieldType? selectedType;
  int? editingIndex;

  String formName = '';
  List<FieldModel> fields = [];
  List<String> dropdownValues = [];
  List<FormModel> savedForms = [];

  void setFormName(String name) {
    formName = name;
    notifyListeners();
  }

  void addOrEditField() {
    if (fieldNameController.text.isEmpty || selectedType == null) return;
    final field = FieldModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: fieldNameController.text,
      type: selectedType!,
      options:
          selectedType == FieldType.dropdown ? List.from(dropdownValues) : null,
    );
    if (editingIndex != null) {
      fields[editingIndex!] = field;
      editingIndex = null;
    } else {
      fields.add(field);
    }
    fieldNameController.clear();
    selectedType = null;
    dropdownValues.clear();
    notifyListeners();
  }

  void startEditingField(int index) {
    final field = fields[index];
    fieldNameController.text = field.label;
    selectedType = field.type;
    dropdownValues.clear();
    if (field.options != null) {
      dropdownValues.addAll(field.options!);
    }
    editingIndex = index;
    notifyListeners();
  }

  void deleteFieldAt(int index) {
    if (index >= 0 && index < fields.length) {
      fields.removeAt(index);
      notifyListeners();
    }
  }

  void saveForm() {
    if (formName.isNotEmpty && fields.isNotEmpty) {
      savedForms.add(FormModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: formName,
          department: '',
          taskType: '',
          fields: List<FieldModel>.from(fields)));
      notifyListeners();
    }
  }

  void clearAll() {
    formName = '';
    fields.clear();
    dropdownValues.clear();
    formNameController.clear();
    fieldNameController.clear();
    dropdownValueController.clear();
    selectedType = null;
    editingIndex = null;
    notifyListeners();
  }

  void addDropdownValue(String value) {
    dropdownValues.add(value);
    dropdownValueController.clear();
    notifyListeners();
  }

  void removeDropdownValue(String value) {
    dropdownValues.remove(value);
    notifyListeners();
  }

  void setSelectedType(FieldType? type) {
    selectedType = type;
    dropdownValues.clear();
    notifyListeners();
  }
}
