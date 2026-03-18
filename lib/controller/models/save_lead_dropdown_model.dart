// To parse this JSON data, do
//
//     final saveLeadDropdownModel = saveLeadDropdownModelFromJson(jsonString);

import 'dart:convert';

SaveLeadDropdownModel saveLeadDropdownModelFromJson(String str) =>
    SaveLeadDropdownModel.fromJson(json.decode(str));

String saveLeadDropdownModelToJson(SaveLeadDropdownModel data) =>
    json.encode(data.toJson());

class SaveLeadDropdownModel {
  List<PanelType> panelType;
  List<RoofType> roofType;
  List<SubsidyType> subsidyType;
  List<CostInclude> costIncludes;
  List<AmountPaidThrough> amountPaidThrough;
  List<Phase> phase;
  List<WorkType> workType;
  List<InverterType> inverterType;

  SaveLeadDropdownModel({
    required this.panelType,
    required this.roofType,
    required this.subsidyType,
    required this.costIncludes,
    required this.amountPaidThrough,
    required this.phase,
    required this.workType,
    required this.inverterType,
  });

  factory SaveLeadDropdownModel.fromJson(Map<String, dynamic> json) =>
      SaveLeadDropdownModel(
        panelType: List<PanelType>.from(
            json["panel_type"].map((x) => PanelType.fromJson(x))),
        roofType: List<RoofType>.from(
            json["roof_type"].map((x) => RoofType.fromJson(x))),
        subsidyType: List<SubsidyType>.from(
            json["subsidy_type"].map((x) => SubsidyType.fromJson(x))),
        costIncludes: List<CostInclude>.from(
            json["cost_includes"].map((x) => CostInclude.fromJson(x))),
        amountPaidThrough: List<AmountPaidThrough>.from(
            json["amount_paid_through"]
                .map((x) => AmountPaidThrough.fromJson(x))),
        phase: List<Phase>.from(json["phase"].map((x) => Phase.fromJson(x))),
        workType: List<WorkType>.from(
            json["work_type"].map((x) => WorkType.fromJson(x))),
        inverterType: List<InverterType>.from(
            json["inverter_type"].map((x) => InverterType.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "panel_type": List<dynamic>.from(panelType.map((x) => x.toJson())),
        "roof_type": List<dynamic>.from(roofType.map((x) => x.toJson())),
        "subsidy_type": List<dynamic>.from(subsidyType.map((x) => x.toJson())),
        "cost_includes":
            List<dynamic>.from(costIncludes.map((x) => x.toJson())),
        "amount_paid_through":
            List<dynamic>.from(amountPaidThrough.map((x) => x.toJson())),
        "phase": List<dynamic>.from(phase.map((x) => x.toJson())),
        "work_type": List<dynamic>.from(workType.map((x) => x.toJson())),
        "inverter_type":
            List<dynamic>.from(inverterType.map((x) => x.toJson())),
      };
}

class AmountPaidThrough {
  int amountPaidThroughId;
  String amountPaidThroughName;
  int deleteStatus;

  AmountPaidThrough({
    required this.amountPaidThroughId,
    required this.amountPaidThroughName,
    required this.deleteStatus,
  });

  factory AmountPaidThrough.fromJson(Map<String, dynamic> json) =>
      AmountPaidThrough(
        amountPaidThroughId: json["amount_paid_through_id"],
        amountPaidThroughName: json["amount_paid_through_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "amount_paid_through_id": amountPaidThroughId,
        "amount_paid_through_name": amountPaidThroughName,
        "delete_status": deleteStatus,
      };
}

class CostInclude {
  int costIncludesId;
  String costIncludesName;
  int deleteStatus;

  CostInclude({
    required this.costIncludesId,
    required this.costIncludesName,
    required this.deleteStatus,
  });

  factory CostInclude.fromJson(Map<String, dynamic> json) => CostInclude(
        costIncludesId: json["cost_includes_id"],
        costIncludesName: json["cost_includes_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "cost_includes_id": costIncludesId,
        "cost_includes_name": costIncludesName,
        "delete_status": deleteStatus,
      };
}

class PanelType {
  int panelTypeId;
  String panelTypeName;
  int deleteStatus;

  PanelType({
    required this.panelTypeId,
    required this.panelTypeName,
    required this.deleteStatus,
  });

  factory PanelType.fromJson(Map<String, dynamic> json) => PanelType(
        panelTypeId: json["panel_type_id"],
        panelTypeName: json["panel_type_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "panel_type_id": panelTypeId,
        "panel_type_name": panelTypeName,
        "delete_status": deleteStatus,
      };
}

class Phase {
  int phaseId;
  String phaseName;
  int deleteStatus;

  Phase({
    required this.phaseId,
    required this.phaseName,
    required this.deleteStatus,
  });

  factory Phase.fromJson(Map<String, dynamic> json) => Phase(
        phaseId: json["phase_id"],
        phaseName: json["phase_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "phase_id": phaseId,
        "phase_name": phaseName,
        "delete_status": deleteStatus,
      };
}

class RoofType {
  int roofTypeId;
  String roofTypeName;
  int deleteStatus;

  RoofType({
    required this.roofTypeId,
    required this.roofTypeName,
    required this.deleteStatus,
  });

  factory RoofType.fromJson(Map<String, dynamic> json) => RoofType(
        roofTypeId: json["roof_type_id"],
        roofTypeName: json["roof_type_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "roof_type_id": roofTypeId,
        "roof_type_name": roofTypeName,
        "delete_status": deleteStatus,
      };
}

class SubsidyType {
  int subsidyTypeId;
  String subsidyTypeName;
  int deleteStatus;

  SubsidyType({
    required this.subsidyTypeId,
    required this.subsidyTypeName,
    required this.deleteStatus,
  });

  factory SubsidyType.fromJson(Map<String, dynamic> json) => SubsidyType(
        subsidyTypeId: json["subsidy_type_id"],
        subsidyTypeName: json["subsidy_type_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "subsidy_type_id": subsidyTypeId,
        "subsidy_type_name": subsidyTypeName,
        "delete_status": deleteStatus,
      };
}

class WorkType {
  int workTypeId;
  String workTypeName;
  int deleteStatus;

  WorkType({
    required this.workTypeId,
    required this.workTypeName,
    required this.deleteStatus,
  });

  factory WorkType.fromJson(Map<String, dynamic> json) => WorkType(
        workTypeId: json["work_type_id"],
        workTypeName: json["work_type_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "work_type_id": workTypeId,
        "work_type_name": workTypeName,
        "delete_status": deleteStatus,
      };
}

class InverterType {
  int inverterTypeId;
  String inverterTypeName;
  int deleteStatus;

  InverterType({
    required this.inverterTypeId,
    required this.inverterTypeName,
    required this.deleteStatus,
  });

  factory InverterType.fromJson(Map<String, dynamic> json) => InverterType(
        inverterTypeId: json["inverter_type_id"],
        inverterTypeName: json["inverter_type_name"],
        deleteStatus: json["delete_status"],
      );

  Map<String, dynamic> toJson() => {
        "inverter_type_id": inverterTypeId,
        "inverter_type_name": inverterTypeName,
        "delete_status": deleteStatus,
      };
}
