class ProjectModel {
  final int? projectId;
  final String? projectName;

  ProjectModel({
    this.projectId,
    this.projectName,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_ID'] ?? 0,
      projectName: json['project_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_ID': projectId,
      'project_Name': projectName,
    };
  }

  @override
  String toString() => 'Project(id: $projectId, name: $projectName)';
}
