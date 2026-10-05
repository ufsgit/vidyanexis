class DocumentCategoryModel {
  final int documentCategoryId;
  final String documentCategoryName;

  DocumentCategoryModel({
    required this.documentCategoryId,
    required this.documentCategoryName,
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    return DocumentCategoryModel(
      documentCategoryId: json['Document_Category_Id'] ?? 0,
      documentCategoryName: json['Document_Category_Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Document_Category_Id': documentCategoryId,
      'Document_Category_Name': documentCategoryName,
    };
  }
}
