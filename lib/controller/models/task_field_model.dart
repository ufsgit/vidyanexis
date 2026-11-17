class TaskField {
  int? taskFieldsId;
  String? taskFieldsName;
  int? isVisibility;
  int? sort;

  TaskField({
    this.taskFieldsId,
    this.taskFieldsName,
    this.isVisibility,
    this.sort,
  });

  factory TaskField.fromJson(Map<String, dynamic> json) => TaskField(
        taskFieldsId: json["task_fields_id"] ?? json["taskFieldsId"],
        taskFieldsName: json["task_fields_name"] ?? json["taskFieldsName"],
        isVisibility: json["is_visibility"] ?? json["isVisibility"],
        sort: json["sort"],
      );

  Map<String, dynamic> toJson() => {
        "task_fields_id": taskFieldsId,
        "task_fields_name": taskFieldsName,
        "is_visibility": isVisibility,
        "sort": sort,
      };
}
