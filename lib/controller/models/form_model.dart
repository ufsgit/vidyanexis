enum FieldType { text, dropdown, date, number }

class FieldModel {
  final String id;
  final String label;
  final FieldType type;
  bool isMandatory;
  final List<String>? options;

  FieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.isMandatory = false,
    this.options,
  });
}

class FormModel {
  final String id;
  final String name;
  final String department;
  final String taskType;
  final List<FieldModel> fields;

  FormModel({
    required this.id,
    required this.name,
    required this.department,
    required this.taskType,
    required this.fields,
  });
}
