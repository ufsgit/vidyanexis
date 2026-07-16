class DocumentListModel {
  final String userName;
  final List<ImageDetail> imageDetails;

  DocumentListModel({
    required this.userName,
    required this.imageDetails,
  });

  factory DocumentListModel.fromJson(Map<String, dynamic> json) {
    return DocumentListModel(
      userName: json['User_Details_Name'] ?? '',
      imageDetails: (json['Image_Details'] as List<dynamic>?)
              ?.map((e) => ImageDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ImageDetail {
  final String filePath;
  final int imageId;
  final String entryDate;
  final String documentTypeId;
  final String documentTypeName;
  final String isVerified;
  final String verifiedName;
  final String verifiedDate;

  ImageDetail({
    required this.filePath,
    required this.imageId,
    required this.entryDate,
    required this.documentTypeId,
    required this.documentTypeName,
    required this.isVerified,
    required this.verifiedName,
    required this.verifiedDate,
  });

  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    return ImageDetail(
      filePath: json['File_Path'] ?? '',
      imageId: json['Images_Id'] ?? 0,
      entryDate: json['Entry_Date'] ?? '',
      documentTypeId: json['Document_Type_Id'] ?? '',
      documentTypeName: json['Document_Type_Name'] ?? '',
      isVerified: json['Is_Verified']?.toString() ?? '0',
      verifiedName: json['Verified_By_Name']?.toString() ?? '',
      verifiedDate: json['Verified_Date']?.toString() ?? '',
    );
  }
}
