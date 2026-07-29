import 'dart:convert';

List<StateModel> stateModelFromJson(String str) =>
    List<StateModel>.from(
        json.decode(str).map((x) => StateModel.fromJson(x)));

String stateModelToJson(List<StateModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StateModel {
  int? stateId;
  String? stateName;

  StateModel({
    this.stateId,
    this.stateName,
  });

  StateModel copyWith({
    int? stateId,
    String? stateName,
  }) =>
      StateModel(
        stateId: stateId ?? this.stateId,
        stateName: stateName ?? this.stateName,
      );

  factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        stateId: json["State_Id"] ?? json["state_id"] ?? json["Id"],
        stateName: json["Name"] ?? json["State_Name"] ?? json["state_name"],
      );

  Map<String, dynamic> toJson() => {
        "State_Id": stateId,
        "State_Name": stateName,
      };
}
