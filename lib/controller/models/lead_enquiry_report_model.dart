class LeadEnquiryReportModel {
  int enquiryForId;
  String enquiryForName;
  String colorCode;
  int count;
  String percentage;

  LeadEnquiryReportModel({
    required this.enquiryForId,
    required this.enquiryForName,
    required this.colorCode,
    required this.count,
    required this.percentage,
  });

  factory LeadEnquiryReportModel.fromJson(Map<String, dynamic> json) {
    return LeadEnquiryReportModel(
      enquiryForId: int.tryParse(json["Enquiry_For_Id"]?.toString() ?? "0") ?? 0,
      enquiryForName: json["Enquiry_For_Name"]?.toString() ?? "",
      // Convert int color code to string for the UI components
      colorCode: json["Color_Code"]?.toString() ?? "",
      count: int.tryParse(json["Count"]?.toString() ?? "0") ?? 0,
      percentage: json["Percentage"]?.toString() ?? "0",
    );
  }
}
