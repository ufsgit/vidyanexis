class ItemDocumentModel {
  final int itemDocumentId;
  final int itemId;
  final int documentTypeId;
  final String filePath;
  final int deleteStatus;
  final String? documentTypeName; // optional, for UI

  ItemDocumentModel({
    required this.itemDocumentId,
    required this.itemId,
    required this.documentTypeId,
    required this.filePath,
    this.deleteStatus = 0,
    this.documentTypeName,
  });

  factory ItemDocumentModel.fromJson(Map<String, dynamic> json) {
    return ItemDocumentModel(
      itemDocumentId: json['Item_Document_Id'] ?? 0,
      itemId: json['Item_Id'] ?? 0,
      documentTypeId: json['Document_Type_Id'] ?? 0,
      filePath: json['File_Path'] ?? '',
      deleteStatus: json['DeleteStatus'] ?? 0,
      documentTypeName: json['Document_Type_Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item_Document_Id': itemDocumentId,
      'Document_Type_Id': documentTypeId,
      'File_Path': filePath,
      'DeleteStatus': deleteStatus,
    };
  }
}