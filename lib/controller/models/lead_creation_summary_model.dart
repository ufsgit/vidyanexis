class LeadCreationSummaryModel {
  final String employeeName;
  final int employeeId;
  final int leadCount;

  LeadCreationSummaryModel({
    required this.employeeName,
    required this.employeeId,
    required this.leadCount,
  });

  factory LeadCreationSummaryModel.fromJson(Map<String, dynamic> json) {
    return LeadCreationSummaryModel(
      employeeName: json['Employee_Name']?.toString() ?? '',
      employeeId: int.tryParse(json['Employee_Id']?.toString() ?? '0') ?? 0,
      leadCount: int.tryParse(json['Lead_Count']?.toString() ?? '0') ?? 0,
    );
  }
}
