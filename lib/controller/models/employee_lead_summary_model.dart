class EmployeeLeadSummaryModel {
  bool? success;
  SummaryData? summary;
  List<EmployeeReportData>? employeeReport;

  EmployeeLeadSummaryModel({
    this.success,
    this.summary,
    this.employeeReport,
  });

  factory EmployeeLeadSummaryModel.fromJson(Map<String, dynamic> json) => EmployeeLeadSummaryModel(
    success: json["Success"],
    summary: json["Summary"] == null ? null : SummaryData.fromJson(json["Summary"]),
    employeeReport: json["Employee_Report"] == null
        ? []
        : List<EmployeeReportData>.from(json["Employee_Report"]!.map((x) => EmployeeReportData.fromJson(x))),
  );
}

class SummaryData {
  int? totalLeads;
  String? pendingFollowup;
  String? todaysFollowup;
  String? upcomingFollowup;

  SummaryData({
    this.totalLeads,
    this.pendingFollowup,
    this.todaysFollowup,
    this.upcomingFollowup,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) => SummaryData(
    totalLeads: json["Total_Leads"],
    pendingFollowup: json["Pending_Followup"]?.toString(),
    todaysFollowup: json["Todays_Followup"]?.toString(),
    upcomingFollowup: json["Upcoming_Followup"]?.toString(),
  );
}

class EmployeeReportData {
  int? userDetailsId;
  String? userDetailsName;
  int? leadAssigned;
  String? pendingFollowup;
  String? todaysFollowup;
  String? upcomingFollowup;

  EmployeeReportData({
    this.userDetailsId,
    this.userDetailsName,
    this.leadAssigned,
    this.pendingFollowup,
    this.todaysFollowup,
    this.upcomingFollowup,
  });

  factory EmployeeReportData.fromJson(Map<String, dynamic> json) => EmployeeReportData(
    userDetailsId: json["User_Details_Id"],
    userDetailsName: json["User_Details_Name"],
    leadAssigned: json["Lead_Assigned"],
    pendingFollowup: json["Pending_Followup"]?.toString(),
    todaysFollowup: json["Todays_Followup"]?.toString(),
    upcomingFollowup: json["Upcoming_Followup"]?.toString(),
  );
}
