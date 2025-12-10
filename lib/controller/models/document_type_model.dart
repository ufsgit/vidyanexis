class DocumentTypeModel {
  final int documentTypeId;
  final String documentTypeName;
  final int deleteStatus;

  DocumentTypeModel({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.deleteStatus,
  });

  /// Factory method to create a TaskType object from JSON
  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      documentTypeId: json['Document_Type_Id'] ?? 0,
      documentTypeName: json['Document_Type_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Document_Type_Id': documentTypeId,
      'Document_Type_Name': documentTypeName,
      // 'DeleteStatus': deleteStatus,
    };
  }
}
