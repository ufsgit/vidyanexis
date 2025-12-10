// To parse this JSON data, do
//
//     final userLocationModel = userLocationModelFromJson(jsonString);

import 'dart:convert';

UserLocationModel userLocationModelFromJson(String str) => UserLocationModel.fromJson(json.decode(str));

String userLocationModelToJson(UserLocationModel data) => json.encode(data.toJson());

class UserLocationModel {
  int? userDetailsId;
  String? location;
  String? latitude;
  String? longitude;
  String? userDetailsName,locationDateTime;

  UserLocationModel({
    this.userDetailsId,
    this.location,
    this.latitude,
    this.longitude,
    this.userDetailsName,this.locationDateTime
  });

  UserLocationModel copyWith({
    int? userDetailsId,
    String? location,
    String? latitude,
    String? longitude,
    String? userDetailsName,
  }) =>
      UserLocationModel(
        userDetailsId: userDetailsId ?? this.userDetailsId,
        location: location ?? this.location,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        userDetailsName: userDetailsName ?? this.userDetailsName,
      );

  factory UserLocationModel.fromJson(Map<String, dynamic> json) => UserLocationModel(
    userDetailsId: json["User_Details_Id"],
    location: json["location"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    userDetailsName: json["User_Details_Name"],
    locationDateTime: json["location_Date_Time"],
  );

  Map<String, dynamic> toJson() => {
    "User_Details_Id": userDetailsId,
    "location": location,
    "latitude": latitude,
    "longitude": longitude,
    "User_Details_Name": userDetailsName,
    "location_Date_Time": locationDateTime,
  };
}
