class WorkCompletionReportModel {
  final Map<String, dynamic> rawData;

  WorkCompletionReportModel({required this.rawData});

  factory WorkCompletionReportModel.fromJson(Map<String, dynamic> json) {
    return WorkCompletionReportModel(rawData: json);
  }

  Map<String, dynamic> toJson() {
    return rawData;
  }
}
