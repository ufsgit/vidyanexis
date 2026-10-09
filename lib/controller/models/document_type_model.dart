class DocumentTypeModel {
  final int documentTypeId;
  final String documentTypeName;
  final int deleteStatus;
  bool isMandatory;
  bool isView;
  final int documentCategoryId;
  final String documentCategoryName;

  DocumentTypeModel({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.deleteStatus,
    required this.isMandatory,
    this.isView = false,
    this.documentCategoryId = 0,
    this.documentCategoryName = '',
  });

  DocumentTypeModel copyWith({
    int? documentTypeId,
    String? documentTypeName,
    int? deleteStatus,
    bool? isMandatory,
    bool? isView,
    int? documentCategoryId,
    String? documentCategoryName,
  }) {
    return DocumentTypeModel(
      documentTypeId: documentTypeId ?? this.documentTypeId,
      documentTypeName: documentTypeName ?? this.documentTypeName,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      isMandatory: isMandatory ?? this.isMandatory,
      isView: isView ?? this.isView,
      documentCategoryId: documentCategoryId ?? this.documentCategoryId,
      documentCategoryName: documentCategoryName ?? this.documentCategoryName,
    );
  }

  /// Factory method to create a TaskType object from JSON
  factory DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    return DocumentTypeModel(
      documentTypeId: json['Document_Type_Id'] ?? 0,
      documentTypeName: json['Document_Type_Name'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      isMandatory: (json['is_mandatory'] == 1 || json['is_mandatory'] == "1" || json['is_mandatory'] == true || json['mandatory'] == 1 || json['mandatory'] == "1" || json['mandatory'] == true) ? true : false,
      isView: (json['is_view'] == 1 || json['is_view'] == "1" || json['is_view'] == true) ? true : false,
      documentCategoryId: json['Document_Category_Id'] ?? 0,
      documentCategoryName: json['Document_Category_Name'] ?? '',
    );
  }

  /// Method to convert TaskType object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Document_Type_Id': documentTypeId,
      'Document_Type_Name': documentTypeName,
      'is_mandatory': isMandatory ? 1 : 0,
      'is_view': isView ? 1 : 0,
      'Document_Category_Id': documentCategoryId,
    };
  }
}
