class CheckListTypeModel {
  final int checklistTypeId;
  final String checklistTypeName;
  final int deleteStatus;

  CheckListTypeModel({
    required this.checklistTypeId,
    required this.checklistTypeName,
    required this.deleteStatus,
  });

  /// Factory method to create a TaskType object from JSON
  factory CheckListTypeModel.fromJson(Map<String, dynamic> json) {
    return CheckListTypeModel(
      checklistTypeId: json['Checklist_Id'] ?? 0,
      checklistTypeName: json['Checklist_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Checklist_Id': checklistTypeId,
      'Checklist_Name': checklistTypeName,
      'DeleteStatus': deleteStatus,
    };
  }
}
