// To parse this JSON data, do
//
//     final leadCoversionChartModel = leadCoversionChartModelFromJson(jsonString);

import 'dart:convert';

List<List<LeadCoversionChartModel>> leadCoversionChartModelFromJson(
        String str) =>
    List<List<LeadCoversionChartModel>>.from(json.decode(str).map((x) =>
        List<LeadCoversionChartModel>.from(
            x.map((x) => LeadCoversionChartModel.fromJson(x)))));

String leadCoversionChartModelToJson(
        List<List<LeadCoversionChartModel>> data) =>
    json.encode(List<dynamic>.from(
        data.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))));

class LeadCoversionChartModel {
  String? enquirySource;
  int? enquirySourceId;
  int? leadCount;
  String? convertedCount;
  int? totalLeadCount;
  String? totalConvertedCount;

  LeadCoversionChartModel({
    this.enquirySource,
    this.enquirySourceId,
    this.leadCount,
    this.convertedCount,
    this.totalLeadCount,
    this.totalConvertedCount,
  });

  factory LeadCoversionChartModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return LeadCoversionChartModel(
      enquirySource: json["Enquiry_Source"],
      enquirySourceId: parseId(json["Enquiry_Source_Id"]) ??
          parseId(json["enquirySourceId"]),
      leadCount: parseId(json["leadCount"]) ?? parseId(json["LeadCount"]),
      convertedCount: json["convertedCount"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "Enquiry_Source": enquirySource,
        "Enquiry_Source_Id": enquirySourceId,
        "leadCount": leadCount,
        "convertedCount": convertedCount,
      };
}

class CountLeadCoversionChartModel {
  int? totalLeadCount;
  String? totalConvertedCount;

  CountLeadCoversionChartModel({this.totalLeadCount, this.totalConvertedCount});

  CountLeadCoversionChartModel.fromJson(Map<String, dynamic> json) {
    totalLeadCount = json['totalLeadCount'];
    totalConvertedCount = json['totalConvertedCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalLeadCount'] = totalLeadCount;
    data['totalConvertedCount'] = totalConvertedCount;
    return data;
  }
}
