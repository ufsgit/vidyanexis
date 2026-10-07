class DocumentTypeModel {
  final int documentTypeId;
  final String documentTypeName;
  final int deleteStatus;
  final bool isMandatory;
  final int documentCategoryId;
  final String documentCategoryName;

  DocumentTypeModel({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.deleteStatus,
    required this.isMandatory,
    this.documentCategoryId = 0,
    this.documentCategoryName = '',
  });

  /// Factory method to create a TaskType object from JSON
  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      documentTypeId: json['Document_Type_Id'] ?? 0,
      documentTypeName: json['Document_Type_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      isMandatory: (json['mandatory'] == 1) ? true : false,
      documentCategoryId: json['Document_Category_Id'] ?? 0,
      documentCategoryName: json['Document_Category_Name'] ?? '',
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Document_Type_Id': documentTypeId,
      'Document_Type_Name': documentTypeName,
      'mandatory': isMandatory ? 1 : 0,
      'Document_Category_Id': documentCategoryId,
    };
  }
}
