// To parse this JSON data, do
//
//     final subUserModel = subUserModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

SubUserModel subUserModelFromJson(String str) =>
    SubUserModel.fromJson(json.decode(str));

String subUserModelToJson(SubUserModel data) => json.encode(data.toJson());

class SubUserModel {
  List<SubUsersDatum> subUsersData;

  SubUserModel({
    required this.subUsersData,
  });

  factory SubUserModel.fromJson(Map<String, dynamic> json) => SubUserModel(
        subUsersData: List<SubUsersDatum>.from(
            json["SubUsersData"].map((x) => SubUsersDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "SubUsersData": List<dynamic>.from(subUsersData.map((x) => x.toJson())),
      };
}

class SubUsersDatum {
  int userSelectionId;
  String userSelectionName;

  SubUsersDatum({
    required this.userSelectionId,
    required this.userSelectionName,
  });

  factory SubUsersDatum.fromJson(Map<String, dynamic> json) => SubUsersDatum(
        userSelectionId: json["User_Selection_Id"],
        userSelectionName: json["User_Selection_Name"],
      );

  Map<String, dynamic> toJson() => {
        "User_Selection_Id": userSelectionId,
        "User_Selection_Name": userSelectionName,
      };
}
