
enum FieldType { textbox, dropdown, datepicker }

class FormFieldModel {
  String name;
  FieldType type;
  List<String>? dropdownValues;

  FormFieldModel({
    required this.name,
    required this.type,
    this.dropdownValues,
  });
}

class FormModel {
  final String name;
  final List<FormFieldModel> fields;
  FormModel({required this.name, required this.fields});
}
