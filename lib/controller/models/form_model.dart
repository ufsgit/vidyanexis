enum FieldType { text, dropdown, date, number, checkbox, file, signature }

class FieldModel {
  final String id;
  final String label;
  final FieldType type;
  bool isMandatory;
  int orderBy;
  String? value;
  final List<String>? options;
  final List<String>? checkBoxOptions;

  FieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.isMandatory = false,
    this.orderBy = 0,
    this.value,
    this.options,
    this.checkBoxOptions,
  });
}

class FormModel {
  final String id;
  final String name;
  final String department;
  final int? departmentId;
  final String taskType;
  final int? taskTypeId;
  final int? customerId;
  final List<FieldModel> fields;
  final int? instanceId;
  final String? createdUser;
  final String? createdDate;
  final int? taskId;
  final int deletedStatus;

  FormModel({
    required this.id,
    required this.name,
    required this.department,
    this.departmentId,
    required this.taskType,
    this.taskTypeId,
    this.customerId,
    required this.fields,
    this.instanceId,
    this.createdUser,
    this.createdDate,
    this.taskId,
    this.deletedStatus = 0,
  });
}
