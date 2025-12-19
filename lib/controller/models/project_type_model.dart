class ProjectTypeModel {
  final int? projectTypeId;
  final String? projectTypeName;

  ProjectTypeModel({
    this.projectTypeId,
    this.projectTypeName,
  });

  factory ProjectTypeModel.fromJson(Map<String, dynamic> json) {
    return ProjectTypeModel(
      projectTypeId: json['Project_Type_Id'] ?? 0,
      projectTypeName: json['Project_Type_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Project_Type_Id': projectTypeId,
      'Project_Type_Name': projectTypeName,
    };
  }
}
