// To parse this JSON data, do
//
//     final searchStatusModel = searchStatusModelFromJson(jsonString);

import 'package:meta/meta.dart';
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
  int isRegistered;
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
        isRegistered: json["Is_Registered"],
        colorCode: json["Color_Code"],
      );

  Map<String, dynamic> toJson() => {
        "Status_Id": statusId,
        "Status_Name": statusName,
        "Status_Order": statusOrder,
        "Followup": followup,
        "Is_Registered": isRegistered,
        "Color_Code": colorCode,
      };
}
