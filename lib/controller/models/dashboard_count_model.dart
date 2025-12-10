// To parse this JSON data, do
//
//     final dashBoardCountModel = dashBoardCountModelFromJson(jsonString);

import 'dart:convert';

List<DashBoardCountModel> dashBoardCountModelFromJson(String str) => List<DashBoardCountModel>.from(json.decode(str).map((x) => DashBoardCountModel.fromJson(x)));

String dashBoardCountModelToJson(List<DashBoardCountModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DashBoardCountModel {
    int tp;
    String title;
    int dataCount;

    DashBoardCountModel({
        required this.tp,
        required this.title,
        required this.dataCount,
    });

    factory DashBoardCountModel.fromJson(Map<String, dynamic> json) => DashBoardCountModel(
        tp: json["tp"],
        title: json["title"],
        dataCount: json["Data_Count"],
    );

    Map<String, dynamic> toJson() => {
        "tp": tp,
        "title": title,
        "Data_Count": dataCount,
    };
}
