import 'package:flutter/material.dart';
import 'form_model.dart';

class FormProvider extends ChangeNotifier {
  List<FormModel> _forms = [];
  List<FormModel> get forms => _forms;

  String searchQuery = "";

  List<String> departments = ["Sales", "Support", "Operations"];

  List<String> taskTypes = ["Installation", "Follow Up", "Service"];

  List<FieldModel> availableFields = [
    FieldModel(id: '1', label: "Customer Name", type: FieldType.text),
    FieldModel(id: '2', label: "Amount", type: FieldType.number),
    FieldModel(id: '3', label: "Visit Date", type: FieldType.date),
    FieldModel(
      id: '4',
      label: "Status",
      type: FieldType.dropdown,
      options: ["Open", "Closed", "Pending"],
    ),
  ];

  void addForm(FormModel form) {
    _forms.add(form);
    notifyListeners();
  }

  void updateForm(String id, FormModel updatedForm) {
    final index = _forms.indexWhere((e) => e.id == id);
    if (index != -1) {
      _forms[index] = updatedForm;
      notifyListeners();
    }
  }

  void deleteForm(String id) {
    _forms.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  List<FormModel> get filteredForms {
    if (searchQuery.isEmpty) return _forms;
    return _forms
        .where((f) => f.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }
}
