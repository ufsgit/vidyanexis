class LeadStageReportModel {
  int? stageId;
  String? stageName;
  int? leadCount;

  LeadStageReportModel({this.stageId, this.stageName, this.leadCount});

  LeadStageReportModel.fromJson(Map<String, dynamic> json) {
    stageId = _parseInt(json['Stage_Id'] ?? json['Id'] ?? json['id'] ?? json['stageId'] ?? json['StageId']);
    stageName = json['Stage_Name'] ?? json['stageName'];
    leadCount = _parseInt(json['Lead_Count'] ?? json['leadCount']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Stage_Id'] = stageId;
    data['Stage_Name'] = stageName;
    data['Lead_Count'] = leadCount;
    return data;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}
