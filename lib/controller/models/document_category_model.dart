class DocumentItem {
  final int documentTypeId;
  final String documentTypeName;
  final String filePath;

  DocumentItem({
    required this.documentTypeId,
    required this.documentTypeName,
    required this.filePath,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      documentTypeId: json['Document_Type_Id'] ?? 0,
      documentTypeName: json['Document_Type_Name']?.toString() ?? '',
      filePath: json['File_Path']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Document_Type_Id': documentTypeId,
      'Document_Type_Name': documentTypeName,
      'File_Path': filePath,
    };
  }

  bool get isPdf => filePath.toLowerCase().endsWith('.pdf');
  bool get isImage {
    final lower = filePath.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.bmp');
  }
}

class DocumentCategoryModel {
  final int documentCategoryId;
  final String documentCategoryName;
  final List<DocumentItem> documents;

  DocumentCategoryModel({
    required this.documentCategoryId,
    required this.documentCategoryName,
    this.documents = const [],
  });

  factory DocumentCategoryModel.fromJson(Map<String, dynamic> json) {
    final docsJson = json['Documents'] as List? ?? [];
    return DocumentCategoryModel(
      documentCategoryId: json['Document_Category_Id'] ?? 0,
      documentCategoryName: json['Document_Category_Name'] ?? '',
      documents: docsJson
          .map((e) => DocumentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Document_Category_Id': documentCategoryId,
      'Document_Category_Name': documentCategoryName,
      'Documents': documents.map((e) => e.toJson()).toList(),
    };
  }
}
