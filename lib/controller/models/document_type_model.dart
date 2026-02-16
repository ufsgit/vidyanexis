class DocumentTypeModel {
  final int documentTypeId;
  final String documentTypeName;
  final int deleteStatus;
  final bool isMandatory;

  DocumentTypeModel({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.deleteStatus,
    required this.isMandatory,
  });

  /// Factory method to create a TaskType object from JSON
  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      documentTypeId: json['Document_Type_Id'] ?? 0,
      documentTypeName: json['Document_Type_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      isMandatory: (json['mandatory'] == 1) ? true : false,
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Document_Type_Id': documentTypeId,
      'Document_Type_Name': documentTypeName,
      'mandatory': isMandatory ? 1 : 0,
    };
  }
}
