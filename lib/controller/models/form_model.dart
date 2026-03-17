enum FieldType { text, dropdown, date, number }

class FieldModel {
  final String id;
  final String label;
  final FieldType type;
  bool isMandatory;
  String? value;
  final List<String>? options;

  FieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.isMandatory = false,
    this.value,
    this.options,
  });
}

class FormModel {
  final String id;
  final String name;
  final String department;
  final int? departmentId;
  final String taskType;
  final int? taskTypeId;
  final List<FieldModel> fields;
  final int? instanceId;

  FormModel({
    required this.id,
    required this.name,
    required this.department,
    this.departmentId,
    required this.taskType,
    this.taskTypeId,
    required this.fields,
    this.instanceId,
  });
}
