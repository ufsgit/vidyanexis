class CaptionModel {
  final int captionId;
  final String caption;
  final int displayOrder;

  CaptionModel({
    required this.captionId,
    required this.caption,
    required this.displayOrder,
  });

  factory CaptionModel.fromJson(Map<String, dynamic> json) {
    return CaptionModel(
      captionId: json['Caption_Id'] ?? 0,
      caption: json['Caption'] ?? '',
      displayOrder: json['Display_Order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Caption_Id': captionId,
      'Caption': caption,
      'Display_Order': displayOrder,
    };
  }
}
