// To parse this JSON data, do
//
//     final districtModel = districtModelFromJson(jsonString);

import 'dart:convert';

List<DistrictModel> districtModelFromJson(String str) =>
    List<DistrictModel>.from(
        json.decode(str).map((x) => DistrictModel.fromJson(x)));

String districtModelToJson(List<DistrictModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DistrictModel {
  int? districtId;
  String? districtName;

  DistrictModel({
    this.districtId,
    this.districtName,
  });

  DistrictModel copyWith({
    int? districtId,
    String? districtName,
  }) =>
      DistrictModel(
        districtId: districtId ?? this.districtId,
        districtName: districtName ?? this.districtName,
      );

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
        districtId: json["District_Id"],
        districtName: json["District_Name"],
      );

  Map<String, dynamic> toJson() => {
        "District_Id": districtId,
        "District_Name": districtName,
      };
}
