class EnquirySourceReportModel {
  String? enquirySourceName;
  String? totalLeads;
  List<SummaryStatus>? summaryStatus;

  EnquirySourceReportModel({
    this.enquirySourceName,
    this.totalLeads,
    this.summaryStatus,
  });

  EnquirySourceReportModel copyWith({
    String? enquirySourceName,
    String? totalLeads,
    List<SummaryStatus>? summaryStatus,
  }) =>
      EnquirySourceReportModel(
        enquirySourceName: enquirySourceName ?? this.enquirySourceName,
        totalLeads: totalLeads ?? this.totalLeads,
        summaryStatus: summaryStatus ?? this.summaryStatus,
      );

  factory EnquirySourceReportModel.fromJson(Map<String, dynamic> json) =>
      EnquirySourceReportModel(
        enquirySourceName: json["Enquiry_Source_Name"],
        totalLeads: json["Total_Leads"],
        summaryStatus: json["summary_status"] == null
            ? []
            : List<SummaryStatus>.from(
                json["summary_status"]!.map((x) => SummaryStatus.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Enquiry_Source_Name": enquirySourceName,
        "Total_Leads": totalLeads,
        "summary_status": summaryStatus == null
            ? []
            : List<dynamic>.from(summaryStatus!.map((x) => x.toJson())),
      };
}

class SummaryStatus {
  int? count;
  int? statusId;
  String? statusName;

  SummaryStatus({
    this.count,
    this.statusId,
    this.statusName,
  });

  SummaryStatus copyWith({
    int? count,
    int? statusId,
    String? statusName,
  }) =>
      SummaryStatus(
        count: count ?? this.count,
        statusId: statusId ?? this.statusId,
        statusName: statusName ?? this.statusName,
      );

  factory SummaryStatus.fromJson(Map<String, dynamic> json) => SummaryStatus(
        count: json["count"],
        statusId: json["Status_Id"],
        statusName: json["Status_Name"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "Status_Id": statusId,
        "Status_Name": statusName,
      };
}
