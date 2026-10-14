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
  final String description;

  ImageDetail({
    required this.filePath,
    required this.imageId,
    required this.entryDate,
    required this.documentTypeId,
    required this.documentTypeName,
    required this.isVerified,
    required this.verifiedName,
    required this.verifiedDate,
    required this.description,
  });

  factory ImageDetail.fromJson(Map<String, dynamic> json) {
    return ImageDetail(
      filePath: json['File_Path']?.toString() ?? '',
      imageId: int.tryParse(json['Images_ID']?.toString() ??
              json['Images_Id']?.toString() ??
              '') ??
          0,
      entryDate: json['Entry_Date']?.toString() ?? '',
      documentTypeId: json['Document_Type_Id']?.toString() ?? '',
      documentTypeName: json['Document_Type_Name']?.toString() ?? '',
      isVerified: json['Is_Verified']?.toString() ?? '0',
      verifiedName: json['Verified_By_Name']?.toString() ?? '',
      verifiedDate: json['Verified_Date']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
    );
  }
}
