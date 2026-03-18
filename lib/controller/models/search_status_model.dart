// To parse this JSON data, do
//
//     final searchStatusModel = searchStatusModelFromJson(jsonString);

import 'dart:convert';

List<SearchStatusModel> searchStatusModelFromJson(String str) =>
    List<SearchStatusModel>.from(
        json.decode(str).map((x) => SearchStatusModel.fromJson(x)));

String searchStatusModelToJson(List<SearchStatusModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchStatusModel {
  int statusId;
  String statusName;
  int statusOrder;
  int followup;
  dynamic isRegistered;
  String colorCode;

  SearchStatusModel({
    required this.statusId,
    required this.statusName,
    required this.statusOrder,
    required this.followup,
    required this.isRegistered,
    required this.colorCode,
  });

  factory SearchStatusModel.fromJson(Map<String, dynamic> json) =>
      SearchStatusModel(
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
        statusOrder: json["Status_Order"],
        followup: json["Followup"],
        isRegistered: json["Is_Registered"] ?? json["registered"],
        colorCode: json["Color_Code"],
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "Followup": followup,
        "registered": isRegistered,
        "Color_Code": colorCode,
      };
}
