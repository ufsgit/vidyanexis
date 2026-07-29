import 'dart:convert';

List<LandmarkModel> landmarkModelFromJson(String str) =>
    List<LandmarkModel>.from(
        json.decode(str).map((x) => LandmarkModel.fromJson(x)));

String landmarkModelToJson(List<LandmarkModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LandmarkModel {
  int? landmarkId;
  String? landmarkName;

  LandmarkModel({
    this.landmarkId,
    this.landmarkName,
  });

  LandmarkModel copyWith({
    int? landmarkId,
    String? landmarkName,
  }) =>
      LandmarkModel(
        landmarkId: landmarkId ?? this.landmarkId,
        landmarkName: landmarkName ?? this.landmarkName,
      );

  factory LandmarkModel.fromJson(Map<String, dynamic> json) => LandmarkModel(
        landmarkId: json["Landmark_Id"] ?? json["landmark_id"] ?? json["Id"],
        landmarkName: json["Name"] ?? json["Landmark_Name"] ?? json["landmark_name"],
      );

  Map<String, dynamic> toJson() => {
        "Landmark_Id": landmarkId,
        "Landmark_Name": landmarkName,
      };
}
