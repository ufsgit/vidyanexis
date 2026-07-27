import 'dart:convert';

List<PriorityModel> priorityModelFromJson(String str) =>
    List<PriorityModel>.from(
        json.decode(str).map((x) => PriorityModel.fromJson(x)));

String priorityModelToJson(List<PriorityModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PriorityModel {
  int priorityId;
  String priorityName;
  String colorCode;

  PriorityModel({
    required this.priorityId,
    required this.priorityName,
    required this.colorCode,
  });

  factory PriorityModel.fromJson(Map<String, dynamic> json) => PriorityModel(
        priorityId: json["Priority_Id"] ?? 0,
        priorityName: json["Priority_Name"] ?? "",
        colorCode: json["Color_Code"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Priority_Id": priorityId,
        "Priority_Name": priorityName,
        "Color_Code": colorCode,
      };
}
